import 'package:equatable/equatable.dart';
import '../../domain/entities/bookmark.dart';

abstract class BookmarkEvent extends Equatable {
  const BookmarkEvent();

  @override
  List<Object> get props => [];
}

class GetBookmarksByBookIdEvent extends BookmarkEvent {
  final String bookId;

  const GetBookmarksByBookIdEvent(this.bookId);

  @override
  List<Object> get props => [bookId];
}

class AddBookmarkEvent extends BookmarkEvent {
  final String bookId;
  final String? chapterId;
  final int? pageIndex;
  final String? note;
  final String? bookmarkName;

  const AddBookmarkEvent({
    required this.bookId,
    this.chapterId,
    this.pageIndex,
    this.note,
    this.bookmarkName,
  });

  @override
  List<Object> get props => [
    bookId,
    chapterId ?? '',
    pageIndex ?? 0,
    note ?? '',
    bookmarkName ?? '',
  ];
}

class DeleteBookmarkEvent extends BookmarkEvent {
  final String bookmarkId;

  const DeleteBookmarkEvent(this.bookmarkId);

  @override
  List<Object> get props => [bookmarkId];
}

class UpdateBookmarkEvent extends BookmarkEvent {
  final String bookmarkId;
  final String? note;
  final String? bookmarkName;

  const UpdateBookmarkEvent({
    required this.bookmarkId,
    this.note,
    this.bookmarkName,
  });

  @override
  List<Object> get props => [bookmarkId, note ?? '', bookmarkName ?? ''];
}

class GetAllBookmarksEvent extends BookmarkEvent {}

class JumpToBookmarkEvent extends BookmarkEvent {
  final Bookmark bookmark;

  const JumpToBookmarkEvent(this.bookmark);

  @override
  List<Object> get props => [bookmark];
}
