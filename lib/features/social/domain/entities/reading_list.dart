import 'package:equatable/equatable.dart';
import '../../../books/domain/entities/book.dart';

class ReadingList extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Book>? books; // For displaying books in the list

  const ReadingList({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    this.books,
  });

  int get bookCount => books?.length ?? 0;

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    description,
    isPublic,
    createdAt,
    updatedAt,
    books,
  ];

  ReadingList copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Book>? books,
  }) {
    return ReadingList(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      books: books ?? this.books,
    );
  }
}
