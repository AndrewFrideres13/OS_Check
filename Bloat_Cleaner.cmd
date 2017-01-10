@set exclude_list= /c:"antivirus"
@set include_list= /c:"wallpaper" /c:"ebay" /c:"screen" /c:"tune" /c:"toolbar" /c:"bar " /c:"coupon" /c:"rebate" /c:"free" /c:"shop " /c:"bargain" /c:"trial" /c:"evaluation" /c:"clean" /c:"security" /c:"scan" /c:"smile" /c:"web" /c:"fun " /c:"optimize" /c:"free" /c:"search" /c:"registry" /c:"arcade" /c:"tweak" /c:"price" /c:"chrome" /c:"bing" /c:"deal" /c:"weather" /c:"game" /c:"speed" /c:"discount" /c:"price" /c:"tab " /c:"speed" /c:"my" /c:"download"

@::-----UAC Prompt----------------------------------
@echo off
NET SESSION >nul 2>&1 && goto noUAC
title.
set n=%0 %*
set n=%n:"=" ^& Chr(34) ^& "%
echo Set objShell = CreateObject("Shell.Application")>"%tmp%\cmdUAC.vbs"
echo objShell.ShellExecute "cmd.exe", "/c start " ^& Chr(34) ^& "." ^& Chr(34) ^& " /d " ^& Chr(34) ^& "%CD%" ^& Chr(34) ^& " cmd /c %n%", "", "runas", ^1>>"%tmp%\cmdUAC.vbs"
echo  Elevating to admin...
cscript "%tmp%\cmdUAC.vbs" //Nologo
del "%tmp%\cmdUAC.vbs"
exit /b
:noUAC

::-----Normal Batch Starts Here---------------------

if '%1'=='/auto' (
   set auto=true
   SHIFT /1
) else (
   if not defined auto (
      if not '%1'=='' (
         echo.
         echo The only command line parameter is /auto
         echo But note, most crap cannot be automatically removed...
         echo ^(only crap installed through Windows Installer Service^)
         exit /B
      )
      set auto=false
   )
)

if not '%1'=='' goto s2
if exist "%tmp%\tmpUC.txt" del "%tmp%\tmpUC.txt"
echo. > "%tmp%\tmpUCN.txt"
cls
title Bloatware Cleaner

echo This program is free software.
echo This program IS PROVIDED WITHOUT WARRANTY, EITHER EXPRESSED OR IMPLIED.
echo This program is copyrighted under the terms of GPLv3:
echo see ^<http://www.gnu.org/licenses/^>.
timeout /t 3 /nobreak > NUL
cls
echo Scanning for Bloatware...

FOR /F "tokens=1 delims=|" %%n IN ('reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /s ^& reg query HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall /s 2^>nul ^& reg query HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /s 2^>nul ^& reg query HKCU\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall /s 2^>nul ') DO echo %%n >> "%tmp%\tmpUC.txt"

echo Option Explicit > "%tmp%\FindReplace.vbs"
echo Dim fso,strFilename,strSearch,strReplace,objFile,oldContent,newContent >> "%tmp%\FindReplace.vbs"
echo Set fso=CreateObject("Scripting.FileSystemObject") >> "%tmp%\FindReplace.vbs"
echo set objFile=fso.OpenTextFile(WScript.Arguments.Item(0),1) >> "%tmp%\FindReplace.vbs"
echo newContent=replace(objFile.ReadAll,WScript.Arguments.Item(1),WScript.Arguments.Item(2),1,-1,0) >> "%tmp%\FindReplace.vbs"
echo set objFile=fso.OpenTextFile(WScript.Arguments.Item(0),2) >> "%tmp%\FindReplace.vbs"
echo objFile.Write newContent >> "%tmp%\FindReplace.vbs"
echo objFile.Close >> "%tmp%\FindReplace.vbs"
cscript //Nologo "%tmp%\FindReplace.vbs" "%tmp%\tmpUC.txt" ^& \and\
cscript //Nologo "%tmp%\FindReplace.vbs" "%tmp%\tmpUC.txt" ^= \equal\
del "%tmp%\FindReplace.vbs"

set p=0
set t=

setlocal enabledelayedexpansion

FOR /F "tokens=1-13" %%n IN ('type "%tmp%\tmpUC.txt"') DO (
   set n=%%n
   set /a p=!p! + 1

   if /i '!n!'=='UninstallString' (
         set c=!p!
   )

   if /i "!n:~0,5!"=="HKEY_" (
      set c=
      set d=
   )

   if /i '!n!'=='DisplayName' (
      echo # %%p %%q %%r %%s %%t %%u %%v %%w %%x %%y %%z | findstr /i /v %exclude_list% | findstr /i %include_list% && (
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

if not "%t%"=="" call %0%t%
endlocal
set auto=
set weallgood=
del "%tmp%\tmpUC.txt"
del "%tmp%\tmpUCN.txt"
timeout /t 2 /nobreak > NUL
cls
title %ComSpec%
exit /B
:s2

if not '%auto%'=='true' (
   if not defined weallgood (
      echo.
      set /p weallgood=Remove ALL listed programs? [y/n] &rem
   )
)
if '%weallgood%'=='y' set weallgood=true
if '%weallgood%'=='' set weallgood=true

if not '%1'=='' (
   FOR /F "skip=%1 tokens=1-26" %%a IN ('type "%tmp%\tmpUC.txt"') DO (
      set c=%%c %%d %%e %%f %%g %%h %%i %%j %%k %%l %%m %%n %%o %%p %%q %%r %%s %%t %%u %%v %%w %%x %%y %%z
      goto s3
   )
)

goto :EOF
:s3

set c1=
set c2=
set c=%c:(=\openpar\%
set c=%c:)=\closepar\%

echo %c% | find /i "msiexec" > nul && goto msiexec
echo %c% | find /i ".msi" > nul && goto msi
echo %c% | find /i ".exe" > nul && goto exe

if '%auto%'=='true' (
   SHIFT
   goto s2
)

goto spacer
::-------------------------------------------------------------------------------

:msiexec
set c=%c:/I=/X%
set c=%c:/i=/X%
set c=%c% /qb

goto spacer
::-------------------------------------------------------------------------------

:msi
set c=%c:"=%
set c=%c:.msi=#%
for /f "usebackq tokens=1 delims=#" %%n in (`echo %c%`) do (set c1=%%n.msi)
set c="%c1%" /x /qb

set c1=%c1:\openpar\=(%
set c1=%c1:\closepar\=)%
set c1=%c1:\and\=^&%

if exist "%c1%\" (
   SHIFT
   goto s2
)

if not exist "%c1%" (
   SHIFT
   goto s2
)

goto spacer
::-------------------------------------------------------------------------------

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

if exist "%c1%\" (
   SHIFT
   goto s2
)

if not exist "%c1%" (
   SHIFT
   goto s2
)

if '%auto%'=='true' (
   SHIFT
   goto s2
)

goto spacer
::-------------------------------------------------------------------------------

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

if not '%auto%'=='true' if not '%weallgood%'=='true' echo. & echo %pname% & set /p wegood=Remove this program? [y/n] &rem
if '%auto%'=='true' set wegood=true
if '%weallgood%'=='true' set wegood=true
if '%wegood%'=='y' set wegood=true
if '%wegood%'=='' set wegood=true
if '%wegood%'=='true' start /wait "uninstall" %c%
set wegood=


SHIFT
goto s2