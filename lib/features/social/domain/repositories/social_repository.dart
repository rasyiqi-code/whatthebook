import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/follow.dart';
import '../entities/book_like.dart';
import '../entities/book_view.dart';
import '../entities/comment.dart';
import '../entities/reading_list.dart';
import '../../../auth/domain/entities/user.dart';

abstract class SocialRepository {
  // Follow System
  Future<Either<Failure, Follow>> followUser(String userId);
  Future<Either<Failure, void>> unfollowUser(String userId);
  Future<Either<Failure, bool>> isFollowing(String userId);
  Future<Either<Failure, List<User>>> getFollowers(String userId);
  Future<Either<Failure, List<User>>> getFollowing(String userId);

  // Book Likes
  Future<Either<Failure, BookLike>> likeBook(String bookId);
  Future<Either<Failure, void>> unlikeBook(String bookId);
  Future<Either<Failure, bool>> isBookLiked(String bookId);
  Future<Either<Failure, List<User>>> getBookLikers(String bookId);

  // Book Views
  Future<Either<Failure, BookView>> trackBookView(String bookId);

  // Comments
  Future<Either<Failure, Comment>> addComment({
    required String bookId,
    String? chapterId,
    required String content,
    String? parentCommentId,
  });
  Future<Either<Failure, Comment>> updateComment({
    required String commentId,
    required String content,
  });
  Future<Either<Failure, void>> deleteComment(String commentId);
  Future<Either<Failure, List<Comment>>> getBookComments(String bookId);
  Future<Either<Failure, List<Comment>>> getChapterComments(String chapterId);

  // Reading Lists
  Future<Either<Failure, ReadingList>> createReadingList({
    required String name,
    String? description,
    bool isPublic = true,
  });
  Future<Either<Failure, ReadingList>> updateReadingList({
    required String listId,
    String? name,
    String? description,
    bool? isPublic,
  });
  Future<Either<Failure, void>> deleteReadingList(String listId);
  Future<Either<Failure, List<ReadingList>>> getUserReadingLists(String userId);
  Future<Either<Failure, void>> addBookToReadingList({
    required String listId,
    required String bookId,
  });
  Future<Either<Failure, void>> removeBookFromReadingList({
    required String listId,
    required String bookId,
  });
}
