@echo off
REM watch-dsh-idle.cmd - hidden idle watcher. Kills dsh 10s after the
REM browser disconnects from port 3080. Runs with no window (via hide-run.vbs).
setlocal enabledelayedexpansion
set "seen=0"
set "idle=0"
:watch
timeout /t 2 /nobreak >nul
set "n=0"
for /f %%C in ('netstat -ano ^| findstr ":3080 " ^| findstr "ESTABLISHED" ^| find /c /v ""') do set "n=%%C"
if !n! GTR 0 (
  set "seen=1"
  set "idle=0"
) else (
  if !seen! EQU 1 (
    set /a idle+=2
    if !idle! GEQ 10 goto kill
  )
)
goto watch
:kill
for /f "tokens=5" %%P in ('netstat -ano ^| findstr :3080 ^| findstr LISTENING') do taskkill /F /T /PID %%P
exit /b 0