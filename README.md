# AI Tools - Free Offline AI (EXE + APK)

**Free local AI that runs on your own CPU/GPU. No API keys, no internet needed after model download.**

- **EXE** for Windows (10/11) + **APK** for Android from one Flutter codebase
- **CPU-only friendly** - shows only models that fit your RAM/CPU, with "Show All" toggle for all DeepSeek + Qwen
- **GPU fallback** automatic (NVIDIA CUDA / Vulkan / OpenCL) if available
- **3-pane UI:** Left history & settings | Middle chat | Right PDF preview + model selector
- **PDF Q&A:** Upload PDF beside chat, AI answers using extracted text (RAG, 30k chars, 50 pages Max for 4GB devices)
- **Empty install (30MB):** Models download on demand from Hugging Face or via Ollama on desktop

---

## 🚀 Quick Start

### Windows Desktop (EXE)

**Option A: Ollama (Recommended - easiest, uses your CPU/GPU automatically):**
1. Install Ollama from https://ollama.com/download
2. Pull a small model for 4GB RAM: 
   ```
   ollama pull qwen2.5:1.5b
   # or coding specialist:
   ollama pull deepseek-coder:1.3b
   for 8GB+ RAM: ollama pull qwen2.5:7b / deepseek-r1:7b
   ```
3. Run `ollama serve` (auto-starts on Windows)
4. Launch `AI Tools.exe` - status shows "Ollama running"

**Option B: Direct GGUF download (no Ollama):**
1. Launch `AI Tools.exe`
2. Right panel → Select model (filtered by your RAM) → Download
3. Chat immediately, model stays in `%APPDATA%/ai_tools/models/`

### Android (APK)

1. Install `app-debug.apk` (89MB) - allow unknown sources
2. Open app → Onboarding scan shows your RAM/CPU
3. Right tab (Models) → pick `Qwen2.5 1.5B` (1.1GB, good for 4GB phones) or `Qwen2.5 0.5B` (0.4GB ultra-light) → Download
4. Chat + PDF Q&A works offline after download
5. For 6GB+ phones, `Qwen2.5 7B (Q2 low)` is available with "Show All"

> **4GB RAM Support:** Default shows only 0.5B-1.5B models (Q4 & Q2 quant). 7B+ needs "Show All" + warning "⚠ Slow / Swap risk" or "✗ Needs more RAM". App won't block selection but warns.

---

## 📁 Project Structure

```
ai_tools/
├── lib/
│   ├── main.dart                 # WindowManager + Provider init
│   ├── models/
│   │   ├── ai_model.dart         # Registry model (DeepSeek/Qwen GGUF list)
│   │   └── chat_models.dart      # ChatMessage / ChatSession (Hive storage)
│   ├── services/
│   │   ├── hardware_service.dart # RAM/CPU/AVX2 detection, filter logic
│   │   ├── gpu_service.dart      # CUDA/Vulkan/OpenCL detection
│   │   ├── model_registry.dart   # Loads assets/models.json (22 models)
│   │   ├── llama_service.dart    # Unified: Ollama on Desktop, GGUF on Android
│   │   ├── ollama_service.dart   # http://localhost:11434 API
│   │   ├── download_service.dart # Dio + Ollama pull fallback
│   │   ├── storage_service.dart  # Hive (chat history, settings)
│   │   └── pdf_service.dart      # syncfusion extract + chunk + RAG retrieve
│   ├── providers/app_provider.dart # State: hardware, gpu, sessions, streaming
│   ├── screens/main_screen.dart  # Responsive: desktop 3-pane, mobile tabs+drawer
│   └── widgets/
│       ├── sidebar.dart          # History, hardware banner, settings dialog
│       ├── chat_view.dart        # Markdown stream, suggestions, input
│       ├── model_selector.dart   # Filtered list, compat badges, download
│       └── pdf_preview.dart      # pdfx viewer + file_picker
├── assets/models.json            # 22 DeepSeek/Qwen GGUF entries (Q4_K_M/Q2_K)
├── android/                      # Gradle 8.14 + AGP 8.11 + Kotlin 2.2.20
├── windows/                      # Flutter Windows runner
├── build/web/                    # Web build output (42MB) - proof compile
└── build/app/outputs/flutter-apk/app-debug.apk (89MB)
```

---

## 🛠️ Build Instructions

Requires: Flutter 3.47.2 (Dart 3.13.2), JDK 21, Android SDK 34+

### APK (Android) - Built on Linux (Kali) ✅ Done

```bash
cd "/home/iyed/Desktop/ai tools"
flutter pub get
flutter build apk --debug                    # 89MB debug (tested OK, 343s)
flutter build apk --release --split-per-abi  # release: app-arm64-v8a-release.apk etc
# Output: build/app/outputs/flutter-apk/
```

Already built: `build/app/outputs/flutter-apk/app-debug.apk` (89MB, Android SDK 36, arm64)

### EXE (Windows) - Build on Windows 10/11

Windows build cannot be cross-compiled from Linux. On a Windows machine:

```powershell
# Install Flutter https://docs.flutter.dev/get-started/install/windows
# Install Visual Studio 2022 with "Desktop development with C++"
git clone <this-project>
cd "ai tools"
flutter config --enable-windows-desktop
flutter pub get

# Debug
flutter build windows --debug

# Release EXE (+ installer)
flutter build windows --release
# Output: build/windows/x64/runner/Release/ai_tools.exe

# Installer (optional, Inno Setup)
# Use /windows/installer.iss with Inno Setup Compiler to create AI_Tools_Setup.exe
```

We provide `build_exe.bat` and GitHub Action for automated Windows builds.

### Web (Preview - works now)

```bash
flutter build web --no-wasm-dry-run
# Output: build/web (42MB)
# Serve: python3 -m http.server -d build/web 8000
```

### Linux Desktop (requires libgtk-3-dev)

```bash
sudo apt install libgtk-3-dev
flutter build linux --release
```

---

## 🧠 Models Included (assets/models.json:1)

22 models, all GGUF Q4_K_M (or Q2_K for low RAM). Emphasis on CPU-friendly:

**Qwen Family (14):** Qwen2.5 0.5B/1.5B/3B/7B/14B/32B, Qwen3 0.6B/1.7B/4B/8B/14B/32B, QwQ 32B, Qwen2.5-Coder 7B
**DeepSeek Family (8):** R1-Distill Qwen 1.5B/7B/14B/32B, Coder 1.3B/6.7B

All show `ramRequiredGB` & `diskGB` for filtering. Example 4GB device:
- ✅ Shown by default: `Qwen2.5 0.5B (0.6GB)`, `1.5B (1.2GB)`, `DeepSeek R1 1.5B (1.3GB)` + Q2 variants
- ⚠ "Show All" reveals `7B (4.8GB)` with orange warning, `32B (20GB)` with red block

URLs point to `Qwen/...-GGUF` and `bartowski/...-GGUF` on Hugging Face.

---

## 💻 Hardware Filtering Logic (lib/services/hardware_service.dart:70)

```dart
recommendedMax = availableRamGB * 0.6
if (model.ram > totalRam * 0.85) → incompatible
else if (needed <= available) → compatible ✓
else if (needed <= available*1.5) → marginal ⚠
else → incompatible ✗
```

GPU: `gpu_service.dart` detects via `wmic`/`nvidia-smi` (Windows), `lspci`/`vulkaninfo` (Linux), `device_info_plus` (Android). If `vram >=2GB` and user pref `useGpu=true`, offload uses `vramRequiredGB` instead of RAM.

---

## 📄 PDF RAG (lib/services/pdf_service.dart:1)

- Viewer: `pdfx` (right panel desktop, tab mobile)
- Text extract: `syncfusion_flutter_pdf` `PdfTextExtractor` (50 pages / 30k chars limit for 4GB)
- Chunk: 800 tokens, 100 overlap
- Retrieve: keyword scoring (no embeddings to save RAM; future: MiniLM ONNX)
- Prompt: `Use this PDF context to answer...` injected as system + top 3 chunks

---

## ⚙️ Settings

- Show All Models toggle (persisted via SharedPreferences)
- Use GPU toggle (auto-detected, disabled if no GPU)
- Temperature slider (0 - 1.5)
- Ollama URL config (default `http://localhost:11434`)
- Hardware banner always visible in sidebar

Chat history persisted via `hive_ce_flutter` (encrypted? plain JSON). Messages support markdown (`flutter_markdown`) + streaming cursor `▌`.

---

## 🔐 Privacy

100% local inference when using GGUF or Ollama. No data leaves device. Only model downloads hit Hugging Face / Ollama registry.

---

## 📦 Releases

- **APK Debug:** `build/app/outputs/flutter-apk/app-debug.apk` (89M) - install directly
- **APK Release (split):** run `flutter build apk --release --split-per-abi` for `app-arm64-v8a-release.apk` (~40M)
- **EXE Release:** Build on Windows → `build/windows/x64/runner/Release/`
- **Web:** `build/web` - host for demo

GitHub Actions workflow `.github/workflows/build.yml` auto-builds both on push.

---

## 🐛 Troubleshooting

- **Ollama not running:** App shows demo mock response + instructions. Install Ollama, `ollama serve`, pull model.
- **Android download slow:** Hugging Face may throttle; try Ollama pull on desktop then copy GGUF to `/data/data/com.aitools.ai_tools/app_flutter/models/`.
- **Gradle build fail (Linux):** Upgrade Gradle to 8.14, AGP 8.11, Kotlin 2.2.20 (already done in `android/`). Use JDK 21.
- **Out of memory on 4GB:** Only use 0.5B-1.5B models. Close other apps. Q2 quant is smaller but lower quality.

---

## 📄 License

MIT - For personal use. Models have their own licenses (Qwen, DeepSeek).

Feedback: https://github.com/anomalyco/opencode

