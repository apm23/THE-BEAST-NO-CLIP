@echo off
setlocal EnableExtensions
title THE BEAST NO-CLIP - GITHUB LOGIN

echo ============================================================
echo THE BEAST NO-CLIP - ONE TIME GITHUB LOGIN
echo ============================================================
echo.

where gh.exe >nul 2>&1
if errorlevel 1 (
    echo [STOP] GitHub CLI ^(gh^) belum ditemukan.
    echo Install:
    echo   winget install --id GitHub.cli -e
    echo.
    pause
    exit /b 1
)

set "CHROME="
for %%P in (
    "%ProgramFiles%\Google\Chrome\Application\chrome.exe"
    "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
    "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
) do (
    if exist "%%~P" (
        set "CHROME=%%~P"
        goto :FOUND_CHROME
    )
)

:FOUND_CHROME
if defined CHROME (
    set "GH_BROWSER=%CHROME%"
    echo [BROWSER] Chrome: %CHROME%
) else (
    echo [BROWSER] Chrome tidak ditemukan. GH akan pakai default browser.
)

echo.
echo [LOGIN] GitHub akan membuka browser.
echo         Kalau muncul kode, copy kode itu ke halaman GitHub lalu Approve.
echo.
gh auth login --hostname github.com --git-protocol https --web
if errorlevel 1 goto :FAIL

echo.
echo [SETUP] Menghubungkan Git ke login GitHub...
gh auth setup-git
if errorlevel 1 goto :FAIL

echo.
echo [CHECK]
gh auth status
if errorlevel 1 goto :FAIL

echo.
echo ============================================================
echo [PASS] LOGIN SELESAI
echo Sekarang jalankan lagi 1_COLLECTOR.cmd
echo ============================================================
echo.
pause
exit /b 0

:FAIL
echo.
echo ============================================================
echo [FAIL] Login/setup GitHub gagal.
echo Coba jalankan CMD ini lagi.
echo ============================================================
echo.
pause
exit /b 1
