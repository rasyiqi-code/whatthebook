import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/book_view.dart';
import '../repositories/social_repository.dart';

class TrackBookView implements UseCase<BookView, TrackBookViewParams> {
  final SocialRepository repository;

  TrackBookView(this.repository);

  @override
  Future<Either<Failure, BookView>> call(TrackBookViewParams params) async {
    return await repository.trackBookView(params.bookId);
  }
}

class TrackBookViewParams extends Equatable {
  final String bookId;

  const TrackBookViewParams({required this.bookId});

  @override
  List<Object> get props => [bookId];
}
