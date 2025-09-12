import 'package:equatable/equatable.dart';

enum BookmarkType { book, pdf }

class UnifiedBookmark extends Equatable {
  final String id;
  final String bookId; // For regular books: book_id, for PDF: pdf_book_id
  final BookmarkType type;
  final String? chapterId; // Only for regular books
  final int? pageIndex; // For regular books
  final int? page; // For PDF books
  final String? note;
  final String? bookmarkName;
  final DateTime createdAt;
  final String userId;
  final String? bookTitle; // For display purposes
  final String? coverImageUrl; // For display purposes

  const UnifiedBookmark({
    required this.id,
    required this.bookId,
    required this.type,
    this.chapterId,
    this.pageIndex,
    this.page,
    this.note,
    this.bookmarkName,
    required this.createdAt,
    required this.userId,
    this.bookTitle,
    this.coverImageUrl,
  });

  @override
  List<Object?> get props => [
    id,
    bookId,
    type,
    chapterId,
    pageIndex,
    page,
    note,
    bookmarkName,
    createdAt,
    userId,
    bookTitle,
    coverImageUrl,
  ];

  // Helper method to get the page number for display
  int? get displayPage {
    return type == BookmarkType.book ? pageIndex : page;
  }

  // Helper method to get the type label for display
  String get typeLabel {
    return type == BookmarkType.book ? '[Buku]' : '[PDF]';
  }
}
