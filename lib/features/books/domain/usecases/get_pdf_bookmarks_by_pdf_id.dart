import '../entities/pdf_bookmark.dart';
import '../repositories/pdf_bookmark_repository.dart';

class GetPdfBookmarksByPdfId {
  final PdfBookmarkRepository repository;
  GetPdfBookmarksByPdfId(this.repository);

  Future<List<PdfBookmark>> call(String pdfBookId) {
    return repository.getBookmarksByPdfId(pdfBookId);
  }
}
