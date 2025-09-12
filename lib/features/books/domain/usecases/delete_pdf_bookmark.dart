import '../repositories/pdf_bookmark_repository.dart';

class DeletePdfBookmark {
  final PdfBookmarkRepository repository;
  DeletePdfBookmark(this.repository);

  Future<void> call(String id) {
    return repository.deleteBookmark(id);
  }
}
