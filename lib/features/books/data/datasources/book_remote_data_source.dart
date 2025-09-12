import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/logger_service.dart';
import '../../domain/usecases/search_books.dart';
import '../models/book_model.dart';

abstract class BookRemoteDataSource {
  Future<List<BookModel>> getBooks({
    int page = 1,
    int limit = 20,
    String? genre,
    String? searchQuery,
  });

  Future<BookModel> getBookById(String bookId);

  Future<BookModel> createBook({
    required String title,
    required String description,
    required List<String> genres,
    String? coverImageUrl,
  });

  Future<BookModel> updateBook({
    required String bookId,
    String? title,
    String? description,
    List<String>? genres,
    String? coverImageUrl,
    bool? isCompleted,
    bool? isPublished,
  });

  Future<void> deleteBook(String bookId);

  Future<List<BookModel>> getMyBooks([String? userId]);

  Future<List<BookModel>> searchBooks({
    required String query,
    SearchFilters? filters,
    String? sortBy,
    int page = 1,
    int limit = 20,
  });
}

class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  final SupabaseClient client;

  BookRemoteDataSourceImpl({required this.client});

  @override
  Future<List<BookModel>> getBooks({
    int page = 1,
    int limit = 20,
    String? genre,
    String? searchQuery,
  }) async {
    try {
      var query = client
          .from('books')
          .select(
            '*, users!books_author_id_fkey(id, email, full_name, username, role)',
          );

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.textSearch('title', searchQuery);
      }

      if (genre != null && genre.isNotEmpty) {
        query = query.contains('tags', [
          genre,
        ]); // Use 'tags' instead of 'genres'
      }

      // Only show published books to regular users
      // Authors, publishers, and admins can see drafts through getMyBooks
      final response = await query
          .eq('status', 'published') // Use status field
          .order('created_at', ascending: false)
          .range((page - 1) * limit, page * limit - 1);

      return (response as List)
          .map((book) => BookModel.fromSupabase(book))
          .toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<BookModel> getBookById(String bookId) async {
    try {
      final response = await client
          .from('books')
          .select('*, users!books_author_id_fkey(*)')
          .eq('id', bookId)
          .single();

      return BookModel.fromSupabase(response);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<BookModel> createBook({
    required String title,
    required String description,
    required List<String> genres,
    String? coverImageUrl,
  }) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) throw const ServerFailure('User not authenticated');

      // Check if user has permission to create books (author or admin)
      final userResponse = await client
          .from('users')
          .select('role')
          .eq('id', userId)
          .single();

      final userRole = userResponse['role'] as String?;
      if (userRole != 'author' && userRole != 'admin') {
        throw const ServerFailure('Only authors and admins can create books');
      }

      // Match the database schema - remove fields that don't exist
      final response = await client
          .from('books')
          .insert({
            'title': title,
            'description': description,
            'tags': genres, // Use 'tags' instead of 'genres' to match schema
            'cover_image_url': coverImageUrl ?? '',
            'author_id': userId,
            'status': 'draft', // Use 'status' field from schema
            'total_chapters': 0,
            'total_words': 0,
            // Remove fields that don't exist in schema:
            // 'author_name', 'is_completed', 'is_published', 'views'
            // created_at and updated_at are handled by database defaults
          })
          .select(
            '*, users!books_author_id_fkey(id, email, full_name, username, role)',
          )
          .single();

      return BookModel.fromSupabase(response);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<BookModel> updateBook({
    required String bookId,
    String? title,
    String? description,
    List<String>? genres,
    String? coverImageUrl,
    bool? isCompleted,
    bool? isPublished,
  }) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) throw const ServerFailure('User not authenticated');

      // Get current user role
      final userResponse = await client
          .from('users')
          .select('role')
          .eq('id', userId)
          .single();

      final userRole = userResponse['role'] as String?;

      // Get book details to check ownership
      final bookResponse = await client
          .from('books')
          .select('author_id, status')
          .eq('id', bookId)
          .single();

      final bookAuthorId = bookResponse['author_id'] as String?;

      final Map<String, dynamic> updates = {};
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (genres != null) {
        updates['tags'] = genres; // Use 'tags' instead of 'genres'
      }
      if (coverImageUrl != null) updates['cover_image_url'] = coverImageUrl;

      // Handle status updates based on user role
      if (isCompleted != null || isPublished != null) {
        String status = 'draft';
        if (isPublished == true) {
          // Only publishers and admins can publish books
          if (userRole != 'publisher' && userRole != 'admin') {
            throw const ServerFailure(
              'Only publishers and admins can publish books',
            );
          }
          status = 'published';
        } else if (isCompleted == true) {
          status = 'completed';
        }
        updates['status'] = status;
      }

      // Check permissions for update
      if (bookAuthorId != userId && userRole != 'admin') {
        // If not the author and not admin, check if publisher trying to update status only
        if (userRole == 'publisher' &&
            updates.length == 1 &&
            updates.containsKey('status')) {
          // Publisher can only update status
        } else {
          throw const ServerFailure('You can only update your own books');
        }
      }

      final response = await client
          .from('books')
          .update(updates)
          .eq('id', bookId)
          .select(
            '*, users!books_author_id_fkey(id, email, full_name, username, role)',
          )
          .single();

      return BookModel.fromSupabase(response);
    } catch (e) {
      logger.error('BookRemoteDataSource - Error updating book', e);
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> deleteBook(String bookId) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) throw const ServerFailure('User not authenticated');

      await client
          .from('books')
          .delete()
          .eq('id', bookId)
          .eq('author_id', userId);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<BookModel>> getMyBooks([String? userId]) async {
    try {
      logger.info('BookRemoteDataSource - Starting getMyBooks');

      final currentUserId = client.auth.currentUser?.id;
      final authorId = userId ?? currentUserId;
      logger.debug('BookRemoteDataSource - Author ID: $authorId');

      if (currentUserId == null) {
        logger.warning('BookRemoteDataSource - User not authenticated');
        throw const ServerFailure('User not authenticated');
      }

      // Get current user role
      final userResponse = await client
          .from('users')
          .select('role')
          .eq('id', currentUserId)
          .single();

      final userRole = userResponse['role'] as String?;

      logger.debug('BookRemoteDataSource - Executing Supabase query');
      var query = client
          .from('books')
          .select(
            '*, users!books_author_id_fkey(id, email, full_name, username, role)',
          );

      // Role-based filtering
      if (userRole == 'admin') {
        // Admins can see all books
        if (authorId != null) {
          query = query.eq('author_id', authorId);
        }
      } else if (userRole == 'publisher') {
        // Publishers can see all books but typically filter by author
        if (authorId != null) {
          query = query.eq('author_id', authorId);
        }
      } else {
        // Authors and readers can only see their own books
        query = query.eq('author_id', currentUserId);
      }

      final response = await query.order('created_at', ascending: false);

      logger.debug('BookRemoteDataSource - Query executed successfully');
      logger.debug(
        'BookRemoteDataSource - Response type: ${response.runtimeType}',
      );

      final responseList = response as List;
      logger.debug(
        'BookRemoteDataSource - Response length: ${responseList.length}',
      );

      final books = <BookModel>[];
      for (int i = 0; i < response.length; i++) {
        try {
          logger.debug('BookRemoteDataSource - Processing book $i');
          final book = BookModel.fromSupabase(response[i]);
          books.add(book);
          logger.debug(
            'BookRemoteDataSource - Successfully processed book: ${book.title}',
          );
        } catch (e) {
          logger.error('BookRemoteDataSource - Error processing book $i', e);
          logger.debug('BookRemoteDataSource - Raw book data: ${response[i]}');
          // Continue processing other books instead of failing completely
          continue;
        }
      }

      logger.info(
        'BookRemoteDataSource - Successfully processed ${books.length} books',
      );
      return books;
    } catch (e) {
      logger.error('BookRemoteDataSource - Error in getMyBooks', e);
      logger.debug('BookRemoteDataSource - Error type: ${e.runtimeType}');
      if (e is ServerFailure) {
        rethrow;
      }
      throw ServerFailure('Failed to fetch books: ${e.toString()}');
    }
  }

  @override
  Future<List<BookModel>> searchBooks({
    required String query,
    SearchFilters? filters,
    String? sortBy,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      var queryBuilder = client
          .from('books_with_metadata')
          .select('*, users!books_author_id_fkey(*)');

      // Apply text search
      if (query.isNotEmpty) {
        queryBuilder = queryBuilder.or(
          'title.ilike.%$query%,description.ilike.%$query%,author_name.ilike.%$query%',
        );
      }

      // Apply filters
      if (filters != null) {
        if (filters.genres != null && filters.genres!.isNotEmpty) {
          queryBuilder = queryBuilder.overlaps(
            'tags',
            filters.genres!,
          ); // Use 'tags' instead of 'genres'
        }

        if (filters.author != null && filters.author!.isNotEmpty) {
          // Join with users table to search by author name
          queryBuilder = queryBuilder.or(
            'users.full_name.ilike.%${filters.author}%,users.email.ilike.%${filters.author}%',
          );
        }

        // Map isCompleted and isPublished to status field
        if (filters.isCompleted != null || filters.isPublished != null) {
          String status = 'draft';
          if (filters.isPublished == true) {
            status = 'published';
          } else if (filters.isCompleted == true) {
            status = 'completed';
          }
          queryBuilder = queryBuilder.eq('status', status);
        }

        if (filters.dateRange != null) {
          if (filters.dateRange!.startDate != null) {
            queryBuilder = queryBuilder.gte(
              'created_at',
              filters.dateRange!.startDate!.toIso8601String(),
            );
          }
          if (filters.dateRange!.endDate != null) {
            queryBuilder = queryBuilder.lte(
              'created_at',
              filters.dateRange!.endDate!.toIso8601String(),
            );
          }
        }

        if (filters.minWordCount != null) {
          queryBuilder = queryBuilder.gte('total_words', filters.minWordCount!);
        }

        if (filters.maxWordCount != null) {
          queryBuilder = queryBuilder.lte('total_words', filters.maxWordCount!);
        }
      }

      // Apply sorting and pagination
      String orderColumn = 'created_at';
      bool ascending = false;

      switch (sortBy) {
        case 'title':
          orderColumn = 'title';
          ascending = true;
          break;
        case 'author':
          orderColumn = 'author_name';
          ascending = true;
          break;
        case 'date_asc':
          orderColumn = 'created_at';
          ascending = true;
          break;
        case 'date_desc':
          orderColumn = 'created_at';
          ascending = false;
          break;
        case 'popularity':
          orderColumn = 'views';
          ascending = false;
          break;
        case 'rating':
          // For rating/likes, we need to use the view that includes likes count
          // This will be handled by using books_with_metadata view
          orderColumn = 'likes';
          ascending = false;
          break;
        default:
          orderColumn = 'created_at';
          ascending = false;
      }

      final response = await queryBuilder
          .order(orderColumn, ascending: ascending)
          .range((page - 1) * limit, page * limit - 1);

      return (response as List)
          .map((book) => BookModel.fromSupabase(book))
          .toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
