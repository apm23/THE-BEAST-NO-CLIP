$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
. (Join-Path $RepoRoot "commands\_common.ps1")

Write-Section "POC_01_DEV_MENU_F10 - APPLY"

if (Get-Process -Name $script:ProcessName -ErrorAction SilentlyContinue) {
    throw "Tutup DLTB dulu. inputs_keyboard.scr dibaca saat startup."
}

$game = Find-DLTB
$source = Join-Path $game "ph_ft\source"
$data7 = Join-Path $source "data7.pak"
$entryPath = "scripts/inputs/inputs_keyboard.scr"

$localRoot = Join-Path $env:LOCALAPPDATA "TBP\THE-BEAST-NO-CLIP"
$stateRoot = Join-Path $localRoot "POC_01_DEV_MENU_F10"
$stateFile = Join-Path $stateRoot "state.json"
$backup = Join-Path $stateRoot "data7.before.pak"
$activeClean = Join-Path $localRoot "ACTIVE_CLEAN.ps1"

if (Test-Path $stateFile) {
    throw "POC_01 sudah installed. Jalankan 2_CLEAN.cmd dulu."
}

New-Item -ItemType Directory -Force -Path $stateRoot | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Read-PakText([string]$Pak,[string]$Wanted) {
    if (-not (Test-Path $Pak)) { return $null }
    $zip=[System.IO.Compression.ZipFile]::OpenRead($Pak)
    try {
        $want=($Wanted -replace '\\','/').ToLowerInvariant()
        foreach($e in $zip.Entries) {
            $n=($e.FullName -replace '\\','/').ToLowerInvariant()
            if($n -eq $want) {
                $s=$e.Open()
                try {
                    $r=New-Object System.IO.StreamReader($s,[System.Text.Encoding]::UTF8,$true)
                    try { return $r.ReadToEnd() } finally { $r.Dispose() }
                } finally { $s.Dispose() }
            }
        }
        return $null
    } finally { $zip.Dispose() }
}

$effectiveText=$null
$effectiveSlot=-1
foreach($n in 0..7) {
    $pak=Join-Path $source ("data{0}.pak" -f $n)
    if(-not (Test-Path $pak)) { continue }
    $txt=Read-PakText $pak $entryPath
    if($null -ne $txt) {
        $effectiveText=$txt
        $effectiveSlot=$n
    }
}
if($null -eq $effectiveText) { throw "inputs_keyboard.scr tidak ditemukan." }

$lines=$effectiveText -split "(?<=\n)"
$changed=0
for($i=0;$i -lt $lines.Count;$i++) {
    if($lines[$i] -match "_ACTION_DEVELOPER_MENU") {
        if($lines[$i] -match "EKey__MULTIPLY") {
            $lines[$i]=$lines[$i] -replace "EKey__MULTIPLY","EKey__F10"
            $changed++
        } elseif($lines[$i] -match "EKey__F10") {
            throw "Developer menu sudah bind ke F10."
        }
    }
}
if($changed -ne 1) {
    throw "Expected exactly 1 developer-menu bind; changed=$changed. STOP aman."
}
$patched=[string]::Concat($lines)

$data7Existed=Test-Path $data7
if($data7Existed) { Copy-Item $data7 $backup -Force }

$tmp=Join-Path $source ".data7.poc01.tmp"
if(Test-Path $tmp) { Remove-Item $tmp -Force }

$outFs=[System.IO.File]::Open($tmp,[System.IO.FileMode]::CreateNew)
try {
    $outZip=New-Object System.IO.Compression.ZipArchive($outFs,[System.IO.Compression.ZipArchiveMode]::Create,$false)
    try {
        if($data7Existed) {
            $inZip=[System.IO.Compression.ZipFile]::OpenRead($data7)
            try {
                $want=$entryPath.ToLowerInvariant()
                foreach($e in $inZip.Entries) {
                    $norm=($e.FullName -replace '\\','/').ToLowerInvariant()
                    if($norm -eq $want) { continue }
                    $ne=$outZip.CreateEntry(($e.FullName -replace '\\','/'),[System.IO.Compression.CompressionLevel]::Optimal)
                    $src=$e.Open()
                    $dst=$ne.Open()
                    try { $src.CopyTo($dst) } finally { $dst.Dispose(); $src.Dispose() }
                }
            } finally { $inZip.Dispose() }
        }

        $newEntry=$outZip.CreateEntry($entryPath,[System.IO.Compression.CompressionLevel]::Optimal)
        $stream=$newEntry.Open()
        try {
            $bytes=[System.Text.UTF8Encoding]::new($false).GetBytes($patched)
            $stream.Write($bytes,0,$bytes.Length)
        } finally { $stream.Dispose() }
    } finally { $outZip.Dispose() }
} finally { $outFs.Dispose() }

Move-Item $tmp $data7 -Force

$verify=Read-PakText $data7 $entryPath
if($verify -notmatch "_ACTION_DEVELOPER_MENU" -or $verify -notmatch "EKey__F10") {
    if($data7Existed -and (Test-Path $backup)) { Copy-Item $backup $data7 -Force }
    elseif(-not $data7Existed -and (Test-Path $data7)) { Remove-Item $data7 -Force }
    throw "Post-check gagal; data7 direstore."
}

$state=[ordered]@{
    candidate="POC_01_DEV_MENU_F10"
    game_path=$game
    data7_path=$data7
    data7_existed=$data7Existed
    effective_source_slot=$effectiveSlot
    installed_at=(Get-Date).ToString("o")
}
$state | ConvertTo-Json -Depth 4 | Set-Content -Encoding UTF8 $stateFile

Copy-Item (Join-Path $PSScriptRoot "CLEAN.ps1") $activeClean -Force

Write-Host ""
Write-Host "APPLY PASS"
Write-Host "Effective source before patch: data$effectiveSlot.pak"
Write-Host "Developer menu key: NumPad * -> F10"
Write-Host "Existing data7/GH1 content preserved."
Write-Host ""
Write-Host "Start DLTB lalu tekan F10 sekali."
