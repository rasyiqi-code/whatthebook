import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/logger_service.dart';
import '../../domain/usecases/create_book.dart';
import '../../domain/usecases/get_book_detail.dart';
import '../../domain/usecases/get_books.dart';
import '../../domain/usecases/update_book.dart';
import '../../domain/usecases/delete_book.dart';
import '../../domain/usecases/get_my_books.dart';
import '../../domain/usecases/search_books.dart';
import 'book_event.dart';
import 'book_state.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final GetBooks getBooks;
  final GetBookDetail getBookDetail;
  final CreateBook createBook;
  final UpdateBook updateBook;
  final DeleteBook deleteBook;
  final GetMyBooks getMyBooks;
  final SearchBooks searchBooks;

  BookBloc({
    required this.getBooks,
    required this.getBookDetail,
    required this.createBook,
    required this.updateBook,
    required this.deleteBook,
    required this.getMyBooks,
    required this.searchBooks,
  }) : super(BookInitial()) {
    on<GetBooksEvent>(_onGetBooks);
    on<GetBookDetailEvent>(_onGetBookDetail);
    on<CreateBookEvent>(_onCreateBook);
    on<UpdateBookEvent>(_onUpdateBook);
    on<DeleteBookEvent>(_onDeleteBook);
    on<GetMyBooksEvent>(_onGetMyBooks);
    on<RefreshBooksEvent>(_onRefreshBooks);
    on<SearchBooksRequested>(_onSearchBooks);
    on<ClearSearchRequested>(_onClearSearch);
  }

  Future<void> _onGetBooks(GetBooksEvent event, Emitter<BookState> emit) async {
    if (event.page == 1) {
      emit(BookLoading());
    } else if (state is BookLoaded) {
      emit(
        BookLoadingMore(
          books: (state as BookLoaded).books,
          currentPage: (state as BookLoaded).currentPage,
        ),
      );
    }

    final result = await getBooks(
      GetBooksParams(
        page: event.page,
        limit: event.limit,
        genre: event.genre,
        searchQuery: event.searchQuery,
      ),
    );

    result.fold((failure) => emit(BookError(_mapFailureToMessage(failure))), (
      books,
    ) {
      if (event.page == 1) {
        emit(
          BookLoaded(
            books: books,
            hasReachedMax: books.length < event.limit,
            currentPage: event.page,
          ),
        );
      } else {
        final currentState = state as BookLoaded;
        final allBooks = List.of(currentState.books)..addAll(books);
        emit(
          BookLoaded(
            books: allBooks,
            hasReachedMax: books.length < event.limit,
            currentPage: event.page,
          ),
        );
      }
    });
  }

  Future<void> _onGetBookDetail(
    GetBookDetailEvent event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());

    final result = await getBookDetail(
      GetBookDetailParams(bookId: event.bookId),
    );

    result.fold(
      (failure) => emit(BookError(_mapFailureToMessage(failure))),
      (book) => emit(BookDetailLoaded(book)),
    );
  }

  Future<void> _onCreateBook(
    CreateBookEvent event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());

    final result = await createBook(
      CreateBookParams(
        title: event.title,
        description: event.description,
        genres: event.genres,
        coverImageUrl: event.coverImageUrl,
      ),
    );

    result.fold(
      (failure) => emit(BookError(_mapFailureToMessage(failure))),
      (book) => emit(BookCreated(book)),
    );
  }

  Future<void> _onUpdateBook(
    UpdateBookEvent event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());

    final result = await updateBook(
      UpdateBookParams(
        bookId: event.bookId,
        title: event.title,
        description: event.description,
        genres: event.genres,
        coverImageUrl: event.coverImageUrl,
        isCompleted: event.isCompleted,
        isPublished: event.isPublished,
      ),
    );

    result.fold(
      (failure) => emit(BookError(_mapFailureToMessage(failure))),
      (book) => emit(BookUpdated(book)),
    );
  }

  Future<void> _onDeleteBook(
    DeleteBookEvent event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());

    final result = await deleteBook(DeleteBookParams(bookId: event.bookId));

    result.fold(
      (failure) => emit(BookError(_mapFailureToMessage(failure))),
      (_) => emit(BookDeleted(event.bookId)),
    );
  }

  Future<void> _onGetMyBooks(
    GetMyBooksEvent event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());

    final result = await getMyBooks(GetMyBooksParams(userId: event.userId));

    result.fold(
      (failure) => emit(BookError(_mapFailureToMessage(failure))),
      (books) => emit(MyBooksLoaded(books)),
    );
  }

  Future<void> _onRefreshBooks(
    RefreshBooksEvent event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());
    add(const GetBooksEvent(page: 1));
  }

  Future<void> _onSearchBooks(
    SearchBooksRequested event,
    Emitter<BookState> emit,
  ) async {
    emit(BookLoading());

    final result = await searchBooks(
      SearchBooksParams(
        query: event.query,
        filters: event.filters,
        sortBy: event.sortBy,
        page: event.page,
        limit: event.limit,
      ),
    );

    result.fold(
      (failure) => emit(BookError(_mapFailureToMessage(failure))),
      (books) => emit(SearchResultsLoaded(books, event.query)),
    );
  }

  Future<void> _onClearSearch(
    ClearSearchRequested event,
    Emitter<BookState> emit,
  ) async {
    emit(SearchCleared());
  }

  String _mapFailureToMessage(Failure failure) {
    logger.debug('BookBloc - Mapping failure: ${failure.runtimeType}');
    logger.debug('BookBloc - Failure message: ${failure.toString()}');

    switch (failure.runtimeType) {
      case ServerFailure _:
        final serverFailure = failure as ServerFailure;
        return serverFailure.message.isNotEmpty
            ? serverFailure.message
            : 'Server error occurred';
      case CacheFailure _:
        return 'Cache error occurred';
      case NetworkFailure _:
        return 'Network error occurred';
      default:
        return failure.toString().isNotEmpty
            ? failure.toString()
            : 'Unexpected error occurred';
    }
  }
}
