import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

class CreateBook implements UseCase<Book, CreateBookParams> {
  final BookRepository repository;

  CreateBook(this.repository);

  @override
  Future<Either<Failure, Book>> call(CreateBookParams params) async {
    return await repository.createBook(
      title: params.title,
      description: params.description,
      genres: params.genres,
      coverImageUrl: params.coverImageUrl,
    );
  }
}

class CreateBookParams extends Equatable {
  final String title;
  final String description;
  final List<String> genres;
  final String? coverImageUrl;

  const CreateBookParams({
    required this.title,
    required this.description,
    required this.genres,
    this.coverImageUrl,
  });

  @override
  List<Object?> get props => [title, description, genres, coverImageUrl];
}
