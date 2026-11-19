@echo off
title Doctavia Backend + Tunnel

echo ==========================================
echo    Doctavia Backend + Local Tunnel
echo ==========================================
echo.

echo [1/3] Configuring Ngrok Auth Token...
:: Using the local ngrok command
ngrok config add-authtoken 3CxbI3DZxp0F3217i9I7zV5AK4i_5oV597YsexWmTQa87YtnH

echo [2/3] Starting Backend Server (Development Mode)...
:: Standard npm start
start /b cmd /c "npm start"

timeout /t 3 >nul

echo [3/3] Starting Ngrok Tunnel on port 5000...
echo Domain: curvy-channel-politely.ngrok-free.dev
echo.

:: REMOVED 'npx' here so it uses the configured local ngrok
ngrok http --domain=curvy-channel-politely.ngrok-free.dev 5000