import '../entities/pdf_bookmark.dart';
import '../repositories/pdf_bookmark_repository.dart';

class UpdatePdfBookmark {
  final PdfBookmarkRepository repository;
  UpdatePdfBookmark(this.repository);

  Future<PdfBookmark> call({
    required String id,
    String? note,
    String? bookmarkName,
  }) {
    return repository.updateBookmark(
      id: id,
      note: note,
      bookmarkName: bookmarkName,
    );
  }
}
