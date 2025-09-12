import 'package:equatable/equatable.dart';
import '../../domain/entities/bookmark.dart';

abstract class BookmarkState extends Equatable {
  const BookmarkState();

  @override
  List<Object> get props => [];
}

class BookmarkInitial extends BookmarkState {}

class BookmarkLoading extends BookmarkState {}

class BookmarksLoaded extends BookmarkState {
  final List<Bookmark> bookmarks;

  const BookmarksLoaded(this.bookmarks);

  @override
  List<Object> get props => [bookmarks];
}

class BookmarkAdded extends BookmarkState {
  final Bookmark bookmark;

  const BookmarkAdded(this.bookmark);

  @override
  List<Object> get props => [bookmark];
}

class BookmarkDeleted extends BookmarkState {
  final String bookmarkId;

  const BookmarkDeleted(this.bookmarkId);

  @override
  List<Object> get props => [bookmarkId];
}

class BookmarkUpdated extends BookmarkState {
  final Bookmark bookmark;

  const BookmarkUpdated(this.bookmark);

  @override
  List<Object> get props => [bookmark];
}

class BookmarkJumped extends BookmarkState {
  final Bookmark bookmark;

  const BookmarkJumped(this.bookmark);

  @override
  List<Object> get props => [bookmark];
}

class BookmarkError extends BookmarkState {
  final String message;

  const BookmarkError(this.message);

  @override
  List<Object> get props => [message];
}
