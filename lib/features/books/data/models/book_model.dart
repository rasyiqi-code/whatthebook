import '../../domain/entities/book.dart';
import '../../../../core/services/logger_service.dart';

class BookModel extends Book {
  const BookModel({
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
  });

  factory BookModel.fromSupabase(Map<String, dynamic> map) {
    try {
      // Handle tags field safely
      List<String>? tagsList;
      if (map['tags'] != null) {
        tagsList = (map['tags'] as List).map((tag) => tag.toString()).toList();
      }

      // Handle dates safely
      DateTime? createdAt;
      DateTime? updatedAt;
      try {
        createdAt = map['created_at'] != null
            ? DateTime.parse(map['created_at'].toString())
            : DateTime.now();
        updatedAt = map['updated_at'] != null
            ? DateTime.parse(map['updated_at'].toString())
            : DateTime.now();
      } catch (e) {
        logger.warning('BookModel - Error parsing dates', e);
        createdAt = DateTime.now();
        updatedAt = DateTime.now();
      }

      // Get author name from users join
      String authorName = 'Anonymous';
      if (map['users'] != null) {
        authorName =
            map['users']['full_name']?.toString() ??
            map['users']['email']?.toString() ??
            'Anonymous';
      }

      return BookModel(
        id: map['id']?.toString() ?? '',
        title: map['title']?.toString() ?? 'Untitled',
        description: map['description']?.toString(),
        authorId: map['author_id']?.toString(),
        authorName: authorName,
        coverImageUrl: map['cover_image_url']?.toString(),
        status: parseBookStatus(map['status']?.toString()),
        genre: map['genre']?.toString(),
        tags: tagsList,
        totalChapters:
            int.tryParse(map['total_chapters']?.toString() ?? '') ?? 0,
        totalWords: int.tryParse(map['total_words']?.toString() ?? '') ?? 0,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      logger.error('BookModel - Error in fromSupabase', e);
      logger.debug('BookModel - Raw data: $map');
      rethrow;
    }
  }

  Map<String, dynamic> toSupabase() {
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
    };
  }

  factory BookModel.fromEntity(Book book) {
    return BookModel(
      id: book.id,
      title: book.title,
      description: book.description,
      authorId: book.authorId,
      authorName: book.authorName,
      coverImageUrl: book.coverImageUrl,
      status: book.status,
      genre: book.genre,
      tags: book.tags,
      totalChapters: book.totalChapters,
      totalWords: book.totalWords,
      createdAt: book.createdAt,
      updatedAt: book.updatedAt,
    );
  }

  Book toEntity() {
    return Book(
      id: id,
      title: title,
      description: description,
      authorId: authorId,
      authorName: authorName,
      coverImageUrl: coverImageUrl,
      status: status,
      genre: genre,
      tags: tags,
      totalChapters: totalChapters,
      totalWords: totalWords,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
