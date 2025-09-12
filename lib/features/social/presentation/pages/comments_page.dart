import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/comment_widget.dart';
import '../bloc/social_event.dart';
import '../bloc/social_state.dart';
import '../bloc/social_bloc.dart';

class CommentsPage extends StatefulWidget {
  final String bookId;
  final String? chapterId;
  final String bookTitle;

  const CommentsPage({
    super.key,
    required this.bookId,
    this.chapterId,
    required this.bookTitle,
  });

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  String? _replyingToCommentId;
  String? _editingCommentId;

  @override
  void initState() {
    super.initState();
    _loadComments();
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

  void _addComment(String content) {
    context.read<SocialBloc>().add(
      AddCommentRequested(
        bookId: widget.bookId,
        chapterId: widget.chapterId,
        content: content,
        parentCommentId: _replyingToCommentId,
      ),
    );
    setState(() {
      _replyingToCommentId = null;
    });
  }

  void _editComment(String commentId, String content) {
    setState(() {
      _editingCommentId = commentId;
      _replyingToCommentId = null;
    });
    // The CommentInputWidget will handle the actual editing
  }

  void _updateComment(String content) {
    if (_editingCommentId != null) {
      context.read<SocialBloc>().add(UpdateCommentRequested(
        commentId: _editingCommentId!,
        content: content,
      ));
      setState(() {
        _editingCommentId = null;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Comments'),
            Text(
              widget.bookTitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: _loadComments, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: BlocListener<SocialBloc, SocialState>(
        listener: (context, state) {
          if (state is CommentAdded ||
              state is CommentUpdated ||
              state is CommentDeleted) {
            _loadComments(); // Refresh comments
          }
          if (state is SocialError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Column(
          children: [
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
                              'No comments yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to share your thoughts!',
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
                            setState(() {
                              _replyingToCommentId = commentId;
                              _editingCommentId = null;
                            });
                          },
                          onEdit: (commentId, content) {
                            _editComment(commentId, content);
                          },
                          onDelete: _deleteComment,
                        );
                      },
                    );
                  }

                  return const Center(child: Text('Failed to load comments'));
                },
              ),
            ),

            // Comment Input
            CommentInputWidget(
              onSubmit: _editingCommentId != null
                  ? _updateComment
                  : _addComment,
              parentCommentId: _replyingToCommentId,
              isEditing: _editingCommentId != null,
            ),

            // Reply/Edit indicator
            if (_replyingToCommentId != null || _editingCommentId != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    Icon(
                      _editingCommentId != null ? Icons.edit : Icons.reply,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _editingCommentId != null
                            ? 'Editing comment'
                            : 'Replying to comment',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _replyingToCommentId = null;
                          _editingCommentId = null;
                        });
                      },
                      icon: const Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
