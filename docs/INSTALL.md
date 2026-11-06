# WIN Infinite Desktop installieren

> „Wenn es Windows 11 ausführt, läuft auch WIN Infinite Desktop.“

WIN Infinite Desktop ist ein Hintergrundprogramm für **Windows 11**. Es macht jeden Monitor zu einer
unendlichen Arbeitsfläche, die man verschieben und zoomen kann. Dazu gehören eine Notiz-App und eine
eigene Einstellungs-App.

**Voraussetzungen**

- Windows 11 **24H2 oder neuer** (Build 26100 und höher; 25H2 und 26H2 werden unterstützt)
- ein **x64**-Prozessor
- ein normales Benutzerkonto, Administratorrechte sind nicht nötig

---

## Inhalt

1. [Schnellstart](#1-schnellstart)
2. [Was der Installer ändert](#2-was-der-installer-ändert)
3. [Smart App Control und SmartScreen](#3-smart-app-control-und-smartscreen)
4. [Starten, beenden, Autostart](#4-starten-beenden-autostart)
5. [Updates](#5-updates)
6. [Deinstallieren](#6-deinstallieren)
7. [Selbst bauen](#7-selbst-bauen)
8. [Fehlerbehebung](#8-fehlerbehebung)
9. [Für Entwickler](#9-für-entwickler)

---

## 1. Schnellstart

Ein Befehl in PowerShell (Startmenü → *Terminal* oder *Windows PowerShell*), als normaler Benutzer:

```powershell
irm https://raw.githubusercontent.com/RandomNam3/win-infinite-desktop/main/install.ps1 | iex
```

Der Befehl lädt das Paket des neuesten Releases von GitHub, vergleicht seine SHA-256-Prüfsumme mit der,
die GitHub dazu veröffentlicht, entpackt es nach `%TEMP%` und startet den Installer darin; ist
WIN Infinite Desktop schon installiert, als Update. Die heruntergeladenen Dateien löscht er danach wieder.
Das Skript dahinter ist [`install.ps1`](../install.ps1) in diesem Repository.

Ohne den Befehl, von Hand:

1. Aus dem [neuesten Release](https://github.com/RandomNam3/win-infinite-desktop/releases/latest) die
   Datei `win-infinite-desktop-<Version>-x64.zip` herunterladen.
2. Das ZIP entpacken (Rechtsklick → *Alle extrahieren*).
3. Im entpackten Ordner ein PowerShell-Fenster öffnen (Rechtsklick in den Ordner → *Im Terminal öffnen*)
   und ausführen:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

Der Installer

1. prüft die Windows-Version (mindestens Build 26100),
2. beendet eine laufende ältere Version sauber, sodass alle Fenster auf den Bildschirm zurückkommen,
3. kopiert die Programme nach `%LOCALAPPDATA%\Programs\WIN Infinite Desktop`,
4. legt die Einträge im Startmenü, im Autostart und unter *Einstellungen → Apps* an,
5. startet WIN Infinite Desktop. Das Symbol erscheint im Infobereich der Taskleiste.

Vorher ansehen, was passieren würde (ändert nichts):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -DryRun
```

Mit `-NoStart` wird nur installiert, nicht gestartet.

---

## 2. Was der Installer ändert

| Was | Wo |
|---|---|
| Programme | `%LOCALAPPDATA%\Programs\WIN Infinite Desktop` (Dienst `win-infinite-desktop.exe`, Notiz-App `wid-notes.exe`, Einstellungs-App `wid-settings.exe`, `wid-ctl.exe`, `wid-probe.exe`, Qt, `install.ps1`) |
| Startmenü | Ordner *WIN Infinite Desktop* mit „WIN Infinite Desktop“ und „WIN Infinite Desktop Settings“ |
| Autostart | `HKCU\Software\Microsoft\Windows\CurrentVersion\Run`, Wert *WIN Infinite Desktop* |
| Eintrag unter *Einstellungen → Apps* | `HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\WinInfiniteDesktop` |

Alles liegt im eigenen Benutzerprofil. Andere Benutzer des Rechners sind nicht betroffen, Dienste oder
Treiber werden nicht installiert.

Deine Daten legen die Programme selbst an; der Installer fasst sie nicht an:

| Daten | Ort |
|---|---|
| Einstellungen und Tastenkürzel | `%APPDATA%\WIN Infinite Desktop\settings.ini` |
| Notizen | `%APPDATA%\WIN Infinite Desktop\notes\` (eine Markdown-Datei je Notiz) |
| Kameras, Lesezeichen, gemerkte Fensterplätze, Gruppen, Bereiche, Protokoll | `%LOCALAPPDATA%\WIN Infinite Desktop\` |

---

## 3. Smart App Control und SmartScreen

Die Programme sind nicht digital signiert.

- **SmartScreen** warnt beim ersten Start von Programmen aus dem Internet. Der Installer entfernt die
  Download-Markierung von den kopierten Dateien, die Warnung erscheint deshalb in der Regel nicht.
- **Smart App Control** blockiert nicht signierte Programme ganz. Ist es eingeschaltet, startet
  WIN Infinite Desktop nicht, und der Installer meldet *„The service did not start“*. Abhilfe: *Windows-
  Sicherheit → App- und Browsersteuerung → Smart App Control* ausschalten.

---

## 4. Starten, beenden, Autostart

- **Starten:** Startmenü → *WIN Infinite Desktop*. Nach der Anmeldung startet es automatisch.
- **Beenden:** Symbol im Infobereich → *Beenden*. Alle Fenster außerhalb der Bildschirme kommen dabei
  zurück, Snap und „immer im Vordergrund“ werden wiederhergestellt. Dasselbe passiert beim Abmelden und
  Herunterfahren.
- **Pausieren:** Symbol im Infobereich → *Gesten pausieren*. Die Fläche bleibt, Maus und Tastatur
  verhalten sich wie ohne WIN Infinite Desktop.
- **Autostart ein- und ausschalten:** in der Einstellungs-App (*Einschalten* / *Ausschalten* auf der
  Startseite) oder unter *Einstellungen → Apps → Autostart*.

---

## 5. Updates

Die Einstellungs-App sieht beim Start auf GitHub nach, ob es eine neue Version gibt. **Update
installieren**

1. lädt das passende ZIP aus dem Release herunter (mit Fortschrittsanzeige) und vergleicht seine
   SHA-256-Prüfsumme mit der von GitHub,
2. entpackt es nach `%TEMP%`,
3. führt dessen `install.ps1 -Update` ohne Fenster aus. Der Installer beendet den laufenden Dienst
   sauber, schließt auch die Einstellungs-App, installiert, startet die neue Version und öffnet die
   Einstellungs-App wieder. Sie zeigt dann, ob das Update geklappt hat.

Was der Installer dabei getan hat, steht in `%LOCALAPPDATA%\WIN Infinite Desktop\update.log`; bei einem
Fehler öffnet *Protokoll öffnen* diese Datei.

Von Hand geht ein Update mit dem Befehl aus dem [Schnellstart](#1-schnellstart), oder: das neue ZIP
herunterladen, entpacken und im Ordner ausführen:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -Update
```

Einstellungen, Notizen und gemerkte Plätze bleiben erhalten.

**Von „WIN Infinit Desktop“ (bis 0.2):** So hieß das Projekt bis Version 0.2. Das Update aus der
Einstellungs-App und der Befehl aus dem Schnellstart funktionieren dort wie gewohnt. Der Installer

- beendet den alten Dienst über dessen Pipe, sodass alle Fenster auf den Bildschirm zurückkommen,
- entfernt `%LOCALAPPDATA%\Programs\WIN Infinit Desktop`, den alten Startmenü-Ordner, den Autostart-Wert
  *WIN Infinit Desktop* und den Eintrag `…\Uninstall\WinInfinitDesktop`,
- verschiebt `%APPDATA%\WIN Infinit Desktop` und `%LOCALAPPDATA%\WIN Infinit Desktop` in die neuen Ordner.

Startet man die neue Version ohne Installer (aus dem ZIP), übernehmen Dienst und Apps die alten Ordner
beim ersten Start selbst.

---

## 6. Deinstallieren

*Einstellungen → Apps → Installierte Apps → WIN Infinite Desktop → Deinstallieren*, oder:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA\Programs\WIN Infinite Desktop\install.ps1" -Uninstall
# zusätzlich Einstellungen, Notizen und gespeicherte Arbeitsflächen löschen:
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA\Programs\WIN Infinite Desktop\install.ps1" -Uninstall -RemoveData
```

Das beendet alle Programme von WIN Infinite Desktop (die Notiz-App speichert vorher), entfernt den
Autostart, den Startmenü-Ordner, den Eintrag unter *Apps* und den Programmordner. Ohne `-RemoveData`
bleiben `%APPDATA%\WIN Infinite Desktop` und `%LOCALAPPDATA%\WIN Infinite Desktop` erhalten.

---

## 7. Selbst bauen

Voraussetzungen:

- Visual Studio 2022 oder 2026 mit *Desktopentwicklung mit C++*
- CMake ≥ 3.22 und Ninja (beide bringt Visual Studio mit)
- Qt ≥ 6.8 für MSVC (Module Core, Gui, Network, Qml, Quick, QuickControls2, Test), z. B. über den
  Qt Online Installer

Die Release-Pakete werden mit Qt 6.11.3 gebaut.

In der *Developer PowerShell for VS*:

```powershell
git clone https://github.com/RandomNam3/win-infinite-desktop.git
cd win-infinite-desktop
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=C:\Qt\6.11.3\msvc2022_64
cmake --build build
ctest --test-dir build --output-on-failure
```

Installierbares ZIP wie im Release (braucht `windeployqt` im `PATH`):

```powershell
$env:PATH = "C:\Qt\6.11.3\msvc2022_64\bin;$env:PATH"
pwsh scripts/package.ps1 -Build build -Output dist -Arch x64
```

Danach `dist\install.ps1` ausführen wie in [Abschnitt 1](#1-schnellstart).

CMake-Optionen:

| Option | Standard | Wirkung |
|---|---|---|
| `WID_WITH_QT` | `ON` | alle Qt-Teile; `OFF` baut nur die Win32-Schicht und `wid-probe` |
| `WID_BUILD_APPS` | `ON` | Notiz-App und Einstellungs-App (Qt Quick) |
| `WID_BUILD_PROBE` | `ON` | das Diagnose-Werkzeug `wid-probe` |
| `WID_ASAN` | `OFF` | AddressSanitizer (`/fsanitize=address`), nur zum Entwickeln |

---

## 8. Fehlerbehebung

**Das Programm startet nicht, kein Symbol im Infobereich**

- Smart App Control prüfen ([Abschnitt 3](#3-smart-app-control-und-smartscreen)).
- Die Windows-Version prüfen: `winver`. Unter Build 26100 startet WIN Infinite Desktop nicht.
- Das Protokoll ansehen: `%LOCALAPPDATA%\WIN Infinite Desktop\service.log`.

**Der Installer meldet „The service did not quit“**

Die laufende Version hat auf die Bitte zum Beenden nicht reagiert. Über das Symbol im Infobereich
beenden und den Installer noch einmal ausführen. Der Installer beendet den Dienst nie gewaltsam, damit
keine Fenster außerhalb der Bildschirme liegen bleiben.

**Fenster liegen außerhalb der Bildschirme**

Symbol im Infobereich → *Alle Fenster zurückholen*. Nach einem Absturz holt der nächste Start alle
Fenster zurück, die ganz außerhalb aller Bildschirme liegen.

**Abgesicherter Modus**

Stürzt der Dienst dreimal hintereinander ab, startet er im abgesicherten Modus: keine Gesten, keine
Fensterverwaltung, nur das Symbol im Infobereich. Verlassen über das Symbol (*Abgesicherten Modus
verlassen*) oder die Einstellungs-App. Von Hand:

```powershell
& "$env:LOCALAPPDATA\Programs\WIN Infinite Desktop\wid-ctl.exe" leaveSafeMode
# Absturzzähler zurücksetzen (bei beendetem Dienst)
Remove-Item "$env:LOCALAPPDATA\WIN Infinite Desktop\crashguard"
```

**Ausführliches Protokoll**

In der Einstellungs-App unter *Erweitert* das *Debug-Protokoll* einschalten. Die Meldungen stehen in
`%LOCALAPPDATA%\WIN Infinite Desktop\service.log`.

**Bericht über das System**

```powershell
& "$env:LOCALAPPDATA\Programs\WIN Infinite Desktop\wid-probe.exe" > bericht.txt
```

Der Bericht enthält Windows-Version, Bildschirme und alle Fenster mit ihrer Einordnung. Fenstertitel
stehen nur mit `--titles` darin, Pfade im Benutzerprofil werden zu `%USERPROFILE%`.

---

## 9. Für Entwickler

```powershell
ctest --test-dir build --output-on-failure        # Unit-Tests
pwsh tests/runtime/smoke.ps1 -Build build         # Laufzeittest auf dem eigenen Desktop
& build\tools\wid-ctl\wid-ctl.exe state           # Zustand des laufenden Dienstes
& build\tools\wid-ctl\wid-ctl.exe pan dx=-500 dy=0
```

`wid-ctl` spricht die Named-Pipe-Schnittstelle des Dienstes (Methoden in
[ARCHITEKTUR.md](ARCHITEKTUR.md#11-ipc-schnittstelle)). Mit `WID_DEBUG=1` schreibt der Dienst ausführliche
Meldungen ins Protokoll.

CI (`.github/workflows/ci.yml`):
- Build und Unit-Tests mit MSVC auf x64, zusätzlich mit AddressSanitizer;
- ARM64-Build der Win32-Schicht und von `wid-probe`;
- der gemeinsame Kern und die plattformneutralen Teile der Apps unter Linux, Prüfung des deutschen
  Katalogs;
- auf x64: Paket bauen, installieren und deinstallieren, alle Seiten der Einstellungs-App rendern, die
  Notiz-App starten und den Laufzeittest ausführen.

`.github/workflows/release.yml` baut für jede neue Version auf `main` das ZIP, setzt den Tag `v<Version>`
und veröffentlicht das Release mit den Notizen aus `docs/releases/<Version>.md`.
