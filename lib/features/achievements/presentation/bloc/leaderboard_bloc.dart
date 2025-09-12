import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/author_leaderboard_entry.dart';
import '../../domain/usecases/get_author_leaderboard.dart';

abstract class LeaderboardEvent {}

class LoadLeaderboardEvent extends LeaderboardEvent {
  final LeaderboardTimeFilter filter;
  LoadLeaderboardEvent(this.filter);
}

abstract class LeaderboardState {}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardLoaded extends LeaderboardState {
  final List<AuthorLeaderboardEntry> entries;
  LeaderboardLoaded(this.entries);
}

class LeaderboardError extends LeaderboardState {
  final String message;
  LeaderboardError(this.message);
}

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final GetAuthorLeaderboard getAuthorLeaderboard;
  LeaderboardBloc({required this.getAuthorLeaderboard})
    : super(LeaderboardInitial()) {
    on<LoadLeaderboardEvent>((event, emit) async {
      emit(LeaderboardLoading());
      try {
        final entries = await getAuthorLeaderboard(event.filter);
        emit(LeaderboardLoaded(entries));
      } catch (e) {
        emit(LeaderboardError('Gagal memuat leaderboard'));
      }
    });
  }
}
