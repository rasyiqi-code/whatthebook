import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/pdf_bookmark.dart';
import '../bloc/pdf_bookmark_bloc.dart';
import '../bloc/pdf_bookmark_event.dart';
import '../bloc/pdf_bookmark_state.dart';

class PdfBookmarkListWidget extends StatelessWidget {
  final String pdfBookId;
  final void Function(PdfBookmark)? onBookmarkTap;
  const PdfBookmarkListWidget({
    super.key,
    required this.pdfBookId,
    this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PdfBookmarkBloc>().add(
        GetPdfBookmarksByPdfIdEvent(pdfBookId),
      );
    });
    return BlocBuilder<PdfBookmarkBloc, PdfBookmarkState>(
      builder: (context, state) {
        if (state is PdfBookmarkLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PdfBookmarksLoaded) {
          return _buildList(context, state.bookmarks);
        } else if (state is PdfBookmarkError) {
          return Center(child: Text('Error: ${state.message}'));
        } else {
          return const Center(child: Text('Tidak ada bookmark'));
        }
      },
    );
  }

  Widget _buildList(BuildContext context, List<PdfBookmark> bookmarks) {
    if (bookmarks.isEmpty) {
      return const Center(child: Text('Belum ada bookmark'));
    }
    return ListView.builder(
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = bookmarks[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.bookmark, color: Colors.orange),
            title: Text(
              bookmark.bookmarkName ?? 'Bookmark Halaman ${bookmark.page + 1}',
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (bookmark.note != null && bookmark.note!.isNotEmpty)
                  Text(bookmark.note!),
                Text('Halaman ${bookmark.page + 1}'),
                Text('Dibuat: ${bookmark.createdAt.toLocal()}'),
              ],
            ),
            onTap: () => onBookmarkTap?.call(bookmark),
          ),
        );
      },
    );
  }
}
