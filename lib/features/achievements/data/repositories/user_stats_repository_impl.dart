import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_stats.dart';
import 'user_stats_repository.dart';

class UserStatsRepositoryImpl implements UserStatsRepository {
  final _client = Supabase.instance.client;

  @override
  Future<UserStats> getUserStats(String userId) async {
    final response = await _client
        .from('user_stats')
        .select()
        .eq('user_id', userId)
        .single();
    return UserStats(
      totalWords: response['total_words'] ?? 0,
      booksPublished: response['books_published'] ?? 0,
      chaptersPublished: response['chapters_published'] ?? 0,
      reviewsWritten: response['reviews_written'] ?? 0,
      likesReceived: response['likes_received'] ?? 0,
      readingStreak: response['reading_streak'] ?? 0,
      activityGraph: null, // Belum diimplementasikan
    );
  }

  @override
  Future<List<UserProductivityPoint>> getUserProductivityTimeSeries(
    String userId,
  ) async {
    final data = await _client
        .from('user_productivity_monthly')
        .select()
        .eq('user_id', userId)
        .order('year_month');
    return (data as List<dynamic>)
        .map((e) => UserProductivityPoint.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<UserProductivityPoint>>
  getCommunityProductivityTimeSeries() async {
    final data = await _client
        .from('community_productivity_monthly')
        .select()
        .order('year_month');
    return (data as List<dynamic>)
        .map(
          (e) => UserProductivityPoint(
            yearMonth: e['year_month'] as String,
            totalWords: (e['avg_total_words'] ?? 0).round(),
            booksPublished: (e['avg_books_published'] ?? 0).round(),
            chaptersPublished: (e['avg_chapters_published'] ?? 0).round(),
            reviewsWritten: (e['avg_reviews_written'] ?? 0).round(),
            likesReceived: (e['avg_likes_received'] ?? 0).round(),
          ),
        )
        .toList();
  }
}
