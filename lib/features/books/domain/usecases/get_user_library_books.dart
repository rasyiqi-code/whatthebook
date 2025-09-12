import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/library_book.dart';
import '../repositories/library_repository.dart';

class GetUserLibraryBooks
    implements UseCase<List<LibraryBook>, GetUserLibraryBooksParams> {
  final LibraryRepository repository;

  GetUserLibraryBooks(this.repository);

  @override
  Future<Either<Failure, List<LibraryBook>>> call(
    GetUserLibraryBooksParams params,
  ) async {
    return await repository.getUserLibraryBooks(
      page: params.page,
      limit: params.limit,
      genre: params.genre,
      sortBy: params.sortBy,
    );
  }
}

class GetUserLibraryBooksParams extends Equatable {
  final int page;
  final int limit;
  final String? genre;
  final String sortBy;

  const GetUserLibraryBooksParams({
    this.page = 1,
    this.limit = 20,
    this.genre,
    this.sortBy = 'last_read', // 'last_read', 'title', 'author'
  });

  @override
  List<Object?> get props => [page, limit, genre, sortBy];
}
