import '../models/pdf_bookmark_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class PdfBookmarkRemoteDataSource {
  Future<List<PdfBookmarkModel>> getBookmarksByPdfId(String pdfBookId);
  Future<PdfBookmarkModel> addBookmark({
    required String pdfBookId,
    required int page,
    String? note,
    String? bookmarkName,
    required String userId,
  });
  Future<void> deleteBookmark(String id);
  Future<PdfBookmarkModel> updateBookmark({
    required String id,
    String? note,
    String? bookmarkName,
  });
}

class PdfBookmarkRemoteDataSourceImpl implements PdfBookmarkRemoteDataSource {
  final SupabaseClient client;
  PdfBookmarkRemoteDataSourceImpl(this.client);

  @override
  Future<List<PdfBookmarkModel>> getBookmarksByPdfId(String pdfBookId) async {
    final response = await client
        .from('pdf_bookmarks')
        .select()
        .eq('pdf_book_id', pdfBookId)
        .order('created_at', ascending: false);
    return (response as List).map((e) => PdfBookmarkModel.fromMap(e)).toList();
  }

  @override
  Future<PdfBookmarkModel> addBookmark({
    required String pdfBookId,
    required int page,
    String? note,
    String? bookmarkName,
    required String userId,
  }) async {
    final response = await client
        .from('pdf_bookmarks')
        .insert({
          'pdf_book_id': pdfBookId,
          'page_index': page,
          'page': page,
          'note': note,
          'bookmark_name': bookmarkName,
          'user_id': userId,
        })
        .select()
        .single();
    return PdfBookmarkModel.fromMap(response);
  }

  @override
  Future<void> deleteBookmark(String id) async {
    await client.from('pdf_bookmarks').delete().eq('id', id);
  }

  @override
  Future<PdfBookmarkModel> updateBookmark({
    required String id,
    String? note,
    String? bookmarkName,
  }) async {
    final response = await client
        .from('pdf_bookmarks')
        .update({'note': note, 'bookmark_name': bookmarkName})
        .eq('id', id)
        .select()
        .single();
    return PdfBookmarkModel.fromMap(response);
  }
}
