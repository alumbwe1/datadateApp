@echo off
echo ========================================
echo DataDate - Run with Real API
echo ========================================
echo.

set /p API_URL="Enter your API URL (default: http://10.0.2.2:8000): "
if "%API_URL%"=="" set API_URL=http://10.0.2.2:8000

echo.
echo Using API URL: %API_URL%
echo.
echo Starting app...
echo.

flutter run --dart-define=API_BASE_URL=%API_URL%
