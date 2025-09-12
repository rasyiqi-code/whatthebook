import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chapter.dart';

abstract class ChapterRepository {
  Future<Either<Failure, List<Chapter>>> getChaptersByBookId(String bookId);
  
  Future<Either<Failure, Chapter>> getChapterById(String chapterId);
  
  Future<Either<Failure, Chapter>> createChapter({
    required String bookId,
    required int chapterNumber,
    required String title,
    String? content,
  });
  
  Future<Either<Failure, Chapter>> updateChapter({
    required String chapterId,
    String? title,
    String? content,
    int? wordCount,
    String? status,
  });
  
  Future<Either<Failure, void>> deleteChapter(String chapterId);
  
  Future<Either<Failure, Chapter>> reorderChapter({
    required String chapterId,
    required int newChapterNumber,
  });
}
