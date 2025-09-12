import 'package:equatable/equatable.dart';

enum BookStatus {
  draft,
  completed,
  published;

  String get displayName {
    switch (this) {
      case BookStatus.draft:
        return 'Draft';
      case BookStatus.completed:
        return 'Completed';
      case BookStatus.published:
        return 'Published';
    }
  }

  bool get isPublic => this == BookStatus.published;
  bool get isDraft => this == BookStatus.draft;
  bool get isCompleted => this == BookStatus.completed;
}

BookStatus parseBookStatus(String? statusString) {
  switch (statusString?.toLowerCase()) {
    case 'published':
      return BookStatus.published;
    case 'completed':
      return BookStatus.completed;
    case 'draft':
    default:
      return BookStatus.draft;
  }
}

String bookStatusToString(BookStatus status) {
  switch (status) {
    case BookStatus.draft:
      return 'draft';
    case BookStatus.completed:
      return 'completed';
    case BookStatus.published:
      return 'published';
  }
}

class Book extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? authorId;
  final String authorName;
  final String? coverImageUrl;
  final BookStatus status;
  final String? genre;
  final List<String>? tags;
  final int totalChapters;
  final int totalWords;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Book({
    required this.id,
    required this.title,
    this.description,
    this.authorId,
    required this.authorName,
    this.coverImageUrl,
    required this.status,
    this.genre,
    this.tags,
    required this.totalChapters,
    required this.totalWords,
    required this.createdAt,
    required this.updatedAt,
  });

  // Legacy support for string status
  String get statusString => bookStatusToString(status);

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    authorId,
    authorName,
    coverImageUrl,
    status,
    genre,
    tags,
    totalChapters,
    totalWords,
    createdAt,
    updatedAt,
  ];

  Book copyWith({
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
  }) {
    return Book(
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
    );
  }
}
