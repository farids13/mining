@echo off
setlocal EnableExtensions

:menu
cls
echo =====================================
echo Mining Portable Launcher
echo Repo  : %~dp0..\..
echo =====================================
echo [1] Start CPU miner
echo [2] Start GPU miner
echo [3] Start CPU + GPU
echo [4] Enable autostart
echo [5] Disable autostart
echo [q] Exit
echo =====================================
set /p "CHOICE=Pilih menu: "

if /I "%CHOICE%"=="1" call "%~dp0start-profile.cmd" cpu
if /I "%CHOICE%"=="2" call "%~dp0start-profile.cmd" gpu
if /I "%CHOICE%"=="3" call "%~dp0start-profile.cmd" both
if /I "%CHOICE%"=="4" powershell -ExecutionPolicy Bypass -File "%~dp0enable-autostart.ps1"
if /I "%CHOICE%"=="5" powershell -ExecutionPolicy Bypass -File "%~dp0disable-autostart.ps1"
if /I "%CHOICE%"=="q" exit /b 0

pause
goto :menu

