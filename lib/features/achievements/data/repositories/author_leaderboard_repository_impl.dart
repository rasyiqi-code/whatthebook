import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/author_leaderboard_entry.dart';
import 'author_leaderboard_repository.dart';

class AuthorLeaderboardRepositoryImpl implements AuthorLeaderboardRepository {
  final _client = Supabase.instance.client;

  @override
  Future<List<AuthorLeaderboardEntry>> getWeeklyLeaderboard() async {
    final response = await _client.from('author_leaderboard_weekly').select();
    return _mapLeaderboardResponse(response);
  }

  @override
  Future<List<AuthorLeaderboardEntry>> getMonthlyLeaderboard() async {
    final response = await _client.from('author_leaderboard_monthly').select();
    return _mapLeaderboardResponse(response);
  }

  @override
  Future<List<AuthorLeaderboardEntry>> getAllTimeLeaderboard() async {
    final response = await _client.from('author_leaderboard_alltime').select();
    return _mapLeaderboardResponse(response);
  }

  List<AuthorLeaderboardEntry> _mapLeaderboardResponse(dynamic response) {
    if (response == null) return [];
    return (response as List)
        .map(
          (e) => AuthorLeaderboardEntry(
            userId: e['author_id']?.toString() ?? '',
            name: e['full_name'] ?? '',
            avatarUrl: e['avatar_url'] ?? '',
            avgRating: (e['avg_rating'] as num?)?.toDouble() ?? 0.0,
            reviewCount: e['reviews_count'] ?? 0,
            bookCount: e['books_count'] ?? 0,
          ),
        )
        .toList();
  }
}
