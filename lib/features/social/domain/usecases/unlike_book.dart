import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/social_repository.dart';

class UnlikeBook implements UseCase<void, UnlikeBookParams> {
  final SocialRepository repository;

  UnlikeBook(this.repository);

  @override
  Future<Either<Failure, void>> call(UnlikeBookParams params) async {
    return await repository.unlikeBook(params.bookId);
  }
}

class UnlikeBookParams extends Equatable {
  final String bookId;

  const UnlikeBookParams({required this.bookId});

  @override
  List<Object> get props => [bookId];
}
