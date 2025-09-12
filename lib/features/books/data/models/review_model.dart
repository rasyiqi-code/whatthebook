import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    super.userId,
    super.bookId,
    required super.rating,
    required super.reviewText,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ReviewModel.fromSupabase(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] as String,
      userId: map['user_id'] as String?,
      bookId: map['book_id'] as String?,
      rating: map['rating'] as int,
      reviewText: map['review_text'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'book_id': bookId,
      'rating': rating,
      'review_text': reviewText,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Review toEntity() => this;
}
