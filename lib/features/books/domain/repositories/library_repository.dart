import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/library_book.dart';

abstract class LibraryRepository {
  Future<Either<Failure, List<LibraryBook>>> getUserLibraryBooks({
    int page = 1,
    int limit = 20,
    String? genre,
    String sortBy = 'last_read',
  });

  Future<Either<Failure, LibraryBook>> addBookToLibrary(String bookId);

  Future<Either<Failure, void>> removeBookFromLibrary(String bookId);

  Future<Either<Failure, void>> updateReadingProgress({
    required String bookId,
    String? lastReadChapterId,
    int? lastReadPage,
    required double readingProgress,
  });

  Future<Either<Failure, bool>> isBookInLibrary(String bookId);

  Future<Either<Failure, List<String>>> getLibraryGenres();
}
