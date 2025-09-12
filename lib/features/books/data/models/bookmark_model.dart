import '../../domain/entities/bookmark.dart';

class BookmarkModel {
  final String id;
  final String bookId;
  final String? chapterId;
  final int? pageIndex;
  final String? note;
  final String? bookmarkName;
  final DateTime createdAt;
  final String userId;

  const BookmarkModel({
    required this.id,
    required this.bookId,
    this.chapterId,
    this.pageIndex,
    this.note,
    this.bookmarkName,
    required this.createdAt,
    required this.userId,
  });

  factory BookmarkModel.fromSupabase(Map<String, dynamic> map) {
    return BookmarkModel(
      id: map['id'] as String,
      bookId: map['book_id'] as String,
      chapterId: map['chapter_id'] as String?,
      pageIndex: map['page_index'] as int?,
      note: map['note'] as String?,
      bookmarkName: map['bookmark_name'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      userId: map['user_id'] as String,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'book_id': bookId,
      'chapter_id': chapterId,
      'page_index': pageIndex,
      'note': note,
      'bookmark_name': bookmarkName,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
    };
  }

  Bookmark toEntity() {
    return Bookmark(
      id: id,
      bookId: bookId,
      chapterId: chapterId,
      pageIndex: pageIndex,
      note: note,
      bookmarkName: bookmarkName,
      createdAt: createdAt,
      userId: userId,
    );
  }

  factory BookmarkModel.fromEntity(Bookmark entity) {
    return BookmarkModel(
      id: entity.id,
      bookId: entity.bookId,
      chapterId: entity.chapterId,
      pageIndex: entity.pageIndex,
      note: entity.note,
      bookmarkName: entity.bookmarkName,
      createdAt: entity.createdAt,
      userId: entity.userId,
    );
  }
}
