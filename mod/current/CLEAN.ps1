$ErrorActionPreference = "Stop"

$localRoot = Join-Path $env:LOCALAPPDATA "TBP\THE-BEAST-NO-CLIP"
$stateRoot = Join-Path $localRoot "POC_01_DEV_MENU_F10"
$stateFile = Join-Path $stateRoot "state.json"
$backup = Join-Path $stateRoot "data7.before.pak"
$activeClean = Join-Path $localRoot "ACTIVE_CLEAN.ps1"

Write-Host "============================================================"
Write-Host "POC_01_DEV_MENU_F10 - CLEAN"
Write-Host "============================================================"

if(-not (Test-Path $stateFile)) {
    Write-Host "POC_01 tidak ditandai installed."
    exit 0
}

$state=Get-Content $stateFile -Raw | ConvertFrom-Json
if(Get-Process -Name "DyingLightGame_TheBeast_x64_rwdi" -ErrorAction SilentlyContinue) {
    throw "Tutup DLTB dulu sebelum CLEAN."
}

$data7=[string]$state.data7_path
if([bool]$state.data7_existed) {
    if(-not (Test-Path $backup)) { throw "Backup data7 hilang; STOP aman." }
    Copy-Item $backup $data7 -Force
    Write-Host "Exact pre-POC data7 restored."
} else {
    if(Test-Path $data7) { Remove-Item $data7 -Force }
    Write-Host "POC-created data7 removed."
}

if(Test-Path $stateRoot) { Remove-Item $stateRoot -Recurse -Force }
if(Test-Path $activeClean) { Remove-Item $activeClean -Force -ErrorAction SilentlyContinue }

Write-Host "CLEAN PASS"
