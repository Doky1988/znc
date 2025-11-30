#!/bin/bash
# ╔══════════════════════════════════════════════════════════════════════════╗
# ║                                                                          ║
# ║                       ⚡ ZNC UNINSTALL SCRIPT ⚡                         ║
# ║                          Debian 13 rendszerhez                           ║
# ║                                                                          ║
# ║      A script teljesen eltávolítja a ZNC csomagokat, törli a hozzá       ║
# ║      tartozó systemd szolgáltatást, a 'znc' felhasználót és annak        ║
# ║      teljes konfigurációs könyvtárát.                                    ║
# ║                                                                          ║
# ║                         Készítette: Doky · 2025                          ║
# ║                                                                          ║
# ╚══════════════════════════════════════════════════════════════════════════╝

set -e

# ──────────────────────────────────────────────────────────────────────────
# 🔒 Root ellenőrzése
# ──────────────────────────────────────────────────────────────────────────
if [ "$EUID" -ne 0 ]; then
  echo "❌ Kérlek rootként futtasd!"
  exit 1
fi

# ──────────────────────────────────────────────────────────────────────────
# 🛑 Szolgáltatás leállítása
# ──────────────────────────────────────────────────────────────────────────
if systemctl is-active --quiet znc; then
    echo "🛑 ZNC leállítása..."
    systemctl stop znc
fi

# Ha a service létezik → disable
if systemctl list-unit-files | grep -q "znc.service"; then
    echo "🚫 ZNC szolgáltatás kikapcsolása..."
    systemctl disable znc || true
fi

# ──────────────────────────────────────────────────────────────────────────
# 🗑 Systemd service törlése
# ──────────────────────────────────────────────────────────────────────────
if [ -f /etc/systemd/system/znc.service ]; then
    echo "🗑 Systemd service törlése..."
    rm -f /etc/systemd/system/znc.service
    systemctl daemon-reload
fi

# ──────────────────────────────────────────────────────────────────────────
# 📦 ZNC csomag eltávolítása
# ──────────────────────────────────────────────────────────────────────────
echo "📦 ZNC csomagok eltávolítása..."
apt purge -y znc znc-dev
apt autoremove -y

# ──────────────────────────────────────────────────────────────────────────
# 👤 'znc' felhasználó és home könyvtár törlése
# ──────────────────────────────────────────────────────────────────────────
if id "znc" &>/dev/null; then
    echo "👤 'znc' felhasználó törlése a home könyvtárral együtt..."
    userdel -r znc || true
fi

# ──────────────────────────────────────────────────────────────────────────
# 🧹 Maradék könyvtárak törlése (ha léteznek)
# ──────────────────────────────────────────────────────────────────────────
if [ -d /home/znc ]; then
    echo "🧹 /home/znc mappa eltávolítása..."
    rm -rf /home/znc
fi

# Biztonsági takarítás ruha
rm -rf /var/lib/znc 2>/dev/null || true

# ──────────────────────────────────────────────────────────────────────────
# 🎉 ÖSSZEGZÉS
# ──────────────────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║          🎉 ZNC TELJESEN ELTÁVOLÍTVA 🎉          ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
echo "🧹 Minden ZNC-hez kapcsolódó csomag, service, felhasználó"
echo "   és konfigurációs adat törlésre került."
echo ""
echo "✨ A rendszer megtisztítva, készen áll az új telepítésre,"
echo "   vagy egy másik IRC bouncer beállítására."
echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║      Scriptet készítette: Doky · zsolti.hu       ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
