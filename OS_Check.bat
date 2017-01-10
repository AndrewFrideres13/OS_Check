@ECHO off

NET SESSION >nul 2>&1 && goto noUAC
set n=%0 %*
set n=%n:"=" ^& Chr(34) ^& "%
echo Set objShell = CreateObject("Shell.Application")>"%tmp%\cmdUAC.vbs"
echo objShell.ShellExecute "cmd.exe", "/c start " ^& Chr(34) ^& "." ^& Chr(34) ^& " /d " ^& Chr(34) ^& "%CD%" ^& Chr(34) ^& " cmd /c %n%", "", "runas", ^1>>"%tmp%\cmdUAC.vbs"
echo Elevating to admin...
cscript "%tmp%\cmdUAC.vbs" //Nologo
del "%tmp%\cmdUAC.vbs"
exit /B
:noUAC

cd /D \
cd %~dp0

ECHO %DATE% %TIME% %ver%

wmic os get version

NETSTAT -nbo > %CD%\outwardconnections.txt
nbtstat -n > %CD%\internalconnections.txt
nbtstat -s >> %CD%\internalconnections.txt
NET start > %CD%\serviceslist.txt 

echo.
SET /p responseCPU=Run CPU check (Y/N)?:
IF /I "%responseCPU%"=="y" (
tasklist /v
ECHO Here is what is taking up virtual memory
pause 
cls
wmic cpu get loadpercentage /every:3 /format:value
cls
wmic ComputerSystem get TotalPhysicalMemory
wmic os get freephysicalmemory /format:value
wmic os get freevirtualmemory /format:value
)
cls

echo.
SET /p responseSys=Run system check (Y/N)?:
IF /I "%responseSys%"=="y" (
  sfc /scannow
)
cls

echo.
SET /p responseBloat=Search for Bloatware (Y/N)?:
IF /I "%responseBloat%"=="y" (
  start %CD:~0,3%OS_Check\Bloat_Cleaner.cmd
)
cls

echo.
SET /p responseDiag=Run diagnostics check (Y/N)?:
IF /I "%responseDiag%"=="y" (
  netsh wlan show wlanreport > %CD%\wlanreport.txt
  start C:\ProgramData\Microsoft\Windows\WlanReport\wlan-report-latest.html
)
cls

echo.
SET /p responseClean=Is CCleaner installed (Y/N)?:
IF /I "%responseClean%"=="n" (
  ECHO Redirecting to CCleaner download page.
  start "" https://www.piriform.com/ccleaner/download
  timeout /t 60
)
cls

echo.
SET /p responseCleanRun=Run CCleaner (Y/N)?:
IF /I "%responseCleanRun%"=="y" (
  start "" "C:\Program Files\CCleaner\CCleaner64.exe"
)
cls

ECHO Process completed at %TIME%. Be sure to examine the files created in
ECHO            the program folder. Exiting now...
timeout /t 5 /nobreak