@echo off
chcp 65001 >nul
REM ============================================================
REM 停止 Dify 栈和 Ollama(释放内存;Docker Desktop 可自行退出)
REM ============================================================
cd /d "%~dp0..\deploy\dify\docker"
docker compose stop
taskkill /F /IM "ollama app.exe" >nul 2>&1
echo.
echo 已停止 Dify 栈和 Ollama。
pause
