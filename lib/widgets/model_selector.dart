import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/ai_model.dart';
import '../services/hardware_service.dart';
import 'model_logo.dart';

class ModelSelector extends StatefulWidget {
  const ModelSelector({super.key});

  @override
  State<ModelSelector> createState() => _ModelSelectorState();
}

class _ModelSelectorState extends State<ModelSelector> {
  String filterFamily = 'all';
  String search = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final selectedId = provider.getSelectedModelId();
    final selectedModel = provider.registry.findById(selectedId);

    List<AiModel> list = provider.filteredModels;
    if (filterFamily != 'all') list = list.where((m) => m.family == filterFamily).toList();
    if (search.isNotEmpty) list = list.where((m) => m.name.toLowerCase().contains(search.toLowerCase()) || m.params.contains(search)).toList();

    // Determine recommended model for empty state
    final recommended = provider.pickRecommendedModel();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.2))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Auto-download banner if downloading
          if (provider.isDownloading && provider.downloadingModel != null && provider.downloadProgress != null)
            Container(
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Downloading ${provider.downloadingModel!.name}...', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            Text(provider.downloadProgress!.status, style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        tooltip: 'Cancel',
                        onPressed: () => provider.cancelDownload(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (provider.downloadProgress!.percent / 100).clamp(0, 1),
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('${provider.downloadProgress!.percent.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      if (provider.downloadProgress!.total > 0)
                        Text('${(provider.downloadProgress!.received / 1024 / 1024).toStringAsFixed(1)}MB / ${(provider.downloadProgress!.total / 1024 / 1024).toStringAsFixed(1)}MB', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),

          // If no model downloaded and not downloading, show welcome auto card
          if (!provider.isDownloading && provider.downloadedModelIds.isEmpty && recommended != null)
            Container(
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16)),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Auto-setup for your device', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)), child: Text(provider.hardware?.ramLabel ?? '', style: const TextStyle(fontSize: 9))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Recommended: ${recommended.name} • ${recommended.displaySize}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  Text(recommended.description, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => provider.startDownload(recommended),
                      icon: const Icon(Icons.download, size: 16),
                      label: Text('Download ${recommended.params} • ${recommended.diskGB.toStringAsFixed(1)}GB (1-click)'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: OutlinedButton(onPressed: () => provider.storage.setAutoDownloadEnabled(false).then((_) => setState(() {})), child: const Text('Manual only', style: TextStyle(fontSize: 11)))),
                      const SizedBox(width: 8),
                      Text('Auto is ON', style: TextStyle(fontSize: 10, color: Colors.green.shade700)),
                    ],
                  ),
                  const Text('No Ollama needed. Direct GGUF download to app storage. Works offline after.', style: TextStyle(fontSize: 9, color: Colors.grey)),
                ],
              ),
            ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                const Icon(Icons.smart_toy_outlined, size: 18),
                const SizedBox(width: 8),
                const Text('AI Model', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const Spacer(),
                if (selectedModel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: _compatColor(provider.getCompat(selectedModel)).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                    child: Text(provider.hardwareService.compatibilityLabel(provider.getCompat(selectedModel)), style: TextStyle(fontSize: 10, color: _compatColor(provider.getCompat(selectedModel)), fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
          if (selectedModel != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.deepPurple.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.1))),
              child: Row(
                children: [
                  ModelLogo(family: selectedModel.family, size: 32),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(selectedModel.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(color: _familyColor(selectedModel.family).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                          child: Text(selectedModel.family.toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: _familyColor(selectedModel.family))),
                        ),
                      ]),
                      Text(selectedModel.displaySize, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      Text(selectedModel.description, style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 2),
                      const SizedBox(height: 4),
                      Row(children: [
                        if (provider.downloadedModelIds.contains(selectedModel.id))
                          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)), child: const Text('✓ Ready', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)))
                        else
                          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)), child: const Text('Not downloaded', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold))),
                        const SizedBox(width: 6),
                        Text('Tap a model below to switch', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                      ]),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  Icon(_compatIcon(provider.getCompat(selectedModel)), color: _compatColor(provider.getCompat(selectedModel))),
                ],
              ),
            ),
          // Controls
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: TextField(
                      decoration: InputDecoration(hintText: 'Search models...', prefixIcon: const Icon(Icons.search, size: 16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0), isDense: true),
                      onChanged: (v) => setState(() => search = v),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: filterFamily,
                  underline: const SizedBox(),
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'qwen', child: Text('Qwen')),
                    DropdownMenuItem(value: 'deepseek', child: Text('DeepSeek')),
                    DropdownMenuItem(value: 'llama', child: Text('Llama')),
                    DropdownMenuItem(value: 'mistral', child: Text('Mistral')),
                    DropdownMenuItem(value: 'gemma', child: Text('Gemma')),
                    DropdownMenuItem(value: 'phi', child: Text('Phi')),
                  ],
                  onChanged: (v) => setState(() => filterFamily = v!),
                ),
              ],
            ),
          ),
          // Show all toggle + auto toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Checkbox(value: provider.showAllModels, onChanged: (v) => provider.toggleShowAll(v!), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact),
                    const Text('Show all models', style: TextStyle(fontSize: 11)),
                    const Spacer(),
                    Text('${list.length}/${provider.allModels.length}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(value: provider.storage.getAutoDownloadEnabled(), onChanged: (v) async { await provider.storage.setAutoDownloadEnabled(v!); setState(() {}); }, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact),
                    const Text('Auto-download best for this device', style: TextStyle(fontSize: 11)),
                    const Spacer(),
                    if (!provider.storage.getAutoDownloadEnabled() && provider.downloadedModelIds.isEmpty)
                      TextButton(onPressed: () => provider.retryAutoDownload(), child: const Text('Auto now', style: TextStyle(fontSize: 11))),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 8),
          // List
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('No models for this filter.\nTry "Show all"', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)))
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final m = list[i];
                      final compat = provider.getCompat(m);
                      final isSelected = m.id == selectedId;
                      final isDownloaded = provider.downloadedModelIds.contains(m.id);
                      final isThisDownloading = provider.isDownloading && provider.downloadingModel?.id == m.id;

                      Widget trailing;
                      if (isThisDownloading) {
                        trailing = SizedBox(
                          width: 60,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(value: provider.downloadProgress?.percent != null ? provider.downloadProgress!.percent / 100 : null, strokeWidth: 2)),
                              const SizedBox(height: 2),
                              Text('${provider.downloadProgress?.percent.toStringAsFixed(0) ?? 0}%', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      } else if (isDownloaded) {
                        trailing = isSelected ? const Icon(Icons.check_circle, color: Colors.deepPurple, size: 22) : const Icon(Icons.check_circle_outline, color: Colors.green, size: 18);
                      } else {
                        trailing = IconButton(
                          icon: const Icon(Icons.download, size: 18, color: Colors.deepPurple),
                          tooltip: 'Download ${m.diskGB}GB • chat with current model while downloading',
                          onPressed: () async {
                            // Light: download in background, keep current model for chatting
                            await provider.startDownload(m);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloading ${m.name} in background • you can still chat with ${provider.registry.findById(provider.getSelectedModelId())?.name ?? "current model"}')));
                            }
                          },
                        );
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.deepPurple.withValues(alpha: 0.1) : null,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected ? Border.all(color: Colors.deepPurple.withValues(alpha: 0.3)) : Border.all(color: Colors.grey.withValues(alpha: 0.12)),
                        ),
                        child: ListTile(
                          dense: true,
                          leading: ModelLogo(family: m.family, size: 28),
                          title: Row(children: [
                            Expanded(child: Text(m.name, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: _familyColor(m.family).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                              child: Text(m.family.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _familyColor(m.family))),
                            ),
                          ]),
                          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(m.displaySize + ' • ctx ${m.contextLength}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Row(children: [
                              Icon(_compatIcon(compat), size: 12, color: _compatColor(compat)),
                              const SizedBox(width: 4),
                              Text(provider.hardwareService.compatibilityLabel(compat), style: TextStyle(fontSize: 10, color: _compatColor(compat), fontWeight: FontWeight.w600)),
                              const SizedBox(width: 6),
                              if (isDownloaded)
                                Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)), child: const Text('Downloaded', style: TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold)))
                              else if (isThisDownloading)
                                Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: Colors.deepPurple.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)), child: Text(provider.downloadProgress?.status ?? 'Downloading', style: const TextStyle(fontSize: 8, color: Colors.deepPurple, fontWeight: FontWeight.bold))),
                            ]),
                            if (isThisDownloading && provider.downloadProgress != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: LinearProgressIndicator(value: provider.downloadProgress!.percent / 100, minHeight: 3, backgroundColor: Colors.grey.withValues(alpha: 0.2)),
                              ),
                          ]),
                          trailing: trailing,
                          onTap: () async {
                            provider.selectModel(m.id);
                            if (!isDownloaded && !isThisDownloading) {
                              // Auto prompt download
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text('Download ${m.name}?'),
                                  content: Text('${m.diskGB.toStringAsFixed(1)}GB • ${m.description}\n\nOn desktop uses Ollama if installed, else direct download.\nOn mobile direct GGUF to app storage.\n\nNeeds ${m.ramRequiredGB}GB RAM, you have ${provider.hardware?.totalRamGB.toStringAsFixed(1)}GB.'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Just select')),
                                    FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Download & Select')),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await provider.startDownload(m);
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
          // Download hint
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: Colors.orange),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    provider.isDownloading
                        ? 'Downloading in background — you can chat after it finishes. Keep app open.'
                        : 'Auto-download is ${provider.storage.getAutoDownloadEnabled() ? "ON" : "OFF"}. Tap any model → Download. First model is ~${recommended?.diskGB.toStringAsFixed(1) ?? "1.0"}GB.',
                    style: TextStyle(fontSize: 10, color: Colors.orange.shade800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _compatColor(ModelCompatibility c) {
    switch (c) {
      case ModelCompatibility.compatible:
        return Colors.green;
      case ModelCompatibility.marginal:
        return Colors.orange;
      case ModelCompatibility.incompatible:
        return Colors.red;
    }
  }

  Color _familyColor(String family) {
    final f = family.toLowerCase();
    if (f.contains('deepseek')) return const Color(0xFF1A73E8);
    if (f.contains('qwen')) return const Color(0xFF00A67D);
    if (f.contains('llama')) return const Color(0xFF9333EA);
    if (f.contains('mistral')) return const Color(0xFFEA580C);
    if (f.contains('gemma')) return const Color(0xFF0EA5E9);
    if (f.contains('phi')) return const Color(0xFF6366F1);
    return Colors.deepPurple;
  }

  IconData _compatIcon(ModelCompatibility c) {
    switch (c) {
      case ModelCompatibility.compatible:
        return Icons.check_circle_outline;
      case ModelCompatibility.marginal:
        return Icons.warning_amber;
      case ModelCompatibility.incompatible:
        return Icons.block;
    }
  }
}
