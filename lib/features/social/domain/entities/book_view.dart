import 'package:equatable/equatable.dart';

class BookView extends Equatable {
  final String id;
  final String bookId;
  final String? userId;
  final DateTime viewedAt;

  const BookView({
    required this.id,
    required this.bookId,
    this.userId,
    required this.viewedAt,
  });

  @override
  List<Object?> get props => [id, bookId, userId, viewedAt];

  BookView copyWith({
    String? id,
    String? bookId,
    String? userId,
    DateTime? viewedAt,
  }) {
    return BookView(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      userId: userId ?? this.userId,
      viewedAt: viewedAt ?? this.viewedAt,
    );
  }
}
