import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

class SearchBooks implements UseCase<List<Book>, SearchBooksParams> {
  final BookRepository repository;

  SearchBooks(this.repository);

  @override
  Future<Either<Failure, List<Book>>> call(SearchBooksParams params) async {
    return await repository.searchBooks(
      query: params.query,
      filters: params.filters,
      sortBy: params.sortBy,
      page: params.page,
      limit: params.limit,
    );
  }
}

class SearchBooksParams extends Equatable {
  final String query;
  final SearchFilters? filters;
  final String? sortBy;
  final int page;
  final int limit;

  const SearchBooksParams({
    required this.query,
    this.filters,
    this.sortBy,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, filters, sortBy, page, limit];
}

class SearchFilters extends Equatable {
  final List<String>? genres;
  final String? author;
  final bool? isCompleted;
  final bool? isPublished;
  final DateRange? dateRange;
  final int? minWordCount;
  final int? maxWordCount;

  const SearchFilters({
    this.genres,
    this.author,
    this.isCompleted,
    this.isPublished,
    this.dateRange,
    this.minWordCount,
    this.maxWordCount,
  });

  @override
  List<Object?> get props => [
        genres,
        author,
        isCompleted,
        isPublished,
        dateRange,
        minWordCount,
        maxWordCount,
      ];
}

class DateRange extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;

  const DateRange({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}
