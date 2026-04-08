@echo off
title AnyDesk Tool
chcp 65001 >nul
setlocal enabledelayedexpansion

:menu
cls
echo ======================================
echo         AnyDesk Management Tool
echo ======================================
echo.
echo 1. Check license status
echo 2. Get AnyDesk ID
echo 3. Reset activation (full cleanup)
echo 4. Exit
echo 5. Get AnyDesk version
echo 6. Ping Google and Yandex
echo 7. Get my IP address
echo.
set /p choice="Select option (1-7): "

if "%choice%"=="1" goto check_license
if "%choice%"=="2" goto get_id
if "%choice%"=="3" goto reset_anydesk
if "%choice%"=="4" exit
if "%choice%"=="5" goto get_version
if "%choice%"=="6" goto ping_sites
if "%choice%"=="7" goto get_ip
echo Invalid choice. Try again.
timeout /t 2 >nul
goto menu

:check_license
cls
echo ======================================
echo         License Status
echo ======================================
echo.

set LICENSE_STATUS=Free

reg query "HKEY_CURRENT_USER\Software\AnyDesk" /v "LicenseKey" 2>nul | findstr /i "PROFESSIONAL" >nul
if %errorlevel%==0 set LICENSE_STATUS=Professional

reg query "HKEY_CURRENT_USER\Software\AnyDesk" /v "LicenseKey" 2>nul | findstr /i "POWER" >nul
if %errorlevel%==0 set LICENSE_STATUS=Power

if exist "%appdata%\AnyDesk\user.conf" (
    findstr /i "Professional" "%appdata%\AnyDesk\user.conf" >nul 2>nul
    if %errorlevel%==0 set LICENSE_STATUS=Professional
    
    findstr /i "Power" "%appdata%\AnyDesk\user.conf" >nul 2>nul
    if %errorlevel%==0 set LICENSE_STATUS=Power
)

if exist "%programdata%\AnyDesk\system.conf" (
    findstr /i "Professional" "%programdata%\AnyDesk\system.conf" >nul 2>nul
    if %errorlevel%==0 set LICENSE_STATUS=Professional
    
    findstr /i "Power" "%programdata%\AnyDesk\system.conf" >nul 2>nul
    if %errorlevel%==0 set LICENSE_STATUS=Power
)

echo.
echo Current license: %LICENSE_STATUS%
echo.

echo ======================================
echo Press any key to return to menu...
pause >nul
goto menu

:get_id
cls
echo ======================================
echo         AnyDesk ID
echo ======================================
echo.

set ANYDESK_ID=Unknown

if exist "%programdata%\AnyDesk\system.conf" (
    for /f "tokens=2 delims==" %%a in ('findstr /i "ad.anynet.id" "%programdata%\AnyDesk\system.conf" 2^>nul') do set ANYDESK_ID=%%a
)

if "%ANYDESK_ID%"=="Unknown" (
    if exist "%programdata%\AnyDesk\service.conf" (
        for /f "tokens=2 delims==" %%a in ('findstr /i "ad.anynet.id" "%programdata%\AnyDesk\service.conf" 2^>nul') do set ANYDESK_ID=%%a
    )
)

if "%ANYDESK_ID%"=="Unknown" (
    for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Wow6432Node\AnyDesk" /v "ClientID" 2^>nul') do set ANYDESK_ID=%%a
)

echo Your AnyDesk ID: %ANYDESK_ID%
echo.

echo ======================================
echo Press any key to return to menu...
pause >nul
goto menu

:reset_anydesk
cls
echo ======================================
echo         Resetting AnyDesk Activation
echo ======================================
echo.

echo [1/7] Killing AnyDesk process...
taskkill /IM AnyDesk.exe /f >nul 2>nul
if %errorlevel%==0 (echo OK) else (echo Not running)

echo [2/7] Deleting files from %%programdata%%...
if exist "%programdata%\anydesk" (
    del "%programdata%\anydesk\*.*" /q /f >nul 2>nul
    echo OK
) else (echo Folder not found)

echo [3/7] Creating backup folder...
if not exist "%programdata%\anydesk\backup" md "%programdata%\anydesk\backup" >nul 2>nul
echo OK

echo [4/7] Backing up user.conf...
if exist "%appdata%\anydesk\user.conf" (
    copy "%appdata%\anydesk\user.conf" "%programdata%\anydesk\backup\user.conf" /Y >nul
    echo OK
) else (echo File not found, skipping)

echo [5/7] Cleaning %%appdata%% folder...
if exist "%appdata%\anydesk" (
    del "%appdata%\anydesk\*.*" /q /f >nul 2>nul
    echo OK
) else (echo Folder not found)

echo [6/7] Starting AnyDesk to apply reset...
start "" "%ProgramFiles(x86)%\AnyDesk\AnyDesk.exe"
timeout /t 5 >nul

echo [7/7] Restoring user.conf and restarting...
taskkill /IM AnyDesk.exe /f >nul 2>nul
if exist "%programdata%\anydesk\backup\user.conf" (
    copy "%programdata%\anydesk\backup\user.conf" "%appdata%\anydesk\user.conf" /Y >nul
    echo user.conf restored
)
start "" "%ProgramFiles(x86)%\AnyDesk\AnyDesk.exe"

echo.
echo ======================================
echo Reset completed successfully!
echo ======================================
echo Press any key to return to menu...
pause >nul
goto menu

:get_version
cls
echo ======================================
echo         AnyDesk Version
echo ======================================
echo.

:: Просто выполняем команду WMIC и выводим результат
wmic datafile where "name='C:\\Program Files (x86)\\AnyDesk\\AnyDesk.exe'" get Version

echo.
echo ======================================
echo Press any key to return to menu...
pause >nul
goto menu

:ping_sites
cls
echo ======================================
echo         Ping Google and Yandex
echo ======================================
echo.

echo Pinging Google (8.8.8.8)...
ping -n 4 8.8.8.8
echo.
echo Pinging Yandex (77.88.8.8)...
ping -n 4 77.88.8.8
echo.
echo Pinging google.com...
ping -n 4 google.com
echo.
echo Pinging yandex.ru...
ping -n 4 yandex.ru

echo.
echo ======================================
echo Press any key to return to menu...
pause >nul
goto menu

:get_ip
cls
echo ======================================
echo         My IP Address
echo ======================================
echo.

echo Local IP Addresses:
ipconfig | findstr "IPv4"
echo.

echo Public IP Address:
powershell -Command "(Invoke-WebRequest -Uri 'https://api.ipify.org' -UseBasicParsing).Content" 2>nul

echo.
echo ======================================
echo Press any key to return to menu...
pause >nul
goto menu