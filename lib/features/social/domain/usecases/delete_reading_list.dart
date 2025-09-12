import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/social_repository.dart';

class DeleteReadingList implements UseCase<void, DeleteReadingListParams> {
  final SocialRepository repository;

  DeleteReadingList(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteReadingListParams params) async {
    return await repository.deleteReadingList(params.listId);
  }
}

class DeleteReadingListParams {
  final String listId;

  DeleteReadingListParams({required this.listId});
}
