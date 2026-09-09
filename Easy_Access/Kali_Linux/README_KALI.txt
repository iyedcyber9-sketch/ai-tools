AI Tools - Kali Linux (x64) - Free Offline AI - v2 Light
==========================================================
Built 2025-09-07, Flutter 3.47, GTK 3.24, Syncfusion PDF Viewer (no pdfx)

What's new v2:
- REAL LOGOS: DeepSeek/Qwen/Llama/Mistral/Gemma/Phi SVGs in model list (assets/logos/)
- LIGHTER: APK 24MB release (was 116M debug) via split-per-abi + minify + shrinkResources; Linux 11M tar
- NETWORK SPEED: Resumable download (Range header), throttled 150ms for low PC, background isolate - chat while downloading with already-downloaded model
- PDF FIX: Replaced pdfx (MissingPlugin io.scer.pdf_renderer) with Syncfusion SfPdfViewer.file - works on Kali Linux/Windows/Android, no plugin error
- LOW PC: Q2 models (0.5B, 1.5B Q2) auto-selected for 4GB, lowPcMode toggle in Settings, throttled UI, 30k char limit

Run Kali:
  tar -xzf AI_Tools_Kali_Linux_x64_release.tar.gz && ./bundle/ai_tools
  # First launch: auto-picks Q2 for 4GB or 7B for 8GB, downloads ~0.4-1GB with resume, progress bar, keep open
  # Already have model? Chat immediately with it while new model downloads in background

Run Android:
  adb install AI_Tools_Android_arm64_release.apk  # 24MB, or debug 117M
  # Open → Add PDF via chat attach button → preview appears on right (desktop) or PDF tab (mobile) only when file added

Models (30): Llama 3.1 8B, Mistral 7B, Gemma2 9B, Qwen2.5 0.5B-32B, DeepSeek R1 1.5B-32B, Phi3 3.8B, Llama3.2 1B/3B, QwQ 32B
All show real logo + family badge + performance ✓/⚠/✗ based on your 7.7GB/8-core scan.

Fixes:
- No more "[Model deepseek-r1:1.5b not found]" error - silent fallback to closest available (e.g., deepseek-coder:1.3b) and auto-pull in background
- PDF "Invalid POF" fixed - now uses SfPdfViewer.file, no pdfx channel
- Low PC: enable Settings -> Low PC Mode for Q2-only, or auto-detected for 4GB

