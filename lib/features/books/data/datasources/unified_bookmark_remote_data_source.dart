import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/unified_bookmark_model.dart';

abstract class UnifiedBookmarkRemoteDataSource {
  Future<List<UnifiedBookmarkModel>> getAllUnifiedBookmarks();
}

class UnifiedBookmarkRemoteDataSourceImpl
    implements UnifiedBookmarkRemoteDataSource {
  final SupabaseClient client;

  UnifiedBookmarkRemoteDataSourceImpl({required this.client});

  @override
  Future<List<UnifiedBookmarkModel>> getAllUnifiedBookmarks() async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Fetch regular bookmarks with book details
      final regularBookmarksResponse = await client
          .from('bookmarks')
          .select('*, books(title, cover_image_url)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      // Fetch PDF bookmarks with PDF book details
      final pdfBookmarksResponse = await client
          .from('pdf_bookmarks')
          .select('*, pdf_books(title, cover_image_url)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List<UnifiedBookmarkModel> allBookmarks = [];

      // Convert regular bookmarks
      for (final bookmark in regularBookmarksResponse) {
        final bookData = bookmark['books'] as Map<String, dynamic>?;
        allBookmarks.add(
          UnifiedBookmarkModel.fromSupabaseBookmark(
            bookmark,
            bookData?['title'] as String?,
            bookData?['cover_image_url'] as String?,
          ),
        );
      }

      // Convert PDF bookmarks
      for (final bookmark in pdfBookmarksResponse) {
        final pdfBookData = bookmark['pdf_books'] as Map<String, dynamic>?;
        allBookmarks.add(
          UnifiedBookmarkModel.fromSupabasePdfBookmark(
            bookmark,
            pdfBookData?['title'] as String?,
            pdfBookData?['cover_image_url'] as String?,
          ),
        );
      }

      // Sort by creation date (newest first)
      allBookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return allBookmarks;
    } catch (e) {
      throw Exception('Failed to get unified bookmarks: $e');
    }
  }
}
