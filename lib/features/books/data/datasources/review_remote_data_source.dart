import '../models/review_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whatthebook/core/services/logger_service.dart';

abstract class ReviewRemoteDataSource {
  Future<List<ReviewModel>> getReviewsForBook(String bookId);
  Future<ReviewModel?> getUserReviewForBook(String bookId, String userId);
  Future<ReviewModel> addReview({
    required String bookId,
    required int rating,
    required String reviewText,
  });
  Future<ReviewModel> updateReview({
    required String reviewId,
    required int rating,
    required String reviewText,
  });
  Future<void> deleteReview(String reviewId);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final SupabaseClient client;

  ReviewRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ReviewModel>> getReviewsForBook(String bookId) async {
    final response = await client
        .from('reviews')
        .select('*')
        .eq('book_id', bookId)
        .order('created_at', ascending: false);
    return (response as List)
        .map((e) => ReviewModel.fromSupabase(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ReviewModel?> getUserReviewForBook(
    String bookId,
    String userId,
  ) async {
    final response = await client
        .from('reviews')
        .select('*')
        .eq('book_id', bookId)
        .eq('user_id', userId)
        .maybeSingle();
    if (response == null) return null;
    return ReviewModel.fromSupabase(response);
  }

  @override
  Future<ReviewModel> addReview({
    required String bookId,
    required int rating,
    required String reviewText,
  }) async {
    final currentUserId = client.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }
    final response = await client
        .from('reviews')
        .insert({
          'user_id': currentUserId,
          'book_id': bookId,
          'rating': rating,
          'review_text': reviewText,
        })
        .select()
        .single();
    return ReviewModel.fromSupabase(response);
  }

  @override
  Future<ReviewModel> updateReview({
    required String reviewId,
    required int rating,
    required String reviewText,
  }) async {
    final response = await client
        .from('reviews')
        .update({
          'rating': rating,
          'review_text': reviewText,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', reviewId)
        .select()
        .single();
    return ReviewModel.fromSupabase(response);
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    try {
      // Check if user is authenticated
      final currentUserId = client.auth.currentUser?.id;
      logger.debug('Delete review - Current user ID: $currentUserId');
      logger.debug('Delete review - Review ID: $reviewId');

      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // First, verify the review exists and belongs to the current user
      final review = await client
          .from('reviews')
          .select('*')
          .eq('id', reviewId)
          .eq('user_id', currentUserId)
          .maybeSingle();

      logger.debug('Delete review - Found review: ${review != null}');
      if (review != null) {
        logger.debug('Delete review - Review details: $review');
      }

      if (review == null) {
        // Let's also check if the review exists at all (without user filter)
        final anyReview = await client
            .from('reviews')
            .select('*')
            .eq('id', reviewId)
            .maybeSingle();

        logger.debug(
          'Delete review - Review exists without user filter: ${anyReview != null}',
        );
        if (anyReview != null) {
          logger.debug('Delete review - Any review details: $anyReview');
          throw Exception(
            'Review exists but does not belong to current user. Review user: ${anyReview['user_id']}, Current user: $currentUserId',
          );
        } else {
          throw Exception('Review not found with ID: $reviewId');
        }
      }

      // Delete the review
      logger.debug('Delete review - Attempting to delete...');
      final result = await client
          .from('reviews')
          .delete()
          .eq('id', reviewId)
          .eq('user_id', currentUserId);

      logger.info('Delete review - Delete result: $result');

      // Check if the review was actually deleted by trying to fetch it again
      final deletedReview = await client
          .from('reviews')
          .select('*')
          .eq('id', reviewId)
          .maybeSingle();

      if (deletedReview != null) {
        throw Exception(
          'Review still exists after delete operation - RLS policy may be blocking deletion',
        );
      }

      logger.info('Delete review - Successfully deleted review (verified)');
    } catch (e) {
      logger.error('Error deleting review: $e');
      rethrow;
    }
  }
}
