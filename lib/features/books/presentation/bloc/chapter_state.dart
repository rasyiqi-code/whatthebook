import 'package:equatable/equatable.dart';
import '../../domain/entities/chapter.dart';

abstract class ChapterState extends Equatable {
  const ChapterState();

  @override
  List<Object?> get props => [];
}

class ChapterInitial extends ChapterState {}

class ChapterLoading extends ChapterState {}

class ChaptersLoaded extends ChapterState {
  final List<Chapter> chapters;

  const ChaptersLoaded(this.chapters);

  @override
  List<Object> get props => [chapters];
}

class ChapterLoaded extends ChapterState {
  final Chapter chapter;

  const ChapterLoaded(this.chapter);

  @override
  List<Object> get props => [chapter];
}

class ChapterCreated extends ChapterState {
  final Chapter chapter;

  const ChapterCreated(this.chapter);

  @override
  List<Object> get props => [chapter];
}

class ChapterUpdated extends ChapterState {
  final Chapter chapter;

  const ChapterUpdated(this.chapter);

  @override
  List<Object> get props => [chapter];
}

class ChapterDeleted extends ChapterState {
  final String chapterId;

  const ChapterDeleted(this.chapterId);

  @override
  List<Object> get props => [chapterId];
}

class ChapterAutoSaved extends ChapterState {
  final Chapter chapter;

  const ChapterAutoSaved(this.chapter);

  @override
  List<Object> get props => [chapter];
}

class ChapterError extends ChapterState {
  final String message;

  const ChapterError(this.message);

  @override
  List<Object> get props => [message];
}

class ChapterSaving extends ChapterState {
  final Chapter chapter;

  const ChapterSaving(this.chapter);

  @override
  List<Object> get props => [chapter];
}
