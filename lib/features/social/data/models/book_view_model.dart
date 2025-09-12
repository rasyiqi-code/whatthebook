import '../../domain/entities/book_view.dart';

class BookViewModel {
  final String id;
  final String bookId;
  final String? userId;
  final DateTime viewedAt;

  const BookViewModel({
    required this.id,
    required this.bookId,
    this.userId,
    required this.viewedAt,
  });

  factory BookViewModel.fromSupabase(Map<String, dynamic> map) {
    return BookViewModel(
      id: map['id'] as String,
      bookId: map['book_id'] as String,
      userId: map['user_id'] as String?,
      viewedAt: DateTime.parse(map['viewed_at'] as String),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'book_id': bookId,
      'user_id': userId,
      'viewed_at': viewedAt.toIso8601String(),
    };
  }

  BookView toEntity() {
    return BookView(
      id: id,
      bookId: bookId,
      userId: userId,
      viewedAt: viewedAt,
    );
  }

  factory BookViewModel.fromEntity(BookView entity) {
    return BookViewModel(
      id: entity.id,
      bookId: entity.bookId,
      userId: entity.userId,
      viewedAt: entity.viewedAt,
    );
  }
}
