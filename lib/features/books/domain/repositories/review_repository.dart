import '../entities/review.dart';

abstract class ReviewRepository {
  Future<List<Review>> getReviewsForBook(String bookId);
  Future<Review?> getUserReviewForBook(String bookId, String userId);
  Future<Review> addReview({
    required String bookId,
    required int rating,
    required String reviewText,
  });
  Future<Review> updateReview({
    required String reviewId,
    required int rating,
    required String reviewText,
  });
  Future<void> deleteReview(String reviewId);
}
