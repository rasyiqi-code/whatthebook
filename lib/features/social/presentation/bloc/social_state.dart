import 'package:equatable/equatable.dart';
import '../../domain/entities/follow.dart';
import '../../domain/entities/book_view.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/reading_list.dart';
import '../../../auth/domain/entities/user.dart';

abstract class SocialState extends Equatable {
  const SocialState();

  @override
  List<Object?> get props => [];
}

class SocialInitial extends SocialState {}

class SocialLoading extends SocialState {}

class SocialError extends SocialState {
  final String message;

  const SocialError(this.message);

  @override
  List<Object> get props => [message];
}

// Follow States
class UserFollowed extends SocialState {
  final Follow follow;

  const UserFollowed(this.follow);

  @override
  List<Object> get props => [follow];
}

class UserUnfollowed extends SocialState {
  final String userId;

  const UserUnfollowed(this.userId);

  @override
  List<Object> get props => [userId];
}

class FollowStatusLoaded extends SocialState {
  final String userId;
  final bool isFollowing;

  const FollowStatusLoaded(this.userId, this.isFollowing);

  @override
  List<Object> get props => [userId, isFollowing];
}

class FollowersLoaded extends SocialState {
  final String userId;
  final List<User> followers;

  const FollowersLoaded(this.userId, this.followers);

  @override
  List<Object> get props => [userId, followers];
}

class FollowingLoaded extends SocialState {
  final String userId;
  final List<User> following;

  const FollowingLoaded(this.userId, this.following);

  @override
  List<Object> get props => [userId, following];
}

// Like States
class BookLiked extends SocialState {
  final String bookId;

  const BookLiked(this.bookId);

  @override
  List<Object> get props => [bookId];
}

class BookUnliked extends SocialState {
  final String bookId;

  const BookUnliked(this.bookId);

  @override
  List<Object> get props => [bookId];
}

class BookLikeStatusLoaded extends SocialState {
  final String bookId;
  final bool isLiked;

  const BookLikeStatusLoaded(this.bookId, this.isLiked);

  @override
  List<Object> get props => [bookId, isLiked];
}

// Comment States
class CommentAdded extends SocialState {
  final Comment comment;

  const CommentAdded(this.comment);

  @override
  List<Object> get props => [comment];
}

class CommentUpdated extends SocialState {
  final Comment comment;

  const CommentUpdated(this.comment);

  @override
  List<Object> get props => [comment];
}

class CommentDeleted extends SocialState {
  final String commentId;

  const CommentDeleted(this.commentId);

  @override
  List<Object> get props => [commentId];
}

class BookCommentsLoaded extends SocialState {
  final String bookId;
  final List<Comment> comments;

  const BookCommentsLoaded(this.bookId, this.comments);

  @override
  List<Object> get props => [bookId, comments];
}

class ChapterCommentsLoaded extends SocialState {
  final String chapterId;
  final List<Comment> comments;

  const ChapterCommentsLoaded(this.chapterId, this.comments);

  @override
  List<Object> get props => [chapterId, comments];
}

// Reading List States
class ReadingListCreated extends SocialState {
  final ReadingList readingList;

  const ReadingListCreated(this.readingList);

  @override
  List<Object> get props => [readingList];
}

class ReadingListUpdated extends SocialState {
  final ReadingList readingList;

  const ReadingListUpdated(this.readingList);

  @override
  List<Object> get props => [readingList];
}

class ReadingListDeleted extends SocialState {
  final String listId;

  const ReadingListDeleted(this.listId);

  @override
  List<Object> get props => [listId];
}

class ReadingListsLoaded extends SocialState {
  final String userId;
  final List<ReadingList> readingLists;

  const ReadingListsLoaded(this.userId, this.readingLists);

  @override
  List<Object> get props => [userId, readingLists];
}

class BookAddedToReadingList extends SocialState {
  final String listId;
  final String bookId;

  const BookAddedToReadingList(this.listId, this.bookId);

  @override
  List<Object> get props => [listId, bookId];
}

class BookRemovedFromReadingList extends SocialState {
  final String listId;
  final String bookId;

  const BookRemovedFromReadingList(this.listId, this.bookId);

  @override
  List<Object> get props => [listId, bookId];
}

// Book View States
class BookViewTracked extends SocialState {
  final BookView bookView;

  const BookViewTracked(this.bookView);

  @override
  List<Object> get props => [bookView];
}
