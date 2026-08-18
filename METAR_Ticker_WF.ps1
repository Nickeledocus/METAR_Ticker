Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ============================================================================
#  INSTELLINGEN
# ============================================================================
$airports = @(
    [pscustomobject]@{ Name='Rotterdam'; Icao='EHRD' }
    [pscustomobject]@{ Name='Amsterdam'; Icao='EHAM' }
    [pscustomobject]@{ Name='Eindhoven'; Icao='EHEH' }
)
$subjects          = 'Wind','Zicht','Weer','Bewolking','Temp/dauw','Luchtdruk'
$secondsPerSubject = 10
$refreshMinutes    = 10
$fontName          = 'Consolas'
$fontSize          = 14
$winWidth          = 1400
$winHeight         = 300
$deg               = [char]176   # het °-teken (Unicode-nummer 176), coderingsonafhankelijk

# ============================================================================
#  PARSER (zelfde logica als eerder, compact)
# ============================================================================
$cloudAmounts = @{ 'FEW'='licht bewolkt';'SCT'='half bewolkt';'BKN'='zwaar bewolkt';'OVC'='geheel bewolkt' }
$wxDescriptor = @{ 'MI'='ondiepe';'BC'='flarden';'DR'='opwaaiende';'BL'='opgejaagde';'SH'='buien';'TS'='onweer met';'FZ'='onderkoelde' }
$wxPhenomena  = @{ 'DZ'='motregen';'RA'='regen';'SN'='sneeuw';'SG'='motsneeuw';'PL'='ijsregen';'GR'='hagel';'GS'='korrelhagel';'IC'='ijskristallen';'BR'='mist';'FG'='dichte mist';'FU'='rook';'VA'='vulkanische as';'DU'='stof';'SA'='zand';'HZ'='nevel';'PO'='stofhozen';'SQ'='windstoten';'FC'='windhoos';'SS'='zandstorm';'DS'='stofstorm' }

function Translate-Weather([string]$code) {
    $prefix=''
    if     ($code.StartsWith('+'))  { $prefix='zware ';          $code=$code.Substring(1) }
    elseif ($code.StartsWith('-'))  { $prefix='lichte ';         $code=$code.Substring(1) }
    elseif ($code.StartsWith('VC')) { $prefix='in de omgeving '; $code=$code.Substring(2) }
    $parts=@()
    for ($i=0; $i -lt $code.Length; $i+=2) {
        $chunk=$code.Substring($i,[Math]::Min(2,$code.Length-$i))
        if     ($wxDescriptor.ContainsKey($chunk)) { $parts+=$wxDescriptor[$chunk] }
        elseif ($wxPhenomena.ContainsKey($chunk))  { $parts+=$wxPhenomena[$chunk] }
        else   { $parts+=$chunk }
    }
    return ($prefix + ($parts -join ' ')).Trim()
}

function Parse-Metar([string]$Raw) {
    $r=[ordered]@{ Wind='-';Zicht='-';Weer='geen bijzonderheden';Bewolking='-';'Temp/dauw'='-';Luchtdruk='-' }
    $tokens=$Raw -split '\s+'
    if ($tokens[0] -in @('METAR','SPECI')) { $tokens=$tokens[1..($tokens.Count-1)] }
    $clouds=@(); $weather=@()
    foreach ($t in $tokens) {
        switch -regex ($t) {
            '^(\d{3}|VRB)(\d{2,3})(G(\d{2,3}))?(KT|MPS)$' {
                $dir=$Matches[1]; $spd=[int]$Matches[2]
                $gust= if ($Matches[4]) { ", uitschieters $([int]$Matches[4])" } else { "" }
                if     ($t -eq '00000KT') { $r.Wind='windstil' }
                elseif ($dir -eq 'VRB')   { $r.Wind="variabel, $spd kt$gust" }
                else                      { $r.Wind="uit ${dir}$deg, $spd kt$gust" }
                break
            }
            '^CAVOK$'   { $r.Zicht='10 km+ (CAVOK)'; $clouds+='onbewolkt'; break }
            '^(\d{4})$' { if ($t -eq '9999') { $r.Zicht='10 km of meer' } else { $r.Zicht="$([int]$t) m" }; break }
            '^(FEW|SCT|BKN|OVC)(\d{3})(CB|TCU)?$' {
                $x= switch($Matches[3]){ 'CB'{' (onweer)'} 'TCU'{' (buienopbouw)'} default{''} }
                $clouds+="$($cloudAmounts[$Matches[1]]) op $([int]$Matches[2]*100) ft$x"; break
            }
            '^(NSC|NCD|SKC|CLR)$' { $clouds+='geen relevante bewolking'; break }
            '^(M?\d{2})/(M?\d{2})$' {
                $temp=$Matches[1]-replace '^M','-'; $dew=$Matches[2]-replace '^M','-'
                $r.'Temp/dauw'="$([int]$temp)$deg / dauwpunt $([int]$dew)$deg"; break
            }
            '^Q(\d{4})$' { $r.Luchtdruk="$([int]$Matches[1]) hPa"; break }
            '^A(\d{4})$' { $r.Luchtdruk="$([decimal]$Matches[1]/100) inHg"; break }
            '^(\+|-|VC)?(MI|BC|DR|BL|SH|TS|FZ)?(DZ|RA|SN|SG|PL|GR|GS|IC|BR|FG|FU|VA|DU|SA|HZ|PO|SQ|FC|SS|DS)+$' {
                $weather+=(Translate-Weather $t); break
            }
        }
    }
    if ($clouds.Count  -gt 0) { $r.Bewolking=($clouds  -join ' / ') }
    if ($weather.Count -gt 0) { $r.Weer     =($weather -join ', ') }
    return $r
}

function Get-AllMetars([string[]]$Icaos) {
    $url="https://aviationweather.gov/api/data/metar?ids=$($Icaos -join ',')&format=raw"
    $map=@{}
    try {
        $resp=Invoke-RestMethod -Uri $url -Headers @{ 'User-Agent'='METAR-ticker/1.0' } -ErrorAction Stop
        foreach ($line in (([string]$resp) -split "`n" | Where-Object { $_.Trim() -ne '' })) {
            $tk=$line.Trim() -split '\s+'
            if ($tk[0] -in @('METAR','SPECI')) { $tk=$tk[1..($tk.Count-1)] }
            $map[$tk[0]]=$line.Trim()
        }
    } catch { }   # stilletjes falen; het venster toont dan 'geen data'
    return $map
}

# ============================================================================
#  HET VENSTER
# ============================================================================
$form = New-Object System.Windows.Forms.Form
$form.Text            = 'METAR Ticker'
$form.Size            = New-Object System.Drawing.Size($winWidth, $winHeight)
$form.StartPosition   = 'CenterScreen'
$form.BackColor       = [System.Drawing.Color]::FromArgb(15,17,26)
$form.FormBorderStyle = 'FixedSingle'   # zet op 'Sizable' als je 'm wél wil kunnen slepen
$form.MaximizeBox     = $false

$header = New-Object System.Windows.Forms.Label
$header.AutoSize  = $false
$header.SetBounds(0, 12, $form.ClientSize.Width, 44)
$header.Font      = New-Object System.Drawing.Font($fontName, [int]($fontSize*0.8), [System.Drawing.FontStyle]::Bold)
$header.ForeColor = [System.Drawing.Color]::FromArgb(120,200,255)
$header.TextAlign = 'MiddleCenter'
$form.Controls.Add($header)

$body = New-Object System.Windows.Forms.Label
$body.AutoSize  = $false
$body.SetBounds(24, 64, $form.ClientSize.Width-24, $form.ClientSize.Height-72)
$body.Font      = New-Object System.Drawing.Font($fontName, $fontSize)
$body.ForeColor = [System.Drawing.Color]::White
$body.TextAlign = 'MiddleLeft'
$form.Controls.Add($body)

# ============================================================================
#  STATUS + TEKENEN
# ============================================================================
$state        = @{}
$subjectIndex = 0
$lastFetch    = (Get-Date).AddYears(-1)

function Refresh-Data {
    $rawMap = Get-AllMetars -Icaos ($airports.Icao)
    $script:state = @{}
    foreach ($ap in $airports) {
        if ($rawMap.ContainsKey($ap.Icao)) { $script:state[$ap.Icao] = Parse-Metar $rawMap[$ap.Icao] }
        else { $script:state[$ap.Icao] = [ordered]@{ Wind='geen data';Zicht='-';Weer='-';Bewolking='-';'Temp/dauw'='-';Luchtdruk='-' } }
    }
    $script:lastFetch = Get-Date
}

function Render {
    $subject = $subjects[$script:subjectIndex]
    $utc     = (Get-Date).ToUniversalTime().ToString('HH:mm')
    $header.Text = "METAR  -  $utc UTC  -  $subject"
    $lines = foreach ($ap in $airports) {
        $val = if ($script:state[$ap.Icao]) { $script:state[$ap.Icao][$subject] } else { '...' }
        ('{0,-14}{1}' -f "$($ap.Name):", $val)
    }
    $body.Text = ($lines -join "`r`n")
}

# ============================================================================
#  TIMERS  (de motor van de ticker)
# ============================================================================
$subjectTimer = New-Object System.Windows.Forms.Timer
$subjectTimer.Interval = $secondsPerSubject * 1000
$subjectTimer.add_Tick({
    $script:subjectIndex = ($script:subjectIndex + 1) % $subjects.Count
    Render
})

$refreshTimer = New-Object System.Windows.Forms.Timer
$refreshTimer.Interval = 60 * 1000   # elke minuut checken of de data verlopen is
$refreshTimer.add_Tick({
    if ((New-TimeSpan -Start $script:lastFetch -End (Get-Date)).TotalMinutes -ge $refreshMinutes) {
        Refresh-Data
        Render
    }
})

# Eerste keer ophalen zodra het venster er staat (niet ervoor, anders blijft 't zwart)
$form.add_Shown({
    Refresh-Data
    Render
    $subjectTimer.Start()
    $refreshTimer.Start()
})

[void]$form.ShowDialog()
