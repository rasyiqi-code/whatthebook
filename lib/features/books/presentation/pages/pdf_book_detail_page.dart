import 'package:flutter/material.dart';
import 'simple_pdf_viewer.dart';
import '../../../social/presentation/widgets/book_comment_section.dart';
import '../../../social/presentation/bloc/social_bloc.dart';
import '../../../../core/injection/injection_container.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/book_review_section.dart';

class PdfBookDetailPage extends StatelessWidget {
  final String pdfBookId;
  final String title;
  final String authorName;
  final String? coverImageUrl;
  final String pdfUrl;

  const PdfBookDetailPage({
    super.key,
    required this.pdfBookId,
    required this.title,
    required this.authorName,
    this.coverImageUrl,
    required this.pdfUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            if (coverImageUrl != null && coverImageUrl!.isNotEmpty)
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(coverImageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Title & Author
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Oleh $authorName',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Tombol Baca PDF
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Baca PDF'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdvancedPdfViewer(
                        bookId: pdfBookId,
                        pdfUrl: pdfUrl,
                        title: title,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            // Komentar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: BlocProvider<SocialBloc>(
                create: (_) => di.sl<SocialBloc>(),
                child: SizedBox(
                  height: 400, // Atur tinggi sesuai kebutuhan UI
                  child: BookCommentSection(bookId: pdfBookId, title: title),
                ),
              ),
            ),
            // Review
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: BookReviewSection(bookId: pdfBookId, title: title),
            ),
          ],
        ),
      ),
    );
  }
}
