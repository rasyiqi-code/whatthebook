import 'package:equatable/equatable.dart';

class BookLike extends Equatable {
  final String id;
  final String userId;
  final String bookId;
  final DateTime createdAt;

  const BookLike({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.createdAt,
  });

  @override
  List<Object> get props => [id, userId, bookId, createdAt];

  BookLike copyWith({
    String? id,
    String? userId,
    String? bookId,
    DateTime? createdAt,
  }) {
    return BookLike(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
