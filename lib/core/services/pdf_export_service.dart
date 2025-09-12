import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:convert';

// ignore_for_file: prefer_const_constructors
class PdfExportService {
  static final _pageFormat = PdfPageFormat(
    21.0 * PdfPageFormat.cm, // A5 width
    29.7 * PdfPageFormat.cm, // A5 height
    marginTop: 2.0 * PdfPageFormat.cm,
    marginBottom: 2.5 * PdfPageFormat.cm,
    marginLeft: 2.5 * PdfPageFormat.cm,
    marginRight: 2.0 * PdfPageFormat.cm,
  );

  static Future<void> exportBookToPdf({
    required String bookTitle,
    required List<Map<String, dynamic>> chapters,
    required BuildContext context,
  }) async {
    try {
      // Create PDF document
      final pdf = pw.Document();

      // Add title page
      pdf.addPage(
        pw.MultiPage(
          pageFormat: _pageFormat,
          build: (pw.Context context) => [
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              child: pw.Center(
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      bookTitle,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 40),
                    pw.Text(
                      'Exported from Alhuda Library App',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      'Generated on ${DateTime.now().toString().split(' ')[0]}',
                      style: pw.TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

      // Add table of contents
      if (chapters.length > 1) {
        pdf.addPage(
          pw.MultiPage(
            pageFormat: _pageFormat,
            build: (pw.Context context) {
              final tocItems = chapters.asMap().entries.map((entry) {
                final index = entry.key;
                final chapter = entry.value;
                return pw.Padding(
                  padding: pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(
                    '${index + 1}. ${chapter['title'] ?? 'Chapter ${index + 1}'}',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                );
              }).toList();

              return [
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    'Table of Contents',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: tocItems,
                ),
              ];
            },
          ),
        );
      }

      // Add chapters
      for (int i = 0; i < chapters.length; i++) {
        final chapter = chapters[i];
        final chapterTitle = chapter['title'] ?? 'Chapter ${i + 1}';
        final content = _parseContentToText(chapter['content'] ?? '');

        pdf.addPage(
          pw.MultiPage(
            pageFormat: _pageFormat,
            footer: (pw.Context context) {
              return pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.symmetric(horizontal: 8),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        bookTitle,
                        style: pw.TextStyle(fontSize: 9),
                        overflow: pw.TextOverflow.clip,
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text(
                        'Page ${context.pageNumber}',
                        style: pw.TextStyle(fontSize: 9),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            },
            build: (pw.Context context) => [
              // Chapter title
              pw.Text(
                chapterTitle,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              // Content
              pw.Text(
                content,
                style: pw.TextStyle(fontSize: 12, lineSpacing: 1.5),
                textAlign: pw.TextAlign.justify,
              ),
            ],
          ),
        );
      }

      // Save PDF
      await _savePdf(pdf, bookTitle, context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static String _parseContentToText(String content) {
    if (content.isEmpty) return '';

    try {
      // Parse as JSON (editor blocks)
      final List<dynamic> blocks = jsonDecode(content);
      final rawText = blocks
          .map((block) {
            if (block is Map<String, dynamic>) {
              return block['content']?.toString() ?? '';
            }
            return block.toString();
          })
          .where((text) => text.isNotEmpty)
          .join('\n\n');
      return rawText;
    } catch (e) {
      // If not JSON, return as plain text
      return content;
    }
  }

  static Future<void> _savePdf(
    pw.Document pdf,
    String bookTitle,
    BuildContext context,
  ) async {
    try {
      final Uint8List bytes = await pdf.save();
      final fileName = '${bookTitle.replaceAll(RegExp(r'[^\w\s-]'), '')}.pdf';

      if (kIsWeb) {
        // For web platform, trigger direct download
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);

        // Create a link element
        final anchor = html.AnchorElement()
          ..href = url
          ..style.display = 'none'
          ..download = fileName;

        // Add to document, click and remove
        html.document.body?.append(anchor);
        anchor.click();
        anchor.remove();

        // Clean up
        html.Url.revokeObjectUrl(url);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF downloaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // For mobile/desktop platforms
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(bytes);

        if (context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('PDF Exported Successfully'),
                content: Text('PDF saved to: ${file.path}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await SharePlus.instance.share(
                        ShareParams(text: 'Check out this book: $bookTitle'),
                      );
                    },
                    child: const Text('Share'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
