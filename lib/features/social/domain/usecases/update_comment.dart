import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/comment.dart';
import '../repositories/social_repository.dart';

class UpdateComment implements UseCase<Comment, UpdateCommentParams> {
  final SocialRepository repository;

  UpdateComment(this.repository);

  @override
  Future<Either<Failure, Comment>> call(UpdateCommentParams params) async {
    return await repository.updateComment(
      commentId: params.commentId,
      content: params.content,
    );
  }
}

class UpdateCommentParams extends Equatable {
  final String commentId;
  final String content;

  const UpdateCommentParams({
    required this.commentId,
    required this.content,
  });

  @override
  List<Object> get props => [commentId, content];
}
