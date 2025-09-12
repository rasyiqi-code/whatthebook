import 'package:hive/hive.dart';
import '../../../../core/errors/failures.dart';
import '../models/book_model.dart';

abstract class BookLocalDataSource {
  Future<List<BookModel>> getCachedBooks();
  Future<BookModel> getCachedBookById(String bookId);
  Future<void> cacheBooks(List<BookModel> books);
  Future<void> cacheBook(BookModel book);
  Future<void> removeCachedBook(String bookId);
  Future<void> clearCache();
}

class BookLocalDataSourceImpl implements BookLocalDataSource {
  static const String _boxName = 'books_cache';
  
  Box<Map>? _box;

  Future<Box<Map>> get box async {
    _box ??= await Hive.openBox<Map>(_boxName);
    return _box!;
  }

  @override
  Future<List<BookModel>> getCachedBooks() async {
    try {
      final booksBox = await box;
      final books = <BookModel>[];
      
      for (final key in booksBox.keys) {
        final bookData = booksBox.get(key);
        if (bookData != null) {
          books.add(BookModel.fromSupabase(Map<String, dynamic>.from(bookData)));
        }
      }
      
      // Sort by updated_at descending
      books.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return books;
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }

  @override
  Future<BookModel> getCachedBookById(String bookId) async {
    try {
      final booksBox = await box;
      final bookData = booksBox.get(bookId);
      
      if (bookData == null) {
        throw const CacheFailure('Book not found in cache');
      }
      
      return BookModel.fromSupabase(Map<String, dynamic>.from(bookData));
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }

  @override
  Future<void> cacheBooks(List<BookModel> books) async {
    try {
      final booksBox = await box;
      
      for (final book in books) {
        await booksBox.put(book.id, book.toSupabase());
      }
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }

  @override
  Future<void> cacheBook(BookModel book) async {
    try {
      final booksBox = await box;
      await booksBox.put(book.id, book.toSupabase());
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }

  @override
  Future<void> removeCachedBook(String bookId) async {
    try {
      final booksBox = await box;
      await booksBox.delete(bookId);
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final booksBox = await box;
      await booksBox.clear();
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }
}
