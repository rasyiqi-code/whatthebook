import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/bookmark_repository.dart';

class DeleteBookmark implements UseCase<void, String> {
  final BookmarkRepository repository;

  DeleteBookmark(this.repository);

  @override
  Future<Either<Failure, void>> call(String bookmarkId) async {
    return await repository.deleteBookmark(bookmarkId);
  }
} 