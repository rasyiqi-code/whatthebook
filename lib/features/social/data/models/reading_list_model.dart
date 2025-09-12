import '../../domain/entities/reading_list.dart';
import '../../../books/data/models/book_model.dart';

class ReadingListModel {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<BookModel>? books;

  ReadingListModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    this.books,
  });

  factory ReadingListModel.fromSupabase(Map<String, dynamic> json) {
    return ReadingListModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isPublic: json['is_public'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      books: json['books'] != null
          ? (json['books'] as List)
                .map((book) => BookModel.fromSupabase(book))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'is_public': isPublic,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ReadingList toEntity() {
    return ReadingList(
      id: id,
      userId: userId,
      name: name,
      description: description,
      isPublic: isPublic,
      createdAt: createdAt,
      updatedAt: updatedAt,
      books: books?.map((book) => book.toEntity()).toList(),
    );
  }

  factory ReadingListModel.fromEntity(ReadingList entity) {
    return ReadingListModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      description: entity.description,
      isPublic: entity.isPublic,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      books: entity.books?.map((book) => BookModel.fromEntity(book)).toList(),
    );
  }
}
