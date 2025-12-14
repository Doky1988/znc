#!/bin/bash
set -e

# ==============================
# Alap változók
# ==============================
ZNC_USER="znc"
ZNC_HOME="/var/lib/znc"
ZNC_DATADIR="/var/lib/znc/.znc"
INSTALL_PREFIX="/usr/local"
SRC_DIR="/usr/local/src"
SERVICE_FILE="/etc/systemd/system/znc.service"

# ==============================
# Root ellenőrzés
# ==============================
if [[ $EUID -ne 0 ]]; then
    echo "❌ Ezt a scriptet rootként kell futtatni."
    exit 1
fi

# ==============================
# Telepített ZNC verzió
# ==============================
get_installed_znc_version() {
    if [[ -x "$INSTALL_PREFIX/bin/znc" ]]; then
        "$INSTALL_PREFIX/bin/znc" --version \
            | grep -oP '[0-9]+\.[0-9]+\.[0-9]+'
    fi
}

# ==============================
# Legfrissebb stabil ZNC verzió
# ==============================
get_latest_znc_version() {
    curl -fsSL https://znc.in/releases/ \
        | grep -oP 'znc-\K[0-9]+\.[0-9]+\.[0-9]+' \
        | sort -V \
        | tail -n1
}

# ==============================
# Van-e már konfiguráció?
# ==============================
znc_config_exists() {
    [[ -f "$ZNC_DATADIR/configs/znc.conf" ]]
}

# ==============================
# Függőségek
# ==============================
install_deps() {
    apt update
    apt install -y \
        build-essential \
        cmake \
        pkg-config \
        libssl-dev \
        libperl-dev \
        python3 \
        libicu-dev \
        ca-certificates \
        curl
}

# ==============================
# ZNC user
# ==============================
create_user() {
    if ! id "$ZNC_USER" &>/dev/null; then
        useradd -r -m -d "$ZNC_HOME" -s /bin/bash "$ZNC_USER"
    fi
}

# ==============================
# systemd service
# ==============================
create_service() {
cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=ZNC IRC Bouncer
After=network.target

[Service]
Type=simple
User=$ZNC_USER
ExecStart=$INSTALL_PREFIX/bin/znc -f
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable znc
}

# ==============================
# Webadmin port (futó ZNC-ből)
# ==============================
get_webadmin_port() {
    ss -lntp 2>/dev/null \
        | grep znc \
        | grep -Eo ':[0-9]{2,5}' \
        | tr -d ':' \
        | head -n1
}

# ==============================
# Telepítés / Frissítés mag
# ==============================
install_znc() {
    LATEST_VERSION=$(get_latest_znc_version)
    INSTALLED_VERSION=$(get_installed_znc_version)

    echo "📦 Telepített verzió : ${INSTALLED_VERSION:-nincs}"
    echo "🌐 Legfrissebb verzió : $LATEST_VERSION"
    echo

    if [[ -n "$INSTALLED_VERSION" && "$INSTALLED_VERSION" == "$LATEST_VERSION" ]]; then
        echo "✅ A ZNC már a legfrissebb verzió ($INSTALLED_VERSION)."
        echo "ℹ️ Frissítés nem szükséges."
        return
    fi

    echo "➡️ ZNC frissítése / telepítése indul ($LATEST_VERSION)"
    echo

    install_deps
    create_user

    mkdir -p "$SRC_DIR"
    cd "$SRC_DIR"

    rm -rf "znc-$LATEST_VERSION"*
    curl -LO "https://znc.in/releases/znc-$LATEST_VERSION.tar.gz"
    tar xzf "znc-$LATEST_VERSION.tar.gz"
    cd "znc-$LATEST_VERSION"

    cmake .
    make -j"$(nproc)"
    make install

    chown -R "$ZNC_USER:$ZNC_USER" "$ZNC_HOME"

    if znc_config_exists; then
        echo "ℹ️ Meglévő ZNC konfiguráció észlelve – makeconf kihagyva."
    else
        echo
        echo "==================================="
        echo " ZNC konfiguráció (makeconf)"
        echo "==================================="
        echo
        echo "⚠️ FONTOS!"
        echo "Launch ZNC now? (yes/no) → NO"
        echo

        sudo -u "$ZNC_USER" "$INSTALL_PREFIX/bin/znc" --makeconf
    fi

    usermod -s /usr/sbin/nologin "$ZNC_USER"

    create_service

    echo
    echo "➡️ ZNC indítása systemd-vel..."
    systemctl restart znc || systemctl start znc

    sleep 1

    SERVER_IP=$(hostname -I | awk '{print $1}')
    WEB_PORT=$(get_webadmin_port)

    echo
    echo "==================================="
    echo " ✅ ZNC kész ($LATEST_VERSION)"
    echo "==================================="
    echo
    echo "🌐 Webadmin:"
    echo "   https://$SERVER_IP:${WEB_PORT:-PORT}"
    echo
    echo "📁 Konfig:"
    echo "   $ZNC_DATADIR"
    echo
    echo "==================================="
}

# ==============================
# Menü műveletek
# ==============================
update_znc() {
    install_znc
}

remove_znc() {
    echo "⚠️ ZNC eltávolítása"

    systemctl stop znc 2>/dev/null || true
    systemctl disable znc 2>/dev/null || true
    systemctl reset-failed

    pkill -u "$ZNC_USER" znc 2>/dev/null || true

    rm -f "$SERVICE_FILE"
    systemctl daemon-reload

    rm -f "$INSTALL_PREFIX/bin/znc"
    rm -rf "$ZNC_HOME"
    rm -rf "$SRC_DIR"/znc-*

    userdel -r "$ZNC_USER" 2>/dev/null || true

    echo "✅ ZNC eltávolítva."
}

# ==============================
# Menü
# ==============================
clear
echo "==================================="
echo "   ZNC Telepítő – Debian 13"
echo "==================================="
echo "1) Telepítés"
echo "2) Frissítés"
echo "3) Eltávolítás"
echo "0) Kilépés"
echo "-----------------------------------"
read -rp "Választás: " CHOICE

case "$CHOICE" in
    1) install_znc ;;
    2) update_znc ;;
    3) remove_znc ;;
    0) exit 0 ;;
    *) echo "❌ Érvénytelen választás." ;;
esac
