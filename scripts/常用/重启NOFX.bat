@echo off
chcp 65001 >nul
title NOFX 交易系统 - 重启服务

echo ================================
echo   NOFX AI Trading System
echo   重启服务
echo ================================
echo.

cd /d "%~dp0"

echo [执行] 重启容器...
docker compose restart

if errorlevel 1 (
    echo [错误] 重启失败
    pause
    exit /b 1
)

echo.
timeout /t 3 /nobreak >nul

echo [状态] 容器状态：
docker compose ps

echo.
echo [√] 服务已重启
echo.
echo [访问地址]
echo   前端界面: http://localhost:3000
echo   后端 API:  http://localhost:8080
echo.
pause
