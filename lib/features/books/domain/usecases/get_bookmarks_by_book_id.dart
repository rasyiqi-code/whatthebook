import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/bookmark.dart';
import '../repositories/bookmark_repository.dart';

class GetBookmarksByBookId implements UseCase<List<Bookmark>, String> {
  final BookmarkRepository repository;

  GetBookmarksByBookId(this.repository);

  @override
  Future<Either<Failure, List<Bookmark>>> call(String bookId) async {
    return await repository.getBookmarksByBookId(bookId);
  }
}
