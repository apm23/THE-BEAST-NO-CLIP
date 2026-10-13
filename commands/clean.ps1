. "$PSScriptRoot\_common.ps1"

Write-Section "THE BEAST NO-CLIP — CLEAN"

$localState = Join-Path $env:LOCALAPPDATA "TBP\THE-BEAST-NO-CLIP"
$activeClean = Join-Path $localState "ACTIVE_CLEAN.ps1"
$currentClean = Join-Path $script:RepoRoot "mod\current\CLEAN.ps1"

if (Test-Path $activeClean) {
    Write-Host "Running cleaner saved by the installed candidate..."
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $activeClean
    if ($LASTEXITCODE -ne 0) { throw "Active cleaner failed." }
    exit 0
}

if (Test-Path $currentClean) {
    Write-Host "No local active cleaner. Running current candidate cleaner..."
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $currentClean
    if ($LASTEXITCODE -ne 0) { throw "Current candidate cleaner failed." }
    exit 0
}

Write-Host "Nothing is marked as installed. CLEAN has nothing to do."
