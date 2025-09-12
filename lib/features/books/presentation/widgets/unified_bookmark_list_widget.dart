import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/injection/injection_container.dart';
import '../../domain/entities/unified_bookmark.dart';
import '../bloc/bookmark_bloc.dart';
import '../bloc/pdf_bookmark_bloc.dart';
import '../bloc/unified_bookmark_bloc.dart';
import '../bloc/unified_bookmark_event.dart';
import '../bloc/unified_bookmark_state.dart';
import '../pages/book_reader_page.dart';
import '../pages/simple_pdf_viewer.dart';

class UnifiedBookmarkListWidget extends StatelessWidget {
  const UnifiedBookmarkListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<UnifiedBookmarkBloc>()..add(GetAllUnifiedBookmarksEvent()),
      child: BlocConsumer<UnifiedBookmarkBloc, UnifiedBookmarkState>(
        listener: (context, state) {
          if (state is UnifiedBookmarkError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is UnifiedBookmarkLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UnifiedBookmarkError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<UnifiedBookmarkBloc>().add(
                        GetAllUnifiedBookmarksEvent(),
                      );
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (state is UnifiedBookmarksLoaded) {
            if (state.bookmarks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada bookmark',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambahkan bookmark saat membaca buku',
                      style: TextStyle(color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<UnifiedBookmarkBloc>().add(
                  GetAllUnifiedBookmarksEvent(),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.bookmarks.length,
                itemBuilder: (context, index) {
                  final bookmark = state.bookmarks[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: bookmark.coverImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                bookmark.coverImageUrl!,
                                width: 48,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 48,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      bookmark.type == BookmarkType.book
                                          ? Icons.book
                                          : Icons.picture_as_pdf,
                                      color: Colors.grey[600],
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(
                              width: 48,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                bookmark.type == BookmarkType.book
                                    ? Icons.book
                                    : Icons.picture_as_pdf,
                                color: Colors.grey[600],
                              ),
                            ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              bookmark.bookmarkName ??
                                  bookmark.bookTitle ??
                                  'Tanpa Judul',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: bookmark.type == BookmarkType.book
                                  ? Colors.blue.withValues(alpha: 102)
                                  : Colors.red.withValues(alpha: 102),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              bookmark.typeLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: bookmark.type == BookmarkType.book
                                    ? Colors.blue[700]
                                    : Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (bookmark.bookTitle != null &&
                              bookmark.bookTitle != bookmark.bookmarkName) ...[
                            Text(
                              bookmark.bookTitle!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                          ],
                          if (bookmark.displayPage != null) ...[
                            Text(
                              'Halaman ${bookmark.displayPage}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          if (bookmark.note != null &&
                              bookmark.note!.isNotEmpty) ...[
                            Text(
                              bookmark.note!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            'Dibuat: ${_formatDate(bookmark.createdAt)}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        _navigateToBookmark(context, bookmark);
                      },
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} menit yang lalu';
      }
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _navigateToBookmark(BuildContext context, UnifiedBookmark bookmark) {
    if (bookmark.type == BookmarkType.book) {
      // Navigate to regular book reader
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => sl<BookmarkBloc>(),
            child: BookReaderPage(
              bookId: bookmark.bookId,
              bookTitle: bookmark.bookTitle ?? 'Buku',
            ),
          ),
        ),
      );
    } else {
      // Navigate to PDF reader - we need to get PDF URL first
      _navigateToPdfBookmark(context, bookmark);
    }
  }

  void _navigateToPdfBookmark(
    BuildContext context,
    UnifiedBookmark bookmark,
  ) async {
    try {
      // Get PDF book details from database
      final response = await Supabase.instance.client
          .from('pdf_books')
          .select('pdf_url, title')
          .eq('id', bookmark.bookId)
          .single();

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => sl<PdfBookmarkBloc>(),
            child: AdvancedPdfViewer(
              bookId: bookmark.bookId,
              pdfUrl: response['pdf_url'] ?? '',
              title: response['title'] ?? bookmark.bookTitle ?? 'PDF Book',
            ),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
