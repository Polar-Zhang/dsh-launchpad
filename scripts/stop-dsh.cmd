@echo off
REM stop-dsh.cmd - kill whatever is listening on port 3080.
for /f "tokens=5" %%P in ('netstat -ano ^| findstr :3080 ^| findstr LISTENING') do (
  echo Stopping PID %%P
  taskkill /F /T /PID %%P
)