import '../../domain/entities/author_leaderboard_entry.dart';

abstract class AuthorLeaderboardRepository {
  Future<List<AuthorLeaderboardEntry>> getWeeklyLeaderboard();
  Future<List<AuthorLeaderboardEntry>> getMonthlyLeaderboard();
  Future<List<AuthorLeaderboardEntry>> getAllTimeLeaderboard();
}
