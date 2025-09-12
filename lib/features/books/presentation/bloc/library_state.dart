import 'package:equatable/equatable.dart';
import '../../domain/entities/library_book.dart';

abstract class LibraryState extends Equatable {
  const LibraryState();

  @override
  List<Object?> get props => [];
}

class LibraryInitial extends LibraryState {}

class LibraryLoading extends LibraryState {}

class LibraryLoaded extends LibraryState {
  final List<LibraryBook> books;
  final bool hasReachedMax;
  final int currentPage;
  final String? selectedGenre;
  final String sortBy;

  const LibraryLoaded({
    required this.books,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.selectedGenre,
    this.sortBy = 'last_read',
  });

  @override
  List<Object?> get props => [
    books,
    hasReachedMax,
    currentPage,
    selectedGenre,
    sortBy,
  ];

  LibraryLoaded copyWith({
    List<LibraryBook>? books,
    bool? hasReachedMax,
    int? currentPage,
    String? selectedGenre,
    String? sortBy,
  }) {
    return LibraryLoaded(
      books: books ?? this.books,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      selectedGenre: selectedGenre ?? this.selectedGenre,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class LibraryError extends LibraryState {
  final String message;

  const LibraryError(this.message);

  @override
  List<Object> get props => [message];
}
