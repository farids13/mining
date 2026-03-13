@echo off
setlocal EnableExtensions

set "PROFILE=%~1"
set "MODE=%~2"

if not defined PROFILE (
    call "%~dp0common.cmd"
    if errorlevel 1 exit /b 1
    set "PROFILE=%AUTOSTART_PROFILE%"
)

if /I not "%MODE%"=="run" set "MODE=launch"

if /I "%PROFILE%"=="cpu" (
    if /I "%MODE%"=="run" (
        call "%~dp0start-xmrig.cmd" run
    ) else (
        call "%~dp0start-xmrig.cmd"
    )
    exit /b %ERRORLEVEL%
)

if /I "%PROFILE%"=="gpu" (
    if /I "%MODE%"=="run" (
        call "%~dp0start-lolminer.cmd" run
    ) else (
        call "%~dp0start-lolminer.cmd"
    )
    exit /b %ERRORLEVEL%
)

if /I "%PROFILE%"=="both" (
    call "%~dp0start-xmrig.cmd"
    call "%~dp0start-lolminer.cmd"
    exit /b %ERRORLEVEL%
)

echo Profile tidak valid: %PROFILE%
echo Gunakan cpu, gpu, atau both.
exit /b 1

