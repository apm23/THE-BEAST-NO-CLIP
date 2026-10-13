$ErrorActionPreference = "Stop"

$script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$script:RepoName = "apm23/THE-BEAST-NO-CLIP"
$script:ProcessName = "DyingLightGame_TheBeast_x64_rwdi"
$script:ProcessExe = "DyingLightGame_TheBeast_x64_rwdi.exe"
$script:GameDll = "gamedll_ph_x64_rwdi.dll"
$script:AppId = "3008130"

function Write-Section([string]$Text) {
    Write-Host ""
    Write-Host ("=" * 72)
    Write-Host $Text
    Write-Host ("=" * 72)
}

function Assert-Tool([string]$Name, [string]$InstallHint) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "$Name is required. $InstallHint"
    }
}

function Ensure-GitHubAuth {
    Assert-Tool "gh" "Install with: winget install --id GitHub.cli"
    & gh auth status *> $null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "GitHub login is required once. Opening browser login..."
        & gh auth login --hostname github.com --git-protocol https --web
        if ($LASTEXITCODE -ne 0) { throw "GitHub login failed." }
    }
    & gh auth setup-git *> $null
}

function Find-DLTB {
    $roots = New-Object System.Collections.Generic.List[string]

    foreach ($pair in @(
        @("HKCU:\Software\Valve\Steam","SteamPath"),
        @("HKLM:\SOFTWARE\WOW6432Node\Valve\Steam","InstallPath"),
        @("HKLM:\SOFTWARE\Valve\Steam","InstallPath")
    )) {
        try {
            $v = (Get-ItemProperty -Path $pair[0] -Name $pair[1] -ErrorAction Stop).($pair[1])
            if ($v) { $roots.Add($v) }
        } catch {}
    }

    foreach ($r in @(
        "$env:ProgramFiles(x86)\Steam",
        "$env:ProgramFiles\Steam",
        "C:\Steam"
    )) {
        if ($r -and (Test-Path $r)) { $roots.Add($r) }
    }

    $libs = New-Object System.Collections.Generic.List[string]
    foreach ($root in ($roots | Select-Object -Unique)) {
        if (Test-Path $root) { $libs.Add($root) }
        $vdf = Join-Path $root "steamapps\libraryfolders.vdf"
        if (Test-Path $vdf) {
            $raw = Get-Content $vdf -Raw
            [regex]::Matches($raw, '"path"\s*"([^"]+)"') | ForEach-Object {
                $p = $_.Groups[1].Value -replace '\\\\','\'
                if (Test-Path $p) { $libs.Add($p) }
            }
        }
    }

    $games = @()
    foreach ($lib in ($libs | Select-Object -Unique)) {
        $g = Join-Path $lib "steamapps\common\Dying Light The Beast"
        if (Test-Path (Join-Path $g "ph_ft\source\data0.pak")) { $games += $g }
    }

    $games = $games | Select-Object -Unique
    if ($games.Count -ne 1) {
        throw "Expected exactly one DLTB installation, found $($games.Count)."
    }
    return $games[0]
}

function Sanitize-Text([string]$Text) {
    if (-not $Text) { return $Text }
    $u = [Environment]::GetFolderPath("UserProfile")
    if ($u) { $Text = $Text.Replace($u, "%USERPROFILE%") }
    return $Text
}

function Push-RunFolder([string]$RelativeFolder, [string]$Message) {
    Ensure-GitHubAuth
    Push-Location $script:RepoRoot
    try {
        & git pull --rebase --autostash origin main
        if ($LASTEXITCODE -ne 0) { throw "git pull failed." }

        & git add -- $RelativeFolder
        $changed = & git status --porcelain -- $RelativeFolder
        if (-not $changed) {
            Write-Host "Nothing new to upload."
            return
        }

        & git commit -m $Message
        if ($LASTEXITCODE -ne 0) { throw "git commit failed." }

        & git push origin main
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Push raced with a remote update; rebasing once and retrying..."
            & git pull --rebase origin main
            if ($LASTEXITCODE -ne 0) { throw "git pull --rebase retry failed." }
            & git push origin main
            if ($LASTEXITCODE -ne 0) { throw "git push retry failed." }
        }
    } finally {
        Pop-Location
    }
}
