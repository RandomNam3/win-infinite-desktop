# Bilder und Animationen der Dokumentation

Die Bilder in `docs/images` entstehen automatisch in **Windows Sandbox**. Der eigene Desktop bleibt
unberührt; das Fenster der Sandbox zeigt, was passiert.

```powershell
cmake --build build
$env:PATH = "C:\Qt\6.11.3\msvc2022_64\bin;$env:PATH"      # windeployqt
powershell -File tools\wid-media\record.ps1 -Build build                 # alle Szenen nach docs\images
powershell -File tools\wid-media\record.ps1 -Build build -Scenes notes   # nur einzelne Szenen
powershell -File tools\wid-media\record.ps1 -Build build -Theme light    # heller Modus
```

Voraussetzungen: Windows Sandbox (`wsb.exe`, Windows 11 24H2 oder neuer), `windeployqt` auf dem PATH und
für die Animationen `ffmpeg` auf dem PATH. Ohne ffmpeg bleiben die Einzelbilder im Arbeitsordner, den
das Skript am Ende nennt.

| Szene | Ergebnis | Zeigt |
|---|---|---|
| `notes` | `notes.png`, `note-editing.png` | eine formatierte Notiz und eine beim Schreiben |
| `menus` | `note-menu.png`, `canvas-menu.png` | das Menü einer Notiz und das Menü der Arbeitsfläche |
| `overview` | `overview.webp` | Übersicht bei 55 %, alle Fenster als Live-Vorschau |
| `zoom` | `zoom-overview.webp` | heraus- und hineinzoomen |
| `pan` | `canvas-pan.webp` | die Fläche verschieben, die Fenster wandern mit |
| `map` | `map.webp` | die Karte der Fläche |

## Wie es funktioniert

- `record.ps1` packt den Build wie für ein Release (`scripts/package.ps1`), legt `wid-media.exe` und
  `scenes.ps1` dazu und startet damit eine Sandbox (`wsb start`, `wsb connect`, `wsb exec`).
- `scenes.ps1` öffnet dort die Einstellungs-App, den Explorer und die Systeminformationen, startet den
  Dienst und legt zwei Notizen an. Dienst und Apps bekommen eigene, leere Datenordner
  (`APPDATA`/`LOCALAPPDATA` zeigen in einen temporären Ordner). Außerhalb der Sandbox läuft das Skript
  nur mit `-Force`, denn es schaltet den Farbmodus um und schließt Explorer-Fenster.
- **Echte Eingaben:** `wid-media.exe` klickt, tippt und drückt Tasten über `SendInput`, wie ein
  Mensch. Die Kamera bewegt `wid-ctl` (`setCamera`, `pan`) in kleinen Schritten; nach jedem Schritt
  nimmt `wid-media shot` ein Bild auf.
- **Bilder:** `BitBlt` vom Bildschirm mit `CAPTUREBLT`, gespeichert als PNG (WIC). Die Markierungen am
  Bildschirmrand sind von Bildschirmaufnahmen ausgenommen und fehlen deshalb auf den Bildern.

`wid-media` taugt auch für eigene Tests:

```text
wid-media shot FILE.png [X Y WIDTH HEIGHT]      Bildschirmfoto (ohne Rechteck: alle Bildschirme)
wid-media icon X Y FILE.png                     Symbol des Fensters an einem Punkt (wie es die Marker zeigen)
wid-media move X Y
wid-media click X Y [left|right|middle] [ANZAHL] [MODIFIKATOREN]
wid-media drag X1 Y1 X2 Y2 [SCHRITTE] [left|middle] [MODIFIKATOREN]
wid-media wheel X Y RASTEN [MODIFIKATOREN]       positiv = vom Benutzer weg
wid-media key KOMBINATION                        z. B. win+alt+m, escape, ctrl+e
wid-media type TEXT
wid-media place PROGRAMM.exe X Y BREITE HÖHE      Hauptfenster eines Programms an eine Stelle
wid-media close KLASSE                           Fenster einer Fensterklasse schließen
wid-media rect KLASSE                            X Y BREITE HÖHE eines Fensters (#32768: offenes Menü)
wid-media theme dark|light                       App- und Systemmodus des Benutzers
wid-media screen                                 Bildschirm, Arbeitsbereich, DPI
```

Koordinaten sind physische Bildschirmpixel; Modifikatoren sind `win`, `ctrl`, `alt`, `shift`,
verbunden mit `+`.
