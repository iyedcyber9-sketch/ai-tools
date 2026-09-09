import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class GpuInfo {
  final bool hasGpu;
  final String gpuName;
  final double vramGB;
  final String backend; // vulkan, cuda, opencl, metal, none

  GpuInfo({required this.hasGpu, required this.gpuName, required this.vramGB, required this.backend});
}

class GpuService {
  GpuInfo? _cached;

  Future<GpuInfo> detectGpu() async {
    if (_cached != null) return _cached!;
    bool hasGpu = false;
    String name = 'CPU Only';
    double vram = 0;
    String backend = 'none';

    try {
      if (Platform.isWindows) {
        // Try wmic detection
        final res = await Process.run('wmic', ['path', 'win32_VideoController', 'get', 'name']);
        if (res.exitCode == 0) {
          final out = res.stdout.toString().toLowerCase();
          if (out.contains('nvidia')) {
            hasGpu = true;
            name = 'NVIDIA GPU';
            backend = 'cuda';
            vram = 6; // guess, real detection needs nvidia-smi
            try {
              final nvidia = await Process.run('nvidia-smi', ['--query-gpu=memory.total', '--format=csv,noheader,nounits']);
              if (nvidia.exitCode == 0) {
                final mb = int.tryParse(nvidia.stdout.toString().trim().split('\n').first) ?? 0;
                vram = mb / 1024;
                name = 'NVIDIA ${vram.toStringAsFixed(0)}GB';
              }
            } catch (_) {}
          } else if (out.contains('amd') || out.contains('radeon')) {
            hasGpu = true;
            name = 'AMD GPU';
            backend = 'vulkan';
            vram = 4;
          } else if (out.contains('intel') && out.contains('arc')) {
            hasGpu = true;
            name = 'Intel Arc';
            backend = 'vulkan';
            vram = 4;
          }
        }
      } else if (Platform.isLinux) {
        final res = await Process.run('lspci', []);
        if (res.exitCode == 0) {
          final out = res.stdout.toString().toLowerCase();
          if (out.contains('nvidia')) {
            hasGpu = true;
            name = 'NVIDIA GPU';
            backend = 'cuda';
            vram = 4;
          } else if (out.contains('amd') || out.contains('radeon')) {
            hasGpu = true;
            name = 'AMD GPU';
            backend = 'vulkan';
            vram = 4;
          }
        }
        // Check vulkaninfo
        try {
          final vk = await Process.run('vulkaninfo', ['--summary']);
          if (vk.exitCode == 0) hasGpu = true;
        } catch (_) {}
      } else if (Platform.isAndroid) {
        // Android GPU via device_info
        final plugin = DeviceInfoPlugin();
        final android = await plugin.androidInfo;
        // Most modern Adreno/Mali support OpenCL/Vulkan via llama.cpp
        // We treat as GPU capable but limited VRAM shared with RAM
        hasGpu = true;
        name = 'Mobile GPU (shared)';
        backend = 'opencl';
        vram = 2; // shared, conservative
        // If device has >6GB RAM, allow more VRAM
        if (android.version.sdkInt >= 29) {
          hasGpu = true;
        }
      }
    } catch (_) {}

    _cached = GpuInfo(hasGpu: hasGpu, gpuName: name, vramGB: vram, backend: backend);
    return _cached!;
  }

  bool shouldUseGpu(GpuInfo info, {bool userPrefGpu = true}) {
    if (!userPrefGpu) return false;
    if (!info.hasGpu) return false;
    if (info.vramGB < 2) return false;
    return true;
  }
}
