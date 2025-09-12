import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String id;
  final String? userId;
  final String? bookId;
  final int rating;
  final String reviewText;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Review({
    required this.id,
    this.userId,
    this.bookId,
    required this.rating,
    required this.reviewText,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    bookId,
    rating,
    reviewText,
    createdAt,
    updatedAt,
  ];
}
