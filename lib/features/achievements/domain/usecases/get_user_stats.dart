import '../entities/user_stats.dart';
import '../../data/repositories/user_stats_repository.dart';

class GetUserStats {
  final UserStatsRepository repository;
  const GetUserStats(this.repository);

  Future<UserStats> call(String userId) {
    return repository.getUserStats(userId);
  }
}

class GetUserProductivityTimeSeries {
  final UserStatsRepository repository;
  const GetUserProductivityTimeSeries(this.repository);

  Future<List<UserProductivityPoint>> call(String userId) {
    return repository.getUserProductivityTimeSeries(userId);
  }
}

class GetCommunityProductivityTimeSeries {
  final UserStatsRepository repository;
  const GetCommunityProductivityTimeSeries(this.repository);

  Future<List<UserProductivityPoint>> call() {
    return repository.getCommunityProductivityTimeSeries();
  }
}
