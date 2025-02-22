@echo off
setlocal enabledelayedexpansion

REM config location lu naruh project nya dimana
set "home=%~dp0"
set "run=mvn clean quarkus:dev"

REM Lokasi Folder Config yang akan dihitung
set "folderWajib=C:\Users\farid\ismaya\config\wajib"
set "folderOptional=C:\Users\farid\ismaya\config\optional"

REM jangan lupa tambah kalau ada environment diluar service
set "s[1]=Mining"
set "s[2]=Zookeeper"
set "s[3]=Kafka"

REM Hitung yang diluar Service 
set "countExService=0"
for /L %%i in (1, 1, 999) do (
    if defined s[%%i] (
        set /a "countExService+=1"
    ) else (
        goto endLoopExService
    )
)
:endLoopExService

set "countMandatoryService=%countExService%"
for /D %%i in ("%folderWajib%\*") do (
    set /A "countMandatoryService+=1"
    set "s[!countMandatoryService!]=%%~nxi"
)

set "countOptionalService=%countMandatoryService%"
for /D %%i in ("%folderOptional%\*") do (
    set /A "countOptionalService+=1"
    set "s[!countOptionalService!]=%%~nxi"
)

REM Dari mandatory hitung lagi jumlah untuk yang optional service
REM Hitung ukuran array ini final sih harusnya
set "count=0"
for /L %%i in (1, 1, 999) do (
    if defined s[%%i] (
        set /a "count+=1"
    ) else (
        goto endLoop
    )
)
:endLoop

REM kalau nambah jangan lupa diubah
set "minChoice=1"
set "maxArray=%count%"


set "commands[1]=wt -w 0 -d !home!xmrig --title !s[1]! --tabColor #f1c40f cmd /k xmrig.exe -o rx.unmineable.com:3333 -a rx -k -u DOGE:DSycjXnngRekwJKRQKXJwY88GPw4w9FmQA.DELL -p x --threads 2"
set "commands[2]=wt -w 0 -d !home!ismaya\apacheKafka --title !s[2]! --tabColor #1abc9c cmd /k bin\windows\zookeeper-server-start.bat config\zookeeper.properties"
set "commands[3]=wt -w 0 -d !home!ismaya\apacheKafka --title !s[3]! --tabColor #16a085 cmd /k bin\windows\kafka-server-start.bat config\server.properties"
set "commands[4]=wt -w 0 -d !home!lolMiner --title !s[1]! --tabColor #f1c40f cmd /k lolMiner.exe --algo ETCHASH --pool etchash.unmineable.com:3333 --user DOGE:DSycjXnngRekwJKRQKXJwY88GPw4w9FmQA.DELL --ethstratum ETHPROXY"

set /a "countExService+=1"
for /L %%i in (%countExService% 1 %countMandatoryService%) do (
    set "commands[%%i]=wt -w 0 -d !home!\ismaya\!s[%%i]! --title !s[%%i]! --tabColor #e74c3c cmd /k !run! -Dquarkus.config.locations=../config/wajib/!s[%%i]!/application-dev.properties,..config/wajib/!s[%%i]!/application-test.properties"
)

set /a "countMandatoryService+=1"
for /L %%i in (%countMandatoryService% 1 %maxArray%) do (
    set "commands[%%i]=wt -w 0 -d !home!\ismaya\!s[%%i]! --title !s[%%i]! --tabColor #3498db cmd /k !run! -Dquarkus.config.locations=../config/optional/!s[%%i]!/application-dev.properties,..config/optional/!s[%%i]!/application-test.properties"
)
@REM set "commands[4]=wt -w 0 -d !home!\ismaya\!s[4]! --title !s[4]! --tabColor #e74c3c cmd /k !run! -Dquarkus.config.locations=../config/!s[4]!/application-dev.properties,..config/!s[4]!/application-test.properties"
set /a "countMandatoryService-=1"

:start
echo "=================================================================================="
echo " ___  ___  __  __  ___ __   __ ___        ___  ___   ___      _  ___   ___  ____TM"
echo "|_ _|/ __||  \/  |/   \\ \ / //   \      | _ \| _ \ / _ \  _ | || __| / __||_   _|"
echo " | | \__ \| |\/| || - | \   / | - |      |  _/|   /| (_) || || || _| | (__   | |  "
echo "|___||___/|_|  |_||_|_|  |_|  |_|_|      |_|  |_|_\ \___/  \__/ |___| \___|  |_|  "
echo "                                                                               %count% "
echo "=================================================================================="

echo ================================== FAST TM ==========================================
echo [1] Running Semua                          
echo [2] Running Service Wajib
echo [3] Running Service Tertentu
echo [4] Clean Kafka Temp And Fixing 
echo [5] Mining CPU Om 2 threads
echo [6] Mining GPU Om
echo [q] Capek Om !!!  
echo ================================== FAST TM ==========================================

set /p "choice=Masukkan pilihan (1-6):"
if "%choice%" lss "%minChoice%" (
    echo Ngapain om kekecilan pilihan lu!  %minChoice%-4.
    goto :start
)

if "%choice%"=="q" (
    echo Thanks Om Dada.......!!
    exit /b
)

if "%choice%" gtr "6" (
    echo Ngapain om Kegedaean pilihan lu! %minChoice%-4.
    goto :start
)

REM  ===== Logic Option =======
if "%choice%"=="1" (
    echo Running Semua Om .....

    for /L %%i in (%minChoice%,1,%maxArray%) do (
        timeout 10
        start "" cmd /c "!commands[%%i]!"
    )

    echo Done Om.......!!! 
    goto :animation
) else if "%choice%"=="2" (
    echo Ok!!! Jalankan Serive Wajib Project Ini Om
    echo %countMandatoryService%
    for /L %%i in (%minChoice%,1,%countMandatoryService%) do (
        timeout 3
        start "" cmd /c "!commands[%%i]!"
    )

    echo Done Om ...... !!!
    goto :animation
) else if "%choice%"=="3" (
    :menu3
    echo Oke Pilihlah Sesuka Hati

    echo ========================================
    echo            Service Apa Om !
    echo ========================================
    for /L %%i in (%minChoice%,1,%maxArray%) do (
        echo [%%i] !s[%%i]!
    )
        echo [q] capek Om!
    echo ========================================

    set /p "service=Pilihlah (%minChoice%-%maxArray%):"

    set "valid=false"
    for /L %%i in (%minChoice%,1,%maxArray%) do (
        if "!service!"=="%%i" (
            echo Menjalankan !s[%%i]! Command !commands[%%i]!...
            start "" cmd /c "!commands[%%i]!"
            set "valid=true"
        )   
    )
    if "!service!"=="q" (
        goto :animation
    )

    if "!valid!"=="false" (
        echo Lu Ngapain Sih Om !! %minChoice%-%maxArray%.
        goto :menu3
    )
    

    echo Done Om !! Kembali ke Menu3 :D
    goto :menu3
) else if "%choice%"=="4" (
    echo Clean Kafka In Folder "C:\tmp"
    rd /s /q "C:\tmp"
    :animation
    echo Done Om ........
) else if "%choice%"=="5" (
    echo Start Mining Doge nya om
    
    start "" cmd /c "!commands[1]!"
)
else if "%choice%"=="6" (
    echo Start Mining GPU Doge nya om
    
    start "" cmd /c "!commands[4]!"
)
else (
    echo Ngapain sih OM !!!!!!
    goto :start
)


:animation
chcp 65001 >nul
:: Mengatur karakter ASCII art untuk animasi loading
set "frames=6"
set "frame[1]=█"
set "frame[2]=████"
set "frame[3]=█████████████"
set "frame[4]=█████████████████████"
set "frame[5]=██████████████████████████████████████████"
set "frame[6]=████████████████████████████████████████████████████████████████████████"

set "delay=1"
for /L %%i in (1,1,%frames%) do (
    cls
    echo LOADING !frame[%%i]!
    python -c "import time; time.sleep(%delay%/10000)"
)

goto :start

pause



@REM wt -w 0 -d c:\users\farid\ismaya\apacheKafka --title zookeeper --tabColor #1abc9c cmd /k bin\windows\zookeeper-server-start.bat config\zookeeper.properties 
@REM timeout 5
@REM wt -w 0 -d c:\users\farid\ismaya\apacheKafka --title kafka --tabColor #16a085 cmd /k bin\windows\kafka-server-start.bat config\server.properties
@REM wt -w 0 -d c:\users\farid\ismaya\core-service --title core-service --tabColor #e74c3c cmd /k mvn clean quarkus:dev
@REM wt -w 0 -d c:\users\farid\ismaya\order-service --title order-service --tabColor #3498db cmd /k mvn clean quarkus:dev
@REM wt -w 0 -d c:\users\farid\ismaya\user-service --title user-service --tabColor #ecf0f1 cmd /k mvn clean quarkus:dev
@REM wt -w 0 -d c:\users\farid\ismaya\loyalty-service --title loyalty-service --tabColor #f1c40f cmd /k mvn clean quarkus:dev
@REM wt -w 0 -d c:\users\farid\ismaya\event-service --title event-service --tabColor #ecf0f1 cmd /k mvn clean quarkus:dev
@REM timeout 20
@REM wt -w 0 -d c:\users\farid\mining\xmrig --title Mining --tabColor #f1c40f cmd /k xmrig.exe -o rx.unmineable.com:3333 -a rx -k -u DOGE:DSycjXnngRekwJKRQKXJwY88GPw4w9FmQA.DELL -p x
