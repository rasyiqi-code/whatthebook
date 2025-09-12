import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/social_repository.dart';

class DeleteComment implements UseCase<void, DeleteCommentParams> {
  final SocialRepository repository;

  DeleteComment(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteCommentParams params) async {
    return await repository.deleteComment(params.commentId);
  }
}

class DeleteCommentParams extends Equatable {
  final String commentId;

  const DeleteCommentParams({required this.commentId});

  @override
  List<Object> get props => [commentId];
}
