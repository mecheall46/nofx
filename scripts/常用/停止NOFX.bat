@echo off
chcp 65001 >nul
title NOFX 交易系统 - 停止服务

echo ================================
echo   NOFX AI Trading System
echo   停止服务
echo ================================
echo.

cd /d "%~dp0"

echo [执行] 停止所有容器...
docker compose down

if errorlevel 1 (
    echo [错误] 停止失败
    pause
    exit /b 1
)

echo.
echo [√] 服务已停止
echo.
pause
