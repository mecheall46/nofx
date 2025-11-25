@echo off
chcp 65001 >nul
title NOFX 交易系统 - 查看日志

echo ================================
echo   NOFX AI Trading System
echo   实时日志查看
echo ================================
echo.
echo [提示] 按 Ctrl+C 退出日志查看
echo.

cd /d "%~dp0"

:: 延迟2秒后开始显示日志
timeout /t 2 /nobreak >nul

docker compose logs -f --tail=100
