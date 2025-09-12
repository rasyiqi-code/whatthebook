import '../entities/author_leaderboard_entry.dart';
import '../../data/repositories/author_leaderboard_repository.dart';

enum LeaderboardTimeFilter { weekly, monthly, allTime }

class GetAuthorLeaderboard {
  final AuthorLeaderboardRepository repository;
  const GetAuthorLeaderboard(this.repository);

  Future<List<AuthorLeaderboardEntry>> call(LeaderboardTimeFilter filter) {
    switch (filter) {
      case LeaderboardTimeFilter.weekly:
        return repository.getWeeklyLeaderboard();
      case LeaderboardTimeFilter.monthly:
        return repository.getMonthlyLeaderboard();
      case LeaderboardTimeFilter.allTime:
        return repository.getAllTimeLeaderboard();
    }
  }
}
