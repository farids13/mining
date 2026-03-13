@echo off
setlocal EnableExtensions EnableDelayedExpansion

call "%~dp0common.cmd"
if errorlevel 1 exit /b 1

set "LOLMINER_BIN=%ROOT%\tools\lolminer\windows\lolMiner.exe"
if not exist "%LOLMINER_BIN%" (
    echo Binary tidak ditemukan: "%LOLMINER_BIN%"
    exit /b 1
)

set "USER_SPEC=%COIN%:%WALLET%"
set "CMD=lolMiner.exe --algo %ALGO_GPU% --pool %POOL_GPU% --user %USER_SPEC% --worker %LOL_WORKER_NAME% --apiport %LOL_API_PORT%"

if defined LOL_EXTRA_ARGS set "CMD=!CMD! %LOL_EXTRA_ARGS%"

if /I "%~1"=="run" (
    cd /d "%ROOT%\tools\lolminer\windows"
    call !CMD!
    exit /b %ERRORLEVEL%
)

start "lolminer-%LOL_WORKER_NAME%" /D "%ROOT%\tools\lolminer\windows" cmd /c "!CMD!"
exit /b 0
