<#
    build.ps1  -  maakt (of vernieuwt) MetarTicker.exe uit MetarTicker.ps1
    Draai dit in PowerShell telkens nadat je het bronscript hebt aangepast.
#>

# --- Paden: pas deze twee regels aan naar jouw situatie ---------------------
$bronScript = 'C:\wrk\METAR_Ticker\METAR_Ticker_WF.ps1'
$doelExe    = 'C:\wrk\METAR_Ticker\METAR_Ticker.exe'

# --- 1. Zorg dat ps2exe beschikbaar is --------------------------------------
if (-not (Get-Module -ListAvailable -Name ps2exe)) {
    Write-Host "ps2exe wordt eenmalig geinstalleerd..." -ForegroundColor Yellow
    Install-Module -Name ps2exe -Scope CurrentUser -Force
}
Import-Module ps2exe

# --- 2. Draaiende versie afsluiten (anders zit het bestand op slot) ---------
$procNaam = [System.IO.Path]::GetFileNameWithoutExtension($doelExe)
$draaiend = Get-Process -Name $procNaam -ErrorAction SilentlyContinue
if ($draaiend) {
    Write-Host "Draaiende $procNaam wordt afgesloten voor de herbouw..." -ForegroundColor Yellow
    $draaiend | Stop-Process -Force
    Start-Sleep -Milliseconds 500   # heel even wachten tot Windows het bestand loslaat
}

# --- 3. Bouwen --------------------------------------------------------------
if (-not (Test-Path $bronScript)) {
    Write-Host "Bronscript niet gevonden: $bronScript" -ForegroundColor Red
    return
}

Write-Host "Bezig met bouwen..." -ForegroundColor Cyan
Invoke-ps2exe -InputFile $bronScript -OutputFile $doelExe -noConsole -title 'METAR Ticker'

if (Test-Path $doelExe) {
    Write-Host "Klaar! Verse .exe staat hier: $doelExe" -ForegroundColor Green
} else {
    Write-Host "Er ging iets mis - de .exe is niet aangemaakt." -ForegroundColor Red
}