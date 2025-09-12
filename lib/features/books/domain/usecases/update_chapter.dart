import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chapter.dart';
import '../repositories/chapter_repository.dart';

class UpdateChapter implements UseCase<Chapter, UpdateChapterParams> {
  final ChapterRepository repository;

  UpdateChapter(this.repository);

  @override
  Future<Either<Failure, Chapter>> call(UpdateChapterParams params) async {
    return await repository.updateChapter(
      chapterId: params.chapterId,
      title: params.title,
      content: params.content,
      wordCount: params.wordCount,
      status: params.status,
    );
  }
}

class UpdateChapterParams extends Equatable {
  final String chapterId;
  final String? title;
  final String? content;
  final int? wordCount;
  final String? status;

  const UpdateChapterParams({
    required this.chapterId,
    this.title,
    this.content,
    this.wordCount,
    this.status,
  });

  @override
  List<Object?> get props => [chapterId, title, content, wordCount, status];
}
