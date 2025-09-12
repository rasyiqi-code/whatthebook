import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/comment.dart';
import '../repositories/social_repository.dart';

class GetChapterComments implements UseCase<List<Comment>, GetChapterCommentsParams> {
  final SocialRepository repository;

  GetChapterComments(this.repository);

  @override
  Future<Either<Failure, List<Comment>>> call(GetChapterCommentsParams params) async {
    return await repository.getChapterComments(params.chapterId);
  }
}

class GetChapterCommentsParams extends Equatable {
  final String chapterId;

  const GetChapterCommentsParams({required this.chapterId});

  @override
  List<Object> get props => [chapterId];
}
