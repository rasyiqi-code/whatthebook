import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/repositories/chapter_repository.dart';
import '../datasources/chapter_remote_data_source.dart';

class ChapterRepositoryImpl implements ChapterRepository {
  final ChapterRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ChapterRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Chapter>>> getChaptersByBookId(
    String bookId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final chapters = await remoteDataSource.getChaptersByBookId(bookId);
        return Right(chapters.map((chapter) => chapter.toEntity()).toList());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Chapter>> getChapterById(String chapterId) async {
    if (await networkInfo.isConnected) {
      try {
        final chapter = await remoteDataSource.getChapterById(chapterId);
        return Right(chapter.toEntity());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Chapter>> createChapter({
    required String bookId,
    required int chapterNumber,
    required String title,
    String? content,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final chapter = await remoteDataSource.createChapter(
          bookId: bookId,
          chapterNumber: chapterNumber,
          title: title,
          content: content,
        );
        return Right(chapter.toEntity());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Chapter>> updateChapter({
    required String chapterId,
    String? title,
    String? content,
    int? wordCount,
    String? status,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final chapter = await remoteDataSource.updateChapter(
          chapterId: chapterId,
          title: title,
          content: content,
          wordCount: wordCount,
          status: status,
        );
        return Right(chapter.toEntity());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChapter(String chapterId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteChapter(chapterId);
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Chapter>> reorderChapter({
    required String chapterId,
    required int newChapterNumber,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final chapter = await remoteDataSource.reorderChapter(
          chapterId: chapterId,
          newChapterNumber: newChapterNumber,
        );
        return Right(chapter.toEntity());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
