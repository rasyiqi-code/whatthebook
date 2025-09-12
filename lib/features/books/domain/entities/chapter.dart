import 'package:equatable/equatable.dart';

class Chapter extends Equatable {
  final String id;
  final String bookId;
  final int chapterNumber;
  final String title;
  final String content;
  final int wordCount;
  final String status; // draft, published
  final DateTime createdAt;
  final DateTime updatedAt;

  const Chapter({
    required this.id,
    required this.bookId,
    required this.chapterNumber,
    required this.title,
    required this.content,
    required this.wordCount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object> get props => [
        id,
        bookId,
        chapterNumber,
        title,
        content,
        wordCount,
        status,
        createdAt,
        updatedAt,
      ];

  Chapter copyWith({
    String? id,
    String? bookId,
    int? chapterNumber,
    String? title,
    String? content,
    int? wordCount,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Chapter(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      title: title ?? this.title,
      content: content ?? this.content,
      wordCount: wordCount ?? this.wordCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
