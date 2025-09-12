import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reading_list.dart';
import '../repositories/social_repository.dart';

class UpdateReadingList
    implements UseCase<ReadingList, UpdateReadingListParams> {
  final SocialRepository repository;

  UpdateReadingList(this.repository);

  @override
  Future<Either<Failure, ReadingList>> call(
    UpdateReadingListParams params,
  ) async {
    return await repository.updateReadingList(
      listId: params.listId,
      name: params.name,
      description: params.description,
      isPublic: params.isPublic,
    );
  }
}

class UpdateReadingListParams {
  final String listId;
  final String? name;
  final String? description;
  final bool? isPublic;

  UpdateReadingListParams({
    required this.listId,
    this.name,
    this.description,
    this.isPublic,
  });
}
