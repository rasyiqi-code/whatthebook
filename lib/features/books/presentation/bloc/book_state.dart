import 'package:equatable/equatable.dart';
import '../../domain/entities/book.dart';

abstract class BookState extends Equatable {
  const BookState();

  @override
  List<Object?> get props => [];
}

class BookInitial extends BookState {}

class BookLoading extends BookState {}

class BookLoaded extends BookState {
  final List<Book> books;
  final bool hasReachedMax;
  final int currentPage;

  const BookLoaded({
    required this.books,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  BookLoaded copyWith({
    List<Book>? books,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return BookLoaded(
      books: books ?? this.books,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object> get props => [books, hasReachedMax, currentPage];
}

class BookDetailLoaded extends BookState {
  final Book book;

  const BookDetailLoaded(this.book);

  @override
  List<Object> get props => [book];
}

class BookCreated extends BookState {
  final Book book;

  const BookCreated(this.book);

  @override
  List<Object> get props => [book];
}

class BookUpdated extends BookState {
  final Book book;

  const BookUpdated(this.book);

  @override
  List<Object> get props => [book];
}

class BookDeleted extends BookState {
  final String bookId;

  const BookDeleted(this.bookId);

  @override
  List<Object> get props => [bookId];
}

class MyBooksLoaded extends BookState {
  final List<Book> books;

  const MyBooksLoaded(this.books);

  @override
  List<Object> get props => [books];
}

class BookError extends BookState {
  final String message;

  const BookError(this.message);

  @override
  List<Object> get props => [message];
}

class SearchResultsLoaded extends BookState {
  final List<Book> books;
  final String query;

  const SearchResultsLoaded(this.books, this.query);

  @override
  List<Object> get props => [books, query];
}

class SearchCleared extends BookState {}

class BookLoadingMore extends BookState {
  final List<Book> books;
  final int currentPage;

  const BookLoadingMore({required this.books, required this.currentPage});

  @override
  List<Object> get props => [books, currentPage];
}
