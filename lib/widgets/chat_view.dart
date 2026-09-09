import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/chat_models.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  Future<void> _pickPdf(AppProvider provider) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true, // allow bytes fallback for Android scoped storage
      );
      if (result == null || result.files.isEmpty) return;
      final picked = result.files.single;
      String? path = picked.path;
      List<int>? bytes = picked.bytes;
      String fileName = picked.name;

      // If path is null or file not accessible, use bytes
      if (path == null || bytes != null) {
        if (bytes == null && path != null) {
          try {
            bytes = await File(path).readAsBytes();
          } catch (_) {}
        }
        if (bytes != null) {
          // Save bytes to app storage
          final tmpDir = await provider.pdfService.copyPdfToAppStorage('/tmp/$fileName', bytes: bytes, fileName: fileName);
          path = tmpDir;
        }
      }

      if (path == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not access PDF file'), backgroundColor: Colors.red));
        return;
      }

      // Copy to app storage for persistence (handles scoped storage and original file moved)
      final storedPath = await provider.pdfService.copyPdfToAppStorage(path, bytes: bytes, fileName: fileName);

      // Pre-validate file exists and looks like PDF
      final f = File(storedPath);
      if (!await f.exists() || await f.length() == 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid PDF file'), backgroundColor: Colors.red));
        return;
      }

      final text = await provider.pdfService.extractText(storedPath);
      await provider.setPdf(storedPath, text);
      if (!mounted) return;
      if (text.startsWith('Error:')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF added but text extract failed: $text'), backgroundColor: Colors.orange, duration: const Duration(seconds: 4)));
      } else if (text.contains('no extractable text')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF preview ready — but it appears to be scanned images (no text). AI can still see file name, but use text-based PDF for Q&A.'), duration: const Duration(seconds: 4)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF loaded: $fileName (${text.length} chars) — preview on right (desktop) or PDF tab (mobile)')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add PDF: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final session = provider.currentSession;
    if (session == null) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        // Top bar
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2)))),
          child: Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(session.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${session.messages.length} messages • ${session.modelId ?? provider.getSelectedModelId()}', style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1),
                ]),
              ),
              if (session.pdfPath == null)
                FilledButton.tonalIcon(
                  onPressed: () => _pickPdf(provider),
                  icon: const Icon(Icons.attach_file, size: 16),
                  label: const Text('Add PDF', style: TextStyle(fontSize: 11)),
                )
              else
                IconButton(onPressed: () => provider.clearPdf(), icon: const Icon(Icons.picture_as_pdf, color: Colors.red), tooltip: 'Clear PDF: ${session.pdfPath!.split('/').last}'),
              const SizedBox(width: 4),
              FilledButton.tonalIcon(onPressed: provider.isGenerating ? null : () => _showClear(context), icon: const Icon(Icons.delete_outline, size: 16), label: const Text('Clear', style: TextStyle(fontSize: 12))),
            ],
          ),
        ),
        // Auto-download banner in chat if needed
        if (provider.isDownloading && provider.downloadingModel != null)
          Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.deepPurple.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.2))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Downloading ${provider.downloadingModel!.name} for you — ${provider.downloadProgress?.status ?? "preparing..."}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                    TextButton(onPressed: () => provider.cancelDownload(), child: const Text('Cancel', style: TextStyle(fontSize: 11))),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: (provider.downloadProgress?.percent ?? 0) / 100, minHeight: 4),
                const SizedBox(height: 4),
                Text('${provider.downloadProgress?.percent.toStringAsFixed(1) ?? "0"}% • ${(provider.downloadProgress?.received ?? 0) / 1024 / 1024 < 1024 ? "${((provider.downloadProgress?.received ?? 0) / 1024 / 1024).toStringAsFixed(1)}MB" : "${((provider.downloadProgress?.received ?? 0) / 1024 / 1024 / 1024).toStringAsFixed(2)}GB"}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                const Text('Keep app open — first chat will be ready automatically. Works offline after.', style: TextStyle(fontSize: 9, color: Colors.grey)),
              ],
            ),
          ),
        if (!provider.isDownloading && provider.downloadedModelIds.isEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.withValues(alpha: 0.2))),
            child: Row(
              children: [
                const Icon(Icons.download, color: Colors.orange, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('No model yet — auto-download will start for ${provider.pickRecommendedModel()?.name ?? "best for your device"}. Or pick one on the right.', style: const TextStyle(fontSize: 11))),
                FilledButton.tonal(onPressed: () => provider.retryAutoDownload(), child: const Text('Start now', style: TextStyle(fontSize: 11))),
              ],
            ),
          ),
        if (session.pdfPath != null)
          Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blue.withValues(alpha: 0.2))),
            child: Row(children: [
              const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text('PDF: ${session.pdfPath!.split('/').last} • AI can answer questions about this document', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
              TextButton(onPressed: () => provider.clearPdf(), child: const Text('Remove', style: TextStyle(fontSize: 11))),
            ]),
          ),
        Expanded(
          child: session.messages.isEmpty
              ? _emptyState(context, provider)
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(16),
                  itemCount: session.messages.length,
                  itemBuilder: (context, i) {
                    final msg = session.messages[i];
                    final isUser = msg.role == MessageRole.user;
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.deepPurple : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16).copyWith(bottomRight: isUser ? const Radius.circular(4) : null, bottomLeft: !isUser ? const Radius.circular(4) : null),
                          border: Border.all(color: isUser ? Colors.deepPurple.withOpacity(0.2) : Colors.grey.withOpacity(0.15)),
                        ),
                        child: isUser
                            ? Text(msg.content, style: TextStyle(color: isUser ? Colors.white : Theme.of(context).colorScheme.onSurface, fontSize: 13, height: 1.4))
                            : MarkdownBody(
                                data: msg.content.isEmpty && msg.isStreaming ? '▌' : msg.content,
                                selectable: true,
                                styleSheet: MarkdownStyleSheet(
                                  p: TextStyle(fontSize: 13, height: 1.5, color: Theme.of(context).colorScheme.onSurface),
                                  code: TextStyle(fontFamily: 'monospace', fontSize: 12, backgroundColor: Colors.black.withOpacity(0.06)),
                                  codeblockDecoration: BoxDecoration(color: Colors.black.withOpacity(0.06), borderRadius: BorderRadius.circular(6)),
                                  h1: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  h2: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  h3: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ),
                      ),
                    );
                  },
                ),
        ),
        if (provider.isGenerating && !provider.isVerifying)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: Colors.deepPurple.withValues(alpha: 0.06),
            child: Row(children: [
              const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
              const SizedBox(width: 10),
              const Text('Generating...', style: TextStyle(fontSize: 12, color: Colors.deepPurple)),
              const Spacer(),
              TextButton(onPressed: () => provider.stopGeneration(), child: const Text('Stop', style: TextStyle(fontSize: 12))),
            ]),
          ),
        if (provider.isVerifying)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: Colors.orange.withValues(alpha: 0.08),
            child: Row(children: [
              const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange)),
              const SizedBox(width: 10),
              const Text('Verifying answer for errors...', style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w600)),
              const SizedBox(width: 6),
              const Text('(checking facts)', style: TextStyle(fontSize: 10, color: Colors.grey)),
              const Spacer(),
              TextButton(onPressed: () => provider.stopGeneration(), child: const Text('Skip', style: TextStyle(fontSize: 12))),
            ]),
          ),
        // Input — disabled while downloading with no model
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _pickPdf(provider),
                icon: const Icon(Icons.picture_as_pdf, size: 20),
                tooltip: session.pdfPath == null ? 'Attach PDF' : 'Change PDF',
                color: session.pdfPath != null ? Colors.red : Colors.grey,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: 5,
                  minLines: 1,
                  enabled: !provider.isGenerating && !(provider.downloadedModelIds.isEmpty && provider.isDownloading),
                  decoration: InputDecoration(
                    hintText: provider.downloadedModelIds.isEmpty && provider.isDownloading
                        ? 'Downloading model... please wait'
                        : provider.downloadedModelIds.isEmpty
                            ? 'No model yet — will auto-download'
                            : session.pdfText != null
                                ? 'Ask about the PDF...'
                                : 'Message AI...',
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3))),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  ),
                  style: const TextStyle(fontSize: 13),
                  onSubmitted: (_) => _send(provider),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: provider.isGenerating || (provider.downloadedModelIds.isEmpty && provider.isDownloading) ? null : () => _send(provider),
                style: FilledButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(14), minimumSize: const Size(48, 48)),
                child: const Icon(Icons.send, size: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _emptyState(BuildContext context, AppProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.chat_bubble_outline, size: 48, color: Colors.deepPurple),
        const SizedBox(height: 12),
        const Text('Chat with your AI', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('All models run locally on your CPU/GPU for free. No API keys. Private.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 20),
        Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
          _suggestion(provider, 'Explain quantum computing simply'),
          _suggestion(provider, 'Write a Python function to sort a list'),
          _suggestion(provider, 'Summarize the PDF document'),
          _suggestion(provider, 'What is DeepSeek R1?'),
        ]),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Quick tips', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 8),
            const Text('• Middle chat • Right panel: PDF preview + model selector\n• Left: history & settings\n• Only models that fit your RAM are shown by default (toggle "Show all" to see all DeepSeek & Qwen)\n• PDF uploaded on right will be used to answer questions', style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.4)),
            const SizedBox(height: 10),
            Text('Hardware: ${provider.hardware?.ramLabel ?? ""}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            Text('GPU: ${provider.gpu?.gpuName ?? "detecting..."}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ]),
        ),
      ],
    );
  }

  Widget _suggestion(AppProvider p, String text) => ActionChip(
        label: Text(text, style: const TextStyle(fontSize: 11)),
        onPressed: () {
          _controller.text = text;
          _send(p);
        },
      );

  void _send(AppProvider provider) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    provider.sendMessage(text).then((_) => _scrollToBottom());
    _scrollToBottom();
  }

  void _showClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear chat?'),
        content: const Text('Messages will be deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              onPressed: () {
                final prov = context.read<AppProvider>();
                prov.clearCurrentChat();
                Navigator.pop(ctx);
              },
              child: const Text('Clear')),
        ],
      ),
    );
  }
}
