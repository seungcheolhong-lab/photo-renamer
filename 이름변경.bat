@echo off
chcp 65001 >nul
echo Processing photos...
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0rename_photos.ps1"
echo.
echo Done!
pause
