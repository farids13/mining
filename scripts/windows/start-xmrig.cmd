@echo off
setlocal EnableExtensions EnableDelayedExpansion

call "%~dp0common.cmd"
if errorlevel 1 exit /b 1

set "XMRIG_BIN=%ROOT%\tools\xmrig\windows\xmrig.exe"
if not exist "%XMRIG_BIN%" (
    echo Binary tidak ditemukan: "%XMRIG_BIN%"
    exit /b 1
)

set "USER_SPEC=%COIN%:%WALLET%.%WORKER_NAME%"
set "CMD=xmrig.exe -o %POOL_CPU% -a %ALGO_CPU% -k -u %USER_SPEC% -p %PASSWORD% --threads=%XMRIG_THREADS% --cpu-priority=%XMRIG_CPU_PRIORITY% --print-time=%XMRIG_PRINT_TIME% --donate-level=%XMRIG_DONATE_LEVEL%"

if /I "%XMRIG_HUGE_PAGES_JIT%"=="true" set "CMD=!CMD! --huge-pages-jit"
if defined XMRIG_CPU_AFFINITY set "CMD=!CMD! --cpu-affinity=%XMRIG_CPU_AFFINITY%"
if defined RIG_ID set "CMD=!CMD! --rig-id=%RIG_ID%"
if defined XMRIG_EXTRA_ARGS set "CMD=!CMD! %XMRIG_EXTRA_ARGS%"

if /I "%~1"=="run" (
    cd /d "%ROOT%\tools\xmrig\windows"
    call !CMD!
    exit /b %ERRORLEVEL%
)

start "xmrig-%WORKER_NAME%" /D "%ROOT%\tools\xmrig\windows" cmd /c "!CMD!"
exit /b 0
