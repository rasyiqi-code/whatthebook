import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chapter.dart';
import '../repositories/chapter_repository.dart';

class CreateChapter implements UseCase<Chapter, CreateChapterParams> {
  final ChapterRepository repository;

  CreateChapter(this.repository);

  @override
  Future<Either<Failure, Chapter>> call(CreateChapterParams params) async {
    return await repository.createChapter(
      bookId: params.bookId,
      chapterNumber: params.chapterNumber,
      title: params.title,
      content: params.content,
    );
  }
}

class CreateChapterParams extends Equatable {
  final String bookId;
  final int chapterNumber;
  final String title;
  final String? content;

  const CreateChapterParams({
    required this.bookId,
    required this.chapterNumber,
    required this.title,
    this.content,
  });

  @override
  List<Object?> get props => [bookId, chapterNumber, title, content];
}
