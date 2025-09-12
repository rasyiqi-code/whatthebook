import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/book_repository.dart';

class DeleteBook implements UseCase<void, DeleteBookParams> {
  final BookRepository repository;

  DeleteBook(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteBookParams params) async {
    return await repository.deleteBook(params.bookId);
  }
}

class DeleteBookParams extends Equatable {
  final String bookId;

  const DeleteBookParams({required this.bookId});

  @override
  List<Object> get props => [bookId];
}
