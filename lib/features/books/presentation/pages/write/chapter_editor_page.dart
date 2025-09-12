import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/injection/injection_container.dart' as di;
import '../../bloc/chapter_bloc.dart';
import 'enhanced_chapter_editor_page.dart';

class ChapterEditorPage extends StatelessWidget {
  final String bookId;
  final String? chapterId;

  const ChapterEditorPage({super.key, required this.bookId, this.chapterId});

  @override
  Widget build(BuildContext context) {
    // Provide ChapterBloc to the enhanced chapter editor
    return BlocProvider(
      create: (context) => di.sl<ChapterBloc>(),
      child: EnhancedChapterEditorPage(bookId: bookId, chapterId: chapterId),
    );
  }
}
