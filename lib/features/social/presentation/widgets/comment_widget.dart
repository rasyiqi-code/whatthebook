import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../domain/entities/comment.dart';

class CommentWidget extends StatelessWidget {
  final Comment comment;
  final Function(String commentId)? onReply;
  final void Function(String commentId, String content)? onEdit;
  final Function(String commentId)? onDelete;
  final bool isCurrentUser;

  const CommentWidget({
    super.key,
    required this.comment,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and timestamp
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.1),
                backgroundImage: comment.user?.avatarUrl != null
                    ? NetworkImage(comment.user!.avatarUrl!)
                    : null,
                child: comment.user?.avatarUrl == null
                    ? Icon(
                        Icons.person,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.user?.fullName ?? 'Anonymous',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      timeago.format(comment.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (isCurrentUser) ...[
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  tooltip: 'Edit',
                  onPressed: () => onEdit?.call(comment.id, comment.content),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  tooltip: 'Delete',
                  onPressed: () => onDelete?.call(comment.id),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Comment content
          Text(
            comment.content,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              TextButton.icon(
                onPressed: () => onReply?.call(comment.id),
                icon: const Icon(Icons.reply, size: 16),
                label: const Text('Reply'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              if (comment.replies != null && comment.replies!.isNotEmpty) ...[
                const SizedBox(width: 16),
                Text(
                  '${comment.replies!.length} ${comment.replies!.length == 1 ? 'reply' : 'replies'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ],
          ),

          // Replies
          if (comment.replies != null && comment.replies!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.only(left: 32),
              padding: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.grey[300]!, width: 2),
                ),
              ),
              child: Column(
                children: comment.replies!
                    .map(
                      (reply) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: CommentWidget(
                          comment: reply,
                          onReply: onReply,
                          onEdit: onEdit,
                          onDelete: onDelete,
                          isCurrentUser: isCurrentUser,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CommentInputWidget extends StatefulWidget {
  final Function(String content) onSubmit;
  final String? parentCommentId;
  final String? initialText;
  final bool isEditing;

  const CommentInputWidget({
    super.key,
    required this.onSubmit,
    this.parentCommentId,
    this.initialText,
    this.isEditing = false,
  });

  @override
  State<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends State<CommentInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null) {
      _controller.text = widget.initialText!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final content = _controller.text.trim();
    if (content.isNotEmpty) {
      widget.onSubmit(content);
      if (!widget.isEditing) {
        _controller.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: widget.parentCommentId != null
                    ? 'Write a reply...'
                    : 'Write a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _submit,
            icon: Icon(
              widget.isEditing ? Icons.check : Icons.send,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
