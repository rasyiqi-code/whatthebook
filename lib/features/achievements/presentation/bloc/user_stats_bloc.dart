import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/usecases/get_user_stats.dart';

abstract class UserStatsEvent {}

class LoadUserStatsEvent extends UserStatsEvent {
  final String userId;
  LoadUserStatsEvent(this.userId);
}

class LoadUserProductivityTimeSeriesEvent extends UserStatsEvent {
  final String userId;
  LoadUserProductivityTimeSeriesEvent(this.userId);
}

abstract class UserStatsState {}

class UserStatsInitial extends UserStatsState {}

class UserStatsLoading extends UserStatsState {}

class UserStatsLoaded extends UserStatsState {
  final UserStats stats;
  UserStatsLoaded(this.stats);
}

class UserStatsError extends UserStatsState {
  final String message;
  UserStatsError(this.message);
}

class UserProductivityTimeSeriesLoaded extends UserStatsState {
  final List<UserProductivityPoint> userSeries;
  final List<UserProductivityPoint> communitySeries;
  UserProductivityTimeSeriesLoaded({
    required this.userSeries,
    required this.communitySeries,
  });
}

class UserStatsBloc extends Bloc<UserStatsEvent, UserStatsState> {
  final GetUserStats getUserStats;
  final GetUserProductivityTimeSeries getUserProductivityTimeSeries;
  final GetCommunityProductivityTimeSeries getCommunityProductivityTimeSeries;
  UserStatsBloc({
    required this.getUserStats,
    required this.getUserProductivityTimeSeries,
    required this.getCommunityProductivityTimeSeries,
  }) : super(UserStatsInitial()) {
    on<LoadUserStatsEvent>((event, emit) async {
      emit(UserStatsLoading());
      try {
        final stats = await getUserStats(event.userId);
        emit(UserStatsLoaded(stats));
      } catch (e) {
        emit(UserStatsError('Gagal memuat statistik user'));
      }
    });
    on<LoadUserProductivityTimeSeriesEvent>((event, emit) async {
      emit(UserStatsLoading());
      try {
        final userSeries = await getUserProductivityTimeSeries(event.userId);
        final communitySeries = await getCommunityProductivityTimeSeries();
        emit(
          UserProductivityTimeSeriesLoaded(
            userSeries: userSeries,
            communitySeries: communitySeries,
          ),
        );
      } catch (e) {
        emit(UserStatsError('Gagal memuat grafik produktivitas'));
      }
    });
  }
}
