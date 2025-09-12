import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/social_repository.dart';

class CheckBookLikeStatus implements UseCase<bool, CheckBookLikeStatusParams> {
  final SocialRepository repository;

  CheckBookLikeStatus(this.repository);

  @override
  Future<Either<Failure, bool>> call(CheckBookLikeStatusParams params) async {
    return await repository.isBookLiked(params.bookId);
  }
}

class CheckBookLikeStatusParams extends Equatable {
  final String bookId;

  const CheckBookLikeStatusParams({required this.bookId});

  @override
  List<Object> get props => [bookId];
}
