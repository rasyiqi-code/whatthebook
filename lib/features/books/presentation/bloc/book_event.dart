import 'package:equatable/equatable.dart';
import '../../domain/usecases/search_books.dart';

abstract class BookEvent extends Equatable {
  const BookEvent();

  @override
  List<Object?> get props => [];
}

class GetBooksEvent extends BookEvent {
  final int page;
  final int limit;
  final String? genre;
  final String? searchQuery;

  const GetBooksEvent({
    this.page = 1,
    this.limit = 20,
    this.genre,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [page, limit, genre, searchQuery];
}

class GetBookDetailEvent extends BookEvent {
  final String bookId;

  const GetBookDetailEvent(this.bookId);

  @override
  List<Object> get props => [bookId];
}

class CreateBookEvent extends BookEvent {
  final String title;
  final String description;
  final List<String> genres;
  final String? coverImageUrl;

  const CreateBookEvent({
    required this.title,
    required this.description,
    required this.genres,
    this.coverImageUrl,
  });

  @override
  List<Object?> get props => [title, description, genres, coverImageUrl];
}

class UpdateBookEvent extends BookEvent {
  final String bookId;
  final String? title;
  final String? description;
  final List<String>? genres;
  final String? coverImageUrl;
  final bool? isCompleted;
  final bool? isPublished;

  const UpdateBookEvent({
    required this.bookId,
    this.title,
    this.description,
    this.genres,
    this.coverImageUrl,
    this.isCompleted,
    this.isPublished,
  });

  @override
  List<Object?> get props => [
    bookId,
    title,
    description,
    genres,
    coverImageUrl,
    isCompleted,
    isPublished,
  ];
}

class DeleteBookEvent extends BookEvent {
  final String bookId;

  const DeleteBookEvent(this.bookId);

  @override
  List<Object> get props => [bookId];
}

class GetMyBooksEvent extends BookEvent {
  final String? userId;

  const GetMyBooksEvent({this.userId});

  @override
  List<Object?> get props => [userId];
}

class RefreshBooksEvent extends BookEvent {}

class SearchBooksRequested extends BookEvent {
  final String query;
  final SearchFilters? filters;
  final String? sortBy;
  final int page;
  final int limit;

  const SearchBooksRequested({
    required this.query,
    this.filters,
    this.sortBy,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, filters, sortBy, page, limit];
}

class ClearSearchRequested extends BookEvent {}
