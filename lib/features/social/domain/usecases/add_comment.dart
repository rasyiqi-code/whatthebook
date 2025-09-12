import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/comment.dart';
import '../repositories/social_repository.dart';

class AddComment implements UseCase<Comment, AddCommentParams> {
  final SocialRepository repository;

  AddComment(this.repository);

  @override
  Future<Either<Failure, Comment>> call(AddCommentParams params) async {
    return await repository.addComment(
      bookId: params.bookId,
      chapterId: params.chapterId,
      content: params.content,
      parentCommentId: params.parentCommentId,
    );
  }
}

class AddCommentParams extends Equatable {
  final String bookId;
  final String? chapterId;
  final String content;
  final String? parentCommentId;

  const AddCommentParams({
    required this.bookId,
    this.chapterId,
    required this.content,
    this.parentCommentId,
  });

  @override
  List<Object?> get props => [bookId, chapterId, content, parentCommentId];
}
