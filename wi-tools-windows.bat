@echo off
setlocal enabledelayedexpansion

:: Administrative privileges verification check
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Error: High integrity administrative token required. Run as Administrator.
    pause
    exit /b
)

set "PRESET_FILE=%USERPROFILE%\unified_ping_presets.txt"

:menu
cls
echo ==================================================
echo           UNIFIED NETWORK UTILITIES (WINDOWS)
echo ==================================================
echo 1] Check Ping and Monitor Connection Loop
echo 2] Switch DNS Provider
echo 3] Reset Network Adapter Manually
echo 4] Exit
echo ==================================================
set /p choice="Choose an option [1-4]: "

if "%choice%"=="1" goto select_target
if "%choice%"=="2" goto dns_changer
if "%choice%"=="3" goto manual_reset
if "%choice%"=="4" exit /b
goto menu

:select_target
cls
echo --- TARGET PRESETS ---
echo 1] Google Core Server (8.8.8.8)
echo 2] Cloudflare Core Server (1.1.1.1)
echo 3] OpenDNS Root (208.67.222.222)
echo 4] Custom Address (Manual Entry)
if exist "!PRESET_FILE!" (
    set /p custom_preset=<"!PRESET_FILE!"
    echo 5] User Custom Preset ^(Saved: !custom_preset!^)
)
echo ==================================================
set /p target_choice="Select monitoring target: "

if "%target_choice%"=="1" set domain=8.8.8.8
if "%target_choice%"=="2" set domain=1.1.1.1
if "%target_choice%"=="3" set domain=208.67.222.222
if "%target_choice%"=="4" (
    set /p domain="Enter custom address: "
    set /p save_pref="Save this target as your persistent preset? [y/n]: "
    if "!save_pref!"=="y" (
        echo !domain!>"!PRESET_FILE!"
        echo Preset saved.
        timeout /t 1 >nul
    )
)
if "%target_choice%"=="5" (
    if exist "!PRESET_FILE!" (
        set /p domain=<"!PRESET_FILE!"
    ) else (
        set domain=8.8.8.8
    )
)
if "%domain%"=="" set domain=8.8.8.8
goto ping_checker

:ping_checker
cls
echo --- CONNECTION MONITORING MODE ---
echo Monitoring link connection via !domain!. Press [CTRL+C] to exit.
:loop
ping -n 1 -w 2000 !domain! | find "TTL=" >nul
if %errorlevel% equ 0 (
    echo [%time%] - Link verification: OK
    timeout /t 5 >nul
    goto loop
) else (
    echo Warning: Connection timeout detected. Resetting interface adapters...
    call :adapter_reset_logic
    echo Adapter cycle completed. Verifying recovery stability link...
    timeout /t 15
    goto loop
)

:manual_reset
cls
echo Initializing forced hardware interface recycling...
call :adapter_reset_logic
echo Success: Operation complete.
pause
goto menu

:adapter_reset_logic
ipconfig /release >nul 2>&1
ipconfig /renew >nul 2>&1
for /f "skip=2 tokens=4*" %%A in ('netsh interface show interface') do (
    netsh interface set interface name="%%B" admin=disabled >nul 2>&1
    timeout /t 1 >nul
    netsh interface set interface name="%%B" admin=enabled >nul 2>&1
)
ipconfig /flushdns >nul 2>&1
exit /b

:dns_changer
cls
echo --- DNS ASSIGNMENT PROFILES ---
echo 1] Cloudflare DNS (1.1.1.1 / 1.0.0.1)
echo 2] Google DNS (8.8.8.8 / 8.8.4.4)
echo 3] Quad9 DNS (9.9.9.9 / 149.112.112.112)
echo 4] Custom DNS Specification
echo 5] Return to Main Menu
set /p dns_choice="Select item: "

if "%dns_choice%"=="5" goto menu
if "%dns_choice%"=="1" (set prim=1.1.1.1& set sec=1.0.0.1)
if "%dns_choice%"=="2" (set prim=8.8.8.8& set sec=8.8.4.4)
if "%dns_choice%"=="3" (set prim=9.9.9.9& set sec=149.112.112.112)
if "%dns_choice%"=="4" (
    set /p prim="Primary Value: "
    set /p sec="Secondary Value: "
)

for /f "skip=2 tokens=4*" %%A in ('netsh interface show interface') do (
    netsh interface ip set dns name="%%B" static %prim% >nul 2>&1
    netsh interface ip add dns name="%%B" %sec% index=2 >nul 2>&1
)

echo Success: DNS configurations applied to active connection devices.
pause
goto menu
