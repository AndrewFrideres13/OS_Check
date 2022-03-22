@ECHO off
:: First step to elevate to admin (DONT REMOVE), rediret standard output stream to nul, and do the same for stndrd error output
NET SESSION >nul 2>&1 && goto noUAC 
:: Create a Visual basic elevation script here echo'ing the code to the file...
echo Set vbsScript = CreateObject("Shell.Application")>"%tmp%\elevateVBS.vbs"
:: ShellExecute "application" ( %~f0 resolves to the full path of the batch file, searching itself),
:: "parameters" (Elevation script we want to run), "dir" (Current dir hence empty),
:: "verb" (runas to elevate), window (1 is a normal window)
echo vbsScript.ShellExecute "%~f0", "%tmp%\elevateVBS.vbs", "", "runas", 1 >>"%tmp%\elevateVBS.vbs"
if exist "%tmp%\elevateVBS.vbs" start /b /wait >nul cscript /nologo "%tmp%\elevateVBS.vbs" 2>&1
:: Delete elevation script if exist
if exist "%tmp%\elevateVBS.vbs" > nul del /f "%tmp%\elevateVBS.vbs" 2>&1
exit /B
:noUAC
::Get our current drive, and directory path
title OS Check
cd /D %~dp0

ECHO %DATE% %TIME% 
wmic OS get Caption, CSDVersion, OSArchitecture,Version
wmic BIOS get Manufacturer,Name,SMBIOSBIOSVersion,Version
wmic CPU get Name,NumberOfCores,NumberOfLogicalProcessors
NETSTAT -nbo > %CD%\outwardconnections.txt
nbtstat -n > %CD%\internalconnections.txt
nbtstat -s >> %CD%\internalconnections.txt
NET start > %CD%\serviceslist.txt 

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
timeout /t 60
)
cls

SET /p responeseUSB=See what is connected (Y/N)?:
IF /I "%responeseUSB%"=="y" (
  wscript %CD%\USBConnections.vbs
  start /wait %CD%\USBConnectedItems.txt
)
cls

SET /p responseSys=Run system check (Y/N)?:
IF /I "%responseSys%"=="y" (
  sfc /scannow
)
cls

SET /p responseBloat=Search for Bloatware (Y/N)?:
IF /I "%responseBloat%"=="y" (
  start /wait %CD%\Bloat_Cleaner.cmd
)
cls

SET /p responseDiag=Run diagnostics check (Y/N) (Windows 10 Only)?:
IF /I "%responseDiag%"=="y" (
  netsh wlan show wlanreport > %CD%\wlanreport.txt
  start C:\ProgramData\Microsoft\Windows\WlanReport\wlan-report-latest.html
)
cls

SET /p responseClean=Is CCleaner installed (Y/N)?:
IF /I "%responseClean%"=="n" (
  ECHO Redirecting to CCleaner download page.
  start "" https://www.piriform.com/ccleaner/download
  timeout /t 60
)
cls

SET /p responseCleanRun=Run CCleaner (Y/N)?:
IF /I "%responseCleanRun%"=="y" (
  start "" "C:\Program Files\CCleaner\CCleaner64.exe"
)
cls

ECHO Process completed at %TIME%.
ECHO      Exiting now...
timeout /t 5 /nobreak