AI Tools - Easy Access - All Platforms
=======================================
Created: 2026-09-07
New easy location: /home/iyed/Desktop/ai tools/Easy_Access/

This folder contains ONLY unique (non-duplicate) builds, one copy each.

Structure:
  Kali_Linux/      -> Kali Linux x64 release (your main: build/linux/x64/release/bundle/ai_tools)
  Android_Phone/   -> 4 unique APKs for phone
  Windows/         -> README, no EXE yet (needs Windows build)

--- Kali Linux ---
Original: /home/iyed/Desktop/ai tools/build/linux/x64/release/bundle/ai_tools (24K binary)
          /home/iyed/Desktop/ai tools/bundle/ai_tools (DUPLICATE - same hash 2daa848c)
          /home/iyed/Desktop/ai tools/dist/AI_Tools_Kali_Linux_x64_release.tar.gz (12M - contains same binary)
Easy copies:
  Kali_Linux/AI_Tools_Kali_Linux_x64_release.tar.gz (12M) - BEST for sharing, extract: tar -xzf ... && ./bundle/ai_tools
  Kali_Linux/ai_tools_binary (24K) - standalone binary (needs data/ + lib/ next to it)
  Kali_Linux/bundle_FULL/ - full runnable folder (ai_tools + data/ + lib/)
  Kali_Linux/README_KALI.txt - instructions

Duplicate check: bundle/ai_tools == build/linux/x64/release/bundle/ai_tools == tar's bundle/ai_tools (hash 2daa848c)
Debug binary is DIFFERENT and NOT copied here: build/linux/x64/debug/bundle/ai_tools (41K, hash 937d1adf)

Run Kali:
  cd Easy_Access/Kali_Linux
  tar -xzf AI_Tools_Kali_Linux_x64_release.tar.gz
  ./bundle/ai_tools
  # OR if using bundle_FULL: ./bundle_FULL/ai_tools

--- Android Phone ---
Originals (11 files found, but only 4 unique hashes):
  dist/AI_Tools_Android_arm64_release.apk (24M, hash ef1d6874) == build/app/outputs/apk/release/app-arm64-v8a-release.apk [DUPLICATE]
  dist/AI_Tools_Android_armeabi_v7a_release.apk (22M, hash ab741429) == build/app/outputs/apk/release/app-armeabi-v7a-release.apk [DUPLICATE]
  build/app/outputs/apk/release/app-x86_64-release.apk (25M, hash 7bbff30c) [UNIQUE - was missing from dist/]
  dist/AI_Tools_Android_arm64_debug.apk (117M, hash 4924ecf3) == build/app/outputs/apk/debug/app-debug.apk [DUPLICATE]

Easy copies (4 unique, non-duplicate):
  Android_Phone/AI_Tools_Phone_arm64-release.apk (24M) - RECOMMENDED for modern phones (arm64-v8a)
  Android_Phone/AI_Tools_Phone_armeabi_v7a-release.apk (22M) - for older 32-bit phones
  Android_Phone/AI_Tools_Phone_x86_64-release.apk (25M) - for emulator / x86_64 devices (NEW, not in dist/)
  Android_Phone/AI_Tools_Phone_DEBUG.apk (117M) - debug version (large, for testing)

Install: adb install AI_Tools_Phone_arm64-release.apk

--- Windows ---
No .exe exists. See Windows/README_WINDOWS.txt
Expected after build: Easy_Access/Windows/AI_Tools_Windows_x64.exe

--- Original locations (full detail) ---
APK: build/app/outputs/apk/release/, build/app/outputs/flutter-apk/, dist/
Linux: build/linux/x64/release/bundle/, bundle/, dist/*.tar.gz
Windows: windows/ (source only)

--- How this Easy_Access was created ---
cp dist/AI_Tools_Kali_Linux_x64_release.tar.gz -> Easy_Access/Kali_Linux/
cp build/linux/x64/release/bundle/ai_tools -> Easy_Access/Kali_Linux/ai_tools_binary
cp -r build/linux/x64/release/bundle -> Easy_Access/Kali_Linux/bundle_FULL/
cp build/app/outputs/apk/release/*.apk -> Easy_Access/Android_Phone/ (renamed)
cp build/app/outputs/apk/debug/app-debug.apk -> Easy_Access/Android_Phone/
