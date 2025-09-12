import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chapter_repository.dart';

class DeleteChapter implements UseCase<void, DeleteChapterParams> {
  final ChapterRepository repository;

  DeleteChapter(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteChapterParams params) async {
    return await repository.deleteChapter(params.chapterId);
  }
}

class DeleteChapterParams extends Equatable {
  final String chapterId;

  const DeleteChapterParams({required this.chapterId});

  @override
  List<Object> get props => [chapterId];
}
