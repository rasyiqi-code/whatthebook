import 'package:equatable/equatable.dart';

abstract class ChapterEvent extends Equatable {
  const ChapterEvent();

  @override
  List<Object?> get props => [];
}

class GetChaptersByBookIdRequested extends ChapterEvent {
  final String bookId;

  const GetChaptersByBookIdRequested(this.bookId);

  @override
  List<Object> get props => [bookId];
}

class GetChapterByIdRequested extends ChapterEvent {
  final String chapterId;

  const GetChapterByIdRequested(this.chapterId);

  @override
  List<Object> get props => [chapterId];
}

class CreateChapterRequested extends ChapterEvent {
  final String bookId;
  final int chapterNumber;
  final String title;
  final String? content;

  const CreateChapterRequested({
    required this.bookId,
    required this.chapterNumber,
    required this.title,
    this.content,
  });

  @override
  List<Object?> get props => [bookId, chapterNumber, title, content];
}

class UpdateChapterRequested extends ChapterEvent {
  final String chapterId;
  final String? title;
  final String? content;
  final int? wordCount;
  final String? status;

  const UpdateChapterRequested({
    required this.chapterId,
    this.title,
    this.content,
    this.wordCount,
    this.status,
  });

  @override
  List<Object?> get props => [chapterId, title, content, wordCount, status];
}

class DeleteChapterRequested extends ChapterEvent {
  final String chapterId;

  const DeleteChapterRequested(this.chapterId);

  @override
  List<Object> get props => [chapterId];
}

class AutoSaveChapterRequested extends ChapterEvent {
  final String chapterId;
  final String content;
  final int wordCount;

  const AutoSaveChapterRequested({
    required this.chapterId,
    required this.content,
    required this.wordCount,
  });

  @override
  List<Object> get props => [chapterId, content, wordCount];
}

class ChapterAutoSaveCompleted extends ChapterEvent {
  final dynamic chapter;

  const ChapterAutoSaveCompleted(this.chapter);

  @override
  List<Object> get props => [chapter];
}

class ChapterErrorOccurred extends ChapterEvent {
  final String message;

  const ChapterErrorOccurred(this.message);

  @override
  List<Object> get props => [message];
}
