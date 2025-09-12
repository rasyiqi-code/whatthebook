import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/follow_model.dart';
import '../models/book_view_model.dart';
import '../models/comment_model.dart';
import '../models/reading_list_model.dart';

abstract class SocialRemoteDataSource {
  // Follow System
  Future<FollowModel> followUser(String userId);
  Future<void> unfollowUser(String userId);
  Future<bool> isFollowing(String userId);
  Future<List<UserModel>> getFollowers(String userId);
  Future<List<UserModel>> getFollowing(String userId);

  // Book Likes
  Future<void> likeBook(String bookId);
  Future<void> unlikeBook(String bookId);
  Future<bool> isBookLiked(String bookId);
  Future<List<UserModel>> getBookLikers(String bookId);

  // Book Views
  Future<BookViewModel> trackBookView(String bookId);

  // Comments
  Future<CommentModel> addComment({
    required String bookId,
    String? chapterId,
    required String content,
    String? parentCommentId,
  });
  Future<CommentModel> updateComment({
    required String commentId,
    required String content,
  });
  Future<void> deleteComment(String commentId);
  Future<List<CommentModel>> getBookComments(String bookId);
  Future<List<CommentModel>> getChapterComments(String chapterId);

  // Reading Lists
  Future<ReadingListModel> createReadingList({
    required String name,
    String? description,
    bool isPublic,
  });

  Future<ReadingListModel> updateReadingList({
    required String listId,
    String? name,
    String? description,
    bool? isPublic,
  });

  Future<void> deleteReadingList(String listId);

  Future<List<ReadingListModel>> getUserReadingLists(String userId);

  Future<void> addBookToReadingList({
    required String listId,
    required String bookId,
  });

  Future<void> removeBookFromReadingList({
    required String listId,
    required String bookId,
  });
}

class SocialRemoteDataSourceImpl implements SocialRemoteDataSource {
  final SupabaseClient client;

  SocialRemoteDataSourceImpl({required this.client});

  @override
  Future<FollowModel> followUser(String userId) async {
    try {
      final currentUserId = client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw const ServerFailure('User not authenticated');
      }

      final response = await client
          .from('follows')
          .insert({'follower_id': currentUserId, 'following_id': userId})
          .select()
          .single();

      return FollowModel.fromSupabase(response);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> unfollowUser(String userId) async {
    try {
      final currentUserId = client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw const ServerFailure('User not authenticated');
      }

      await client
          .from('follows')
          .delete()
          .eq('follower_id', currentUserId)
          .eq('following_id', userId);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<bool> isFollowing(String userId) async {
    try {
      final currentUserId = client.auth.currentUser?.id;
      if (currentUserId == null) {
        return false;
      }

      final response = await client
          .from('follows')
          .select('id')
          .eq('follower_id', currentUserId)
          .eq('following_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<UserModel>> getFollowers(String userId) async {
    try {
      final response = await client
          .from('follows')
          .select('follower_id, users!follows_follower_id_fkey(*)')
          .eq('following_id', userId);

      return (response as List)
          .map((follow) => UserModel.fromSupabase(follow['users']))
          .toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<UserModel>> getFollowing(String userId) async {
    try {
      final response = await client
          .from('follows')
          .select('following_id, users!follows_following_id_fkey(*)')
          .eq('follower_id', userId);

      return (response as List)
          .map((follow) => UserModel.fromSupabase(follow['users']))
          .toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> likeBook(String bookId) async {
    try {
      final currentUserId = client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw const ServerFailure('User not authenticated');
      }

      // Check if the like already exists
      final existingLike = await client
          .from('book_likes')
          .select('id')
          .eq('user_id', currentUserId)
          .eq('book_id', bookId)
          .maybeSingle();

      // Only insert if the like doesn't exist
      if (existingLike == null) {
        await client.from('book_likes').insert({
          'user_id': currentUserId,
          'book_id': bookId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> unlikeBook(String bookId) async {
    try {
      final currentUserId = client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw const ServerFailure('User not authenticated');
      }

      await client
          .from('book_likes')
          .delete()
          .eq('user_id', currentUserId)
          .eq('book_id', bookId);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<bool> isBookLiked(String bookId) async {
    try {
      final currentUserId = client.auth.currentUser?.id;
      if (currentUserId == null) {
        return false;
      }

      final response = await client
          .from('book_likes')
          .select('id')
          .eq('user_id', currentUserId)
          .eq('book_id', bookId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<UserModel>> getBookLikers(String bookId) async {
    try {
      final response = await client
          .from('book_likes')
          .select('user_id, users(*)')
          .eq('book_id', bookId);

      return (response as List)
          .map((like) => UserModel.fromSupabase(like['users']))
          .toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<BookViewModel> trackBookView(String bookId) async {
    try {
      final currentUserId = client.auth.currentUser?.id;
      
      final response = await client
          .from('book_views')
          .insert({
        'book_id': bookId,
        'user_id': currentUserId, // Can be null for anonymous users
        'viewed_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return BookViewModel.fromSupabase(response);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<CommentModel> addComment({
    required String bookId,
    String? chapterId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final currentUserId = client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw const ServerFailure('User not authenticated');
      }

      final response = await client
          .from('comments')
          .insert({
            'user_id': currentUserId,
            'book_id': bookId,
            'chapter_id': chapterId,
            'content': content,
            'parent_comment_id': parentCommentId,
          })
          .select('*, users(*)')
          .single();

      return CommentModel.fromSupabase(response);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<CommentModel> updateComment({
    required String commentId,
    required String content,
  }) async {
    try {
      final response = await client
          .from('comments')
          .update({
            'content': content,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', commentId)
          .select('*, users(*)')
          .single();

      return CommentModel.fromSupabase(response);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      await client.from('comments').delete().eq('id', commentId);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<CommentModel>> getBookComments(String bookId) async {
    try {
      final response = await client
          .from('comments')
          .select('*, users(*)')
          .eq('book_id', bookId)
          .order('created_at', ascending: false);

      // Flat list of all comments
      final allComments = (response as List)
          .map((comment) => CommentModel.fromSupabase(comment))
          .toList();

      // Map to hold replies for each parent
      final Map<String, List<CommentModel>> repliesMap = {};
      for (final comment in allComments) {
        if (comment.parentCommentId != null) {
          repliesMap
              .putIfAbsent(comment.parentCommentId!, () => [])
              .add(comment);
        }
      }
      // Build root comments with nested replies
      final List<CommentModel> rootComments = [];
      for (final comment in allComments) {
        if (comment.parentCommentId == null) {
          final replies = repliesMap[comment.id]?.cast<CommentModel>() ?? [];
          rootComments.add(
            replies.isNotEmpty ? comment.copyWith(replies: replies) : comment,
          );
        }
      }
      return rootComments;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<CommentModel>> getChapterComments(String chapterId) async {
    try {
      final response = await client
          .from('comments')
          .select('*, users(*)')
          .eq('chapter_id', chapterId)
          .isFilter('parent_comment_id', null)
          .order('created_at', ascending: false);

      return (response as List)
          .map((comment) => CommentModel.fromSupabase(comment))
          .toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  // Reading Lists Implementation
  @override
  Future<ReadingListModel> createReadingList({
    required String name,
    String? description,
    bool isPublic = true,
  }) async {
    try {
      final currentUserId = client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw const ServerFailure('User not authenticated');
      }

      final now = DateTime.now().toIso8601String();
      final response = await client
          .from('reading_lists')
          .insert({
            'user_id': currentUserId,
            'name': name,
            'description': description,
            'is_public': isPublic,
            'created_at': now,
            'updated_at': now,
          })
          .select()
          .single();

      return ReadingListModel.fromSupabase(response);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<ReadingListModel> updateReadingList({
    required String listId,
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    try {
      final currentUserId = client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw const ServerFailure('User not authenticated');
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (isPublic != null) updateData['is_public'] = isPublic;

      final response = await client
          .from('reading_lists')
          .update(updateData)
          .eq('id', listId)
          .eq('user_id', currentUserId) // Ensure user owns the list
          .select()
          .single();

      return ReadingListModel.fromSupabase(response);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> deleteReadingList(String listId) async {
    try {
      final currentUserId = client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw const ServerFailure('User not authenticated');
      }

      await client
          .from('reading_lists')
          .delete()
          .eq('id', listId)
          .eq('user_id', currentUserId); // Ensure user owns the list
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<ReadingListModel>> getUserReadingLists(String userId) async {
    try {
      final currentUserId = client.auth.currentUser?.id;

      final query = client
          .from('reading_lists')
          .select('*, books(*)')
          .eq('user_id', userId);

      // If not viewing own lists, only show public ones
      if (currentUserId != userId) {
        query.eq('is_public', true);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((list) => ReadingListModel.fromSupabase(list))
          .toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> addBookToReadingList({
    required String listId,
    required String bookId,
  }) async {
    try {
      final currentUserId = client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw const ServerFailure('User not authenticated');
      }

      // First verify user owns the list
      try {
        await client
            .from('reading_lists')
            .select()
            .eq('id', listId)
            .eq('user_id', currentUserId)
            .single();
      } catch (e) {
        throw const ServerFailure('Reading list not found');
      }

      // Add book to list
      await client.from('reading_list_books').insert({
        'list_id': listId,
        'book_id': bookId,
        'added_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> removeBookFromReadingList({
    required String listId,
    required String bookId,
  }) async {
    try {
      final currentUserId = client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw const ServerFailure('User not authenticated');
      }

      // First verify user owns the list
      try {
        await client
            .from('reading_lists')
            .select()
            .eq('id', listId)
            .eq('user_id', currentUserId)
            .single();
      } catch (e) {
        throw const ServerFailure('Reading list not found');
      }

      // Remove book from list
      await client
          .from('reading_list_books')
          .delete()
          .eq('list_id', listId)
          .eq('book_id', bookId);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
