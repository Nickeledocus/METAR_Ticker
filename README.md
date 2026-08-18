# METAR Ticker

Een klein Windows-bureaubladvenster dat het actuele vliegveldweer van meerdere luchthavens laat zien als een soort vertrekbord: per onderwerp (wind, zicht, bewolking, ...) een paar seconden in beeld, en dan door naar het volgende. Handig om op een tweede scherm te laten draaien.

De ticker haalt zogenoemde METAR's op — **MET**eorological **A**erodrome **R**eport, het standaard weerberichtje dat vliegvelden wereldwijd uitzenden — en vertaalt die cryptische regels naar gewoon Nederlands.

Zo'n ruwe METAR ziet er bijvoorbeeld zo uit: `EHAM 181025Z 24008KT 9999 FEW020 13/07 Q1026`. Voor de ingewijde één regel vol afkortingen; deze tool maakt er "wind uit 240°, 8 knopen, zicht 10 km of meer, licht bewolkt op 2000 voet, 13 graden, 1026 hectopascal" van.

> Zet je eigen schermafbeelding in een mapje `docs/` en pas de regel hierboven aan, of haal 'm weg.

## Wat het doet

- Toont meerdere luchthavens tegelijk, netjes onder elkaar.
- Loopt automatisch door de onderwerpen heen (wind, zicht, weer, bewolking, temperatuur/dauwpunt, luchtdruk), elk een paar seconden in beeld.
- Vertaalt de ruwe METAR-codes naar leesbaar Nederlands, inclusief windrichting, wolkentypes, weersverschijnselen en luchtdruk.
- Ververst zichzelf op de achtergrond (METAR's veranderen ongeveer één keer per uur, dus vaak ophalen is nergens voor nodig).
- Draait als los venster met een eigen lettertype, grootte en kleuren — geen zwart consolescherm.
- Gratis databron, geen registratie en geen API-sleutel (API = **A**pplication **P**rogramming **I**nterface, de "stekker" waarmee het script data ophaalt) nodig.

## Screenshot
<img width="2089" height="446" alt="image" src="https://github.com/user-attachments/assets/3293dad5-0496-4597-86d5-b1d92a07558b" />


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

## Hoe het werkt (onder de motorkap)

De data komt van de gratis Data-API van aviationweather.gov (de Amerikaanse luchtvaartweerdienst). Alle luchthavens worden in één verzoek opgehaald — netjes tegenover de gratis server.

De ruwe METAR wordt daarna stukje voor stukje ontcijferd met reguliere expressies (regex, een taaltje om patronen in tekst te herkennen). Elk METAR-groepje heeft een vaste vorm, en op basis van die vorm weet het script wat het betekent.

Het rondlopen door de onderwerpen gebeurt met twee timers in plaats van een wachtlus. Dat moet ook wel: een venster moet tussendoor kunnen "ademen" om op je te reageren en zichzelf opnieuw te tekenen. Een gewone wachtlus zou het venster laten bevriezen.

Zie het als een kok met twee kookwekkers op het aanrecht. Hij staat niet bevroren naar één pan te staren, maar loopt rond en doet pas iets zodra er een wekker afgaat — ondertussen kan hij nog steeds opendoen. De ene wekker schuift elke paar seconden naar het volgende onderwerp; de andere kijkt af en toe of de weerdata al ververst moet worden.

## Goed om te weten

- **Het °-teken en tekencodering.** Het graden-teken wordt in de code opgebouwd via `[char]176` in plaats van letterlijk in het bestand te staan. Dat voorkomt het klassieke `18Â°`-probleem, waarbij het teken verhaspeld raakt door een verschil in tekencodering (encoding) tussen opslaan en inlezen. Zo overleeft het teken ook het door `ps2exe` halen zonder gedoe.
- **Even een minibevriezinkje bij het verversen.** Op het moment dat nieuwe data wordt opgehaald staat het venster héél kort stil (een fractie van een seconde), omdat ophalen en tekenen op dezelfde lijn gebeuren. Bij één keer per tien minuten merk je dat nauwelijks. Wil je het écht vloeiend, dan is het ophalen op een aparte werklijn (een background job of runspace) een mooi vervolgstapje.
- **Waarom geen browserversie?** De weerdienst-server stuurt geen CORS-toestemming mee — **C**ross-**O**rigin **R**esource **S**haring, de regel waarmee een browser bepaalt of hij data van andermans server mag ophalen. Een browser zou de data dus weigeren. PowerShell heeft daar geen last van, want dat is een eigen client en geen browser.

## Databron & dank

Weerdata is afkomstig van [Aviation Weather Center](https://aviationweather.gov/) (National Weather Service, VS). Gebruik de bron met mate: het is een gratis publieke dienst, dus overspoel 'm niet met verzoeken.

Het bouwen leunt op de [`ps2exe`](https://github.com/MScholtes/PS2EXE)-module van Markus Scholtes.

## Ideeën voor later

- Eén luchthaven tegelijk volledig in beeld (eerst Rotterdam al zijn onderwerpen, dán Amsterdam), als alternatief voor het huidige gesynchroniseerde bord.
- Een mist-waarschuwing wanneer temperatuur en dauwpunt dicht bij elkaar liggen.
- Instellingen in een los tekstbestandje, zodat je luchthavens kunt wisselen zonder opnieuw te bouwen.

## Disclaimer

Deze tool toont uitsluitend wat de vliegveldsensoren rapporteren. Of elk stipje dat als "vogel" op de radar verschijnt werkelijk een vogel is, en niet gewoon keurig geregistreerde overheidsapparatuur, laat de METAR wijselijk in het midden. Vlieg — en interpreteer — dus op eigen risico.
