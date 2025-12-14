# ZNC Telepítő – Debian 13

![Debian](https://img.shields.io/badge/Debian-13-red)
![ZNC](https://img.shields.io/badge/ZNC-Stable-blue)
![Systemd](https://img.shields.io/badge/systemd-supported-green)
![Shell](https://img.shields.io/badge/Shell-Bash-yellow)
![License](https://img.shields.io/badge/License-MIT-lightgrey)
![Status](https://img.shields.io/badge/Status-Production%20Ready-brightgreen)
![Author](https://img.shields.io/badge/Author-Doky-blueviolet)

Stabil, forrásból fordító **ZNC telepítő / frissítő / eltávolító script** Debian 13 (Trixie) rendszerhez.  
A script **üzemeltetői szemlélettel készült**: nem találgat, nem ír felül konfigurációt, és csak azt állítja, amit biztosan tud.

---

## 🎯 Fő jellemzők

- Debian 13 kompatibilis  
- Legfrissebb stabil ZNC release (automatikus ellenőrzés)  
- Forrásból fordít (nem disztrócsomag)  
- Menüvezérelt működés  
- systemd-integráció (stabil foreground mód)  
- Dedikált `znc` rendszerfelhasználó  
- Helyes adatkönyvtár: `/var/lib/znc/.znc`  
- Biztonságos frissítés (nem futtat makeconf-ot újra)  
- Őszinte állapotellenőrzés (nem ad fals státuszt)  

---

## 📋 Menüfunkciók

### 1️⃣ Telepítés
- Telepíti a szükséges függőségeket  
- Letölti a legfrissebb stabil ZNC verziót  
- Lefordítja és telepíti  
- Létrehozza a `znc` usert  
- Első telepítéskor lefuttatja a `znc --makeconf`-ot  
- Létrehozza és elindítja a systemd szolgáltatást  

### 2️⃣ Frissítés
- Ellenőrzi az aktuális és a legfrissebb ZNC verziót  
- Csak akkor frissít, ha valóban van új verzió  
- Nem futtatja újra a makeconf-ot  
- Nem nyúl a meglévő konfigurációhoz  

### 3️⃣ Állapot ellenőrzés
Megmutatja:
- fut-e a znc.service  
- telepített ZNC verzió  
- WebAdmin elérési URL (valós port alapján)  
- konfigurációs könyvtár helye  
- IRC kapcsolat ellenőrzésének helyes módját  

Megjegyzés:  
Az IRC kapcsolat állapota nem kérdezhető le megbízhatóan CLI-ből.  
A script ezt korrekt módon jelzi, és a helyes ellenőrzési útvonalat adja meg:

**WebAdmin → Traffic Info**

### 4️⃣ Eltávolítás
- Leállítja és kikapcsolja a ZNC szolgáltatást  
- Törli a binárist, forrásfájlokat, konfigurációt  
- Eltávolítja a `znc` felhasználót  
- Tiszta, maradványmentes eltávolítás  

---

## 🖥️ Használat

1. Hozd létre az **znc-telepito.sh** fájlt terminálon:
   ```bash
   nano znc-telepito.sh
2. Másold bele az itt található **znc-telepito.sh** script tartalmát, majd mentsd el.
3. Adj neki futási jogot:
   ```bash
   chmod +x znc-telepito.sh
4. Futtasd a scriptet:
   ```bash
   ./znc-telepito.sh

---

## 📁 Fontos elérési utak

ZNC bináris:  
/usr/local/bin/znc  

Konfiguráció:  
/var/lib/znc/.znc  

systemd service:  
/etc/systemd/system/znc.service  

---

## 🔐 Biztonsági megjegyzések

- A ZNC nem rootként fut  
- A znc user shellje le van tiltva (nologin)  
- systemd automatikus újraindítás be van állítva  
- Nincs timeout-probléma induláskor  

---

## 🧠 Tervezési elvek

- Nincs log-heurisztika alapú találgatás  
- Nincs konfiguráció-felülírás frissítéskor  
- Determinisztikus működés  
- Őszinte állapotkommunikáció  
- Üzemeltetőbarát kimenet  

---

## 🏁 Összegzés

Ez a script egy **production-ready ZNC telepítő és kezelő eszköz**, amely:

- stabil  
- karbantartható  
- frissítésbiztos  
- nem ad félrevezető információt  

Ajánlott mind egyéni VPS-ekhez, mind hosszú távú ZNC üzemeltetéshez.

---

## 📜 Licenc

MIT License  
Szabadon használható, módosítható, terjeszthető.

---

## 🤝 Közreműködés

Pull requestek, hibajelentések és fejlesztési ötletek szívesen fogadva.
