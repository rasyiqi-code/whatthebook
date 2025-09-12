import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bookmark_model.dart';

abstract class BookmarkRemoteDataSource {
  Future<List<BookmarkModel>> getBookmarksByBookId(String bookId);
  Future<BookmarkModel> addBookmark({
    required String bookId,
    String? chapterId,
    int? pageIndex,
    String? note,
    String? bookmarkName,
  });
  Future<void> deleteBookmark(String bookmarkId);
  Future<BookmarkModel> updateBookmark({
    required String bookmarkId,
    String? note,
    String? bookmarkName,
  });
  Future<List<BookmarkModel>> getAllBookmarks();
}

class BookmarkRemoteDataSourceImpl implements BookmarkRemoteDataSource {
  final SupabaseClient client;

  BookmarkRemoteDataSourceImpl({required this.client});

  @override
  Future<List<BookmarkModel>> getBookmarksByBookId(String bookId) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await client
          .from('bookmarks')
          .select()
          .eq('book_id', bookId)
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((bookmark) => BookmarkModel.fromSupabase(bookmark))
          .toList();
    } catch (e) {
      throw Exception('Failed to get bookmarks: $e');
    }
  }

  @override
  Future<BookmarkModel> addBookmark({
    required String bookId,
    String? chapterId,
    int? pageIndex,
    String? note,
    String? bookmarkName,
  }) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await client
          .from('bookmarks')
          .insert({
            'book_id': bookId,
            'chapter_id': chapterId,
            'page_index': pageIndex,
            'note': note,
            'bookmark_name': bookmarkName,
            'user_id': userId,
          })
          .select()
          .single();

      return BookmarkModel.fromSupabase(response);
    } catch (e) {
      throw Exception('Failed to add bookmark: $e');
    }
  }

  @override
  Future<void> deleteBookmark(String bookmarkId) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await client
          .from('bookmarks')
          .delete()
          .eq('id', bookmarkId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to delete bookmark: $e');
    }
  }

  @override
  Future<BookmarkModel> updateBookmark({
    required String bookmarkId,
    String? note,
    String? bookmarkName,
  }) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final updateData = <String, dynamic>{};
      if (note != null) updateData['note'] = note;
      if (bookmarkName != null) updateData['bookmark_name'] = bookmarkName;

      final response = await client
          .from('bookmarks')
          .update(updateData)
          .eq('id', bookmarkId)
          .eq('user_id', userId)
          .select()
          .single();

      return BookmarkModel.fromSupabase(response);
    } catch (e) {
      throw Exception('Failed to update bookmark: $e');
    }
  }

  @override
  Future<List<BookmarkModel>> getAllBookmarks() async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await client
          .from('bookmarks')
          .select(
            '*, books(title, cover_image_url), chapters(title, chapter_number)',
          )
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((bookmark) => BookmarkModel.fromSupabase(bookmark))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all bookmarks: $e');
    }
  }
}
