import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfService {
  Future<String> extractText(String pdfPath) async {
    try {
      final file = File(pdfPath);
      if (!await file.exists()) return 'Error: PDF file not found at $pdfPath';
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return 'Error: PDF file is empty';
      // Check PDF header
      if (bytes.length < 4 || String.fromCharCodes(bytes.take(4)) != '%PDF') {
        // Still try, but warn
      }
      final doc = PdfDocument(inputBytes: bytes);
      if (doc.pages.count == 0) {
        doc.dispose();
        return 'Error: PDF has no pages';
      }
      final extractor = PdfTextExtractor(doc);
      String fullText = '';
      try {
        for (int i = 0; i < doc.pages.count; i++) {
          try {
            final pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
            if (pageText.trim().isNotEmpty) {
              fullText += pageText;
              fullText += '\n\n';
            }
          } catch (e) {
            // Skip problematic page, continue
            fullText += '\n[Could not extract page ${i + 1}: $e]\n';
          }
          if (fullText.length > 30000) {
            fullText = fullText.substring(0, 30000) + '\n...[truncated to 30k chars for 4GB RAM]';
            break;
          }
          if (i >= 50) {
            fullText += '\n...[limited to 50 pages]';
            break;
          }
        }
      } finally {
        doc.dispose();
      }
      final trimmed = fullText.trim();
      if (trimmed.isEmpty) {
        return '[PDF has no extractable text — it may be scanned images. Preview still works, but AI cannot read text. Try a text-based PDF.]';
      }
      return trimmed;
    } catch (e) {
      // Provide more helpful message
      if (e.toString().contains('Password') || e.toString().contains('encrypted')) {
        return 'Error: PDF is password-protected/encrypted. Please provide an unprotected PDF.';
      }
      return 'Error extracting PDF text: $e';
    }
  }

  // Simple RAG: chunk text and find relevant chunks for a query (keyword scoring, no embeddings needed for 4GB devices)
  List<String> chunkText(String text, {int chunkSize = 800, int overlap = 100}) {
    if (text.isEmpty) return [];
    final chunks = <String>[];
    int start = 0;
    while (start < text.length) {
      int end = (start + chunkSize).clamp(0, text.length);
      chunks.add(text.substring(start, end));
      if (end >= text.length) break;
      start = end - overlap;
    }
    return chunks;
  }

  List<String> retrieveRelevant(String query, String fullText, {int topK = 3}) {
    final chunks = chunkText(fullText);
    if (chunks.isEmpty) return [];
    final qWords = query.toLowerCase().split(RegExp(r'\W+')).where((w) => w.length > 2).toSet();
    final scored = <MapEntry<String, int>>[];
    for (var c in chunks) {
      final lower = c.toLowerCase();
      int score = 0;
      for (var w in qWords) {
        if (lower.contains(w)) score++;
      }
      scored.add(MapEntry(c, score));
    }
    scored.sort((a, b) => b.value.compareTo(a.value));
    final top = scored.take(topK).where((e) => e.value > 0).map((e) => e.key).toList();
    if (top.isEmpty) {
      // fallback to first chunks
      return chunks.take(topK).toList();
    }
    return top;
  }

  String buildRagPrompt(String question, String pdfText) {
    // If pdfText is error placeholder, don't use it as context
    if (pdfText.startsWith('Error:') || pdfText.startsWith('[PDF has no extractable')) {
      return '''User asks about a PDF that has no readable text (scanned image or error).
PDF NOTE: $pdfText

USER QUESTION: $question

Explain that the PDF has no extractable text and suggest using a text-based PDF, but still try to answer generally if possible.''';
    }
    final relevant = retrieveRelevant(question, pdfText, topK: 3);
    final context = relevant.join('\n---\n');
    return '''Use the following PDF context to answer the user's question. If the answer is not in the context, say you couldn't find it in the document but try to answer generally.

PDF CONTEXT:
$context

USER QUESTION: $question

Answer concisely and cite relevant parts.''';
  }

  Future<String> copyPdfToAppStorage(String originalPath, {List<int>? bytes, String? fileName}) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final pdfDir = Directory('${dir.path}/pdfs');
      if (!await pdfDir.exists()) await pdfDir.create(recursive: true);
      final name = fileName ?? originalPath.split('/').last.split('\\').last;
      final safeName = name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final destPath = '${pdfDir.path}/$safeName';
      if (bytes != null && bytes.isNotEmpty) {
        await File(destPath).writeAsBytes(bytes);
      } else {
        final src = File(originalPath);
        if (await src.exists()) {
          await src.copy(destPath);
        } else {
          return originalPath; // fallback
        }
      }
      return destPath;
    } catch (_) {
      return originalPath;
    }
  }
}
