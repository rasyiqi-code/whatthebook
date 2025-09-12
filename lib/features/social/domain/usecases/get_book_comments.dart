import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/comment.dart';
import '../repositories/social_repository.dart';

class GetBookComments implements UseCase<List<Comment>, GetBookCommentsParams> {
  final SocialRepository repository;

  GetBookComments(this.repository);

  @override
  Future<Either<Failure, List<Comment>>> call(GetBookCommentsParams params) async {
    return await repository.getBookComments(params.bookId);
  }
}

class GetBookCommentsParams extends Equatable {
  final String bookId;

  const GetBookCommentsParams({required this.bookId});

  @override
  List<Object> get props => [bookId];
}
