import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/injection/injection_container.dart';
import '../bloc/book_bloc.dart';
import '../bloc/book_event.dart';
import '../bloc/book_state.dart';
import '../widgets/book_card.dart';
import 'book_detail_page.dart';
import '../../../auth/domain/services/role_service.dart';
import '../../../auth/domain/entities/user.dart';

class BooksPage extends StatelessWidget {
  const BooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<BookBloc>()..add(const GetBooksEvent()),
      child: const BooksView(),
    );
  }
}

class BooksView extends StatefulWidget {
  const BooksView({super.key});

  @override
  State<BooksView> createState() => _BooksViewState();
}

class _BooksViewState extends State<BooksView> {
  late RoleService _roleService;
  bool _canCreateBooks = false;

  @override
  void initState() {
    super.initState();
    _roleService = sl<RoleService>();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final role = await _roleService.getCurrentUserRole();
      if (mounted) {
        setState(() {
          _canCreateBooks = role == UserRole.author || role == UserRole.admin;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _canCreateBooks = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BookBloc>().add(RefreshBooksEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<BookBloc, BookState>(
        builder: (context, state) {
          if (state is BookLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BookLoaded) {
            if (state.books.isEmpty) {
              return const Center(child: Text('No books found'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<BookBloc>().add(RefreshBooksEvent());
              },
              child: ListView.builder(
                itemCount: state.books.length,
                itemBuilder: (context, index) {
                  final book = state.books[index];
                  return BookCard(
                    title: book.title,
                    description: book.description ?? '',
                    authorName: book.authorName,
                    genres: book.genre != null ? [book.genre!] : [],
                    coverImageUrl: book.coverImageUrl ?? '',
                    views: 0, // Not available in new schema
                    likes: 0, // Not available in new schema
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetailPage(
                            bookId: book.id,
                            title: book.title,
                            authorName: book.authorName,
                            coverImageUrl: book.coverImageUrl ?? '',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          } else if (state is BookError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BookBloc>().add(const GetBooksEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Welcome to Alhuda Library!'));
        },
      ),
      floatingActionButton: _canCreateBooks
          ? FloatingActionButton(
              onPressed: () {
                // Navigate to create book page
                _showCreateBookDialog(context);
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showCreateBookDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final genresController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create New Book'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: genresController,
              decoration: const InputDecoration(
                labelText: 'Genres (comma separated)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final description = descriptionController.text.trim();
              final genresText = genresController.text.trim();

              if (title.isNotEmpty && description.isNotEmpty) {
                final genresList = genresText
                    .split(',')
                    .map((g) => g.trim())
                    .where((g) => g.isNotEmpty)
                    .toList();

                context.read<BookBloc>().add(
                  CreateBookEvent(
                    title: title,
                    description: description,
                    genres: genresList.isEmpty ? ['General'] : genresList,
                  ),
                );

                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
