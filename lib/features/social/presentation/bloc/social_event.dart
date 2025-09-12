import 'package:equatable/equatable.dart';

abstract class SocialEvent extends Equatable {
  const SocialEvent();

  @override
  List<Object?> get props => [];
}

// Follow Events
class FollowUserRequested extends SocialEvent {
  final String userId;

  const FollowUserRequested(this.userId);

  @override
  List<Object> get props => [userId];
}

class UnfollowUserRequested extends SocialEvent {
  final String userId;

  const UnfollowUserRequested(this.userId);

  @override
  List<Object> get props => [userId];
}

class CheckFollowStatusRequested extends SocialEvent {
  final String userId;

  const CheckFollowStatusRequested(this.userId);

  @override
  List<Object> get props => [userId];
}

class GetFollowersRequested extends SocialEvent {
  final String userId;

  const GetFollowersRequested(this.userId);

  @override
  List<Object> get props => [userId];
}

class GetFollowingRequested extends SocialEvent {
  final String userId;

  const GetFollowingRequested(this.userId);

  @override
  List<Object> get props => [userId];
}

// Like Events
class LikeBookRequested extends SocialEvent {
  final String bookId;

  const LikeBookRequested(this.bookId);

  @override
  List<Object> get props => [bookId];
}

class UnlikeBookRequested extends SocialEvent {
  final String bookId;

  const UnlikeBookRequested(this.bookId);

  @override
  List<Object> get props => [bookId];
}

class CheckBookLikeStatusRequested extends SocialEvent {
  final String bookId;

  const CheckBookLikeStatusRequested(this.bookId);

  @override
  List<Object> get props => [bookId];
}

// Comment Events
class AddCommentRequested extends SocialEvent {
  final String bookId;
  final String? chapterId;
  final String content;
  final String? parentCommentId;

  const AddCommentRequested({
    required this.bookId,
    this.chapterId,
    required this.content,
    this.parentCommentId,
  });

  @override
  List<Object?> get props => [bookId, chapterId, content, parentCommentId];
}

class UpdateCommentRequested extends SocialEvent {
  final String commentId;
  final String content;

  const UpdateCommentRequested({
    required this.commentId,
    required this.content,
  });

  @override
  List<Object> get props => [commentId, content];
}

class DeleteCommentRequested extends SocialEvent {
  final String commentId;

  const DeleteCommentRequested(this.commentId);

  @override
  List<Object> get props => [commentId];
}

class GetBookCommentsRequested extends SocialEvent {
  final String bookId;

  const GetBookCommentsRequested(this.bookId);

  @override
  List<Object> get props => [bookId];
}

class GetChapterCommentsRequested extends SocialEvent {
  final String chapterId;

  const GetChapterCommentsRequested(this.chapterId);

  @override
  List<Object> get props => [chapterId];
}

// Reading List Events
class CreateReadingListRequested extends SocialEvent {
  final String name;
  final String? description;
  final bool isPublic;

  const CreateReadingListRequested({
    required this.name,
    this.description,
    this.isPublic = true,
  });

  @override
  List<Object?> get props => [name, description, isPublic];
}

class UpdateReadingListRequested extends SocialEvent {
  final String listId;
  final String? name;
  final String? description;
  final bool? isPublic;

  const UpdateReadingListRequested({
    required this.listId,
    this.name,
    this.description,
    this.isPublic,
  });

  @override
  List<Object?> get props => [listId, name, description, isPublic];
}

class DeleteReadingListRequested extends SocialEvent {
  final String listId;

  const DeleteReadingListRequested(this.listId);

  @override
  List<Object> get props => [listId];
}

class GetUserReadingListsRequested extends SocialEvent {
  final String userId;

  const GetUserReadingListsRequested(this.userId);

  @override
  List<Object> get props => [userId];
}

class AddBookToReadingListRequested extends SocialEvent {
  final String listId;
  final String bookId;

  const AddBookToReadingListRequested({
    required this.listId,
    required this.bookId,
  });

  @override
  List<Object> get props => [listId, bookId];
}

class RemoveBookFromReadingListRequested extends SocialEvent {
  final String listId;
  final String bookId;

  const RemoveBookFromReadingListRequested({
    required this.listId,
    required this.bookId,
  });

  @override
  List<Object> get props => [listId, bookId];
}

// Book View Events
class TrackBookViewRequested extends SocialEvent {
  final String bookId;

  const TrackBookViewRequested(this.bookId);

  @override
  List<Object> get props => [bookId];
}
