@echo off
chcp 65001 >nul
title NOFX 交易系统 - 一键启动

echo ================================
echo   NOFX AI Trading System
echo   一键启动脚本
echo ================================
echo.

:: 检查 Docker Desktop 是否运行
echo [1/4] 检查 Docker 服务...
docker info >nul 2>&1
if errorlevel 1 (
    echo [!] Docker Desktop 未运行，正在启动...
    echo [提示] 如果 Docker Desktop 无法自动启动，请手动打开它
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    echo [等待] 等待 Docker 启动（30秒）...
    timeout /t 30 /nobreak >nul

    :: 再次检查
    docker info >nul 2>&1
    if errorlevel 1 (
        echo [错误] Docker 启动失败，请手动启动 Docker Desktop
        pause
        exit /b 1
    )
)
echo [√] Docker 服务正常运行
echo.

:: 进入项目目录
echo [2/4] 进入项目目录...
cd /d "%~dp0"
echo [√] 当前目录: %CD%
echo.

:: 启动容器
echo [3/4] 启动 NOFX 容器...
docker compose up -d
if errorlevel 1 (
    echo [错误] 容器启动失败
    pause
    exit /b 1
)
echo [√] 容器启动成功
echo.

:: 等待服务就绪
echo [4/4] 等待服务就绪...
timeout /t 5 /nobreak >nul

:: 检查容器状态
docker compose ps
echo.

:: 健康检查
echo [检查] API 健康状态...
curl -s http://localhost:8080/api/health
echo.
echo.

echo ================================
echo   启动完成！
echo ================================
echo.
echo [访问地址]
echo   前端界面: http://localhost:3000
echo   后端 API:  http://localhost:8080
echo.
echo [管理命令]
echo   查看日志:   docker compose logs -f
echo   停止服务:   docker compose down
echo   重启服务:   docker compose restart
echo.
echo 按任意键打开浏览器访问前端...
pause >nul

:: 打开浏览器
start http://localhost:3000

exit /b 0
