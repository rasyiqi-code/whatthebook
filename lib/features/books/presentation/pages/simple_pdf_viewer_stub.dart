import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui' as ui;
// ignore: avoid_web_libraries_in_flutter
import 'package:web/web.dart' as web;

void initializeWebViewer(
  String pdfUrl, {
  required void Function(bool) onLoadingChanged,
}) {
  // No initialization needed for mobile PDF viewer
  onLoadingChanged(false);
}

class PdfViewerPage extends StatelessWidget {
  final String pdfUrl;

  const PdfViewerPage({super.key, required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Daftarkan viewType untuk iframe secara dinamis
      // viewType harus unik per url agar bisa reload PDF berbeda
      final viewType = 'iframe-pdf-viewer-${pdfUrl.hashCode}';
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
        final element = web.document.createElement('iframe') as web.HTMLElement;
        element.setAttribute('src', pdfUrl);
        element.style.border = 'none';
        element.style.width = '100%';
        element.style.height = '100%';
        return element;
      });
      return Scaffold(
        appBar: AppBar(title: const Text('PDF Viewer')),
        body: Center(
          child: SizedBox.expand(child: HtmlElementView(viewType: viewType)),
        ),
      );
    }
    // Untuk mobile, pakai PDFView
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Viewer')),
      body: PDFView(
        filePath: pdfUrl,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        onError: (error) {
          // Handle error
        },
        onPageError: (page, error) {
          // Handle page error
        },
      ),
    );
  }
}

Widget buildWebViewer(BuildContext context, bool isLoading, {String? pdfUrl}) {
  // For mobile platforms, show the PDF viewer page
  return PdfViewerPage(pdfUrl: pdfUrl ?? '');
}
