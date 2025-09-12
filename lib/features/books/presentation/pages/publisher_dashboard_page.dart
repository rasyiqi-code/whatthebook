import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/book.dart';
import '../widgets/book_status_chip.dart';
import '../widgets/improved_book_actions.dart';
import '../../../../core/injection/injection_container.dart';
import '../../../auth/domain/services/role_service.dart';
import '../../../auth/domain/entities/user.dart';

class PublisherDashboardPage extends StatefulWidget {
  const PublisherDashboardPage({super.key});

  @override
  State<PublisherDashboardPage> createState() => _PublisherDashboardPageState();
}

class _PublisherDashboardPageState extends State<PublisherDashboardPage> {
  final _client = Supabase.instance.client;
  final _roleService = sl<RoleService>();
  List<Map<String, dynamic>> _pendingBooks = [];
  List<Map<String, dynamic>> _publishedBooks = [];
  bool _isLoading = true;
  bool _isPendingExpanded = true;
  bool _isPublishedExpanded = false;
  bool _hasAccess = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    try {
      final userRole = await _roleService.getCurrentUserRole();
      if (userRole == UserRole.publisher) {
        setState(() {
          _hasAccess = true;
        });
        _loadBooks();
      } else {
        setState(() {
          _isLoading = false;
          _hasAccess = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasAccess = false;
      });
    }
  }

  Future<void> _loadBooks() async {
    try {
      // Load books pending review (completed status)
      final pendingResponse = await _client
          .from('books')
          .select('*, users!books_author_id_fkey(email, full_name)')
          .eq('status', 'completed')
          .order('updated_at', ascending: false);

      // Load published books
      final publishedResponse = await _client
          .from('books')
          .select('*, users!books_author_id_fkey(email, full_name)')
          .eq('status', 'published')
          .order('updated_at', ascending: false);

      setState(() {
        _pendingBooks = List<Map<String, dynamic>>.from(pendingResponse);
        _publishedBooks = List<Map<String, dynamic>>.from(publishedResponse);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading books: $e')));
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _publishBook(String bookId) async {
    try {
      await _client
          .from('books')
          .update({
            'status': 'published',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookId);

      await _loadBooks(); // Reload the lists
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book published successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error publishing book: $e')));
      }
    }
  }

  Future<void> _rejectBook(String bookId) async {
    try {
      await _client
          .from('books')
          .update({
            'status': 'draft',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookId);

      await _loadBooks(); // Reload the lists
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book sent back to draft')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating book status: $e')),
        );
      }
    }
  }

  Future<void> _unpublishBook(String bookId) async {
    try {
      await _client
          .from('books')
          .update({
            'status': 'completed',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookId);

      await _loadBooks(); // Reload the lists
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Book unpublished')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error unpublishing book: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_hasAccess) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              const Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'You need publisher role to access this page',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Publisher Dashboard')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Compact header with stats
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Pending Review',
                      _pendingBooks.length.toString(),
                      Icons.pending_actions,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Published',
                      _publishedBooks.length.toString(),
                      Icons.published_with_changes,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            // Accordion Sections
            const SizedBox(height: 8),

            // Pending Books Accordion
            _buildAccordionSection(
              title: 'Pending Review',
              icon: Icons.pending_actions,
              count: _pendingBooks.length,
              color: Colors.orange,
              isExpanded: _isPendingExpanded,
              onToggle: () {
                setState(() {
                  _isPendingExpanded = !_isPendingExpanded;
                });
              },
              content: _buildPendingBooksContent(),
            ),

            const SizedBox(height: 8),

            // Published Books Accordion
            _buildAccordionSection(
              title: 'Published Books',
              icon: Icons.published_with_changes,
              count: _publishedBooks.length,
              color: Colors.green,
              isExpanded: _isPublishedExpanded,
              onToggle: () {
                setState(() {
                  _isPublishedExpanded = !_isPublishedExpanded;
                });
              },
              content: _buildPublishedBooksContent(),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAccordionSection({
    required String title,
    required IconData icon,
    required int count,
    required Color color,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$count ${count == 1 ? 'book' : 'books'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: isExpanded ? null : 0,
            child: isExpanded
                ? Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    child: content,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingBooksContent() {
    if (_pendingBooks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'No books pending review',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: _pendingBooks.map((book) {
          final author = book['users'];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              title: Text(
                book['title'],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'By ${author['full_name'] ?? author['email']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    BookStatusChip(status: parseBookStatus(book['status'])),
                  ],
                ),
              ),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (book['description'] != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              book['description'],
                              style: const TextStyle(fontSize: 12),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        if (book['genre'] != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              book['genre'],
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                          const Spacer(),
                        ] else
                          const Spacer(),
                        ImprovedBookActions(
                          book: Book(
                            id: book['id'],
                            title: book['title'],
                            description: book['description'],
                            authorId: book['author_id'],
                            authorName: author['full_name'] ?? author['email'],
                            status: parseBookStatus(book['status']),
                            genre: book['genre'],
                            totalChapters: book['total_chapters'] ?? 0,
                            totalWords: book['total_words'] ?? 0,
                            createdAt: DateTime.parse(book['created_at']),
                            updatedAt: DateTime.parse(book['updated_at']),
                          ),
                          onStatusChange: (status) {
                            if (status == BookStatus.published) {
                              _publishBook(book['id']);
                            } else if (status == BookStatus.draft) {
                              _rejectBook(book['id']);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPublishedBooksContent() {
    if (_publishedBooks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.library_books, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'No published books',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: _publishedBooks.map((book) {
          final author = book['users'];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'By ${author['full_name'] ?? author['email']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          BookStatusChip(
                            status: parseBookStatus(book['status']),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ImprovedBookActions(
                  book: Book(
                    id: book['id'],
                    title: book['title'],
                    description: book['description'],
                    authorId: book['author_id'],
                    authorName: author['full_name'] ?? author['email'],
                    status: parseBookStatus(book['status']),
                    genre: book['genre'],
                    totalChapters: book['total_chapters'] ?? 0,
                    totalWords: book['total_words'] ?? 0,
                    createdAt: DateTime.parse(book['created_at']),
                    updatedAt: DateTime.parse(book['updated_at']),
                  ),
                  onStatusChange: (status) {
                    if (status == BookStatus.completed) {
                      _unpublishBook(book['id']);
                    }
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
