import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/get_user_library_books.dart';
import 'library_event.dart';
import 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final GetUserLibraryBooks getUserLibraryBooks;

  LibraryBloc({required this.getUserLibraryBooks}) : super(LibraryInitial()) {
    on<GetUserLibraryEvent>(_onGetUserLibrary);
    on<RefreshLibraryEvent>(_onRefreshLibrary);
    on<FilterLibraryByGenreEvent>(_onFilterLibraryByGenre);
    on<SortLibraryEvent>(_onSortLibrary);
  }

  Future<void> _onGetUserLibrary(
    GetUserLibraryEvent event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      if (event.page == 1) {
        emit(LibraryLoading());
      }

      final result = await getUserLibraryBooks(
        GetUserLibraryBooksParams(
          page: event.page,
          limit: event.limit,
          genre: event.genre,
          sortBy: event.sortBy,
        ),
      );

      result.fold(
        (failure) => emit(LibraryError(_mapFailureToMessage(failure))),
        (books) {
          if (event.page == 1) {
            emit(
              LibraryLoaded(
                books: books,
                hasReachedMax: books.length < event.limit,
                currentPage: event.page,
                selectedGenre: event.genre,
                sortBy: event.sortBy,
              ),
            );
          } else {
            final currentState = state as LibraryLoaded;
            final allBooks = List.of(currentState.books)..addAll(books);
            emit(
              LibraryLoaded(
                books: allBooks,
                hasReachedMax: books.length < event.limit,
                currentPage: event.page,
                selectedGenre: event.genre,
                sortBy: event.sortBy,
              ),
            );
          }
        },
      );
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }

  Future<void> _onRefreshLibrary(
    RefreshLibraryEvent event,
    Emitter<LibraryState> emit,
  ) async {
    if (state is LibraryLoaded) {
      final currentState = state as LibraryLoaded;
      add(
        GetUserLibraryEvent(
          page: 1,
          genre: currentState.selectedGenre,
          sortBy: currentState.sortBy,
        ),
      );
    } else {
      add(const GetUserLibraryEvent(page: 1));
    }
  }

  Future<void> _onFilterLibraryByGenre(
    FilterLibraryByGenreEvent event,
    Emitter<LibraryState> emit,
  ) async {
    String sortBy = 'last_read';
    if (state is LibraryLoaded) {
      sortBy = (state as LibraryLoaded).sortBy;
    }

    add(GetUserLibraryEvent(page: 1, genre: event.genre, sortBy: sortBy));
  }

  Future<void> _onSortLibrary(
    SortLibraryEvent event,
    Emitter<LibraryState> emit,
  ) async {
    String? genre;
    if (state is LibraryLoaded) {
      genre = (state as LibraryLoaded).selectedGenre;
    }

    add(GetUserLibraryEvent(page: 1, genre: genre, sortBy: event.sortBy));
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Server error occurred';
    } else if (failure is CacheFailure) {
      return 'Cache error occurred';
    } else if (failure is NetworkFailure) {
      return 'Network error occurred';
    } else {
      return 'Unexpected error occurred';
    }
  }
}
