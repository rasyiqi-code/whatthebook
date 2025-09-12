import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_data_source.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Review>> getReviewsForBook(String bookId) async {
    return await remoteDataSource.getReviewsForBook(bookId);
  }

  @override
  Future<Review?> getUserReviewForBook(String bookId, String userId) async {
    return await remoteDataSource.getUserReviewForBook(bookId, userId);
  }

  @override
  Future<Review> addReview({
    required String bookId,
    required int rating,
    required String reviewText,
  }) async {
    return await remoteDataSource.addReview(
      bookId: bookId,
      rating: rating,
      reviewText: reviewText,
    );
  }

  @override
  Future<Review> updateReview({
    required String reviewId,
    required int rating,
    required String reviewText,
  }) async {
    return await remoteDataSource.updateReview(
      reviewId: reviewId,
      rating: rating,
      reviewText: reviewText,
    );
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await remoteDataSource.deleteReview(reviewId);
  }
}
