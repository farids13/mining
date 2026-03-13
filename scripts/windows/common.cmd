@echo off

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..") do set "ROOT=%%~fI"
set "GLOBAL_ENV_FILE=%ROOT%\config\miner.env"
set "ENV_FILE=%ROOT%\config.local\miner.env"

if not exist "%GLOBAL_ENV_FILE%" (
    copy /Y "%ROOT%\config\miner.env.example" "%GLOBAL_ENV_FILE%" >nul
)

if not exist "%ENV_FILE%" (
    if not exist "%ROOT%\config.local" mkdir "%ROOT%\config.local"
    copy /Y "%GLOBAL_ENV_FILE%" "%ENV_FILE%" >nul
)

for /f "usebackq tokens=1,* delims==" %%A in ("%GLOBAL_ENV_FILE%") do (
    set "KEY=%%~A"
    set "VALUE=%%~B"
    if defined KEY (
        if not "!KEY:~0,1!"=="#" (
            if not "!KEY:~0,1!"==";" (
                set "!KEY!=!VALUE!"
            )
        )
    )
)

for /f "usebackq tokens=1,* delims==" %%A in ("%ENV_FILE%") do (
    set "KEY=%%~A"
    set "VALUE=%%~B"
    if defined KEY (
        if not "!KEY:~0,1!"=="#" (
            if not "!KEY:~0,1!"==";" (
                set "!KEY!=!VALUE!"
            )
        )
    )
)

if not defined COIN (
    echo COIN wajib diisi di "%GLOBAL_ENV_FILE%" atau "%ENV_FILE%"
    exit /b 1
)

if not defined WALLET (
    echo WALLET wajib diisi di "%GLOBAL_ENV_FILE%" atau "%ENV_FILE%"
    exit /b 1
)

if not defined POOL_CPU set "POOL_CPU=rx.unmineable.com:3333"
if not defined ALGO_CPU set "ALGO_CPU=rx"
if not defined POOL_GPU set "POOL_GPU=etchash.unmineable.com:3333"
if not defined ALGO_GPU set "ALGO_GPU=ETCHASH"

if not defined PASSWORD set "PASSWORD=x"
if not defined WORKER_NAME set "WORKER_NAME=%COMPUTERNAME%"
if not defined LOL_WORKER_NAME set "LOL_WORKER_NAME=%WORKER_NAME%"
if not defined AUTOSTART_PROFILE set "AUTOSTART_PROFILE=cpu"
if not defined XMRIG_THREADS set "XMRIG_THREADS=2"
if not defined XMRIG_PRINT_TIME set "XMRIG_PRINT_TIME=60"
if not defined XMRIG_HEALTH_PRINT_TIME set "XMRIG_HEALTH_PRINT_TIME=60"
if not defined XMRIG_DONATE_LEVEL set "XMRIG_DONATE_LEVEL=1"
if not defined XMRIG_HUGE_PAGES_JIT set "XMRIG_HUGE_PAGES_JIT=false"
if not defined XMRIG_CPU_PRIORITY set "XMRIG_CPU_PRIORITY=5"
if not defined LOL_API_PORT set "LOL_API_PORT=8020"

exit /b 0
