import 'package:equatable/equatable.dart';

class ReadingProgressModel extends Equatable {
  final String id;
  final String? bookId;
  final String? chapterId;
  final double? progressPercentage;
  final DateTime? lastReadAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? userId;
  final String? pdfBookId;

  const ReadingProgressModel({
    required this.id,
    this.bookId,
    this.chapterId,
    this.progressPercentage,
    this.lastReadAt,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.pdfBookId,
  });

  factory ReadingProgressModel.fromJson(Map<String, dynamic> json) {
    return ReadingProgressModel(
      id: json['id'] as String,
      bookId: json['book_id'] as String?,
      chapterId: json['chapter_id'] as String?,
      progressPercentage: (json['progress_percentage'] as num?)?.toDouble(),
      lastReadAt: json['last_read_at'] != null
          ? DateTime.parse(json['last_read_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      userId: json['user_id'] as String?,
      pdfBookId: json['pdf_book_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_id': bookId,
      'chapter_id': chapterId,
      'progress_percentage': progressPercentage,
      'last_read_at': lastReadAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user_id': userId,
      'pdf_book_id': pdfBookId,
    };
  }

  @override
  List<Object?> get props => [
    id,
    bookId,
    chapterId,
    progressPercentage,
    lastReadAt,
    createdAt,
    updatedAt,
    userId,
    pdfBookId,
  ];
}
