@echo off
chcp 65001 >nul
REM ============================================================
REM 一键拉起本地知识库服务:Docker Desktop + Dify 栈 + Ollama
REM 可重复执行(已运行的服务会自动跳过)
REM ============================================================
echo [1/4] 启动 Docker Desktop...
start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"

echo [2/4] 启动 Ollama(端口 28434)...
set OLLAMA_HOST=0.0.0.0:28434
start "" "%USERPROFILE%\AppData\Local\Programs\Ollama\ollama app.exe"

echo [3/4] 等待 Docker 引擎就绪...
:wait_engine
timeout /t 5 /nobreak >nul
docker info >nul 2>&1
if errorlevel 1 goto wait_engine

echo [4/4] 启动 Dify 栈...
cd /d "%~dp0..\deploy\dify\docker"
docker compose up -d

echo.
echo 完成!浏览器打开 http://localhost
pause
