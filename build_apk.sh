#!/bin/bash
# Build AI Tools APK on Linux/Mac
# Requires: Flutter 3.47+, JDK 21, Android SDK 34+
set -e
export JAVA_HOME=${JAVA_HOME:-$HOME/android-env/jdk-21.0.12+8}
export PATH="$HOME/flutter/bin:$PATH"

echo "[*] Flutter version:"
flutter --version

echo "[*] Pub get..."
flutter pub get

echo "[*] Building APK debug (arm64)..."
flutter build apk --debug --target-platform android-arm64

echo "[*] Building APK release split per ABI (smaller)..."
flutter build apk --release --split-per-abi

echo "[*] Done!"
ls -lh build/app/outputs/flutter-apk/
echo ""
echo "Install debug: adb install build/app/outputs/flutter-apk/app-debug.apk"
echo "Or copy app-arm64-v8a-release.apk to phone"
