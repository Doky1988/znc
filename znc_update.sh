#!/bin/bash
# ╔══════════════════════════════════════════════════════════════════════════╗
# ║                                                                          ║
# ║             ⚡ ZNC VERZIÓELLENŐ + AUTO-FRISSÍTŐ SCRIPT ⚡                ║
# ║                          Debian 13 rendszerhez                           ║
# ║                                                                          ║
# ║ A script automatikusan ellenőrzi a telepített és repóban elérhető        ║
# ║ ZNC verziót.Ha újabb érhető el, frissíti és újraindítja a szolgáltatást. ║
# ║                                                                          ║
# ║                        Készítette: Doky · 2025                           ║
# ║                                                                          ║
# ╚══════════════════════════════════════════════════════════════════════════╝

set -e

# ──────────────────────────────────────────────────────────────────────────
# 🔒 Root jogosultság ellenőrzése
# ──────────────────────────────────────────────────────────────────────────
if [ "$EUID" -ne 0 ]; then
  echo "❌ Kérlek root felhasználóként futtasd ezt a scriptet (sudo ./znc_auto_update.sh)"
  exit 1
fi

# ──────────────────────────────────────────────────────────────────────────
# 🔍 Telepített verzió lekérése (HEAD FIX)
# ──────────────────────────────────────────────────────────────────────────
INSTALLED=$(znc --version 2>/dev/null | head -n 1 | awk '{print $2}')

if [ -z "$INSTALLED" ]; then
    echo "❌ A ZNC nincs telepítve erre a rendszerre."
    exit 1
fi

# ──────────────────────────────────────────────────────────────────────────
# 🔍 Debian repóban elérhető (candidate) verzió lekérése
# ──────────────────────────────────────────────────────────────────────────
CANDIDATE=$(apt-cache policy znc | grep Candidate | awk '{print $2}')

if [ "$CANDIDATE" = "(none)" ] || [ -z "$CANDIDATE" ]; then
    echo "❌ A Debian repóban nem található ZNC csomag."
    exit 1
fi

# ──────────────────────────────────────────────────────────────────────────
# 📊 Verziók megjelenítése
# ──────────────────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║                    🔍 ZNC VERZIÓK                ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
echo "📦 Telepített verzió:      $INSTALLED"
echo "📦 Elérhető repó verzió:   $CANDIDATE"
echo ""

# ──────────────────────────────────────────────────────────────────────────
# 🔎 Verziók összehasonlítása + automatikus frissítés
# ──────────────────────────────────────────────────────────────────────────
if dpkg --compare-versions "$CANDIDATE" "gt" "$INSTALLED"; then
    echo "⬆️ Újabb ZNC verzió érhető el!"
    echo "👉 Frissítés indítása..."
    echo ""

    apt update -y
    apt install --only-upgrade -y znc znc-dev

    echo "🔄 ZNC újraindítása..."
    systemctl restart znc

    # Frissítés utáni verzió lekérése (HEAD FIX)
    NEW_VERSION=$(znc --version | head -n 1 | awk '{print $2}')

    echo ""
    echo "╔══════════════════════════════════════════════════╗"
    echo "║             🎉 ZNC FRISSÍTÉS KÉSZ! 🎉            ║"
    echo "╚══════════════════════════════════════════════════╝"
    echo ""
    echo "📦 Új telepített verzió:   $NEW_VERSION"
    echo ""
else
    echo "✅ A ZNC naprakész."
    echo "   Nincs frissebb verzió a Debian repóban."
fi

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║      Scriptet készítette: Doky · zsolti.hu       ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
