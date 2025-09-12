import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chapter.dart';
import '../repositories/chapter_repository.dart';

class GetChaptersByBookId implements UseCase<List<Chapter>, GetChaptersByBookIdParams> {
  final ChapterRepository repository;

  GetChaptersByBookId(this.repository);

  @override
  Future<Either<Failure, List<Chapter>>> call(GetChaptersByBookIdParams params) async {
    return await repository.getChaptersByBookId(params.bookId);
  }
}

class GetChaptersByBookIdParams extends Equatable {
  final String bookId;

  const GetChaptersByBookIdParams({required this.bookId});

  @override
  List<Object> get props => [bookId];
}
