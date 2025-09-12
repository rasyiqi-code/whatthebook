import 'package:equatable/equatable.dart';
import '../../domain/entities/unified_bookmark.dart';

abstract class UnifiedBookmarkEvent extends Equatable {
  const UnifiedBookmarkEvent();

  @override
  List<Object> get props => [];
}

class GetAllUnifiedBookmarksEvent extends UnifiedBookmarkEvent {}

class JumpToUnifiedBookmarkEvent extends UnifiedBookmarkEvent {
  final UnifiedBookmark bookmark;

  const JumpToUnifiedBookmarkEvent(this.bookmark);

  @override
  List<Object> get props => [bookmark];
}
