import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/unified_bookmark.dart';
import '../../domain/repositories/unified_bookmark_repository.dart';
import '../datasources/unified_bookmark_remote_data_source.dart';

class UnifiedBookmarkRepositoryImpl implements UnifiedBookmarkRepository {
  final UnifiedBookmarkRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  UnifiedBookmarkRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<UnifiedBookmark>>>
  getAllUnifiedBookmarks() async {
    if (await networkInfo.isConnected) {
      try {
        final bookmarks = await remoteDataSource.getAllUnifiedBookmarks();
        return Right(bookmarks);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(ServerFailure('No internet connection'));
    }
  }
}
