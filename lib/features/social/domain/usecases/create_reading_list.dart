import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reading_list.dart';
import '../repositories/social_repository.dart';

class CreateReadingList
    implements UseCase<ReadingList, CreateReadingListParams> {
  final SocialRepository repository;

  CreateReadingList(this.repository);

  @override
  Future<Either<Failure, ReadingList>> call(
    CreateReadingListParams params,
  ) async {
    return await repository.createReadingList(
      name: params.name,
      description: params.description,
      isPublic: params.isPublic,
    );
  }
}

class CreateReadingListParams {
  final String name;
  final String? description;
  final bool isPublic;

  CreateReadingListParams({
    required this.name,
    this.description,
    this.isPublic = true,
  });
}
