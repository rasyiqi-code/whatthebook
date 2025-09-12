import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

class GetBooks implements UseCase<List<Book>, GetBooksParams> {
  final BookRepository repository;

  GetBooks(this.repository);

  @override
  Future<Either<Failure, List<Book>>> call(GetBooksParams params) async {
    return await repository.getBooks(
      page: params.page,
      limit: params.limit,
      genre: params.genre,
      searchQuery: params.searchQuery,
    );
  }
}

class GetBooksParams extends Equatable {
  final int page;
  final int limit;
  final String? genre;
  final String? searchQuery;

  const GetBooksParams({
    this.page = 1,
    this.limit = 20,
    this.genre,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [page, limit, genre, searchQuery];
}
