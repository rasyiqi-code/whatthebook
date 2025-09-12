import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user.dart';

class Comment extends Equatable {
  final String id;
  final String userId;
  final String bookId;
  final String? chapterId;
  final String content;
  final String? parentCommentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user; // For displaying user info
  final List<Comment>? replies; // For nested comments

  const Comment({
    required this.id,
    required this.userId,
    required this.bookId,
    this.chapterId,
    required this.content,
    this.parentCommentId,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.replies,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        bookId,
        chapterId,
        content,
        parentCommentId,
        createdAt,
        updatedAt,
        user,
        replies,
      ];

  Comment copyWith({
    String? id,
    String? userId,
    String? bookId,
    String? chapterId,
    String? content,
    String? parentCommentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
    List<Comment>? replies,
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      chapterId: chapterId ?? this.chapterId,
      content: content ?? this.content,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      replies: replies ?? this.replies,
    );
  }
}
