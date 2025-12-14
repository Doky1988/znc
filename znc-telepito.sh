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
    echo "❌ Rootként futtasd."
    exit 1
fi

# ==============================
# Verziók
# ==============================
get_installed_znc_version() {
    [[ -x "$INSTALL_PREFIX/bin/znc" ]] && \
    "$INSTALL_PREFIX/bin/znc" --version | grep -oP '[0-9]+\.[0-9]+\.[0-9]+'
}

get_latest_znc_version() {
    curl -fsSL https://znc.in/releases/ \
        | grep -oP 'znc-\K[0-9]+\.[0-9]+\.[0-9]+' \
        | sort -V | tail -n1
}

znc_config_exists() {
    [[ -f "$ZNC_DATADIR/configs/znc.conf" ]]
}

# ==============================
# Függőségek
# ==============================
install_deps() {
    apt update
    apt install -y \
        build-essential cmake pkg-config \
        libssl-dev libperl-dev python3 \
        libicu-dev ca-certificates curl
}

# ==============================
# ZNC user
# ==============================
create_user() {
    id "$ZNC_USER" &>/dev/null || \
    useradd -r -m -d "$ZNC_HOME" -s /bin/bash "$ZNC_USER"
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
# WebAdmin port (valós)
# ==============================
get_webadmin_port() {
    ss -lntp 2>/dev/null \
        | grep znc \
        | grep -Eo ':[0-9]{2,5}' \
        | tr -d ':' \
        | head -n1
}

# ==============================
# Telepítés / Frissítés
# ==============================
install_znc() {
    LATEST=$(get_latest_znc_version)
    INSTALLED=$(get_installed_znc_version)

    echo "📦 Telepített verzió : ${INSTALLED:-nincs}"
    echo "🌐 Legfrissebb verzió : $LATEST"
    echo

    if [[ -n "$INSTALLED" && "$INSTALLED" == "$LATEST" ]]; then
        echo "✅ A ZNC már naprakész. Nincs teendő."
        return
    fi

    install_deps
    create_user

    mkdir -p "$SRC_DIR"
    cd "$SRC_DIR"
    rm -rf "znc-$LATEST"*
    curl -LO "https://znc.in/releases/znc-$LATEST.tar.gz"
    tar xzf "znc-$LATEST.tar.gz"
    cd "znc-$LATEST"

    cmake .
    make -j"$(nproc)"
    make install

    chown -R "$ZNC_USER:$ZNC_USER" "$ZNC_HOME"

    if ! znc_config_exists; then
        echo
        echo "==================================="
        echo " ZNC konfiguráció (makeconf)"
        echo "==================================="
        echo "A végén válaszolj: NO"
        echo
        sudo -u "$ZNC_USER" "$INSTALL_PREFIX/bin/znc" --makeconf
    else
        echo "ℹ️ Meglévő konfiguráció – makeconf kihagyva."
    fi

    usermod -s /usr/sbin/nologin "$ZNC_USER"
    create_service

    systemctl restart znc || systemctl start znc
}

# ==============================
# ŐSZINTE ÁLLAPOTELLENŐRZÉS
# ==============================
status_znc() {
    echo "==================================="
    echo " 📊 ZNC ÁLLAPOTELLENŐRZÉS"
    echo "==================================="

    echo
    echo "⚙️ Szolgáltatás:"
    systemctl is-active --quiet znc \
        && echo "   ✅ znc.service fut" \
        || echo "   ❌ znc.service NEM fut"

    echo
    echo "📦 Verzió:"
    echo "   $(get_installed_znc_version || echo nincs telepítve)"

    echo
    echo "🌐 WebAdmin:"
    PORT=$(get_webadmin_port)
    if [[ -n "$PORT" ]]; then
        IP=$(hostname -I | awk '{print $1}')
        echo "   http://$IP:$PORT"
    else
        echo "   ❌ nem hallgat portra"
    fi

    echo
    echo "📁 Konfiguráció:"
    znc_config_exists \
        && echo "   $ZNC_DATADIR" \
        || echo "   ❌ nincs konfiguráció"

    echo
    echo "🌍 IRC kapcsolat:"
    echo "   ℹ️ CLI-ből nem határozható meg megbízhatóan"
    echo "   ➜ WebAdmin: Traffic Info"
    echo "   ➜ vagy IRC kliensből ellenőrizd"

    echo "==================================="
}

# ==============================
# Eltávolítás
# ==============================
remove_znc() {
    systemctl stop znc 2>/dev/null || true
    systemctl disable znc 2>/dev/null || true
    systemctl reset-failed

    pkill -u "$ZNC_USER" znc 2>/dev/null || true
    rm -f "$SERVICE_FILE"
    systemctl daemon-reload

    rm -f "$INSTALL_PREFIX/bin/znc"
    rm -rf "$ZNC_HOME" "$SRC_DIR"/znc-*
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
echo "3) Állapot ellenőrzés"
echo "4) Eltávolítás"
echo "0) Kilépés"
echo "-----------------------------------"
read -rp "Választás: " CHOICE

case "$CHOICE" in
    1) install_znc ;;
    2) install_znc ;;
    3) status_znc ;;
    4) remove_znc ;;
    0) exit 0 ;;
    *) echo "❌ Érvénytelen választás." ;;
esac
