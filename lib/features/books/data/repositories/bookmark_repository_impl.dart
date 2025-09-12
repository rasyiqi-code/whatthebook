import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/repositories/bookmark_repository.dart';
import '../datasources/bookmark_remote_data_source.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  final BookmarkRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  BookmarkRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Bookmark>>> getBookmarksByBookId(
    String bookId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final bookmarks = await remoteDataSource.getBookmarksByBookId(bookId);
        return Right(bookmarks.map((model) => model.toEntity()).toList());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(ServerFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Bookmark>> addBookmark({
    required String bookId,
    String? chapterId,
    int? pageIndex,
    String? note,
    String? bookmarkName,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final bookmark = await remoteDataSource.addBookmark(
          bookId: bookId,
          chapterId: chapterId,
          pageIndex: pageIndex,
          note: note,
          bookmarkName: bookmarkName,
        );
        return Right(bookmark.toEntity());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(ServerFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBookmark(String bookmarkId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteBookmark(bookmarkId);
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(ServerFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Bookmark>> updateBookmark({
    required String bookmarkId,
    String? note,
    String? bookmarkName,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final bookmark = await remoteDataSource.updateBookmark(
          bookmarkId: bookmarkId,
          note: note,
          bookmarkName: bookmarkName,
        );
        return Right(bookmark.toEntity());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(ServerFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<Bookmark>>> getAllBookmarks() async {
    if (await networkInfo.isConnected) {
      try {
        final bookmarks = await remoteDataSource.getAllBookmarks();
        return Right(bookmarks.map((model) => model.toEntity()).toList());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(ServerFailure('No internet connection'));
    }
  }
}
 