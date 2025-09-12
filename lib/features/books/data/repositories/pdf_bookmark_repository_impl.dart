import '../../domain/entities/pdf_bookmark.dart';
import '../../domain/repositories/pdf_bookmark_repository.dart';
import '../datasources/pdf_bookmark_remote_data_source.dart';

class PdfBookmarkRepositoryImpl implements PdfBookmarkRepository {
  final PdfBookmarkRemoteDataSource remoteDataSource;
  PdfBookmarkRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<PdfBookmark>> getBookmarksByPdfId(String pdfBookId) async {
    final models = await remoteDataSource.getBookmarksByPdfId(pdfBookId);
    return models;
  }

  @override
  Future<PdfBookmark> addBookmark({
    required String pdfBookId,
    required int page,
    String? note,
    String? bookmarkName,
    required String userId,
  }) async {
    final model = await remoteDataSource.addBookmark(
      pdfBookId: pdfBookId,
      page: page,
      note: note,
      bookmarkName: bookmarkName,
      userId: userId,
    );
    return model;
  }

  @override
  Future<void> deleteBookmark(String id) async {
    await remoteDataSource.deleteBookmark(id);
  }

  @override
  Future<PdfBookmark> updateBookmark({
    required String id,
    String? note,
    String? bookmarkName,
  }) async {
    final model = await remoteDataSource.updateBookmark(
      id: id,
      note: note,
      bookmarkName: bookmarkName,
    );
    return model;
  }
}
