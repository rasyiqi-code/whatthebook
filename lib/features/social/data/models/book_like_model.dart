import '../../domain/entities/book_like.dart';

class BookLikeModel extends BookLike {
  const BookLikeModel({
    required super.id,
    required super.userId,
    required super.bookId,
    required super.createdAt,
  });

  factory BookLikeModel.fromSupabase(Map<String, dynamic> map) {
    return BookLikeModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      bookId: map['book_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'user_id': userId,
      'book_id': bookId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BookLikeModel.fromEntity(BookLike bookLike) {
    return BookLikeModel(
      id: bookLike.id,
      userId: bookLike.userId,
      bookId: bookLike.bookId,
      createdAt: bookLike.createdAt,
    );
  }

  BookLike toEntity() {
    return BookLike(
      id: id,
      userId: userId,
      bookId: bookId,
      createdAt: createdAt,
    );
  }
}
