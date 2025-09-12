import '../../domain/entities/chapter.dart';

class ChapterModel extends Chapter {
  const ChapterModel({
    required super.id,
    required super.bookId,
    required super.chapterNumber,
    required super.title,
    required super.content,
    required super.wordCount,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ChapterModel.fromSupabase(Map<String, dynamic> map) {
    return ChapterModel(
      id: map['id'] as String,
      bookId: map['book_id'] as String,
      chapterNumber: map['chapter_number'] as int,
      title: map['title'] as String,
      content: map['content'] as String? ?? '',
      wordCount: map['word_count'] as int? ?? 0,
      status: map['status'] as String? ?? 'draft',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'book_id': bookId,
      'chapter_number': chapterNumber,
      'title': title,
      'content': content,
      'word_count': wordCount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ChapterModel.fromEntity(Chapter chapter) {
    return ChapterModel(
      id: chapter.id,
      bookId: chapter.bookId,
      chapterNumber: chapter.chapterNumber,
      title: chapter.title,
      content: chapter.content,
      wordCount: chapter.wordCount,
      status: chapter.status,
      createdAt: chapter.createdAt,
      updatedAt: chapter.updatedAt,
    );
  }

  Chapter toEntity() {
    return Chapter(
      id: id,
      bookId: bookId,
      chapterNumber: chapterNumber,
      title: title,
      content: content,
      wordCount: wordCount,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
