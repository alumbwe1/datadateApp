@echo off
echo ========================================
echo DataDate API Integration Setup
echo ========================================
echo.

echo Step 1: Installing dependencies...
call flutter pub get

echo.
echo Step 2: Generating code (if needed)...
call flutter pub run build_runner build --delete-conflicting-outputs

echo.
echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Set your API base URL:
echo    flutter run --dart-define=API_BASE_URL=http://localhost:8000
echo.
echo 2. Or use production:
echo    flutter run --dart-define=API_BASE_URL=https://api.datadate.com
echo.
echo 3. Read API_INTEGRATION_GUIDE.md for usage details
echo.
pause
