import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/follow.dart';
import '../repositories/social_repository.dart';

class FollowUser implements UseCase<Follow, FollowUserParams> {
  final SocialRepository repository;

  FollowUser(this.repository);

  @override
  Future<Either<Failure, Follow>> call(FollowUserParams params) async {
    return await repository.followUser(params.userId);
  }
}

class FollowUserParams extends Equatable {
  final String userId;

  const FollowUserParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
