#!/bin/bash
# ╔════════════════════════════════════════════════════════════════════╗
# ║                          ⚡ ZNC TELEPÍTŐ ⚡                        ║
# ║                              Debian 13			       ║
# ║────────────────────────────────────────────────────────────────────║
# ║  Ez a script automatikusan telepíti és konfigurálja a ZNC IRC      ║
# ║  Bouncert, létrehozza a rendszerfelhasználót, és beállítja mint    ║
# ║  systemd szolgáltatás. Gyors, stabil és teljesen automatizált.     ║
# ║                                                                    ║
# ║  Készítette: Doky ✦ 2025.11.30				       ║
# ╚════════════════════════════════════════════════════════════════════╝

set -e

# ──────────────────────────────────────────────────────────────────────────
# 🔒 Root jogosultság ellenőrzése
# ──────────────────────────────────────────────────────────────────────────
if [ "$EUID" -ne 0 ]; then
  echo "❌ Kérlek root felhasználóként futtasd ezt a scriptet!"
  exit 1
fi

# ──────────────────────────────────────────────────────────────────────────
# 🔧 Rendszer frissítése
# ──────────────────────────────────────────────────────────────────────────
echo "🔧 Rendszer frissítése..."
apt update -y && apt upgrade -y

# ──────────────────────────────────────────────────────────────────────────
# 📦 Alap csomagok telepítése (ZNC + ZNC-dev + curl)
# ──────────────────────────────────────────────────────────────────────────
echo "📦 Szükséges csomagok telepítése..."
apt install -y znc znc-dev curl

# ──────────────────────────────────────────────────────────────────────────
# 👤 'znc' felhasználó létrehozása (ha még nem létezik)
# ──────────────────────────────────────────────────────────────────────────
if ! id "znc" &>/dev/null; then
  echo "👤 'znc' felhasználó létrehozása..."
  useradd -m -s /bin/bash znc
fi

# ──────────────────────────────────────────────────────────────────────────
# 🧩 Interaktív ZNC konfiguráció indítása
# ──────────────────────────────────────────────────────────────────────────
echo ""
echo "=== 🧩 ZNC interaktív konfiguráció ==="
echo "👉 A következő lépésben elindul a ZNC beállító varázsló."
echo "   Itt manuálisan add meg a portot, usert, iRC szervert, jelszót stb."
echo ""
read -p "Nyomj Enter-t a folytatáshoz..."

sudo -u znc znc --makeconf

# ──────────────────────────────────────────────────────────────────────────
# 🛠 Systemd szolgáltatás létrehozása
# ──────────────────────────────────────────────────────────────────────────
echo "🧠 Systemd szolgáltatás létrehozása..."

cat >/etc/systemd/system/znc.service <<'EOL'
[Unit]
Description=ZNC IRC Bouncer
After=network.target

[Service]
Type=simple
User=znc
ExecStart=/usr/bin/znc -f
ExecReload=/bin/kill -HUP $MAINPID
Restart=always

[Install]
WantedBy=multi-user.target
EOL

systemctl daemon-reload
systemctl enable znc
systemctl start znc

# ──────────────────────────────────────────────────────────────────────────
# 🌐 Publikus IP cím lekérdezése
# ──────────────────────────────────────────────────────────────────────────
PUBLIC_IP=$(curl -s https://api.ipify.org)

# ──────────────────────────────────────────────────────────────────────────
# 🎉 ÖSSZEGZÉS
# ──────────────────────────────────────────────────────────────────────────
echo ""
echo "╔════════════════════════════════════════╗"
echo "║         🎉 ZNC TELEPÍTÉS KÉSZ! 🎉      ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "🌐 Publikus IP cím: $PUBLIC_IP"
echo "💻 Webadmin: http://$PUBLIC_IP:<port>"
echo "📁 Konfig fájl: /home/znc/.znc/configs/znc.conf"
echo ""
echo "🛠 Hasznos parancsok:"
echo "   • systemctl status znc"
echo "   • systemctl restart znc"
echo "   • systemctl stop znc"
echo ""
echo "🎧 Kellemes IRC-zést kíván: Doky"
echo "🌍 Weboldal: https://www.zsolti.hu"
echo ""
