class Bookmark {
  final String id;
  final String bookId;
  final String? chapterId;
  final int? pageIndex;
  final String? note;
  final String? bookmarkName;
  final DateTime createdAt;
  final String userId;

  const Bookmark({
    required this.id,
    required this.bookId,
    this.chapterId,
    this.pageIndex,
    this.note,
    this.bookmarkName,
    required this.createdAt,
    required this.userId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bookmark &&
        other.id == id &&
        other.bookId == bookId &&
        other.chapterId == chapterId &&
        other.pageIndex == pageIndex &&
        other.note == note &&
        other.bookmarkName == bookmarkName &&
        other.createdAt == createdAt &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        bookId.hashCode ^
        chapterId.hashCode ^
        pageIndex.hashCode ^
        note.hashCode ^
        bookmarkName.hashCode ^
        createdAt.hashCode ^
        userId.hashCode;
  }
}
