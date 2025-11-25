@echo off
chcp 65001 >nul
title NOFX 交易系统 - 查看状态

echo ================================
echo   NOFX AI Trading System
echo   系统状态
echo ================================
echo.

cd /d "%~dp0"

echo [容器状态]
docker compose ps
echo.

echo [API 健康检查]
curl -s http://localhost:8080/api/health
echo.
echo.

echo [最近日志 - 后端]
docker compose logs nofx --tail 20
echo.

echo ================================
echo.
pause
