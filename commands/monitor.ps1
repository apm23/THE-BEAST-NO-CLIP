. "$PSScriptRoot\_common.ps1"

Write-Section "THE BEAST NO-CLIP — MONITOR"

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$rel = "monitor/runs/$stamp"
$out = Join-Path $script:RepoRoot $rel
New-Item -ItemType Directory -Force -Path $out | Out-Null
$log = Join-Path $out "monitor.log"

"timestamp,event,pid,cpu_s,working_set" | Set-Content -Encoding UTF8 $log

Write-Host "Waiting for DLTB. Press Ctrl+C to stop and upload."
$proc = $null
while (-not $proc) {
    $proc = Get-Process -Name $script:ProcessName -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $proc) { Start-Sleep -Seconds 1 }
}

Write-Host "Monitoring PID" $proc.Id

try {
    while (-not $proc.HasExited) {
        $proc.Refresh()
        $line = "{0},alive,{1},{2},{3}" -f (Get-Date -Format "o"),$proc.Id,$proc.CPU,$proc.WorkingSet64
        Add-Content -Encoding UTF8 $log $line
        Start-Sleep -Seconds 1
    }
} finally {
    Add-Content -Encoding UTF8 $log ("{0},stopped,{1},," -f (Get-Date -Format "o"),$proc.Id)
    $master = Join-Path $script:RepoRoot "MASTER_STATE.md"
    if (Test-Path $master) { Copy-Item $master (Join-Path $out "MASTER_STATE_AT_RUN.md") }
    Push-RunFolder $rel "monitor: no-clip run $stamp"
    Write-Host "MONITOR UPLOAD PASS:" $rel
}

# Initial minimal monitor. This remote file can later become an exact position/physics trace.
