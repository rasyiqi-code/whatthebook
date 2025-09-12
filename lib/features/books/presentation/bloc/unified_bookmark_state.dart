import 'package:equatable/equatable.dart';
import '../../domain/entities/unified_bookmark.dart';

abstract class UnifiedBookmarkState extends Equatable {
  const UnifiedBookmarkState();

  @override
  List<Object?> get props => [];
}

class UnifiedBookmarkInitial extends UnifiedBookmarkState {
  const UnifiedBookmarkInitial();
}

class UnifiedBookmarkLoading extends UnifiedBookmarkState {
  const UnifiedBookmarkLoading();
}

class UnifiedBookmarkError extends UnifiedBookmarkState {
  final String message;

  const UnifiedBookmarkError(this.message);

  @override
  List<Object?> get props => [message];
}

class UnifiedBookmarksLoaded extends UnifiedBookmarkState {
  final List<UnifiedBookmark> bookmarks;

  const UnifiedBookmarksLoaded(this.bookmarks);

  @override
  List<Object?> get props => [bookmarks];
}

class UnifiedBookmarkJumped extends UnifiedBookmarkState {
  final UnifiedBookmark bookmark;

  const UnifiedBookmarkJumped(this.bookmark);

  @override
  List<Object?> get props => [bookmark];
}
