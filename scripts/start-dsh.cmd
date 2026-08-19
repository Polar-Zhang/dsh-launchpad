@echo off
REM start-dsh.cmd - silent launcher for the DSH web profile.
REM Double-click (or run from cmd). No windows: dsh runs hidden, the browser
REM opens the launchpad splash page and jumps in when the server is ready.
REM Close the browser tab and dsh stops automatically (see watch-dsh-idle.cmd).
setlocal

set "DSH=%APPDATA%\npm\dsh.cmd"
set "LOG=%USERPROFILE%\.dsh\logs\web.log"
set "VBS=%USERPROFILE%\.dsh\hide-run.vbs"
set "WATCHER=%USERPROFILE%\.dsh\watch-dsh-idle.cmd"
set "LOADING=%USERPROFILE%\.dsh\loading.html"
if not exist "%USERPROFILE%\.dsh\logs" mkdir "%USERPROFILE%\.dsh\logs"

REM If dsh is already up, skip everything and just open the loading page.
netstat -ano | findstr ":3080 " | findstr "LISTENING" >nul && goto open

REM Kill zombies on port 3080.
for /f "tokens=5" %%P in ('netstat -ano ^| findstr :3080 ^| findstr LISTENING') do taskkill /F /T /PID %%P >nul 2>&1

REM Start dsh hidden, then the idle watcher hidden.
wscript.exe "%VBS%" "cmd /c %DSH% web > %LOG% 2>&1"
wscript.exe "%VBS%" "cmd /c %WATCHER%"

:open
start "" "%LOADING%"
exit /b 0