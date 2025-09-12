import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

class GetMyBooksParams {
  final String? userId;

  GetMyBooksParams({this.userId});
}

class GetMyBooks implements UseCase<List<Book>, GetMyBooksParams> {
  final BookRepository repository;

  GetMyBooks(this.repository);

  @override
  Future<Either<Failure, List<Book>>> call(GetMyBooksParams params) async {
    return await repository.getMyBooks(params.userId);
  }
}
