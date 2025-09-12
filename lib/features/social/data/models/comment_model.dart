import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/comment.dart';
import '../../../auth/domain/entities/user.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.userId,
    required super.bookId,
    super.chapterId,
    required super.content,
    super.parentCommentId,
    required super.createdAt,
    required super.updatedAt,
    super.user,
    super.replies,
  });

  factory CommentModel.fromSupabase(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      bookId: map['book_id'] as String,
      chapterId: map['chapter_id'] as String?,
      content: map['content'] as String,
      parentCommentId: map['parent_comment_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      user: map['users'] != null
          ? UserModel.fromSupabase(
              map['users'] as Map<String, dynamic>,
            ).toEntity()
          : null,
      replies: map['replies'] != null
          ? (map['replies'] as List)
                .map((reply) => CommentModel.fromSupabase(reply))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'user_id': userId,
      'book_id': bookId,
      'chapter_id': chapterId,
      'content': content,
      'parent_comment_id': parentCommentId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CommentModel.fromEntity(Comment comment) {
    return CommentModel(
      id: comment.id,
      userId: comment.userId,
      bookId: comment.bookId,
      chapterId: comment.chapterId,
      content: comment.content,
      parentCommentId: comment.parentCommentId,
      createdAt: comment.createdAt,
      updatedAt: comment.updatedAt,
      user: comment.user,
      replies: comment.replies,
    );
  }

  Comment toEntity() {
    return Comment(
      id: id,
      userId: userId,
      bookId: bookId,
      chapterId: chapterId,
      content: content,
      parentCommentId: parentCommentId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      user: user,
      replies: replies,
    );
  }

  @override
  CommentModel copyWith({
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
    return CommentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      chapterId: chapterId ?? this.chapterId,
      content: content ?? this.content,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      replies:
          replies
              ?.map((e) => e is CommentModel ? e : CommentModel.fromEntity(e))
              .toList() ??
          this.replies,
    );
  }
}
