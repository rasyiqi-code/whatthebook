import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/unified_bookmark.dart';
import '../repositories/unified_bookmark_repository.dart';

class GetAllUnifiedBookmarks
    implements UseCase<List<UnifiedBookmark>, NoParams> {
  final UnifiedBookmarkRepository repository;

  GetAllUnifiedBookmarks(this.repository);

  @override
  Future<Either<Failure, List<UnifiedBookmark>>> call(NoParams params) async {
    return await repository.getAllUnifiedBookmarks();
  }
}
