import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/chat_view.dart';
import '../widgets/pdf_preview.dart';
import '../widgets/model_selector.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final hasPdf = provider.currentSession?.pdfPath != null;
    final isMobile = MediaQuery.of(context).size.width < 900;

    if (isMobile) {
      final tabCount = hasPdf ? 3 : 2;
      return DefaultTabController(
        length: tabCount,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('AI Tools', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            bottom: TabBar(tabs: hasPdf ? const [
              Tab(icon: Icon(Icons.chat), text: 'Chat'),
              Tab(icon: Icon(Icons.picture_as_pdf), text: 'PDF'),
              Tab(icon: Icon(Icons.smart_toy), text: 'Models'),
            ] : const [
              Tab(icon: Icon(Icons.chat), text: 'Chat'),
              Tab(icon: Icon(Icons.smart_toy), text: 'Models'),
            ]),
          ),
          drawer: const Drawer(child: Sidebar()),
          body: hasPdf
              ? const TabBarView(children: [
                  ChatView(),
                  PdfPreview(),
                  ModelSelector(),
                ])
              : const TabBarView(children: [
                  ChatView(),
                  ModelSelector(),
                ]),
        ),
      );
    }

    // Desktop: 3-pane — PDF preview only when a PDF is loaded
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
          const VerticalDivider(width: 1),
          // Middle: Chat
          const Expanded(flex: 5, child: ChatView()),
          const VerticalDivider(width: 1),
          // Right: conditional PDF + Model selector
          Expanded(
            flex: 4,
            child: hasPdf
                ? Column(
                    children: [
                      const Expanded(flex: 5, child: PdfPreview()),
                      const Divider(height: 1),
                      const Expanded(flex: 6, child: ModelSelector()),
                      // Quick hide PDF bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color: Colors.grey.withValues(alpha: 0.08),
                        child: Row(
                          children: [
                            const Icon(Icons.picture_as_pdf, size: 14, color: Colors.red),
                            const SizedBox(width: 6),
                            Expanded(child: Text(provider.currentSession!.pdfPath!.split('/').last, style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis)),
                            TextButton(onPressed: () => provider.clearPdf(), child: const Text('Hide PDF', style: TextStyle(fontSize: 10))),
                          ],
                        ),
                      ),
                    ],
                  )
                : const ModelSelector(),
          ),
        ],
      ),
    );
  }
}
