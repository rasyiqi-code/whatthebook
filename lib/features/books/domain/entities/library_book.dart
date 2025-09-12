import 'book.dart';

class LibraryBook extends Book {
  final String? lastReadChapterId;
  final int? lastReadPage;
  final DateTime? lastReadAt;
  final double readingProgress; // Percentage of completion (0-100)

  const LibraryBook({
    required super.id,
    required super.title,
    super.description,
    super.authorId,
    required super.authorName,
    super.coverImageUrl,
    required super.status,
    super.genre,
    super.tags,
    required super.totalChapters,
    required super.totalWords,
    required super.createdAt,
    required super.updatedAt,
    this.lastReadChapterId,
    this.lastReadPage,
    this.lastReadAt,
    required this.readingProgress,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    lastReadChapterId,
    lastReadPage,
    lastReadAt,
    readingProgress,
  ];

  @override
  LibraryBook copyWith({
    String? id,
    String? title,
    String? description,
    String? authorId,
    String? authorName,
    String? coverImageUrl,
    BookStatus? status,
    String? genre,
    List<String>? tags,
    int? totalChapters,
    int? totalWords,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastReadChapterId,
    int? lastReadPage,
    DateTime? lastReadAt,
    double? readingProgress,
  }) {
    return LibraryBook(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      status: status ?? this.status,
      genre: genre ?? this.genre,
      tags: tags ?? this.tags,
      totalChapters: totalChapters ?? this.totalChapters,
      totalWords: totalWords ?? this.totalWords,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastReadChapterId: lastReadChapterId ?? this.lastReadChapterId,
      lastReadPage: lastReadPage ?? this.lastReadPage,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      readingProgress: readingProgress ?? this.readingProgress,
    );
  }
}
