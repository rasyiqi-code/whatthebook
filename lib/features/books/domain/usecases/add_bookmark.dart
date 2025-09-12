import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/bookmark.dart';
import '../repositories/bookmark_repository.dart';

class AddBookmark implements UseCase<Bookmark, AddBookmarkParams> {
  final BookmarkRepository repository;

  AddBookmark(this.repository);

  @override
  Future<Either<Failure, Bookmark>> call(AddBookmarkParams params) async {
    return await repository.addBookmark(
      bookId: params.bookId,
      chapterId: params.chapterId,
      pageIndex: params.pageIndex,
      note: params.note,
      bookmarkName: params.bookmarkName,
    );
  }
}

class AddBookmarkParams {
  final String bookId;
  final String? chapterId;
  final int? pageIndex;
  final String? note;
  final String? bookmarkName;

  AddBookmarkParams({
    required this.bookId,
    this.chapterId,
    this.pageIndex,
    this.note,
    this.bookmarkName,
  });
}
