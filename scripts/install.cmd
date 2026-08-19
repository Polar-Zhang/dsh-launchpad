@echo off
REM install.cmd - deploy dsh-launchpad scripts + splash page to ~/.dsh
setlocal
set "DST=%USERPROFILE%\.dsh"
set "SRC=%~dp0.."

if not exist "%DST%" mkdir "%DST%"
if not exist "%DST%\logs" mkdir "%DST%\logs"

copy /Y "%SRC%\assets\loading.html" "%DST%\loading.html" >nul
copy /Y "%SRC%\scripts\start-dsh.cmd"     "%DST%\start-dsh.cmd"     >nul
copy /Y "%SRC%\scripts\watch-dsh-idle.cmd" "%DST%\watch-dsh-idle.cmd" >nul
copy /Y "%SRC%\scripts\hide-run.vbs"       "%DST%\hide-run.vbs"       >nul
copy /Y "%SRC%\scripts\stop-dsh.cmd"       "%DST%\stop-dsh.cmd"       >nul

echo.
echo Installed to %DST%:
echo   loading.html  start-dsh.cmd  watch-dsh-idle.cmd  hide-run.vbs  stop-dsh.cmd
echo.
echo Desktop shortcut (run once):
echo   wscript.exe "%DST%\hide-run.vbs" "cmd /c %DST%\start-dsh.cmd"
echo.
echo Preview splash:  start "" "%DST%\loading.html?p"
endlocal