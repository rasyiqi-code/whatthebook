import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

class UpdateBook implements UseCase<Book, UpdateBookParams> {
  final BookRepository repository;

  UpdateBook(this.repository);

  @override
  Future<Either<Failure, Book>> call(UpdateBookParams params) async {
    return await repository.updateBook(
      bookId: params.bookId,
      title: params.title,
      description: params.description,
      genres: params.genres,
      coverImageUrl: params.coverImageUrl,
      isCompleted: params.isCompleted,
      isPublished: params.isPublished,
    );
  }
}

class UpdateBookParams extends Equatable {
  final String bookId;
  final String? title;
  final String? description;
  final List<String>? genres;
  final String? coverImageUrl;
  final bool? isCompleted;
  final bool? isPublished;

  const UpdateBookParams({
    required this.bookId,
    this.title,
    this.description,
    this.genres,
    this.coverImageUrl,
    this.isCompleted,
    this.isPublished,
  });

  @override
  List<Object?> get props => [
        bookId,
        title,
        description,
        genres,
        coverImageUrl,
        isCompleted,
        isPublished,
      ];
}
