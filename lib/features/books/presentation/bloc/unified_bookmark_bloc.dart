import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_all_unified_bookmarks.dart';
import 'unified_bookmark_event.dart';
import 'unified_bookmark_state.dart';

class UnifiedBookmarkBloc
    extends Bloc<UnifiedBookmarkEvent, UnifiedBookmarkState> {
  final GetAllUnifiedBookmarks getAllUnifiedBookmarks;

  UnifiedBookmarkBloc({required this.getAllUnifiedBookmarks})
    : super(UnifiedBookmarkInitial()) {
    on<GetAllUnifiedBookmarksEvent>(_onGetAllUnifiedBookmarks);
    on<JumpToUnifiedBookmarkEvent>(_onJumpToUnifiedBookmark);
  }

  Future<void> _onGetAllUnifiedBookmarks(
    GetAllUnifiedBookmarksEvent event,
    Emitter<UnifiedBookmarkState> emit,
  ) async {
    emit(UnifiedBookmarkLoading());
    final result = await getAllUnifiedBookmarks(NoParams());
    result.fold(
      (failure) => emit(UnifiedBookmarkError(failure.toString())),
      (bookmarks) => emit(UnifiedBookmarksLoaded(bookmarks)),
    );
  }

  Future<void> _onJumpToUnifiedBookmark(
    JumpToUnifiedBookmarkEvent event,
    Emitter<UnifiedBookmarkState> emit,
  ) async {
    emit(UnifiedBookmarkJumped(event.bookmark));
  }
}
