import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reading_list.dart';
import '../repositories/social_repository.dart';

class GetUserReadingLists
    implements UseCase<List<ReadingList>, GetUserReadingListsParams> {
  final SocialRepository repository;

  GetUserReadingLists(this.repository);

  @override
  Future<Either<Failure, List<ReadingList>>> call(
    GetUserReadingListsParams params,
  ) async {
    return await repository.getUserReadingLists(params.userId);
  }
}

class GetUserReadingListsParams {
  final String userId;

  GetUserReadingListsParams({required this.userId});
}
