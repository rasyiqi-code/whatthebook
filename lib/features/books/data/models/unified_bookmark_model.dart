import '../../domain/entities/unified_bookmark.dart';

class UnifiedBookmarkModel extends UnifiedBookmark {
  const UnifiedBookmarkModel({
    required super.id,
    required super.bookId,
    required super.type,
    super.chapterId,
    super.pageIndex,
    super.page,
    super.note,
    super.bookmarkName,
    required super.createdAt,
    required super.userId,
    super.bookTitle,
    super.coverImageUrl,
  });

  factory UnifiedBookmarkModel.fromSupabaseBookmark(
    Map<String, dynamic> bookmark,
    String? bookTitle,
    String? coverImageUrl,
  ) {
    return UnifiedBookmarkModel(
      id: bookmark['id'] as String,
      bookId: bookmark['book_id'] as String,
      type: BookmarkType.book,
      chapterId: bookmark['chapter_id'] as String?,
      pageIndex: bookmark['page_index'] as int?,
      page: null,
      note: bookmark['note'] as String?,
      bookmarkName: bookmark['bookmark_name'] as String?,
      createdAt: DateTime.parse(bookmark['created_at'] as String),
      userId: bookmark['user_id'] as String,
      bookTitle: bookTitle,
      coverImageUrl: coverImageUrl,
    );
  }

  factory UnifiedBookmarkModel.fromSupabasePdfBookmark(
    Map<String, dynamic> bookmark,
    String? bookTitle,
    String? coverImageUrl,
  ) {
    return UnifiedBookmarkModel(
      id: bookmark['id'] as String,
      bookId: bookmark['pdf_book_id'] as String,
      type: BookmarkType.pdf,
      chapterId: null,
      pageIndex: null,
      page: bookmark['page'] as int,
      note: bookmark['note'] as String?,
      bookmarkName: bookmark['bookmark_name'] as String?,
      createdAt: DateTime.parse(bookmark['created_at'] as String),
      userId: bookmark['user_id'] as String,
      bookTitle: bookTitle,
      coverImageUrl: coverImageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'type': type.name,
      'chapterId': chapterId,
      'pageIndex': pageIndex,
      'page': page,
      'note': note,
      'bookmarkName': bookmarkName,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
      'bookTitle': bookTitle,
      'coverImageUrl': coverImageUrl,
    };
  }

  factory UnifiedBookmarkModel.fromMap(Map<String, dynamic> map) {
    return UnifiedBookmarkModel(
      id: map['id'] as String,
      bookId: map['bookId'] as String,
      type: BookmarkType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => BookmarkType.book,
      ),
      chapterId: map['chapterId'] as String?,
      pageIndex: map['pageIndex'] as int?,
      page: map['page'] as int?,
      note: map['note'] as String?,
      bookmarkName: map['bookmarkName'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      userId: map['userId'] as String,
      bookTitle: map['bookTitle'] as String?,
      coverImageUrl: map['coverImageUrl'] as String?,
    );
  }
}
