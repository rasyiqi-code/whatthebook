import 'package:equatable/equatable.dart';
import '../../domain/entities/pdf_bookmark.dart';

abstract class PdfBookmarkState extends Equatable {
  const PdfBookmarkState();
  @override
  List<Object?> get props => [];
}

class PdfBookmarkInitial extends PdfBookmarkState {}

class PdfBookmarkLoading extends PdfBookmarkState {}

class PdfBookmarksLoaded extends PdfBookmarkState {
  final List<PdfBookmark> bookmarks;
  const PdfBookmarksLoaded(this.bookmarks);
  @override
  List<Object?> get props => [bookmarks];
}

class PdfBookmarkError extends PdfBookmarkState {
  final String message;
  const PdfBookmarkError(this.message);
  @override
  List<Object?> get props => [message];
}

class PdfBookmarkAdded extends PdfBookmarkState {
  final PdfBookmark bookmark;
  const PdfBookmarkAdded(this.bookmark);
  @override
  List<Object?> get props => [bookmark];
}

class PdfBookmarkDeleted extends PdfBookmarkState {
  final String id;
  const PdfBookmarkDeleted(this.id);
  @override
  List<Object?> get props => [id];
}

class PdfBookmarkUpdated extends PdfBookmarkState {
  final PdfBookmark bookmark;
  const PdfBookmarkUpdated(this.bookmark);
  @override
  List<Object?> get props => [bookmark];
}
