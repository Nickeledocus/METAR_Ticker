# METAR Ticker

Toont het actuele vliegveldweer van meerdere luchthavens als een soort vertrekbord: per onderwerp (wind, zicht, bewolking, ...) een paar seconden in beeld, en dan door naar het volgende. Handig om op een tweede scherm of op je telefoon te laten draaien.

De ticker haalt zogenoemde METAR's op — **MET**eorological **A**erodrome **R**eport, het standaard weerberichtje dat vliegvelden wereldwijd uitzenden — en vertaalt die cryptische regels naar gewoon Nederlands.

Zo'n ruwe METAR ziet er bijvoorbeeld zo uit: `EHAM 181025Z 24008KT 9999 FEW020 13/07 Q1026`. Voor de ingewijde één regel vol afkortingen; deze tool maakt er "wind uit 240°, 8 knopen, zicht 10 km of meer, licht bewolkt op 2000 voet, 13 graden, 1026 hectopascal" van.

Er zijn **twee smaken** in deze repo, met dezelfde vertaallogica:

- **Desktop** — een Windows-venster gebouwd met PowerShell, eventueel om te bouwen naar een `.exe`.
- **Web** — één HTML-bestand dat in de browser draait en dat je als app op je telefoon of pc kunt installeren.

## Screenshot
<img width="2089" height="446" alt="image" src="https://github.com/user-attachments/assets/3293dad5-0496-4597-86d5-b1d92a07558b" />

## Wat het doet

- Toont meerdere luchthavens tegelijk, netjes onder elkaar.
- Loopt automatisch door de onderwerpen heen (wind, zicht, weer, bewolking, temperatuur/dauwpunt, luchtdruk), elk een paar seconden in beeld.
- Vertaalt de ruwe METAR-codes naar leesbaar Nederlands, inclusief windrichting, wolkentypes, weersverschijnselen en luchtdruk.
- Ververst zichzelf op de achtergrond (METAR's veranderen ongeveer één keer per uur, dus vaak ophalen is nergens voor nodig).
- Gratis databron, geen registratie en geen API-sleutel (API = **A**pplication **P**rogramming **I**nterface, de "stekker" waarmee de tool data ophaalt) nodig.

## Wat zit er in deze repo

| Bestand | Waarvoor |
|---|---|
| `METAR_Ticker_WF.ps1` | De desktopversie (PowerShell + Windows Forms). |
| `Builder.ps1` | Bouwt van de desktopversie een `.exe`. |
| `index.html` | De volledige webversie in één bestand. |
| `manifest.webmanifest` | Het "paspoort" van de web-app (naam, kleuren, icoon). |
| `sw.js` | De service worker die de app installeerbaar maakt. |
| `icons/` | De app-iconen. |

---

# Desktopversie (Windows)

## Vereisten

- Windows (het venster is gebouwd met Windows Forms, de ingebouwde vensterbouwdoos van Windows).
- Windows PowerShell 5.1 (standaard aanwezig op Windows) of PowerShell 7 op Windows.
- Een internetverbinding, want de weerdata komt van een online bron.
- Alleen nodig als je een `.exe` wilt bouwen: de PowerShell-module `ps2exe` (spreek uit: "PowerShell-to-exe"). Het bouwscript installeert die zo nodig zelf.

## Snel starten (zonder te bouwen)

Je kunt het gewoon als script draaien om te kijken of het bevalt:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\METAR_Ticker_WF.ps1
```

`-ExecutionPolicy Bypass` zorgt dat Windows je eigen script niet blokkeert. Het venster verschijnt gecentreerd op je scherm; afsluiten doe je met het kruisje.

## Instellingen

Alle knoppen zitten bovenin `METAR_Ticker_WF.ps1`, in het blok `INSTELLINGEN`. Aanpassen, opslaan, opnieuw draaien (of opnieuw bouwen, zie hieronder).

| Instelling | Standaard | Betekenis |
|---|---|---|
| `$airports` | Rotterdam (EHRD), Amsterdam (EHAM), Eindhoven (EHEH) | De luchthavens die getoond worden. Elke regel is een naam plus een ICAO-code. |
| `$subjects` | Wind, Zicht, Weer, Bewolking, Temp/dauw, Luchtdruk | De onderwerpen die langskomen, in deze volgorde. |
| `$secondsPerSubject` | `10` | Hoeveel seconden elk onderwerp in beeld blijft. |
| `$refreshMinutes` | `10` | Hoe vaak nieuwe weerdata wordt opgehaald. |
| `$fontName` | `Consolas` | Het lettertype in het venster. |
| `$fontSize` | `14` | De lettergrootte. |
| `$winWidth` | `1400` | Vensterbreedte in pixels. |
| `$winHeight` | `300` | Vensterhoogte in pixels. |

Een luchthaven toevoegen doe je door een regel bij te plakken in `$airports`. Je hebt de ICAO-code nodig — **I**nternational **C**ivil **A**viation **O**rganization, de viertekenige luchthavencode. Een paar Nederlandse:

```powershell
$airports = @(
    [pscustomobject]@{ Name='Rotterdam'; Icao='EHRD' }
    [pscustomobject]@{ Name='Amsterdam'; Icao='EHAM' }
    [pscustomobject]@{ Name='Eindhoven'; Icao='EHEH' }
    [pscustomobject]@{ Name='Groningen'; Icao='EHGG' }
    [pscustomobject]@{ Name='Maastricht'; Icao='EHBK' }
)
```

## Een `.exe` bouwen

`Builder.ps1` bakt van je script een dubbelklikbaar programma (`METAR_Ticker.exe`), zodat je geen PowerShell-venster meer hoeft te openen. Pas eerst de twee padregels bovenin `Builder.ps1` aan naar jouw situatie:

```powershell
$bronScript = 'C:\wrk\METAR_Ticker\METAR_Ticker_WF.ps1'
$doelExe    = 'C:\wrk\METAR_Ticker\METAR_Ticker.exe'
```

En draai dan:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Builder.ps1
```

Het bouwscript doet drie dingen: het installeert `ps2exe` eenmalig als die nog ontbreekt, het sluit een eventueel draaiende ticker af (anders zit het `.exe`-bestand op slot en kun je er niet overheen schrijven), en het bakt vervolgens een verse `.exe`.

Belangrijk om te weten: `ps2exe` **bakt je script op het moment van bouwen volledig in de `.exe` in**. Er is daarna geen levende link meer met je `.ps1`.

Zie de `.exe` als een gedrukt boek en je `.ps1` als het Word-document waaruit het gedrukt is. Corrigeer je een typefout in het Word-bestand, dan verandert het boek dat al op de plank staat niet mee — je moet een nieuwe druk laten maken.

Je werkwijze wordt daarom: `METAR_Ticker_WF.ps1` aanpassen (bijvoorbeeld een luchthaven erbij), `Builder.ps1` draaien, klaar. Elke wijziging betekent één keer opnieuw bouwen.

## Automatisch opstarten (optioneel)

Wil je 'm elke keer bij het aanzetten van je computer laten starten, zet dan een snelkoppeling naar `METAR_Ticker.exe` in je opstartmap. Druk op Windows-toets + R, typ `shell:startup`, druk op Enter, en sleep er een snelkoppeling naartoe.

---

# Webversie (browser & telefoon)

Dezelfde ticker, maar dan als één `index.html`-bestand dat in elke moderne browser draait — op je pc én je telefoon. Tikken op het scherm spoelt meteen door naar het volgende onderwerp.

## Even proberen

Je kunt `index.html` lokaal openen om te kijken of het bevalt. Voor de installeerbare app-versie en de betrouwbaarste werking zet je 'm online via GitHub Pages (zie verderop) — dat is gratis en zo geregeld.

## Instellingen

Alle knoppen zitten bovenin `index.html`, in het blok `INSTELLINGEN`:

| Instelling | Standaard | Betekenis |
|---|---|---|
| `AIRPORTS` | Rotterdam, Amsterdam, Eindhoven | De luchthavens (naam + ICAO-code). |
| `SUBJECTS` | Wind, Zicht, Weer, Bewolking, Temp/dauw, Luchtdruk | De onderwerpen die langskomen. |
| `SECONDS_PER_SUBJECT` | `8` | Seconden per onderwerp in beeld. |
| `REFRESH_MINUTES` | `10` | Hoe vaak nieuwe data wordt opgehaald. |
| `PROXIES` | twee stuks | Het doorgeef-luik voor de weerdata (zie hieronder). |

Fijn verschil met de desktopversie: hier hoef je **niets te bouwen**. Aanpassen, opslaan, pagina verversen — klaar.

## Waarom een "proxy"? (de CORS-omweg)

De weerdienst staat het niet toe dat een browser zijn data rechtstreeks ophaalt. Dat heet CORS — **C**ross-**O**rigin **R**esource **S**haring, de regel waarmee een browser bepaalt of hij data van andermans server mag lezen — en die staat bij deze bron dicht. De webversie vraagt de data daarom niet zelf op, maar laat een tussenpartij (een "proxy") het even ophalen en doorgeven.

Zie zo'n proxy als een conciërge bij de balie. Jij mag zelf niet achter in het magazijn komen, maar je vraagt het de conciërge, die loopt erheen, pakt het pakketje en geeft het aan jou over de balie. Jij krijgt precies wat je wilde; je bent alleen niet zélf naar achteren gelopen.

Er staan er twee ingesteld als vangnet: valt de eerste weg, dan pakt de app automatisch de tweede. Het zijn gratis diensten van derden, dus ze kunnen af en toe traag zijn of plat liggen. Voor een persoonlijk tickertje is dat prima; je kunt ze bovenin bij `PROXIES` zo omwisselen, of de lijst leegmaken (`[]`) als je ooit een bron gebruikt die CORS wél toestaat of je eigen proxy draait.

## Als app installeren (PWA)

Een PWA — **P**rogressive **W**eb **A**pp — is een webpagina die zich als een geïnstalleerde app gedraagt: eigen icoon op je startscherm, schermvullend, zonder browserbalk eromheen. Deze repo bevat alles wat daarvoor nodig is (`manifest.webmanifest`, `sw.js` en de iconen).

Zet de app online met GitHub Pages:

1. Zet deze bestanden in je repo (zie de mappenindeling hieronder).
2. Ga in je repo naar **Settings → Pages** en kies als bron je hoofdbranch (root). GitHub geeft je dan een `https://...`-adres.
3. Open dat adres op je telefoon in Chrome, tik op het menu en kies **"Toevoegen aan startscherm"** (op de iPhone doe je dit via het deel-icoon in Safari).

Je krijgt dan een icoon dat de ticker schermvullend opent. Dat GitHub Pages een echt `https://`-adres geeft, is precies wat een installeerbare app nodig heeft — en meteen loopt de proxy er ook betrouwbaarder overheen dan bij een lokaal geopend bestand.

### Mappenindeling in de repo

De web-app gebruikt bewust relatieve paden, zodat hij ook werkt onder het subpad van een GitHub Pages-adres. Houd deze indeling aan:

```
/ (repo-root)
├─ index.html
├─ manifest.webmanifest
├─ sw.js
├─ icons/
│  ├─ icon-192.png
│  ├─ icon-512.png
│  └─ icon-maskable-512.png
├─ METAR_Ticker_WF.ps1
├─ Builder.ps1
└─ README.md
```

> Wijzig je de web-app later? Hoog dan het versienummer in `sw.js` op (bijvoorbeeld `metar-ticker-v1` → `v2`). Zo weet de service worker dat hij de oude, onthouden versie mag weggooien en de verse moet laden.

---

## Hoe het werkt (onder de motorkap)

De data komt van de gratis Data-API van aviationweather.gov (de Amerikaanse luchtvaartweerdienst). Alle luchthavens worden in één verzoek opgehaald — netjes tegenover de gratis server.

De ruwe METAR wordt daarna stukje voor stukje ontcijferd met reguliere expressies (regex, een taaltje om patronen in tekst te herkennen). Elk METAR-groepje heeft een vaste vorm, en op basis van die vorm weet de tool wat het betekent.

Het rondlopen door de onderwerpen gebeurt met timers in plaats van een wachtlus. Dat moet ook wel: een venster of pagina moet tussendoor kunnen "ademen" om op je te reageren en zichzelf opnieuw te tekenen. Een gewone wachtlus zou alles laten bevriezen.

Zie het als een kok met twee kookwekkers op het aanrecht. Hij staat niet bevroren naar één pan te staren, maar loopt rond en doet pas iets zodra er een wekker afgaat — ondertussen kan hij nog steeds opendoen. De ene wekker schuift naar het volgende onderwerp; de andere kijkt af en toe of de weerdata ververst moet worden.

## Goed om te weten

- **Het °-teken en tekencodering (desktop).** In de PowerShell-versie wordt het graden-teken opgebouwd via `[char]176` in plaats van letterlijk in het bestand te staan. Dat voorkomt het klassieke `18Â°`-probleem, waarbij het teken verhaspeld raakt door een verschil in tekencodering (encoding). In de webversie speelt dit niet: die staat als UTF-8 ingesteld, dus daar mag het °-teken gewoon letterlijk in.
- **Even een minibevriezinkje bij het verversen (desktop).** Op het moment dat nieuwe data wordt opgehaald staat het venster héél kort stil, omdat ophalen en tekenen op dezelfde lijn gebeuren. Bij één keer per tien minuten merk je dat nauwelijks.
- **De statusbolletjes (web).** In de webversie kleurt een bolletje per luchthaven van groen (VFR, ruim zicht) tot magenta (LIFR, zeer slecht), volgens de gangbare METAR-grenzen voor vliegcondities. Dat is een grove inschatting op basis van zicht en bewolking, geen officiële classificatie.

## Databron & dank

Weerdata is afkomstig van [Aviation Weather Center](https://aviationweather.gov/) (National Weather Service, VS). Gebruik de bron met mate: het is een gratis publieke dienst, dus overspoel 'm niet met verzoeken.

De desktopversie leunt bij het bouwen op de [`ps2exe`](https://github.com/MScholtes/PS2EXE)-module van Markus Scholtes. De webversie haalt de data op via een publieke CORS-proxy ([allorigins](https://allorigins.win/) of [corsproxy.io](https://corsproxy.io/)).

## Ideeën voor later

- Eén luchthaven tegelijk volledig in beeld (eerst Rotterdam al zijn onderwerpen, dán Amsterdam), als alternatief voor het huidige gesynchroniseerde bord.
- Een mist-waarschuwing wanneer temperatuur en dauwpunt dicht bij elkaar liggen.
- Instellingen in een los tekstbestandje (desktop), zodat je luchthavens kunt wisselen zonder opnieuw te bouwen.

## Disclaimer

Deze tool toont uitsluitend wat de vliegveldsensoren rapporteren. Of elk stipje dat als "vogel" op de radar verschijnt werkelijk een vogel is, en niet gewoon keurig geregistreerde overheidsapparatuur, laat de METAR wijselijk in het midden. Vlieg — en interpreteer — dus op eigen risico.
