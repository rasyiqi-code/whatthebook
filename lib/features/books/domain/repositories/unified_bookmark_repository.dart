import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/unified_bookmark.dart';

abstract class UnifiedBookmarkRepository {
  Future<Either<Failure, List<UnifiedBookmark>>> getAllUnifiedBookmarks();
}
