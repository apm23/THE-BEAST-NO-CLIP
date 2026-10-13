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
