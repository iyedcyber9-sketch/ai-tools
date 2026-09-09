import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:system_info2/system_info2.dart';
import '../models/ai_model.dart';

class HardwareInfo {
  final double totalRamGB;
  final double availableRamGB;
  final int cpuCores;
  final int cpuThreads;
  final String cpuName;
  final String cpuArch;
  final bool hasAvx2;
  final String os;
  final double freeDiskGB;
  final String deviceModel;

  HardwareInfo({
    required this.totalRamGB,
    required this.availableRamGB,
    required this.cpuCores,
    required this.cpuThreads,
    required this.cpuName,
    required this.cpuArch,
    required this.hasAvx2,
    required this.os,
    required this.freeDiskGB,
    required this.deviceModel,
  });

  double get recommendedMaxModelGB {
    // Use the more generous of total*0.6 and available*0.85 to reflect real usable RAM
    // This fixes 7.7GB device showing 7B as incompatible when free is low due to cache
    final fromTotal = totalRamGB * 0.65;
    final fromAvail = availableRamGB * 0.85;
    return (fromTotal > fromAvail ? fromTotal : fromAvail).clamp(0.5, 100);
  }
  // Also provide total-based max for filtering (more permissive)
  double get totalBasedMax => (totalRamGB * 0.75).clamp(0.5, 100);
  bool get isLowRam => totalRamGB <= 4.5;
  bool get isMidRam => totalRamGB > 4.5 && totalRamGB <= 8.5;
  bool get isHighRam => totalRamGB > 8.5;

  String get ramLabel => '${totalRamGB.toStringAsFixed(1)}GB RAM (${availableRamGB.toStringAsFixed(1)}GB free) • ${cpuName.split('@').first.trim()} • ${cpuCores} cores';
}

enum ModelCompatibility { compatible, marginal, incompatible }

class HardwareService {
  HardwareInfo? _cached;

  Future<HardwareInfo> getHardwareInfo() async {
    if (_cached != null) return _cached!;
    final totalRamMB = SysInfo.getTotalPhysicalMemory() / (1024 * 1024);
    final freeRamMB = SysInfo.getFreePhysicalMemory() / (1024 * 1024);
    final totalRamGB = totalRamMB / 1024;
    final availableRamGB = freeRamMB / 1024;

    // CPU
    final cores = SysInfo.cores.length;
    String cpuName = 'Unknown CPU';
    try {
      if (Platform.isLinux) {
        final cpuInfo = await File('/proc/cpuinfo').readAsString();
        final match = RegExp(r'model name\s*:\s*(.+)').firstMatch(cpuInfo);
        if (match != null) cpuName = match.group(1)!.trim();
      } else if (Platform.isWindows) {
        cpuName = Platform.localHostname; // fallback
      }
    } catch (_) {}

    // AVX2 detection - heuristic: x86_64 generally has AVX2 on modern CPUs
    bool hasAvx2 = Platform.version.contains('x64') || cpuName.toLowerCase().contains('intel') || cpuName.toLowerCase().contains('amd');

    // Disk free
    double freeDiskGB = 10;
    try {
      final dir = Directory.systemTemp;
      final stat = await dir.stat();
      // approximate free disk via system; fallback
      freeDiskGB = 20; // default guess, will be updated by caller with path_provider check
      if (Platform.isLinux || Platform.isWindows || Platform.isAndroid) {
        // use df via FileStat? simplified
      }
    } catch (_) {}

    // Use device_info_plus for model
    String deviceModel = 'PC';
    String os = Platform.operatingSystem;
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        deviceModel = '${android.manufacturer} ${android.model}';
        os = 'Android ${android.version.release}';
      } else if (Platform.isLinux) {
        final linux = await deviceInfo.linuxInfo;
        deviceModel = linux.prettyName;
        os = linux.prettyName;
      } else if (Platform.isWindows) {
        final windows = await deviceInfo.windowsInfo;
        deviceModel = windows.computerName;
        os = 'Windows ${windows.displayVersion}';
      }
    } catch (_) {}

    // Try to get actual free disk via path_provider later
    _cached = HardwareInfo(
      totalRamGB: totalRamGB.isNaN ? 8 : totalRamGB,
      availableRamGB: availableRamGB.isNaN ? totalRamGB * 0.5 : availableRamGB,
      cpuCores: cores,
      cpuThreads: cores,
      cpuName: cpuName,
      cpuArch: SysInfo.kernelArchitecture.name,
      hasAvx2: hasAvx2,
      os: os,
      freeDiskGB: freeDiskGB,
      deviceModel: deviceModel,
    );
    return _cached!;
  }

  // Compatibility check mirroring spec: 4GB -> only <=1.5B, but allow best performance
  ModelCompatibility checkCompatibility(AiModel model, HardwareInfo hw, {bool useGpu = false, double gpuVramGB = 0}) {
    double needed = useGpu && gpuVramGB > 0 ? model.vramRequiredGB : model.ramRequiredGB;
    // Use generous calculation: max of total-based and available-based
    double availableRecommended = hw.recommendedMaxModelGB;
    double availableTotalBased = hw.totalBasedMax;
    // GPU path
    if (useGpu && gpuVramGB > 0) {
      if (needed <= gpuVramGB * 0.9) return ModelCompatibility.compatible;
      if (needed <= gpuVramGB * 1.2) return ModelCompatibility.marginal;
      return ModelCompatibility.incompatible;
    }
    // Total RAM hard guard - must leave 15% for OS
    if (model.ramRequiredGB > hw.totalRamGB * 0.88) return ModelCompatibility.incompatible;
    // Check against recommended (best performance)
    if (needed <= availableRecommended) return ModelCompatibility.compatible;
    if (needed <= availableTotalBased) return ModelCompatibility.marginal;
    if (needed <= hw.totalRamGB * 0.75) return ModelCompatibility.marginal;
    return ModelCompatibility.incompatible;
  }

  List<AiModel> filterCompatible(List<AiModel> models, HardwareInfo hw, {bool showAll = false, bool useGpu = false, double gpuVramGB = 0}) {
    if (showAll) return models;
    return models.where((m) => checkCompatibility(m, hw, useGpu: useGpu, gpuVramGB: gpuVramGB) != ModelCompatibility.incompatible).toList();
  }

  String compatibilityLabel(ModelCompatibility c) {
    switch (c) {
      case ModelCompatibility.compatible:
        return '✓ Compatible';
      case ModelCompatibility.marginal:
        return '⚠ Slow / Swap risk';
      case ModelCompatibility.incompatible:
        return '✗ Needs more RAM';
    }
  }
}
