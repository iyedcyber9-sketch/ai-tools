Windows EXE - NOT BUILT YET
===========================
Status: No .exe found on this Kali Linux machine.

Expected location if built on Windows:
  build/windows/x64/runner/Release/ai_tools.exe

How to build (from build_exe.bat):
  1. On Windows 10/11, install:
     - Flutter 3.47+ (https://docs.flutter.dev/get-started/install/windows)
     - Visual Studio 2022 with "Desktop development with C++" workload
     - JDK 21
  2. Run:
     flutter config --enable-windows-desktop
     flutter pub get
     flutter build windows --release
  3. Output: build\windows\x64\runner\Release\ai_tools.exe
     + data/ and lib/ folders next to it

Current Windows source exists at:
  /home/iyed/Desktop/ai tools/windows/
  /home/iyed/Desktop/ai tools/windows/runner/

But build/windows/ does NOT exist because project was built on Linux only.
To get EXE, you must build on Windows or use GitHub Actions Windows runner.

Alternative: Copy the file after building on Windows to:
  Easy_Access/Windows/AI_Tools_Windows_x64.exe
