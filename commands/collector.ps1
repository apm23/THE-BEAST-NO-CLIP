. "$PSScriptRoot\_common.ps1"

Write-Section "THE BEAST NO-CLIP — COLLECTOR"

$game = Find-DLTB
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$rel = "data/runs/$stamp"
$out = Join-Path $script:RepoRoot $rel
New-Item -ItemType Directory -Force -Path $out | Out-Null

$exe = Join-Path $game "ph_ft\work\bin\x64\DyingLightGame_TheBeast_x64_rwdi.exe"
$dll = Join-Path $game "ph_ft\work\bin\x64\gamedll_ph_x64_rwdi.dll"
$proc = Get-Process -Name $script:ProcessName -ErrorAction SilentlyContinue | Select-Object -First 1

$report = New-Object System.Collections.Generic.List[string]
$report.Add("# No-Clip Collector Run $stamp")
$report.Add("")
$report.Add("- Game: " + (Sanitize-Text $game))
$report.Add("- Process running: " + [bool]$proc)
if ($proc) {
    $report.Add("- PID: " + $proc.Id)
    $report.Add("- Working set: " + $proc.WorkingSet64)
}
$report.Add("")

foreach ($p in @($exe,$dll)) {
    if (Test-Path $p) {
        $fi = Get-Item $p
        $hash = (Get-FileHash $p -Algorithm SHA256).Hash
        $report.Add("## " + $fi.Name)
        $report.Add("- Size: " + $fi.Length)
        $report.Add("- LastWriteTimeUtc: " + $fi.LastWriteTimeUtc.ToString("o"))
        $report.Add("- SHA256: " + $hash)
        $report.Add("")
    }
}

$source = Join-Path $game "ph_ft\source"
$report.Add("## Loaded data*.pak files")
Get-ChildItem $source -Filter "data*.pak" -File |
    Sort-Object Name |
    ForEach-Object {
        $h = (Get-FileHash $_.FullName -Algorithm SHA256).Hash
        $report.Add("- $($_.Name) | $($_.Length) bytes | $h")
    }

if ($proc) {
    $report.Add("")
    $report.Add("## Process modules")
    try {
        $mods = $proc.Modules | Sort-Object ModuleName
        foreach ($m in $mods) {
            $path = Sanitize-Text $m.FileName
            $report.Add(("- {0} | base=0x{1:X} | size={2} | {3}" -f $m.ModuleName,$m.BaseAddress.ToInt64(),$m.ModuleMemorySize,$path))
        }
    } catch {
        $report.Add("- Module enumeration failed: " + $_.Exception.Message)
        $report.Add("- If live module bases are needed later, run the CMD as Administrator.")
    }
}


# ---------------------------------------------------------------------------
# Phase 1 targeted scan: native/effective developer hotkey definitions.
# Text snippets only; do NOT upload whole game scripts.
# ---------------------------------------------------------------------------

Add-Type -AssemblyName System.IO.Compression.FileSystem

function Get-PakEntryText([string]$PakPath, [string]$EntryPath) {
    if (-not (Test-Path $PakPath)) { return $null }
    $zip = [System.IO.Compression.ZipFile]::OpenRead($PakPath)
    try {
        $want = ($EntryPath -replace '\\','/').ToLowerInvariant()
        foreach ($e in $zip.Entries) {
            $name = ($e.FullName -replace '\\','/').ToLowerInvariant()
            if ($name -eq $want) {
                $s = $e.Open()
                try {
                    $r = New-Object System.IO.StreamReader($s, [System.Text.Encoding]::UTF8, $true)
                    try { return $r.ReadToEnd() } finally { $r.Dispose() }
                } finally { $s.Dispose() }
            }
        }
        return $null
    } finally {
        $zip.Dispose()
    }
}

function Find-EffectiveEntry([string]$EntryPath) {
    $best = $null
    foreach ($n in 0..7) {
        $pak = Join-Path $source ("data{0}.pak" -f $n)
        if (-not (Test-Path $pak)) { continue }
        $txt = Get-PakEntryText $pak $EntryPath
        if ($null -ne $txt) {
            $best = [pscustomobject]@{ Slot=$n; Pak=$pak; Text=$txt }
        }
    }
    return $best
}

function Get-MatchSnippets([string]$Label, [string]$Text) {
    $lines = $Text -split "\r?\n"
    $rx = '(?i)(noclip|no[_ -]?clip|EKey__Y|free.?cam|free.?camera|third.?person|\btpp\b|teleport|debug|developer|ghost|collision|EKey__PAUSE|EKey__SCROLL|EKey__F1\b|EKey__PGUP|EKey__PGDOWN|page.?up|page.?down|camera)'
    $hits = New-Object System.Collections.Generic.List[int]

    for ($i=0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match $rx) { $hits.Add($i) }
    }

    $ranges = @()
    foreach ($i in $hits) {
        $a = [Math]::Max(0, $i-2)
        $b = [Math]::Min($lines.Count-1, $i+2)
        if ($ranges.Count -gt 0 -and $a -le ($ranges[-1].B + 1)) {
            if ($b -gt $ranges[-1].B) { $ranges[-1].B = $b }
        } else {
            $ranges += [pscustomobject]@{ A=$a; B=$b }
        }
    }

    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine("## $Label")
    [void]$sb.AppendLine("- total lines: $($lines.Count)")
    [void]$sb.AppendLine("- raw matches: $($hits.Count)")
    [void]$sb.AppendLine("")

    $emitted = 0
    foreach ($r in $ranges) {
        if ($emitted -ge 240) {
            [void]$sb.AppendLine("... output capped at 240 snippet lines ...")
            break
        }
        [void]$sb.AppendLine("[BEGIN SNIPPET]")
        for ($j=$r.A; $j -le $r.B; $j++) {
            [void]$sb.AppendLine(("{0,5}: {1}" -f ($j+1), $lines[$j]))
            $emitted++
            if ($emitted -ge 240) { break }
        }
        [void]$sb.AppendLine("[END SNIPPET]")
        [void]$sb.AppendLine("")
    }
    return $sb.ToString()
}

$scan = New-Object System.Text.StringBuilder
[void]$scan.AppendLine("# Native Developer Hotkey Scan — $stamp")
[void]$scan.AppendLine("")
[void]$scan.AppendLine("Target: independently inspect the game's own input scripts. No third-party mod assets copied.")
[void]$scan.AppendLine("")

$kbPath = "scripts/inputs/inputs_keyboard.scr"
$enumPath = "scripts/inputs/inputenums.def"

$data0 = Join-Path $source "data0.pak"
$vanillaKB = Get-PakEntryText $data0 $kbPath
$effectiveKB = Find-EffectiveEntry $kbPath
$vanillaEnum = Get-PakEntryText $data0 $enumPath
$effectiveEnum = Find-EffectiveEntry $enumPath

if ($vanillaKB) {
    [void]$scan.AppendLine((Get-MatchSnippets "data0 vanilla inputs_keyboard.scr" $vanillaKB))
} else {
    [void]$scan.AppendLine("## data0 vanilla inputs_keyboard.scr")
    [void]$scan.AppendLine("NOT FOUND")
    [void]$scan.AppendLine("")
}

if ($effectiveKB) {
    [void]$scan.AppendLine("## Effective keyboard source")
    [void]$scan.AppendLine("- slot: data$($effectiveKB.Slot).pak")
    [void]$scan.AppendLine("- pak: " + (Sanitize-Text $effectiveKB.Pak))
    [void]$scan.AppendLine("")
    [void]$scan.AppendLine((Get-MatchSnippets "effective inputs_keyboard.scr" $effectiveKB.Text))
} else {
    [void]$scan.AppendLine("## Effective inputs_keyboard.scr")
    [void]$scan.AppendLine("NOT FOUND")
    [void]$scan.AppendLine("")
}

if ($vanillaEnum) {
    [void]$scan.AppendLine((Get-MatchSnippets "data0 vanilla inputenums.def" $vanillaEnum))
}

if ($effectiveEnum) {
    [void]$scan.AppendLine("## Effective enum source")
    [void]$scan.AppendLine("- slot: data$($effectiveEnum.Slot).pak")
    [void]$scan.AppendLine("- pak: " + (Sanitize-Text $effectiveEnum.Pak))
    [void]$scan.AppendLine("")
    [void]$scan.AppendLine((Get-MatchSnippets "effective inputenums.def" $effectiveEnum.Text))
}

$scan.ToString() | Set-Content -Encoding UTF8 (Join-Path $out "INPUT_DEV_HOTKEY_SCAN.md")

$master = Join-Path $script:RepoRoot "MASTER_STATE.md"
if (Test-Path $master) {
    Copy-Item $master (Join-Path $out "MASTER_STATE_AT_RUN.md")
}

($report -join [Environment]::NewLine) | Set-Content -Encoding UTF8 (Join-Path $out "REPORT.md")

$meta = [ordered]@{
    timestamp = $stamp
    process_running = [bool]$proc
    pid = if ($proc) { $proc.Id } else { $null }
    process = $script:ProcessExe
    dll = $script:GameDll
    appid = $script:AppId
}
$meta | ConvertTo-Json -Depth 4 | Set-Content -Encoding UTF8 (Join-Path $out "run.json")

Write-Host "Collector output:" $rel
Push-RunFolder $rel "collector: no-clip baseline $stamp"
Write-Host ""
Write-Host "UPLOAD PASS. Tell ChatGPT: read the newest data/runs folder."
