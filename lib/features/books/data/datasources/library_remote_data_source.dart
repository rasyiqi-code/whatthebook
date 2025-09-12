import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/library_book_model.dart';
import 'package:whatthebook/core/services/logger_service.dart';

abstract class LibraryRemoteDataSource {
  Future<List<LibraryBookModel>> getUserLibraryBooks({
    int page = 1,
    int limit = 20,
    String? genre,
    String sortBy = 'last_read',
  });

  Future<LibraryBookModel> addBookToLibrary(String bookId);

  Future<void> removeBookFromLibrary(String bookId);

  Future<void> updateReadingProgress({
    required String bookId,
    String? lastReadChapterId,
    int? lastReadPage,
    required double readingProgress,
  });

  Future<bool> isBookInLibrary(String bookId);

  Future<List<String>> getLibraryGenres();
}

class LibraryRemoteDataSourceImpl implements LibraryRemoteDataSource {
  final SupabaseClient supabase;

  LibraryRemoteDataSourceImpl({required this.supabase});

  @override
  Future<List<LibraryBookModel>> getUserLibraryBooks({
    int page = 1,
    int limit = 20,
    String? genre,
    String sortBy = 'last_read',
  }) async {
    try {
      // Ambil data langsung dari tabel books dengan join ke users
      final response = await supabase.from('books').select('*, users(email)');

      if (response.isEmpty) {
        return [];
      }

      final books = response.map((book) {
        // Handle tags field
        List<String>? tagsList;
        if (book['tags'] != null) {
          tagsList = List<String>.from(book['tags']);
        }

        return LibraryBookModel(
          id: book['id'] ?? '',
          title: book['title'] ?? 'Untitled',
          description: book['description'],
          authorId: book['author_id'],
          authorName: book['users']?['email'] as String? ?? 'Anonymous',
          coverImageUrl: book['cover_image_url'],
          status: book['status'] ?? 'draft',
          genre: book['genre'],
          tags: tagsList,
          totalChapters: book['total_chapters'] ?? 0,
          totalWords: book['total_words'] ?? 0,
          createdAt: book['created_at'] != null
              ? DateTime.tryParse(book['created_at']) ?? DateTime.now()
              : DateTime.now(),
          updatedAt: book['updated_at'] != null
              ? DateTime.tryParse(book['updated_at']) ?? DateTime.now()
              : DateTime.now(),
          lastReadChapterId: null,
          lastReadPage: 0,
          lastReadAt: DateTime.now(),
          readingProgress: 0.0,
        );
      }).toList();

      // Apply genre filtering if specified
      var filteredBooks = genre != null
          ? books.where((book) => book.genre?.contains(genre) == true).toList()
          : books;

      // Apply sorting
      switch (sortBy) {
        case 'title':
          filteredBooks.sort((a, b) => a.title.compareTo(b.title));
          break;
        case 'author':
          filteredBooks.sort((a, b) => a.authorName.compareTo(b.authorName));
          break;
        case 'last_read':
        default:
          filteredBooks.sort((a, b) => b.lastReadAt!.compareTo(a.lastReadAt!));
      }

      return filteredBooks;
    } catch (e) {
      logger.error('Error in getUserLibraryBooks: $e');
      return [];
    }
  }

  @override
  Future<LibraryBookModel> addBookToLibrary(String bookId) async {
    try {
      final userId = supabase.auth.currentUser!.id;

      await supabase.from('user_library').insert({
        'user_id': userId,
        'book_id': bookId,
        'last_read_at': DateTime.now().toIso8601String(),
      });

      final response = await supabase
          .from('user_library')
          .select('''
            *,
            books!inner (
              *,
              users (
                email
              )
            )
          ''')
          .eq('user_id', userId)
          .eq('book_id', bookId)
          .single();

      final book = response['books'] as Map<String, dynamic>;

      return LibraryBookModel.fromJson({
        ...book,
        'last_read_chapter': response['last_read_chapter'],
        'last_read_page': response['last_read_page'],
        'last_read_at': response['last_read_at'],
      });
    } catch (e) {
      throw Exception('Failed to add book to library: $e');
    }
  }

  @override
  Future<void> removeBookFromLibrary(String bookId) async {
    try {
      await supabase
          .from('user_library')
          .delete()
          .eq('user_id', supabase.auth.currentUser!.id)
          .eq('book_id', bookId);
    } catch (e) {
      throw Exception('Failed to remove book from library: $e');
    }
  }

  @override
  Future<void> updateReadingProgress({
    required String bookId,
    String? lastReadChapterId,
    int? lastReadPage,
    required double readingProgress,
  }) async {
    try {
      await supabase
          .from('user_library')
          .update({
            'last_read_chapter': lastReadChapterId,
            'last_read_page': lastReadPage,
            'last_read_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', supabase.auth.currentUser!.id)
          .eq('book_id', bookId);
    } catch (e) {
      throw Exception('Failed to update reading progress: $e');
    }
  }

  @override
  Future<bool> isBookInLibrary(String bookId) async {
    try {
      final response = await supabase
          .from('user_library')
          .select()
          .eq('user_id', supabase.auth.currentUser!.id)
          .eq('book_id', bookId);

      return response.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check if book is in library: $e');
    }
  }

  @override
  Future<List<String>> getLibraryGenres() async {
    try {
      final response = await supabase
          .from('user_library')
          .select('books (genre)')
          .eq('user_id', supabase.auth.currentUser!.id);

      final Set<String> genres = {};
      for (final record in response) {
        final book = record['books'] as Map<String, dynamic>;
        final bookGenre = book['genre'] as String?;
        if (bookGenre != null) {
          genres.add(bookGenre);
        }
      }

      return genres.toList()..sort();
    } catch (e) {
      throw Exception('Failed to get library genres: $e');
    }
  }
}
