import '../../domain/entities/pdf_bookmark.dart';

class PdfBookmarkModel extends PdfBookmark {
  const PdfBookmarkModel({
    required super.id,
    required super.pdfBookId,
    required super.page,
    super.note,
    super.bookmarkName,
    required super.createdAt,
    required super.userId,
  });

  factory PdfBookmarkModel.fromMap(Map<String, dynamic> map) {
    return PdfBookmarkModel(
      id: map['id'] as String,
      pdfBookId: map['pdf_book_id'] as String,
      page: map['page'] as int,
      note: map['note'] as String?,
      bookmarkName: map['bookmark_name'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      userId: map['user_id'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pdf_book_id': pdfBookId,
      'page': page,
      'note': note,
      'bookmark_name': bookmarkName,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
    };
  }

  factory PdfBookmarkModel.fromJson(Map<String, dynamic> json) =>
      PdfBookmarkModel.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}
