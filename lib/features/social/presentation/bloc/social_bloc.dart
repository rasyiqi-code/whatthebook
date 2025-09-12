import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';

import '../../domain/usecases/create_reading_list.dart';
import '../../domain/usecases/get_user_reading_lists.dart';
import '../../domain/usecases/delete_reading_list.dart';
import '../../domain/usecases/update_reading_list.dart';
import '../../domain/usecases/like_book.dart';
import '../../domain/usecases/unlike_book.dart';
import '../../domain/usecases/check_book_like_status.dart';
import '../../domain/usecases/track_book_view.dart';
import '../../domain/usecases/get_book_comments.dart';
import '../../domain/usecases/get_chapter_comments.dart';
import '../../domain/usecases/add_comment.dart';
import '../../domain/usecases/update_comment.dart';
import '../../domain/usecases/delete_comment.dart';
import 'social_event.dart';
import 'social_state.dart';

class SocialBloc extends Bloc<SocialEvent, SocialState> {
  final CreateReadingList createReadingList;
  final GetUserReadingLists getUserReadingLists;
  final DeleteReadingList deleteReadingList;
  final UpdateReadingList updateReadingList;
  final LikeBook likeBook;
  final UnlikeBook unlikeBook;
  final CheckBookLikeStatus checkBookLikeStatus;
  final TrackBookView trackBookView;
  final GetBookComments getBookComments;
  final GetChapterComments getChapterComments;
  final AddComment addComment;
  final UpdateComment updateComment;
  final DeleteComment deleteComment;

  SocialBloc({
    required this.createReadingList,
    required this.getUserReadingLists,
    required this.deleteReadingList,
    required this.updateReadingList,
    required this.likeBook,
    required this.unlikeBook,
    required this.checkBookLikeStatus,
    required this.trackBookView,
    required this.getBookComments,
    required this.getChapterComments,
    required this.addComment,
    required this.updateComment,
    required this.deleteComment,
  }) : super(SocialInitial()) {
    on<CreateReadingListRequested>(_onCreateReadingList);
    on<GetUserReadingListsRequested>(_onGetUserReadingLists);
    on<DeleteReadingListRequested>(_onDeleteReadingList);
    on<UpdateReadingListRequested>(_onUpdateReadingList);
    on<LikeBookRequested>(_onLikeBook);
    on<UnlikeBookRequested>(_onUnlikeBook);
    on<CheckBookLikeStatusRequested>(_onCheckBookLikeStatus);
    on<TrackBookViewRequested>(_onTrackBookView);
    on<GetBookCommentsRequested>(_onGetBookCommentsRequested);
    on<GetChapterCommentsRequested>(_onGetChapterCommentsRequested);
    on<AddCommentRequested>(_onAddCommentRequested);
    on<UpdateCommentRequested>(_onUpdateCommentRequested);
    on<DeleteCommentRequested>(_onDeleteCommentRequested);
  }

  Future<void> _onCreateReadingList(
    CreateReadingListRequested event,
    Emitter<SocialState> emit,
  ) async {
    emit(SocialLoading());

    final result = await createReadingList(
      CreateReadingListParams(
        name: event.name,
        description: event.description,
        isPublic: event.isPublic,
      ),
    );

    result.fold(
      (failure) => emit(SocialError(_mapFailureToMessage(failure))),
      (readingList) => emit(ReadingListCreated(readingList)),
    );
  }

  Future<void> _onGetUserReadingLists(
    GetUserReadingListsRequested event,
    Emitter<SocialState> emit,
  ) async {
    emit(SocialLoading());

    final result = await getUserReadingLists(
      GetUserReadingListsParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(SocialError(_mapFailureToMessage(failure))),
      (readingLists) => emit(ReadingListsLoaded(event.userId, readingLists)),
    );
  }

  Future<void> _onDeleteReadingList(
    DeleteReadingListRequested event,
    Emitter<SocialState> emit,
  ) async {
    emit(SocialLoading());

    final result = await deleteReadingList(
      DeleteReadingListParams(listId: event.listId),
    );

    result.fold(
      (failure) => emit(SocialError(_mapFailureToMessage(failure))),
      (_) => emit(ReadingListDeleted(event.listId)),
    );
  }

  Future<void> _onUpdateReadingList(
    UpdateReadingListRequested event,
    Emitter<SocialState> emit,
  ) async {
    emit(SocialLoading());

    final result = await updateReadingList(
      UpdateReadingListParams(
        listId: event.listId,
        name: event.name,
        description: event.description,
        isPublic: event.isPublic,
      ),
    );

    result.fold(
      (failure) => emit(SocialError(_mapFailureToMessage(failure))),
      (readingList) => emit(ReadingListUpdated(readingList)),
    );
  }

  Future<void> _onLikeBook(
    LikeBookRequested event,
    Emitter<SocialState> emit,
  ) async {
    final result = await likeBook(LikeBookParams(bookId: event.bookId));

    result.fold(
      (failure) => emit(SocialError(_mapFailureToMessage(failure))),
      (_) => emit(BookLiked(event.bookId)),
    );
  }

  Future<void> _onUnlikeBook(
    UnlikeBookRequested event,
    Emitter<SocialState> emit,
  ) async {
    final result = await unlikeBook(UnlikeBookParams(bookId: event.bookId));

    result.fold(
      (failure) => emit(SocialError(_mapFailureToMessage(failure))),
      (_) => emit(BookUnliked(event.bookId)),
    );
  }

  Future<void> _onCheckBookLikeStatus(
    CheckBookLikeStatusRequested event,
    Emitter<SocialState> emit,
  ) async {
    final result = await checkBookLikeStatus(CheckBookLikeStatusParams(bookId: event.bookId));

    result.fold(
      (failure) => emit(SocialError(_mapFailureToMessage(failure))),
      (isLiked) => emit(BookLikeStatusLoaded(event.bookId, isLiked)),
    );
  }

  Future<void> _onTrackBookView(
    TrackBookViewRequested event,
    Emitter<SocialState> emit,
  ) async {
    final result = await trackBookView(TrackBookViewParams(bookId: event.bookId));

    result.fold(
      (failure) => emit(SocialError(_mapFailureToMessage(failure))),
      (bookView) => emit(BookViewTracked(bookView)),
    );
  }

  Future<void> _onGetBookCommentsRequested(
    GetBookCommentsRequested event,
    Emitter<SocialState> emit,
  ) async {
    emit(SocialLoading());
    final result = await getBookComments(GetBookCommentsParams(bookId: event.bookId));
    result.fold(
      (failure) => emit(SocialError(_mapFailureToMessage(failure))),
      (comments) => emit(BookCommentsLoaded(event.bookId, comments)),
    );
  }

  Future<void> _onGetChapterCommentsRequested(
    GetChapterCommentsRequested event,
    Emitter<SocialState> emit,
  ) async {
    emit(SocialLoading());
    final result = await getChapterComments(GetChapterCommentsParams(chapterId: event.chapterId));
    result.fold(
      (failure) => emit(SocialError(_mapFailureToMessage(failure))),
      (comments) => emit(ChapterCommentsLoaded(event.chapterId, comments)),
    );
  }

  Future<void> _onAddCommentRequested(
    AddCommentRequested event,
    Emitter<SocialState> emit,
  ) async {
    emit(SocialLoading());
    final result = await addComment(AddCommentParams(
      bookId: event.bookId,
      chapterId: event.chapterId,
      content: event.content,
      parentCommentId: event.parentCommentId,
    ));
    result.fold(
      (failure) => emit(SocialError(_mapFailureToMessage(failure))),
      (comment) => emit(CommentAdded(comment)),
    );
  }

  Future<void> _onUpdateCommentRequested(
    UpdateCommentRequested event,
    Emitter<SocialState> emit,
  ) async {
    emit(SocialLoading());
    final result = await updateComment(UpdateCommentParams(
      commentId: event.commentId,
      content: event.content,
    ));
    result.fold(
      (failure) => emit(SocialError(_mapFailureToMessage(failure))),
      (comment) => emit(CommentUpdated(comment)),
    );
  }

  Future<void> _onDeleteCommentRequested(
    DeleteCommentRequested event,
    Emitter<SocialState> emit,
  ) async {
    emit(SocialLoading());
    final result = await deleteComment(DeleteCommentParams(commentId: event.commentId));
    result.fold(
      (failure) => emit(SocialError(_mapFailureToMessage(failure))),
      (_) => emit(CommentDeleted(event.commentId)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Server error occurred';
      case CacheFailure _:
        return 'Cache error occurred';
      case NetworkFailure _:
        return 'Network error occurred';
      default:
        return 'Unexpected error occurred';
    }
  }
}
