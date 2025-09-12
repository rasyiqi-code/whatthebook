import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/bookmark.dart';
import '../repositories/bookmark_repository.dart';

class GetAllBookmarks implements UseCase<List<Bookmark>, NoParams> {
  final BookmarkRepository repository;

  GetAllBookmarks(this.repository);

  @override
  Future<Either<Failure, List<Bookmark>>> call(NoParams params) async {
    return await repository.getAllBookmarks();
  }
}
