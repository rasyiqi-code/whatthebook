import '../../domain/entities/user_stats.dart';

abstract class UserStatsRepository {
  Future<UserStats> getUserStats(String userId);
  Future<List<UserProductivityPoint>> getUserProductivityTimeSeries(
    String userId,
  );
  Future<List<UserProductivityPoint>> getCommunityProductivityTimeSeries();
}
