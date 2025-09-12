import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/bookmark.dart';
import '../repositories/bookmark_repository.dart';

class UpdateBookmark implements UseCase<Bookmark, UpdateBookmarkParams> {
  final BookmarkRepository repository;

  UpdateBookmark(this.repository);

  @override
  Future<Either<Failure, Bookmark>> call(UpdateBookmarkParams params) async {
    return await repository.updateBookmark(
      bookmarkId: params.bookmarkId,
      note: params.note,
      bookmarkName: params.bookmarkName,
    );
  }
}

class UpdateBookmarkParams {
  final String bookmarkId;
  final String? note;
  final String? bookmarkName;

  UpdateBookmarkParams({
    required this.bookmarkId,
    this.note,
    this.bookmarkName,
  });
}
