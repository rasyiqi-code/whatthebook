import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/book.dart';
import '../usecases/search_books.dart';

abstract class BookRepository {
  Future<Either<Failure, List<Book>>> getBooks({
    int page = 1,
    int limit = 20,
    String? genre,
    String? searchQuery,
  });

  Future<Either<Failure, Book>> getBookById(String bookId);

  Future<Either<Failure, Book>> createBook({
    required String title,
    required String description,
    required List<String> genres,
    String? coverImageUrl,
  });

  Future<Either<Failure, Book>> updateBook({
    required String bookId,
    String? title,
    String? description,
    List<String>? genres,
    String? coverImageUrl,
    bool? isCompleted,
    bool? isPublished,
  });

  Future<Either<Failure, void>> deleteBook(String bookId);

  Future<Either<Failure, List<Book>>> getMyBooks([String? userId]);

  Future<Either<Failure, List<Book>>> getCachedBooks();

  Future<Either<Failure, void>> cacheBook(Book book);

  Future<Either<Failure, List<Book>>> searchBooks({
    required String query,
    SearchFilters? filters,
    String? sortBy,
    int page = 1,
    int limit = 20,
  });
}
