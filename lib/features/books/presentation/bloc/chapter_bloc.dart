import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/logger_service.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/usecases/get_chapters_by_book_id.dart';
import '../../domain/usecases/create_chapter.dart';
import '../../domain/usecases/update_chapter.dart';
import '../../domain/usecases/delete_chapter.dart';
import 'chapter_event.dart';
import 'chapter_state.dart';

final logger = LoggerService();

class ChapterBloc extends Bloc<ChapterEvent, ChapterState> {
  final GetChaptersByBookId getChaptersByBookId;
  final CreateChapter createChapter;
  final UpdateChapter updateChapter;
  final DeleteChapter deleteChapter;

  Timer? _autoSaveTimer;

  ChapterBloc({
    required this.getChaptersByBookId,
    required this.createChapter,
    required this.updateChapter,
    required this.deleteChapter,
  }) : super(ChapterInitial()) {
    on<GetChaptersByBookIdRequested>(_onGetChaptersByBookId);
    on<CreateChapterRequested>(_onCreateChapter);
    on<UpdateChapterRequested>(_onUpdateChapter);
    on<DeleteChapterRequested>(_onDeleteChapter);
    on<AutoSaveChapterRequested>(_onAutoSaveChapter);
    on<ChapterAutoSaveCompleted>(_onChapterAutoSaveCompleted);
    on<ChapterErrorOccurred>(_onChapterErrorOccurred);
  }

  @override
  Future<void> close() {
    _autoSaveTimer?.cancel();
    return super.close();
  }

  Future<void> _onGetChaptersByBookId(
    GetChaptersByBookIdRequested event,
    Emitter<ChapterState> emit,
  ) async {
    emit(ChapterLoading());

    final result = await getChaptersByBookId(
      GetChaptersByBookIdParams(bookId: event.bookId),
    );

    result.fold(
      (failure) => emit(ChapterError(_mapFailureToMessage(failure))),
      (chapters) => emit(ChaptersLoaded(chapters)),
    );
  }

  Future<void> _onCreateChapter(
    CreateChapterRequested event,
    Emitter<ChapterState> emit,
  ) async {
    emit(ChapterLoading());

    final result = await createChapter(
      CreateChapterParams(
        bookId: event.bookId,
        chapterNumber: event.chapterNumber,
        title: event.title,
        content: event.content,
      ),
    );

    result.fold(
      (failure) => emit(ChapterError(_mapFailureToMessage(failure))),
      (chapter) => emit(ChapterCreated(chapter)),
    );
  }

  Future<void> _onUpdateChapter(
    UpdateChapterRequested event,
    Emitter<ChapterState> emit,
  ) async {
    // Show saving state for manual saves only if we have a valid chapter state
    if (event.title != null) {
      final currentChapter = _getCurrentChapter();
      if (currentChapter != null) {
        emit(ChapterSaving(currentChapter));
      }
    }

    final result = await updateChapter(
      UpdateChapterParams(
        chapterId: event.chapterId,
        title: event.title,
        content: event.content,
        wordCount: event.wordCount,
        status: event.status,
      ),
    );

    result.fold(
      (failure) => emit(ChapterError(_mapFailureToMessage(failure))),
      (chapter) => emit(ChapterUpdated(chapter)),
    );
  }

  Chapter? _getCurrentChapter() {
    if (state is ChapterLoaded) {
      return (state as ChapterLoaded).chapter;
    } else if (state is ChapterUpdated) {
      return (state as ChapterUpdated).chapter;
    } else if (state is ChapterAutoSaved) {
      return (state as ChapterAutoSaved).chapter;
    } else if (state is ChapterCreated) {
      return (state as ChapterCreated).chapter;
    } else if (state is ChapterSaving) {
      return (state as ChapterSaving).chapter;
    }
    return null;
  }

  Future<void> _onDeleteChapter(
    DeleteChapterRequested event,
    Emitter<ChapterState> emit,
  ) async {
    emit(ChapterLoading());

    final result = await deleteChapter(
      DeleteChapterParams(chapterId: event.chapterId),
    );

    result.fold(
      (failure) => emit(ChapterError(_mapFailureToMessage(failure))),
      (_) => emit(ChapterDeleted(event.chapterId)),
    );
  }

  Future<void> _onAutoSaveChapter(
    AutoSaveChapterRequested event,
    Emitter<ChapterState> emit,
  ) async {
    // Cancel previous timer
    _autoSaveTimer?.cancel();

    // Set new timer for auto-save (debounce)
    _autoSaveTimer = Timer(const Duration(seconds: 2), () async {
      // Check if the bloc is still active before proceeding
      if (isClosed) return;

      final result = await updateChapter(
        UpdateChapterParams(
          chapterId: event.chapterId,
          content: event.content,
          wordCount: event.wordCount,
        ),
      );

      // Check again if bloc is still active and emit is not done
      if (!isClosed) {
        result.fold(
          (failure) {
            // Add the error event instead of emitting directly
            add(ChapterErrorOccurred(_mapFailureToMessage(failure)));
          },
          (chapter) {
            // Add the auto-saved event instead of emitting directly
            add(ChapterAutoSaveCompleted(chapter));
          },
        );
      }
    });
  }

  Future<void> _onChapterAutoSaveCompleted(
    ChapterAutoSaveCompleted event,
    Emitter<ChapterState> emit,
  ) async {
    emit(ChapterAutoSaved(event.chapter));
  }

  Future<void> _onChapterErrorOccurred(
    ChapterErrorOccurred event,
    Emitter<ChapterState> emit,
  ) async {
    emit(ChapterError(event.message));
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        final serverFailure = failure as ServerFailure;
        // Log the actual error for debugging
        logger.error('❌ Chapter Server Error: ${serverFailure.message}');
        return 'Server error: ${serverFailure.message}';
      case CacheFailure _:
        final cacheFailure = failure as CacheFailure;
        logger.error('❌ Chapter Cache Error: ${cacheFailure.message}');
        return 'Cache error: ${cacheFailure.message}';
      case NetworkFailure _:
        final networkFailure = failure as NetworkFailure;
        logger.error('❌ Chapter Network Error: ${networkFailure.message}');
        return 'Network error: ${networkFailure.message}';
      default:
        logger.error('❌ Chapter Unexpected Error: ${failure.toString()}');
        return 'Unexpected error: ${failure.toString()}';
    }
  }
}
