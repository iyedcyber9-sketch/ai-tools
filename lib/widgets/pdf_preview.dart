import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../providers/app_provider.dart';

class PdfPreview extends StatefulWidget {
  const PdfPreview({super.key});

  @override
  State<PdfPreview> createState() => _PdfPreviewState();
}

class _PdfPreviewState extends State<PdfPreview> {
  String? _pdfPath;
  final PdfViewerController _viewerController = PdfViewerController();
  int _pages = 0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<AppProvider>();
    final providerPath = provider.currentSession?.pdfPath;
    if (providerPath != null && _pdfPath != providerPath) {
      setState(() => _pdfPath = providerPath);
    } else if (providerPath == null && _pdfPath != null) {
      setState(() => _pdfPath = null);
    }
  }

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf'], withData: true);
      if (result == null || result.files.isEmpty) return;
      final picked = result.files.single;
      String? path = picked.path;
      List<int>? bytes = picked.bytes;
      String fileName = picked.name;

      if (path == null || bytes != null) {
        if (bytes == null && path != null) {
          try { bytes = await File(path).readAsBytes(); } catch (_) {}
        }
        if (bytes != null) {
          final provider = context.read<AppProvider>();
          final stored = await provider.pdfService.copyPdfToAppStorage('/tmp/$fileName', bytes: bytes, fileName: fileName);
          path = stored;
        }
      }
      if (path == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not access PDF file'), backgroundColor: Colors.red));
        return;
      }

      final provider = context.read<AppProvider>();
      final storedPath = await provider.pdfService.copyPdfToAppStorage(path, bytes: bytes, fileName: fileName);

      // Validate file exists and is PDF
      final f = File(storedPath);
      if (!await f.exists()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF file not found after copy'), backgroundColor: Colors.red));
        return;
      }
      final len = await f.length();
      if (len == 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF file is empty'), backgroundColor: Colors.red));
        return;
      }

      setState(() => _pdfPath = storedPath);

      // Extract text for RAG
      final text = await provider.pdfService.extractText(storedPath);
      await provider.setPdf(storedPath, text);
      if (!mounted) return;
      if (text.startsWith('Error:')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF added but extract failed: $text'), backgroundColor: Colors.orange, duration: const Duration(seconds: 4)));
      } else if (text.contains('no extractable text')) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF preview ready — scanned image PDF, use text PDF for AI Q&A'), duration: Duration(seconds: 4)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF loaded: $fileName (${text.length} chars) • ${text.length > 500 ? "AI can answer" : "short doc"}')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick PDF: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final session = provider.currentSession;
    final hasPdf = session?.pdfPath != null;
    final displayPath = _pdfPath ?? session?.pdfPath;

    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, border: Border(left: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)))),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)))),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf, size: 18, color: Colors.red),
                const SizedBox(width: 8),
                const Text('PDF Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const Spacer(),
                if (hasPdf)
                  IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () async {
                    setState(() => _pdfPath = null);
                    await provider.clearPdf();
                  }, tooltip: 'Remove PDF'),
              ],
            ),
          ),
          if (!hasPdf)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_file, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text('No PDF loaded', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    const Text('AI can answer questions about your PDF.\nUpload and ask "Summarize" or "What is on page 2?"', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 16),
                    FilledButton.icon(onPressed: _pickPdf, icon: const Icon(Icons.upload_file, size: 18), label: const Text('Upload PDF')),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(8)),
                      child: const Text('Supported: text-based PDFs (not scanned images). Max 50 pages / 30k chars extracted for 4GB devices. Works offline after upload.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.green.withValues(alpha: 0.07),
              child: Row(children: [
                const Icon(Icons.check_circle, size: 14, color: Colors.green),
                const SizedBox(width: 6),
                Expanded(child: Text((displayPath ?? '').split('/').last, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                Text('${provider.currentSession?.pdfText?.length ?? 0} chars', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ]),
            ),
            Expanded(
              child: displayPath == null
                  ? const Center(child: CircularProgressIndicator())
                  : SfPdfViewer.file(
                      File(displayPath),
                      controller: _viewerController,
                      onDocumentLoaded: (details) => setState(() => _pages = details.document.pages.count),
                      onDocumentLoadFailed: (details) => Center(child: Padding(padding: const EdgeInsets.all(16), child: Text('Failed to render PDF: ${details.error}\n\nText extraction: ${provider.currentSession?.pdfText?.substring(0, (provider.currentSession?.pdfText?.length ?? 0) > 200 ? 200 : provider.currentSession?.pdfText?.length ?? 0)}', style: const TextStyle(fontSize: 11, color: Colors.red)))),
                    ),
            ),
            if (_pages > 0)
              Container(
                padding: const EdgeInsets.all(8),
                child: Text('$_pages pages • AI will use extracted text to answer', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(onPressed: _pickPdf, icon: const Icon(Icons.swap_horiz, size: 16), label: const Text('Change PDF', style: TextStyle(fontSize: 12))),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
