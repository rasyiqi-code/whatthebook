import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/editor/block_editor.dart';
import '../../bloc/chapter_bloc.dart';
import '../../bloc/chapter_event.dart';
import '../../bloc/chapter_state.dart';
import '../../../domain/entities/chapter.dart';

class EnhancedChapterEditorPage extends StatefulWidget {
  final String bookId;
  final String? chapterId;

  const EnhancedChapterEditorPage({
    super.key,
    required this.bookId,
    this.chapterId,
  });

  @override
  State<EnhancedChapterEditorPage> createState() =>
      _EnhancedChapterEditorPageState();
}

class _EnhancedChapterEditorPageState extends State<EnhancedChapterEditorPage> {
  final TextEditingController _titleController = TextEditingController();
  List<Chapter> _chapters = [];
  int _currentChapterIndex = 0;
  Chapter? _currentChapter;
  bool _hasUnsavedChanges = false;
  String _lastSavedContent = '';

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _loadChapters() {
    context.read<ChapterBloc>().add(
      GetChaptersByBookIdRequested(widget.bookId),
    );
  }

  void _createNewChapter() {
    final chapterNumber = _chapters.length + 1;
    context.read<ChapterBloc>().add(
      CreateChapterRequested(
        bookId: widget.bookId,
        chapterNumber: chapterNumber,
        title: 'Chapter $chapterNumber',
        content: '',
      ),
    );
  }

  void _saveChapter() {
    if (_currentChapter == null) return;

    context.read<ChapterBloc>().add(
      UpdateChapterRequested(
        chapterId: _currentChapter!.id,
        title: _titleController.text.isNotEmpty ? _titleController.text : null,
      ),
    );
  }

  void _deleteCurrentChapter() {
    if (_currentChapter == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chapter'),
        content: const Text(
          'Are you sure you want to delete this chapter? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ChapterBloc>().add(
                DeleteChapterRequested(_currentChapter!.id),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _onContentChanged(String content, int wordCount) {
    setState(() {
      _hasUnsavedChanges = content != _lastSavedContent;
    });
  }

  void _onAutoSave(String content, int wordCount) {
    if (_currentChapter != null && mounted) {
      context.read<ChapterBloc>().add(
        AutoSaveChapterRequested(
          chapterId: _currentChapter!.id,
          content: content,
          wordCount: wordCount,
        ),
      );
      if (mounted) {
        setState(() {
          _lastSavedContent = content;
          _hasUnsavedChanges = false;
        });
      }
    }
  }

  void _switchChapter(int index) {
    if (index >= 0 && index < _chapters.length) {
      setState(() {
        _currentChapterIndex = index;
        _currentChapter = _chapters[index];
        _titleController.text = _currentChapter!.title;
        _lastSavedContent = _currentChapter!.content;
        _hasUnsavedChanges = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChapterBloc, ChapterState>(
      listener: (context, state) {
        if (state is ChaptersLoaded) {
          setState(() {
            _chapters = state.chapters;
            _chapters.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
            if (_chapters.isNotEmpty) {
              _currentChapterIndex = 0;
              _currentChapter = _chapters[0];
              _titleController.text = _currentChapter!.title;
              _lastSavedContent = _currentChapter!.content;
            }
          });
        } else if (state is ChapterCreated) {
          setState(() {
            _chapters.add(state.chapter);
            _currentChapterIndex = _chapters.length - 1;
            _currentChapter = state.chapter;
            _titleController.text = state.chapter.title;
            _lastSavedContent = state.chapter.content;
          });
        } else if (state is ChapterUpdated) {
          setState(() {
            final index = _chapters.indexWhere((c) => c.id == state.chapter.id);
            if (index != -1) {
              _chapters[index] = state.chapter;
              if (_currentChapter?.id == state.chapter.id) {
                _currentChapter = state.chapter;
              }
            }
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Chapter saved!')));
        } else if (state is ChapterAutoSaved) {
          setState(() {
            final index = _chapters.indexWhere((c) => c.id == state.chapter.id);
            if (index != -1) {
              _chapters[index] = state.chapter;
              if (_currentChapter?.id == state.chapter.id) {
                _currentChapter = state.chapter;
              }
            }
          });
        } else if (state is ChapterDeleted) {
          setState(() {
            _chapters.removeWhere((c) => c.id == state.chapterId);
            if (_chapters.isNotEmpty) {
              _currentChapterIndex = 0;
              _currentChapter = _chapters[0];
              _titleController.text = _currentChapter!.title;
              _lastSavedContent = _currentChapter!.content;
            } else {
              _currentChapter = null;
              _titleController.clear();
              _lastSavedContent = '';
            }
          });
        } else if (state is ChapterError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _chapters.isNotEmpty
                ? 'Chapter ${_currentChapterIndex + 1} of ${_chapters.length}'
                : 'Chapter Editor',
          ),
          actions: [
            if (_currentChapter != null) ...[
              // Chapter navigation
              if (_chapters.length > 1) ...[
                IconButton(
                  onPressed: _currentChapterIndex > 0
                      ? () => _switchChapter(_currentChapterIndex - 1)
                      : null,
                  icon: const Icon(Icons.navigate_before),
                ),
                IconButton(
                  onPressed: _currentChapterIndex < _chapters.length - 1
                      ? () => _switchChapter(_currentChapterIndex + 1)
                      : null,
                  icon: const Icon(Icons.navigate_next),
                ),
              ],

              // Save button
              IconButton(
                onPressed: _hasUnsavedChanges ? _saveChapter : null,
                icon: Icon(
                  Icons.save,
                  color: _hasUnsavedChanges ? null : Colors.grey,
                ),
              ),

              // More options
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'new':
                      _createNewChapter();
                      break;
                    case 'delete':
                      _deleteCurrentChapter();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'new',
                    child: ListTile(
                      leading: Icon(Icons.add),
                      title: Text('New Chapter'),
                    ),
                  ),
                  if (_chapters.length > 1)
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete Chapter'),
                      ),
                    ),
                ],
              ),
            ] else ...[
              IconButton(
                onPressed: _createNewChapter,
                icon: const Icon(Icons.add),
              ),
            ],
          ],
        ),
        body: BlocBuilder<ChapterBloc, ChapterState>(
          builder: (context, state) {
            if (state is ChapterLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_currentChapter == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.book, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No chapters yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _createNewChapter,
                      icon: const Icon(Icons.add),
                      label: const Text('Create First Chapter'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Chapter title
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _titleController,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Chapter Title',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _hasUnsavedChanges = true;
                      });
                    },
                  ),
                ),

                // Rich text editor
                Expanded(
                  child: BlockEditor(
                    key: ValueKey(_currentChapter!.id),
                    initialContent: _currentChapter!.content,
                    onContentChanged: _onContentChanged,
                    onAutoSave: _onAutoSave,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
