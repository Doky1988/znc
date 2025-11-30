# ⚡ ZNC – Telepítő, Frissítő és Eltávolító Scriptek  
**Debian 13 | Systemd | Teljesen automatizált üzemeltetés**  
*Készítette: Doky · 2025*

Ez a repository három professzionális, biztonságos és teljesen automatizált scriptet tartalmaz a ZNC IRC Bouncer kezelésére Debian 13 rendszeren.  
A scriptek célja: stabil működés, egyszerű üzemeltetés, tiszta környezet.

---

## 📦 Tartalom

- **znc_install.sh** – Komplett ZNC telepítő  
- **znc_update.sh** – Automatikus verzióellenőrző + frissítő script  
- **znc_uninstall.sh** – Teljes eltávolító (clean uninstall)

---

# 🚀 ZNC Telepítő – znc_install.sh

### Funkciók
- Debian rendszer teljes frissítése  
- ZNC + ZNC-dev telepítése  
- `znc` felhasználó létrehozása (ha nem létezik)  
- Interaktív ZNC konfigurátor indítása (`znc --makeconf`)  
- Systemd szolgáltatás létrehozása és aktiválása  
- Publikus IP cím megjelenítése  
- Kész állapotjelentés telepítés végén  

### Használat
wget https://yourrepo/znc_install.sh  
chmod +x znc_install.sh  
sudo ./znc_install.sh

### Service parancsok
systemctl status znc  
systemctl restart znc  
systemctl stop znc  

### Konfiguráció
/home/znc/.znc/configs/znc.conf

---

# 🔄 ZNC Frissítő – znc_update.sh

### Mit csinál?
- Lekéri a telepített ZNC verziót  
- Lekéri a Debian repóban elérhető candidate verziót  
- Összehasonlítja őket  
- Ha elérhető frissebb → automatikusan frissít  
- Systemd újraindítás  
- Kiírja a régi és az új verziót

### Használat
wget https://yourrepo/znc_update.sh  
chmod +x znc_update.sh  
sudo ./znc_update.sh

### Frissítendő csomagok
- znc  
- znc-dev  

---

# 🗑️ ZNC Eltávolító – znc_uninstall.sh

### Mit távolít el?
- Leállítja a ZNC szolgáltatást  
- Törli a systemd service fájlt  
- Eltávolítja a ZNC csomagokat  
- Törli a `znc` felhasználót és teljes home könyvtárát  
- Letakarít minden maradék könyvtárat (pl. /home/znc, /var/lib/znc)  

### Használat
wget https://yourrepo/znc_uninstall.sh  
chmod +x znc_uninstall.sh  
sudo ./znc_uninstall.sh

### Figyelmeztetés
A script **teljes** eltávolítást végez.  
Minden ZNC-hez tartozó fájl törlésre kerül.

---

# 📁 Könyvtárstruktúra

.  
├── znc_install.sh  
├── znc_update.sh  
└── znc_uninstall.sh  

---

# 🔧 Követelmények
- Debian 13 (Trixie)  
- Root vagy sudo hozzáférés  
- Internetkapcsolat  
- Systemd rendszer  

---

# 💡 Hasznos tippek

### Konfiguráció újragenerálása  
sudo -u znc znc --makeconf

### Logok megtekintése  
journalctl -xeu znc.service

### Webadmin elérése  
http://IP:PORT

---

# 🧩 Kapcsolódó információk

- A telepítő script teljesen automatizált, csak a konfigurátor rész manuális.  
- A frissítő script kizárólag Debian repóból frissít.  
- Az eltávolító script tiszta környezetet hagy maga után új telepítéshez.

---

# 👨‍💻 Készítette  
**Doky**  
2025
