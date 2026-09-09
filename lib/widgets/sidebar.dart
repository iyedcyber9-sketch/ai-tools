import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/chat_models.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(right: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2))),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI Tools', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Free Offline AI', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => provider.newChat(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Chat'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Hardware banner
          if (provider.hardware != null)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.deepPurple.withOpacity(0.15))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.memory, size: 14, color: Colors.deepPurple),
                    const SizedBox(width: 6),
                    Expanded(child: Text(provider.hardware!.ramLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                  ]),
                  const SizedBox(height: 4),
                  Text('${provider.hardware!.cpuName} • ${provider.hardware!.cpuCores} cores', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: provider.hardware!.isLowRam ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                      child: Text(provider.hardware!.isLowRam ? '4GB Mode' : provider.hardware!.isMidRam ? '8GB Mode' : 'High RAM', style: TextStyle(fontSize: 10, color: provider.hardware!.isLowRam ? Colors.orange.shade800 : Colors.green.shade700, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(provider.gpu?.hasGpu == true ? 'GPU: ${provider.gpu!.gpuName}' : 'CPU Only', style: const TextStyle(fontSize: 10, color: Colors.grey), overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                ],
              ),
            ),
          // History
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('History', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey)),
                const Spacer(),
                Text('${provider.sessions.length}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: provider.sessions.length,
              itemBuilder: (context, i) {
                final s = provider.sessions[i];
                final isSelected = provider.currentSession?.id == s.id;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.deepPurple.withOpacity(0.12) : null,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected ? Border.all(color: Colors.deepPurple.withOpacity(0.2)) : null,
                  ),
                  child: ListTile(
                    dense: true,
                    title: Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                    subtitle: Text(s.preview, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    leading: Icon(isSelected ? Icons.chat_bubble : Icons.chat_bubble_outline, size: 18, color: isSelected ? Colors.deepPurple : Colors.grey),
                    trailing: PopupMenuButton(
                      icon: const Icon(Icons.more_horiz, size: 16),
                      onSelected: (v) {
                        if (v == 'delete') provider.deleteSession(s.id);
                        if (v == 'rename') _showRename(context, s);
                      },
                      itemBuilder: (c) => [
                        const PopupMenuItem(value: 'rename', child: Text('Rename')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                    onTap: () => provider.switchSession(s),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          // Footer / Settings
          ListTile(
            leading: const Icon(Icons.settings, size: 20),
            title: const Text('Settings', style: TextStyle(fontSize: 13)),
            subtitle: const Text('Model, temp, Ollama', style: TextStyle(fontSize: 11)),
            onTap: () => _showSettings(context),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(provider.statusMessage ?? '', style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 3),
          ),
        ],
      ),
    );
  }

  void _showRename(BuildContext context, ChatSession s) {
    final c = TextEditingController(text: s.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Chat'),
        content: TextField(controller: c, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              onPressed: () {
                context.read<AppProvider>().renameSession(s.id, c.text.trim().isEmpty ? 'Untitled' : c.text.trim());
                Navigator.pop(ctx);
              },
              child: const Text('Save')),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(context: context, builder: (_) => const SettingsDialog());
  }
}

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return AlertDialog(
      title: const Text('Settings'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Auto-download best model', style: TextStyle(fontSize: 13)),
                subtitle: Text(provider.storage.getAutoDownloadEnabled() ? 'On first launch, auto fetch recommended model for your RAM' : 'Manual: you pick and tap Download', style: const TextStyle(fontSize: 11)),
                value: provider.storage.getAutoDownloadEnabled(),
                onChanged: (v) async {
                  await provider.storage.setAutoDownloadEnabled(v);
                  (context as Element).markNeedsBuild();
                  if (v && provider.downloadedModelIds.isEmpty) provider.retryAutoDownload();
                },
              ),
              SwitchListTile(
                title: const Text('Low PC Mode (4GB)', style: TextStyle(fontSize: 13)),
                subtitle: Text(provider.isLowPcMode || (provider.hardware?.isLowRam ?? false) ? 'Light: Q2/0.5B-1.5B only, throttled download, chat while downloading' : 'Balanced performance', style: const TextStyle(fontSize: 11)),
                value: provider.isLowPcMode || (provider.hardware?.isLowRam ?? false),
                onChanged: (v) async => await provider.setLowPcMode(v),
              ),
              SwitchListTile(
                title: const Text('Verify answers before showing', style: TextStyle(fontSize: 13)),
                subtitle: Text(provider.storage.getVerifyResponses() ? 'AI double-checks for errors, then shows corrected answer (slower, more accurate)' : 'Show raw answer immediately (faster)', style: const TextStyle(fontSize: 11)),
                value: provider.storage.getVerifyResponses(),
                onChanged: (v) async {
                  await provider.storage.setVerifyResponses(v);
                  (context as Element).markNeedsBuild();
                },
              ),
              if (provider.isDownloading && provider.downloadingModel != null)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.deepPurple.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Downloading ${provider.downloadingModel!.name} in background...', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('You can still chat with ${provider.downloadedModelIds.isNotEmpty ? provider.registry.findById(provider.downloadedModelIds.first)?.name ?? "downloaded model" : "current model"}', style: const TextStyle(fontSize: 10, color: Colors.green)),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(value: (provider.downloadProgress?.percent ?? 0) / 100),
                    const SizedBox(height: 4),
                    Text(provider.downloadProgress?.status ?? '', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    TextButton(onPressed: () => provider.cancelDownload(), child: const Text('Pause', style: TextStyle(fontSize: 11))),
                  ]),
                ),
              if (!provider.isDownloading && provider.downloadedModelIds.isEmpty && provider.pickRecommendedModel() != null)
                FilledButton.icon(
                  onPressed: () => provider.startDownload(provider.pickRecommendedModel()!),
                  icon: const Icon(Icons.download, size: 16),
                  label: Text('Auto-download ${provider.pickRecommendedModel()!.name}'),
                ),
              const Divider(height: 16),
              SwitchListTile(
                title: const Text('Show All Models', style: TextStyle(fontSize: 13)),
                subtitle: const Text('Show models that need more RAM (with warning)', style: TextStyle(fontSize: 11)),
                value: provider.showAllModels,
                onChanged: (v) => provider.toggleShowAll(v),
              ),
              SwitchListTile(
                title: const Text('Use GPU if available', style: TextStyle(fontSize: 13)),
                subtitle: Text(provider.gpu?.hasGpu == true ? 'GPU: ${provider.gpu!.gpuName} (${provider.gpu!.backend})' : 'No GPU detected - CPU only', style: const TextStyle(fontSize: 11)),
                value: provider.useGpu,
                onChanged: provider.gpu?.hasGpu == true ? (v) => provider.toggleUseGpu(v) : null,
              ),
              const SizedBox(height: 8),
              Text('Temperature: ${provider.temperature.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              Slider(value: provider.temperature, min: 0, max: 1.5, divisions: 15, label: provider.temperature.toStringAsFixed(2), onChanged: (v) => provider.setTemperature(v)),
              const Text('Lower = deterministic, Higher = creative', style: TextStyle(fontSize: 10, color: Colors.grey)),
              const Divider(height: 24),
              const Text('How it works', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              const Text('• First launch: app auto-picks best model for your RAM/CPU (e.g., 1.5B for 4GB) and downloads it with progress. No manual Ollama needed.\n• On desktop if Ollama is installed (ollama.com), it uses Ollama pull (faster, shared). Else direct Hugging Face download.\n• On Android: direct GGUF to app storage, offline after.\n• You can cancel, switch model, or disable auto in this settings.', style: TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(6)),
                child: const SelectableText('Manual Ollama (optional):\nollama pull qwen2.5:1.5b\nollama pull deepseek-coder:1.3b', style: TextStyle(fontFamily: 'monospace', fontSize: 11)),
              ),
            ],
          ),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    );
  }
}
