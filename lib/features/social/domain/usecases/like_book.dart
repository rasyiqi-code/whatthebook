import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/book_like.dart';
import '../repositories/social_repository.dart';

class LikeBook implements UseCase<BookLike, LikeBookParams> {
  final SocialRepository repository;

  LikeBook(this.repository);

  @override
  Future<Either<Failure, BookLike>> call(LikeBookParams params) async {
    return await repository.likeBook(params.bookId);
  }
}

class LikeBookParams extends Equatable {
  final String bookId;

  const LikeBookParams({required this.bookId});

  @override
  List<Object> get props => [bookId];
}
