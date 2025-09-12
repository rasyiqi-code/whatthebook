import 'package:flutter/material.dart';
import '../../domain/entities/reading_list.dart';
import '../bloc/social_bloc.dart';
import '../bloc/social_event.dart';
import 'edit_reading_list_page.dart';
import '../../../books/presentation/pages/book_detail_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReadingListDetailsPage extends StatefulWidget {
  final ReadingList readingList;

  const ReadingListDetailsPage({super.key, required this.readingList});

  @override
  State<ReadingListDetailsPage> createState() => _ReadingListDetailsPageState();
}

class _ReadingListDetailsPageState extends State<ReadingListDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.readingList.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              if (!mounted) return;
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditReadingListPage(readingList: widget.readingList),
                ),
              );
              if (result == true) {
                if (!mounted) return;
                if (context.mounted) {
                  Navigator.pop(context, true); // Pop and trigger refresh
                }
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete List', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // List Info Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.readingList.description != null) ...[
                    Text(
                      widget.readingList.description!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      Icon(
                        widget.readingList.isPublic ? Icons.public : Icons.lock,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.readingList.isPublic ? 'Public' : 'Private',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      Icon(Icons.book, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.readingList.books?.length ?? 0} books',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Books List
          Expanded(
            child: widget.readingList.books?.isEmpty ?? true
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No books yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add books to your reading list',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.readingList.books!.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final book = widget.readingList.books![index];
                      return Card(
                        child: ListTile(
                          leading: book.coverImageUrl != null
                              ? Image.network(
                                  book.coverImageUrl!,
                                  width: 40,
                                  height: 60,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 40,
                                  height: 60,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.book),
                                ),
                          title: Text(book.title),
                          subtitle: Text(book.authorName),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            color: Colors.red,
                            onPressed: () {
                              context.read<SocialBloc>().add(
                                RemoveBookFromReadingListRequested(
                                  listId: widget.readingList.id,
                                  bookId: book.id,
                                ),
                              );
                            },
                          ),
                          onTap: () {
                            // Navigate to book details
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BookDetailPage(bookId: book.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add book page - show a dialog to search and add books
          _showAddBookDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reading List'),
        content: const Text(
          'Are you sure you want to delete this reading list? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SocialBloc>().add(
                DeleteReadingListRequested(widget.readingList.id),
              );
              Navigator.pop(context); // Pop the details page
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddBookDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Book to Reading List'),
        content: const Text(
          'Book search and add functionality will be implemented when the book search feature is ready.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
