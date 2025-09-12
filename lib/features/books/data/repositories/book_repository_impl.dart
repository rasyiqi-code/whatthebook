import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../../domain/usecases/search_books.dart';
import '../datasources/book_local_data_source.dart';
import '../datasources/book_remote_data_source.dart';
import '../models/book_model.dart';

class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource remoteDataSource;
  final BookLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  BookRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Book>>> getBooks({
    int page = 1,
    int limit = 20,
    String? genre,
    String? searchQuery,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final books = await remoteDataSource.getBooks(
          page: page,
          limit: limit,
          genre: genre,
          searchQuery: searchQuery,
        );
        await localDataSource.cacheBooks(books);
        return Right(books);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try {
        final localBooks = await localDataSource.getCachedBooks();
        return Right(localBooks);
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, Book>> getBookById(String bookId) async {
    if (await networkInfo.isConnected) {
      try {
        final book = await remoteDataSource.getBookById(bookId);
        await localDataSource.cacheBook(book);
        return Right(book);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try {
        final localBook = await localDataSource.getCachedBookById(bookId);
        return Right(localBook);
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, Book>> createBook({
    required String title,
    required String description,
    required List<String> genres,
    String? coverImageUrl,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final book = await remoteDataSource.createBook(
          title: title,
          description: description,
          genres: genres,
          coverImageUrl: coverImageUrl,
        );
        await localDataSource.cacheBook(book);
        return Right(book);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(ServerFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Book>> updateBook({
    required String bookId,
    String? title,
    String? description,
    List<String>? genres,
    String? coverImageUrl,
    bool? isCompleted,
    bool? isPublished,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final book = await remoteDataSource.updateBook(
          bookId: bookId,
          title: title,
          description: description,
          genres: genres,
          coverImageUrl: coverImageUrl,
          isCompleted: isCompleted,
          isPublished: isPublished,
        );
        await localDataSource.cacheBook(book);
        return Right(book);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(ServerFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBook(String bookId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteBook(bookId);
        await localDataSource.removeCachedBook(bookId);
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(ServerFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<Book>>> getMyBooks([String? userId]) async {
    if (await networkInfo.isConnected) {
      try {
        final books = await remoteDataSource.getMyBooks(userId);
        await localDataSource.cacheBooks(books);
        return Right(books);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try {
        final localBooks = await localDataSource.getCachedBooks();
        return Right(localBooks);
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<Book>>> getCachedBooks() async {
    try {
      final localBooks = await localDataSource.getCachedBooks();
      return Right(localBooks);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cacheBook(Book book) async {
    try {
      final bookModel = BookModel.fromEntity(book);
      await localDataSource.cacheBook(bookModel);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Book>>> searchBooks({
    required String query,
    SearchFilters? filters,
    String? sortBy,
    int page = 1,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final books = await remoteDataSource.searchBooks(
          query: query,
          filters: filters,
          sortBy: sortBy,
          page: page,
          limit: limit,
        );
        return Right(books.map((book) => book.toEntity()).toList());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
