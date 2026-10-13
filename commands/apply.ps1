. "$PSScriptRoot\_common.ps1"

Write-Section "THE BEAST NO-CLIP — APPLY"

$current = Join-Path $script:RepoRoot "mod\current"
$apply = Join-Path $current "APPLY.ps1"
$meta = Join-Path $current "CANDIDATE.json"

if (-not (Test-Path $apply)) {
    Write-Host "There is no current candidate yet."
    Write-Host "ChatGPT will place the next POC in mod/current/ when ready."
    exit 0
}

if (Test-Path $meta) {
    Write-Host "Candidate:"
    Get-Content $meta
    Write-Host ""
}

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $apply
if ($LASTEXITCODE -ne 0) { throw "Candidate APPLY failed." }

Write-Host ""
Write-Host "APPLY PASS."
