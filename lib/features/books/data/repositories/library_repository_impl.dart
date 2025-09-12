import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/library_book.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/library_remote_data_source.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  LibraryRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<LibraryBook>>> getUserLibraryBooks({
    int page = 1,
    int limit = 20,
    String? genre,
    String sortBy = 'last_read',
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final books = await remoteDataSource.getUserLibraryBooks(
          page: page,
          limit: limit,
          genre: genre,
          sortBy: sortBy,
        );

        return Right(books);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, LibraryBook>> addBookToLibrary(String bookId) async {
    if (await networkInfo.isConnected) {
      try {
        final book = await remoteDataSource.addBookToLibrary(bookId);
        return Right(book);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> removeBookFromLibrary(String bookId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.removeBookFromLibrary(bookId);
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> updateReadingProgress({
    required String bookId,
    String? lastReadChapterId,
    int? lastReadPage,
    required double readingProgress,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateReadingProgress(
          bookId: bookId,
          lastReadChapterId: lastReadChapterId,
          lastReadPage: lastReadPage,
          readingProgress: readingProgress,
        );
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> isBookInLibrary(String bookId) async {
    if (await networkInfo.isConnected) {
      try {
        final isInLibrary = await remoteDataSource.isBookInLibrary(bookId);
        return Right(isInLibrary);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getLibraryGenres() async {
    if (await networkInfo.isConnected) {
      try {
        final genres = await remoteDataSource.getLibraryGenres();
        return Right(genres);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
