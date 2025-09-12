import 'package:equatable/equatable.dart';

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

class GetUserLibraryEvent extends LibraryEvent {
  final int page;
  final int limit;
  final String? genre;
  final String sortBy;

  const GetUserLibraryEvent({
    this.page = 1,
    this.limit = 10,
    this.genre,
    this.sortBy = 'last_read',
  });

  @override
  List<Object?> get props => [page, limit, genre, sortBy];
}

class RefreshLibraryEvent extends LibraryEvent {}

class FilterLibraryByGenreEvent extends LibraryEvent {
  final String? genre;

  const FilterLibraryByGenreEvent(this.genre);

  @override
  List<Object?> get props => [genre];
}

class SortLibraryEvent extends LibraryEvent {
  final String sortBy; // 'last_read', 'title', 'author'

  const SortLibraryEvent(this.sortBy);

  @override
  List<Object> get props => [sortBy];
}
