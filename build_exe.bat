@echo off
REM Build AI Tools EXE on Windows
REM Requires: Flutter 3.47+, Visual Studio 2022 C++ desktop, JDK 21

echo [*] Checking Flutter...
where flutter >nul 2>nul || (echo Flutter not found! Install from https://docs.flutter.dev/get-started/install/windows && exit /b 1)
flutter --version

echo [*] Enabling Windows desktop...
flutter config --enable-windows-desktop

echo [*] Getting deps...
flutter pub get

echo [*] Building Windows Release EXE...
flutter build windows --release
if %errorlevel% neq 0 (
  echo [!] Build failed. Check Visual Studio C++ workload is installed.
  exit /b %errorlevel%
)

echo [*] Build OK!
echo     Output: build\windows\x64\runner\Release\ai_tools.exe
echo     Assets: assets\models.json (22 models)
echo     Next: Create installer with Inno Setup using windows\installer.iss
pause
