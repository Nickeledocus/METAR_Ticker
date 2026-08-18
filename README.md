# METAR Ticker

Vliegveldweer voor meerdere luchthavens, weergegeven als een vertrekbord. De ticker loopt automatisch door de onderwerpen — wind, zicht, bewolking, temperatuur, luchtdruk — en toont elk een paar seconden. Handig op een tweede scherm of op je telefoon.

De data komt uit METAR's (**MET**eorological **A**erodrome **R**eport), de standaard weerberichten van vliegvelden, en wordt vertaald naar leesbaar Nederlands. Een ruwe METAR als `EHAM 181025Z 24008KT 9999 FEW020 13/07 Q1026` wordt zo "wind uit 240°, 8 knopen, zicht 10 km of meer, licht bewolkt op 2000 voet, 13 graden, 1026 hectopascal".

**Live demo Web:** `https://nickeledocus.github.io/METAR_Ticker/` &nbsp;·&nbsp; werkt in de browser en is te installeren als app.

## Screenshots
Desktop
<img width="2089" height="446" alt="image" src="https://github.com/user-attachments/assets/3293dad5-0496-4597-86d5-b1d92a07558b" />

Web
<img width="1170" height="502" alt="image" src="https://github.com/user-attachments/assets/81443078-9539-42d3-a6ed-cd29f66f6743" />


## Kenmerken

- Toont meerdere luchthavens tegelijk, netjes onder elkaar.
- Vertaalt de ruwe METAR-codes naar leesbaar Nederlands: windrichting en -snelheid, zicht, weersverschijnselen, wolkentypes en luchtdruk.
- Loopt automatisch door de onderwerpen; ververst zichzelf op de achtergrond.
- Gratis databron, geen account en geen API-sleutel (API = **A**pplication **P**rogramming **I**nterface) nodig.
- Twee smaken met dezelfde vertaallogica: een **webversie** (browser en telefoon) en een **desktopversie** (Windows).

## Twee versies

| Versie | Voor wie | Bestand |
|---|---|---|
| **Web** | Iedereen — draait in de browser, installeerbaar als app op telefoon en pc | `index.html` |
| **Desktop** | Windows-gebruikers die een los venster of een `.exe` willen | `METAR_Ticker_WF.ps1` |

---

## Webversie

### Gebruiken

Open de [live demo](#) in je browser. Tik op het scherm om meteen naar het volgende onderwerp te springen.

### Installeren als app

De webversie is een PWA (**P**rogressive **W**eb **A**pp) en kan als echte app worden geïnstalleerd — met eigen icoon en schermvullend, zonder browserbalk.

- **Android (Chrome):** menu (drie puntjes) → *App installeren* of *Toevoegen aan startscherm*.
- **iPhone (Safari):** deel-icoon → *Zet op beginscherm*.
- **Desktop (Chrome/Edge):** klik op het installatie-icoon in de adresbalk → *Installeren*.

### Instellingen

Bovenin `index.html`, in het blok `INSTELLINGEN`. Aanpassen, opslaan, pagina verversen — er hoeft niets gebouwd te worden.

| Instelling | Standaard | Betekenis |
|---|---|---|
| `AIRPORTS` | Rotterdam, Amsterdam, Eindhoven | De luchthavens (naam + ICAO-code). |
| `SUBJECTS` | Wind, Zicht, Weer, Bewolking, Temp/dauw, Luchtdruk | De onderwerpen die langskomen. |
| `SECONDS_PER_SUBJECT` | `8` | Seconden per onderwerp in beeld. |
| `REFRESH_MINUTES` | `10` | Hoe vaak nieuwe data wordt opgehaald. |
| `PROXIES` | twee stuks | Het doorgeef-luik voor de weerdata (zie hieronder). |

Luchthavens toevoegen doe je met hun ICAO-code (**I**nternational **C**ivil **A**viation **O**rganization). Een paar Nederlandse: `EHRD` Rotterdam, `EHAM` Amsterdam, `EHEH` Eindhoven, `EHGG` Groningen, `EHBK` Maastricht.

Het gekleurde bolletje per luchthaven geeft de globale vliegconditie aan volgens de gangbare METAR-grenzen: groen (VFR, ruim zicht) tot magenta (LIFR, zeer slecht).

### Zelf hosten (GitHub Pages)

De webversie is één statische map, dus elke statische host werkt. Met GitHub Pages:

1. Zorg dat `index.html`, `manifest.webmanifest`, `sw.js` en de map `icons/` in de repo staan (zie [mappenindeling](#mappenindeling)).
2. Ga naar **Settings → Pages**, kies *Deploy from a branch*, je hoofdbranch en de map `/ (root)`, en sla op.
3. Na een minuut of twee is de app bereikbaar op `https://<gebruiker>.github.io/<repo>/`.

De app gebruikt bewust relatieve paden, zodat hij ook onder het subpad van een Pages-adres blijft werken.

### Over de databron en CORS

De weerbron (aviationweather.gov) staat geen directe browsertoegang toe — dat heet CORS (**C**ross-**O**rigin **R**esource **S**haring). De webversie haalt de data daarom op via een publieke proxy die als tussenpersoon fungeert. Er staan er twee ingesteld als vangnet; je kunt ze bovenin bij `PROXIES` wijzigen of leegmaken als je een eigen proxy of een CORS-vriendelijke bron gebruikt.

---

## Desktopversie (Windows)

Een venster gebouwd met PowerShell en Windows Forms. Vereist Windows met Windows PowerShell 5.1 (standaard aanwezig) of PowerShell 7.

### Snel starten

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\METAR_Ticker_WF.ps1
```

### Instellingen

Bovenin `METAR_Ticker_WF.ps1`, in het blok `INSTELLINGEN`.

| Instelling | Standaard | Betekenis |
|---|---|---|
| `$airports` | Rotterdam, Amsterdam, Eindhoven | Luchthavens (naam + ICAO-code). |
| `$subjects` | Wind, Zicht, Weer, Bewolking, Temp/dauw, Luchtdruk | De onderwerpen die langskomen. |
| `$secondsPerSubject` | `10` | Seconden per onderwerp. |
| `$refreshMinutes` | `10` | Hoe vaak nieuwe data wordt opgehaald. |
| `$fontName` / `$fontSize` | `Consolas` / `14` | Lettertype en -grootte. |
| `$winWidth` / `$winHeight` | `1400` / `300` | Vensterafmeting in pixels. |

### Een `.exe` bouwen (optioneel)

`Builder.ps1` maakt met de module [`ps2exe`](https://github.com/MScholtes/PS2EXE) een dubbelklikbaar programma. Pas eerst de twee padregels bovenin `Builder.ps1` aan naar je eigen locatie en draai het dan:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Builder.ps1
```

`ps2exe` bakt het script op dat moment volledig in de `.exe` in: na een wijziging in het bronscript moet je opnieuw bouwen.

---

## Hoe het werkt

De ticker haalt alle luchthavens in één verzoek op bij de Data-API van aviationweather.gov en ontcijfert elke ruwe METAR met reguliere expressies (regex): elk METAR-groepje heeft een vaste vorm, en op basis daarvan wordt het vertaald. Het doorlopen van de onderwerpen en het verversen gebeurt met timers, zodat de weergave soepel blijft reageren.

<a name="mappenindeling"></a>

## Bestanden in de repo

```
/ (repo-root)
├─ index.html               # webversie (compleet in één bestand)
├─ manifest.webmanifest     # app-gegevens voor de PWA
├─ sw.js                    # service worker (installeerbaar + offline opstarten)
├─ icons/                   # app-iconen (192, 512, maskable)
├─ METAR_Ticker_WF.ps1      # desktopversie (PowerShell)
├─ Builder.ps1              # bouwt de desktop-.exe
└─ README.md
```

## Databron & credits

Weerdata: [Aviation Weather Center](https://aviationweather.gov/) (National Weather Service, VS) — een gratis publieke dienst; gebruik hem met mate. De webversie gebruikt een publieke CORS-proxy ([allorigins](https://allorigins.win/) of [corsproxy.io](https://corsproxy.io/)). De desktop-`.exe` wordt gebouwd met [`ps2exe`](https://github.com/MScholtes/PS2EXE) van Markus Scholtes.

## Roadmap

- Eén luchthaven tegelijk volledig in beeld, als alternatief voor het gesynchroniseerde bord.
- Mist-waarschuwing wanneer temperatuur en dauwpunt dicht bij elkaar liggen.
- Externe instellingen voor de desktopversie, zodat luchthavens gewisseld kunnen worden zonder opnieuw te bouwen.

## Licentie
MIT License

Copyright (c) 2026 Nick Scheffers

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


## Disclaimer

Niet gebruiken voor vluchtvoorbereiding of beslissingen tijdens de vlucht — raadpleeg daarvoor altijd officiële, gecertificeerde weerbronnen. Deze tool toont uitsluitend wat de vliegveldsensoren rapporteren. En of elk stipje dat als "vogel" op de radar verschijnt werkelijk een vogel is en niet gewoon keurig geregistreerde overheidsapparatuur, laat de METAR wijselijk in het midden.
