import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/add_bookmark.dart';
import '../../domain/usecases/delete_bookmark.dart';
import '../../domain/usecases/get_all_bookmarks.dart';
import '../../domain/usecases/get_bookmarks_by_book_id.dart';
import '../../domain/usecases/update_bookmark.dart';
import 'bookmark_event.dart';
import 'bookmark_state.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  final GetBookmarksByBookId getBookmarksByBookId;
  final AddBookmark addBookmark;
  final DeleteBookmark deleteBookmark;
  final UpdateBookmark updateBookmark;
  final GetAllBookmarks getAllBookmarks;

  BookmarkBloc({
    required this.getBookmarksByBookId,
    required this.addBookmark,
    required this.deleteBookmark,
    required this.updateBookmark,
    required this.getAllBookmarks,
  }) : super(BookmarkInitial()) {
    on<GetBookmarksByBookIdEvent>(_onGetBookmarksByBookId);
    on<AddBookmarkEvent>(_onAddBookmark);
    on<DeleteBookmarkEvent>(_onDeleteBookmark);
    on<UpdateBookmarkEvent>(_onUpdateBookmark);
    on<GetAllBookmarksEvent>(_onGetAllBookmarks);
    on<JumpToBookmarkEvent>(_onJumpToBookmark);
  }

  Future<void> _onGetBookmarksByBookId(
    GetBookmarksByBookIdEvent event,
    Emitter<BookmarkState> emit,
  ) async {
    emit(BookmarkLoading());
    final result = await getBookmarksByBookId(event.bookId);
    result.fold(
      (failure) => emit(BookmarkError(failure.toString())),
      (bookmarks) => emit(BookmarksLoaded(bookmarks)),
    );
  }

  Future<void> _onAddBookmark(
    AddBookmarkEvent event,
    Emitter<BookmarkState> emit,
  ) async {
    emit(BookmarkLoading());
    final result = await addBookmark(
      AddBookmarkParams(
        bookId: event.bookId,
        chapterId: event.chapterId,
        pageIndex: event.pageIndex,
        note: event.note,
        bookmarkName: event.bookmarkName,
      ),
    );
    result.fold(
      (failure) => emit(BookmarkError(failure.toString())),
      (bookmark) => emit(BookmarkAdded(bookmark)),
    );
  }

  Future<void> _onDeleteBookmark(
    DeleteBookmarkEvent event,
    Emitter<BookmarkState> emit,
  ) async {
    emit(BookmarkLoading());
    final result = await deleteBookmark(event.bookmarkId);
    result.fold(
      (failure) => emit(BookmarkError(failure.toString())),
      (_) => emit(BookmarkDeleted(event.bookmarkId)),
    );
  }

  Future<void> _onUpdateBookmark(
    UpdateBookmarkEvent event,
    Emitter<BookmarkState> emit,
  ) async {
    emit(BookmarkLoading());
    final result = await updateBookmark(
      UpdateBookmarkParams(
        bookmarkId: event.bookmarkId,
        note: event.note,
        bookmarkName: event.bookmarkName,
      ),
    );
    result.fold(
      (failure) => emit(BookmarkError(failure.toString())),
      (bookmark) => emit(BookmarkUpdated(bookmark)),
    );
  }

  Future<void> _onGetAllBookmarks(
    GetAllBookmarksEvent event,
    Emitter<BookmarkState> emit,
  ) async {
    emit(BookmarkLoading());
    final result = await getAllBookmarks(NoParams());
    result.fold(
      (failure) => emit(BookmarkError(failure.toString())),
      (bookmarks) => emit(BookmarksLoaded(bookmarks)),
    );
  }

  Future<void> _onJumpToBookmark(
    JumpToBookmarkEvent event,
    Emitter<BookmarkState> emit,
  ) async {
    emit(BookmarkJumped(event.bookmark));
  }
}
