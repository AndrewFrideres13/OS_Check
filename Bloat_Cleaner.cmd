@set bloat_to_search= /c:"wallpaper" /c:"screen" /c:"tune" /c:"bar " /c:"coupon" /c:"rebate" /c:"free" /c:"shop " /c:"bargain" /c:"trial" /c:"eval" /c:"clean" /c:"scan" /c:"smile" /c:"web" /c:"fun " /c:"optimize" /c:"free" /c:"search" /c:"registry" /c:"arcade" /c:"tweak" /c:"price" /c:"deal" /c:"weather" /c:"game" /c:"speed" /c:"discount" /c:"price" /c:"tab " /c:"speed" /c:"my" /c:"download"
@echo off
set n=%0 %*
set n=%n:"=" ^& Chr(34) ^& "%
if not '%1'=='' goto s2
::Checks to see if these files already exist, if so delete them so we can refresh them
if exist "%tmp%\tmpUC.txt" del "%tmp%\tmpUC.txt" "%tmp%\tmpUCN.txt"
::Will direct the output of what we find to a file
echo. > "%tmp%\tmpUCN.txt"

title Bloat Cleaner
echo Scanning for Bloatware...
for /F "tokens=1 delims=|" %%n IN ('reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /s ^& reg query HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall /s 2^>nul ^& reg query HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /s 2^>nul ^& reg query HKCU\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall /s 2^>nul ') DO echo %%n >> "%tmp%\tmpUC.txt"

set p=0
set t=

setlocal enabledelayedexpansion
  for /F "tokens=1-13" %%n IN ('type "%tmp%\tmpUC.txt"') DO (
     set n=%%n
     set /a p=!p! + 1

     if '!n!'=='UninstallString' (
           set c=!p!
     )
::If first 5 chars match HKEY_
     if "!n:~0,5!"=="HKEY_" (
        set c=
        set d=
     )

     if /i '!n!'=='DisplayName' (
        echo # %%p %%q %%r %%s %%t %%u %%v %%w %%x %%y %%z | findstr /i %bloat_to_search% && (
           set d=1
           echo %%p %%q %%r %%s %%t %%u %%v %%w %%x %%y %%z >> "%tmp%\tmpUCN.txt"
        )
     )

     if defined d (
        if defined c (
           set /a c=!c!-1
           set t=!t! !c!
           set c=
           set d=
        )
     )
  )
setlocal disabledelayedexpansion

:s2
if not '%1'=='' (
   for /F "skip=%1 tokens=1-26" %%a IN ('type "%tmp%\tmpUC.txt"') DO (
      set c=%%c %%d %%e %%f %%g %%h %%i %%j %%k %%l %%m %%n %%o %%p %%q %%r %%s %%t %%u %%v %%w %%x %%y %%z
      goto s3
   )
)

if not "%t%"=="" call %0%t%
endlocal
goto exit

:s3
set c1=
set c2=
set c=%c:(=\openpar\%
set c=%c:)=\closepar\%

echo %c% | find "msiexec" > nul && goto msiexec
echo %c% | find ".msi" > nul && goto msi
echo %c% | find ".exe" > nul && goto exe
goto spacer

:msiexec
set c=%c:/i=/X%
set c=%c% /qb
goto spacer

:msi
set c=%c:"=%
set c=%c:.msi=#%
for /f "usebackq tokens=1 delims=#" %%n in (`echo %c%`) do (set c1=%%n.msi)
set c="%c1%" /x /qb
set c1=%c1:\openpar\=(%
set c1=%c1:\closepar\=)%
set c1=%c1:\and\=^&%

if not exist "%c1%" if exist "%c1%\"  (
   SHIFT
   goto s2
)
goto spacer

:exe
set c=%c:.exe=#%
for /f "usebackq tokens=1* delims=#" %%n in (`echo %c%`) do set c1=%%n.exe
set c1=%c1:"=#%
if "%c1:~0,1%"=="#" set c1=%c1:~1%
for /f "usebackq tokens=1* delims=#" %%n in (`echo %c%`) do set c2=%%o
if defined c2 set c2=%c2:~1%
set c="%c1%" %c2%
set c1=%c1:\openpar\=(%
set c1=%c1:\closepar\=)%
set c1=%c1:\and\=^&%

if not exist "%c1%" if exist "%c1%\"  (
   SHIFT
   goto s2
)
goto spacer

:spacer
cmd /s /c "if "%c:~-1%"==" " exit 42 > nul 2>&1"
if '%errorlevel%'=='42' set c=%c:~0,-1%& goto spacer
set c=%c:\openpar\=(%
set c=%c:\closepar\=)%
set c=%c:\and\=&%
set c=%c:\equal\==%
if not defined passnumber set passnumber=0
set /a passnumber=%passnumber% + 1
FOR /F "skip=%passnumber% tokens=*" %%a IN ('type "%tmp%\tmpUCN.txt"') DO (
   set pname=%%a
   goto starter
)

:starter
::uninstconfirm will get reset each iteration so no need to clear
echo. & echo %pname% & set /p uninstconfirm=Remove this program? [y/n]
if '%uninstconfirm%'=='y' start /wait "uninstall" %c%
SHIFT
goto s2

:exit
::A note exit /b will attempt to kill the parent script (OS_Main) and lead to an error message in this script
exit