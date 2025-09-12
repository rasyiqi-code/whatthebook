import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/bookmark.dart';
import '../bloc/bookmark_bloc.dart';
import '../bloc/bookmark_event.dart';
import '../bloc/bookmark_state.dart';
import 'add_bookmark_dialog.dart';

class BookmarkListWidget extends StatelessWidget {
  final String bookId;
  final Function(Bookmark)? onBookmarkTap;

  const BookmarkListWidget({
    super.key,
    required this.bookId,
    this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure bookmarks are loaded when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookmarkBloc>().add(GetBookmarksByBookIdEvent(bookId));
    });
    return BlocBuilder<BookmarkBloc, BookmarkState>(
      builder: (context, state) {
        if (state is BookmarkLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is BookmarksLoaded) {
          return _buildBookmarkList(context, state.bookmarks);
        } else if (state is BookmarkError) {
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
              ],
            ),
          );
        } else {
          return const Center(child: Text('Tidak ada bookmark'));
        }
      },
    );
  }

  Widget _buildBookmarkList(BuildContext context, List<Bookmark> bookmarks) {
    if (bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
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
              'Tap tombol + untuk menambah bookmark',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bookmark (${bookmarks.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final bookmark = bookmarks[index];
              return _buildBookmarkItem(context, bookmark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookmarkItem(BuildContext context, Bookmark bookmark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.bookmark, color: Colors.orange),
        title: Text(
          bookmark.bookmarkName ?? 'Bookmark ${bookmark.pageIndex ?? 0}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bookmark.note != null) ...[
              Text(bookmark.note!),
              const SizedBox(height: 4),
            ],
            Text(
              'Halaman ${(bookmark.pageIndex ?? 0) + 1}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              'Dibuat: ${_formatDate(bookmark.createdAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) =>
              _handleBookmarkAction(context, value, bookmark),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Hapus', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          if (onBookmarkTap != null) {
            onBookmarkTap!(bookmark);
          }
        },
      ),
    );
  }

  void _handleBookmarkAction(
    BuildContext context,
    String action,
    Bookmark bookmark,
  ) {
    switch (action) {
      case 'edit':
        _showEditBookmarkDialog(context, bookmark);
        break;
      case 'delete':
        _showDeleteConfirmation(context, bookmark);
        break;
    }
  }

  void _showEditBookmarkDialog(BuildContext context, Bookmark bookmark) {
    showDialog(
      context: context,
      builder: (context) => AddBookmarkDialog(
        initialNote: bookmark.note,
        initialBookmarkName: bookmark.bookmarkName,
        onSave: (note, bookmarkName) {
          context.read<BookmarkBloc>().add(
            UpdateBookmarkEvent(
              bookmarkId: bookmark.id,
              note: note,
              bookmarkName: bookmarkName,
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Bookmark bookmark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Bookmark'),
        content: Text(
          'Apakah Anda yakin ingin menghapus bookmark "${bookmark.bookmarkName ?? 'Bookmark ${bookmark.pageIndex}'}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<BookmarkBloc>().add(
                DeleteBookmarkEvent(bookmark.id),
              );
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
