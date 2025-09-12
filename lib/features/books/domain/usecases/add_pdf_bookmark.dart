import '../entities/pdf_bookmark.dart';
import '../repositories/pdf_bookmark_repository.dart';

class AddPdfBookmark {
  final PdfBookmarkRepository repository;
  AddPdfBookmark(this.repository);

  Future<PdfBookmark> call({
    required String pdfBookId,
    required int page,
    String? note,
    String? bookmarkName,
    required String userId,
  }) {
    return repository.addBookmark(
      pdfBookId: pdfBookId,
      page: page,
      note: note,
      bookmarkName: bookmarkName,
      userId: userId,
    );
  }
}
