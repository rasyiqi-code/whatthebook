import 'package:flutter/material.dart';
import '../../domain/entities/book.dart';
import '../../../auth/domain/services/role_service.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../../core/injection/injection_container.dart';

class ImprovedBookActions extends StatelessWidget {
  final Book book;
  final VoidCallback? onEdit;
  final Function(BookStatus)? onStatusChange;
  final VoidCallback? onDelete;
  late final RoleService _roleService;

  ImprovedBookActions({
    super.key,
    required this.book,
    this.onEdit,
    this.onStatusChange,
    this.onDelete,
  }) {
    _roleService = sl<RoleService>();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserRole?>(
      future: _roleService.getCurrentUserRole(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final userRole = snapshot.data!;
        final isAuthor = _roleService.isBookAuthor(book.authorId ?? '');

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit action - Available to author and admin
            if ((isAuthor || userRole == UserRole.admin) && onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
                tooltip: 'Edit Book',
              ),

            // Status change actions
            if (onStatusChange != null)
              FutureBuilder<List<BookStatus>>(
                future: _roleService.getAvailableStatusChanges(
                  book.status,
                  book.authorId ?? '',
                ),
                builder: (context, statusSnapshot) {
                  if (!statusSnapshot.hasData || statusSnapshot.data!.isEmpty) {
                    return const SizedBox();
                  }

                  final availableStatuses = statusSnapshot.data!;

                  if (userRole == UserRole.publisher &&
                      book.status == BookStatus.completed) {
                    // Special UI for publishers reviewing completed books
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          onPressed: () =>
                              onStatusChange?.call(BookStatus.draft),
                          icon: const Icon(Icons.close, color: Colors.red),
                          label: const Text(
                            'Send Back to Draft',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () =>
                              onStatusChange?.call(BookStatus.published),
                          icon: const Icon(Icons.publish),
                          label: const Text('Publish'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    );
                  }

                  if (userRole == UserRole.publisher &&
                      book.status == BookStatus.published) {
                    // Unpublish action for publishers
                    return IconButton(
                      icon: const Icon(Icons.unpublished),
                      color: Colors.orange,
                      tooltip: 'Unpublish',
                      onPressed: () =>
                          onStatusChange?.call(BookStatus.completed),
                    );
                  }

                  // Default status change menu
                  return PopupMenuButton<BookStatus>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: onStatusChange,
                    itemBuilder: (context) {
                      return availableStatuses.map((status) {
                        String label;
                        switch (status) {
                          case BookStatus.draft:
                            label = 'Set as Draft';
                            break;
                          case BookStatus.completed:
                            label = book.status == BookStatus.published
                                ? 'Unpublish'
                                : 'Mark as Completed';
                            break;
                          case BookStatus.published:
                            label = 'Publish';
                            break;
                        }

                        return PopupMenuItem(value: status, child: Text(label));
                      }).toList();
                    },
                  );
                },
              ),

            // Delete action - Available to author and admin
            if ((isAuthor || userRole == UserRole.admin) && onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Book'),
                      content: const Text(
                        'Are you sure you want to delete this book? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onDelete?.call();
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                tooltip: 'Delete Book',
              ),
          ],
        );
      },
    );
  }
}
