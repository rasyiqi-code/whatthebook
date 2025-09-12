import '../../domain/entities/library_book.dart';
import '../../domain/entities/book.dart';

class LibraryBookModel extends LibraryBook {
  const LibraryBookModel({
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
    super.lastReadChapterId,
    super.lastReadPage,
    super.lastReadAt,
    required super.readingProgress,
  });

  factory LibraryBookModel.fromJson(Map<String, dynamic> json) {
    // Handle tags field
    List<String>? tagsList;
    if (json['tags'] != null) {
      tagsList = List<String>.from(json['tags']);
    }

    return LibraryBookModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      authorId: json['author_id'] as String?,
      authorName: json['users']?['email'] as String? ?? 'Anonymous',
      coverImageUrl: json['cover_image_url'] as String?,
      status: parseBookStatus(json['status'] as String?),
      genre: json['genre'] as String?,
      tags: tagsList,
      totalChapters: json['total_chapters'] as int? ?? 0,
      totalWords: json['total_words'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastReadChapterId: json['last_read_chapter'] as String?,
      lastReadPage: json['last_read_page'] as int?,
      lastReadAt: json['last_read_at'] != null
          ? DateTime.parse(json['last_read_at'] as String)
          : null,
      readingProgress: _calculateReadingProgress(
        totalChapters: json['total_chapters'] as int? ?? 0,
        lastReadChapter: json['last_read_chapter'] as String?,
        lastReadPage: json['last_read_page'] as int?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'author_id': authorId,
      'cover_image_url': coverImageUrl,
      'status': bookStatusToString(status),
      'genre': genre,
      'tags': tags,
      'total_chapters': totalChapters,
      'total_words': totalWords,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_read_chapter': lastReadChapterId,
      'last_read_page': lastReadPage,
      'last_read_at': lastReadAt?.toIso8601String(),
    };
  }

  static double _calculateReadingProgress({
    required int totalChapters,
    String? lastReadChapter,
    int? lastReadPage,
  }) {
    if (totalChapters == 0 || lastReadChapter == null) {
      return 0.0;
    }

    // Extract chapter number from chapter ID (assuming format like 'chapter_1')
    final chapterNumber = int.tryParse(lastReadChapter.split('_').last) ?? 0;

    // Calculate basic progress based on chapters
    double progress = (chapterNumber / totalChapters) * 100;

    // Adjust progress based on page if available
    if (lastReadPage != null) {
      // Assume each chapter has 100 pages for simplicity
      const pagesPerChapter = 100;
      final pageProgress = lastReadPage / pagesPerChapter;
      progress = ((chapterNumber - 1 + pageProgress) / totalChapters) * 100;
    }

    return progress.clamp(0.0, 100.0);
  }
}
