import '../entities/pdf_bookmark.dart';

abstract class PdfBookmarkRepository {
  Future<List<PdfBookmark>> getBookmarksByPdfId(String pdfBookId);
  Future<PdfBookmark> addBookmark({
    required String pdfBookId,
    required int page,
    String? note,
    String? bookmarkName,
    required String userId,
  });
  Future<void> deleteBookmark(String id);
  Future<PdfBookmark> updateBookmark({
    required String id,
    String? note,
    String? bookmarkName,
  });
} 