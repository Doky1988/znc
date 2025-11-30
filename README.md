# ⚡ ZNC – Telepítő, Frissítő és Eltávolító Scriptek  
**Debian 13 | Systemd | Teljesen automatizált üzemeltetés**  

<p align="center">
  <img src="https://img.shields.io/badge/Debian-13-red?style=for-the-badge&logo=debian" />
  <img src="https://img.shields.io/badge/ZNC-Automated-blue?style=for-the-badge&logo=linux" />
  <img src="https://img.shields.io/badge/Shell_Script-Bash-1f425f?style=for-the-badge&logo=gnu-bash" />
  <img src="https://img.shields.io/badge/Systemd-Service-green?style=for-the-badge&logo=systemd" />
  <img src="https://img.shields.io/badge/Maintained-Yes-brightgreen?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Created_by-Doky-blueviolet?style=for-the-badge" />
</p>

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

1) Telepítőfájl létrehozása:
   ```bash
   nano znc_install.sh

2) Másold bele az itt található **znc_install.sh** script tartalmát, majd mentsd el.

3) Futási jog adása:
   ```bash
   chmod +x znc_install.sh

4) Telepítés futtatása:
   ```bash
   ./znc_install.sh

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

1) Telepítőfájl létrehozása:
   ```bash
   nano znc_update.sh

2) Másold bele az itt található **znc_update.sh** script tartalmát, majd mentsd el.

3) Futási jog adása:
   ```bash
   chmod +x znc_update.sh

4) Telepítés futtatása:
   ```bash
   ./znc_update.sh

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

1) Telepítőfájl létrehozása:
   ```bash
   nano znc_uninstall.sh

2) Másold bele az itt található **znc_uninstall.sh** script tartalmát, majd mentsd el.

3) Futási jog adása:
   ```bash
   chmod +x znc_uninstall.sh

4) Telepítés futtatása:
   ```bash
   ./znc_uninstall.sh

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
