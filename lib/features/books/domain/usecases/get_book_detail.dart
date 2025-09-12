import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

class GetBookDetail implements UseCase<Book, GetBookDetailParams> {
  final BookRepository repository;

  GetBookDetail(this.repository);

  @override
  Future<Either<Failure, Book>> call(GetBookDetailParams params) async {
    return await repository.getBookById(params.bookId);
  }
}

class GetBookDetailParams extends Equatable {
  final String bookId;

  const GetBookDetailParams({required this.bookId});

  @override
  List<Object> get props => [bookId];
}
