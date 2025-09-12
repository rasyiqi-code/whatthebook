import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bookmark.dart';

abstract class BookmarkRepository {
  Future<Either<Failure, List<Bookmark>>> getBookmarksByBookId(String bookId);

  Future<Either<Failure, Bookmark>> addBookmark({
    required String bookId,
    String? chapterId,
    int? pageIndex,
    String? note,
    String? bookmarkName,
  });

  Future<Either<Failure, void>> deleteBookmark(String bookmarkId);

  Future<Either<Failure, Bookmark>> updateBookmark({
    required String bookmarkId,
    String? note,
    String? bookmarkName,
  });

  Future<Either<Failure, List<Bookmark>>> getAllBookmarks();
}
