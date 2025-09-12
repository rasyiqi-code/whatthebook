import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../bloc/social_bloc.dart';
import '../bloc/social_event.dart';
import '../bloc/social_state.dart';
import 'comment_widget.dart';

class BookCommentSection extends StatefulWidget {
  final String bookId;
  final String? chapterId;
  final String? title;
  final String? parentCommentId;
  final ValueChanged<String>? onSubmitComment;

  const BookCommentSection({
    super.key,
    required this.bookId,
    this.chapterId,
    this.title,
    this.parentCommentId,
    this.onSubmitComment,
  });

  @override
  State<BookCommentSection> createState() => _BookCommentSectionState();
}

class _BookCommentSectionState extends State<BookCommentSection> {
  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadComments() {
    if (widget.chapterId != null) {
      context.read<SocialBloc>().add(
        GetChapterCommentsRequested(widget.chapterId!),
      );
    } else {
      context.read<SocialBloc>().add(GetBookCommentsRequested(widget.bookId));
    }
  }

  void _deleteComment(String commentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SocialBloc>().add(DeleteCommentRequested(commentId));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editComment(String commentId, String content) {
    TextEditingController editController = TextEditingController(text: content);
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit, color: Colors.green, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Edit Komentar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: editController,
                decoration: const InputDecoration(
                  hintText: 'Edit komentar Anda...',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFF8F8F8),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      final newContent = editController.text.trim();
                      if (newContent.isNotEmpty) {
                        context.read<SocialBloc>().add(
                          UpdateCommentRequested(
                            commentId: commentId,
                            content: newContent,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text('Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SocialBloc, SocialState>(
      listener: (context, state) {
        if (state is CommentAdded ||
            state is CommentUpdated ||
            state is CommentDeleted) {
          _loadComments();
        }
        if (state is SocialError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Komentar untuk ${widget.title}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            // Comments List
            Expanded(
              child: BlocBuilder<SocialBloc, SocialState>(
                builder: (context, state) {
                  if (state is SocialLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is BookCommentsLoaded ||
                      state is ChapterCommentsLoaded) {
                    final comments = state is BookCommentsLoaded
                        ? state.comments
                        : (state as ChapterCommentsLoaded).comments;
                    if (comments.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.comment_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada komentar',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Jadilah yang pertama berkomentar!',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: comments.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1, color: Colors.grey[300]),
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final currentUser =
                            Supabase.instance.client.auth.currentUser;
                        final isCurrentUser = currentUser?.id == comment.userId;
                        return CommentWidget(
                          comment: comment,
                          isCurrentUser: isCurrentUser,
                          onReply: (commentId) {
                            if (widget.onSubmitComment != null) {
                              widget.onSubmitComment!(commentId);
                            }
                          },
                          onEdit: (commentId, content) {
                            if (isCurrentUser) {
                              _editComment(commentId, content);
                            }
                          },
                          onDelete: (commentId) {
                            _deleteComment(commentId);
                          },
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
