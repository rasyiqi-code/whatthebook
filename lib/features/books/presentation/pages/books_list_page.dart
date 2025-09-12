import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/book_card.dart';
import 'book_detail_page.dart';

class BooksListPage extends StatefulWidget {
  final String title;
  final String? filterType;

  const BooksListPage({super.key, required this.title, this.filterType});

  @override
  State<BooksListPage> createState() => _BooksListPageState();
}

class _BooksListPageState extends State<BooksListPage> {
  List<Map<String, dynamic>> books = [];
  List<Map<String, dynamic>> filteredBooks = [];
  bool isLoading = true;
  String currentFilter = 'all'; // all, newest, oldest, most_viewed, most_liked

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  void _applyFilter(String filter) {
    setState(() {
      currentFilter = filter;
      switch (filter) {
        case 'newest':
          filteredBooks.sort(
            (a, b) => (b['created_at'] ?? '').compareTo(a['created_at'] ?? ''),
          );
          break;
        case 'oldest':
          filteredBooks.sort(
            (a, b) => (a['created_at'] ?? '').compareTo(b['created_at'] ?? ''),
          );
          break;
        case 'most_viewed':
          filteredBooks.sort(
            (a, b) => (b['views'] ?? 0).compareTo(a['views'] ?? 0),
          );
          break;
        case 'most_liked':
          filteredBooks.sort(
            (a, b) => (b['likes'] ?? 0).compareTo(a['likes'] ?? 0),
          );
          break;
        default: // 'all'
          filteredBooks = List.from(books);
          break;
      }
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Books'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Books'),
              selected: currentFilter == 'all',
              onTap: () {
                Navigator.pop(context);
                _applyFilter('all');
              },
            ),
            ListTile(
              title: const Text('Newest First'),
              selected: currentFilter == 'newest',
              onTap: () {
                Navigator.pop(context);
                _applyFilter('newest');
              },
            ),
            ListTile(
              title: const Text('Oldest First'),
              selected: currentFilter == 'oldest',
              onTap: () {
                Navigator.pop(context);
                _applyFilter('oldest');
              },
            ),
            ListTile(
              title: const Text('Most Viewed'),
              selected: currentFilter == 'most_viewed',
              onTap: () {
                Navigator.pop(context);
                _applyFilter('most_viewed');
              },
            ),
            ListTile(
              title: const Text('Most Liked'),
              selected: currentFilter == 'most_liked',
              onTap: () {
                Navigator.pop(context);
                _applyFilter('most_liked');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadBooks() async {
    try {
      late final List<Map<String, dynamic>> response;

      // Apply different filters based on the type
      switch (widget.filterType) {
        case 'recommended':
          // For recommended, order by total_words (more content = better recommendation)
          response = await Supabase.instance.client
              .from('books')
              .select('*, users!books_author_id_fkey(*)')
              .eq('status', 'published')
              .order('total_words', ascending: false)
              .limit(20);
          break;
        case 'trending':
          // For trending, order by recent creation date (newest first)
          response = await Supabase.instance.client
              .from('books')
              .select('*, users!books_author_id_fkey(*)')
              .eq('status', 'published')
              .order('created_at', ascending: false)
              .limit(20);
          break;
        case 'latest':
          // For latest, order by creation date
          response = await Supabase.instance.client
              .from('books')
              .select('*, users!books_author_id_fkey(*)')
              .eq('status', 'published')
              .order('created_at', ascending: false)
              .limit(20);
          break;
        default:
          // Default: show all books
          response = await Supabase.instance.client
              .from('books')
              .select('*, users!books_author_id_fkey(*)')
              .eq('status', 'published')
              .order('created_at', ascending: false);
          break;
      }

      setState(() {
        books = List<Map<String, dynamic>>.from(response);
        filteredBooks = List.from(books); // Initialize filtered books
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading books: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              _loadBooks();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : books.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No books found',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for new books',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadBooks,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${filteredBooks.length} book${filteredBooks.length == 1 ? '' : 's'}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.filter_list),
                            onPressed: _showFilterDialog,
                            tooltip: 'Filter books',
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 140, // Fixed card width
                            childAspectRatio: 0.6,
                            crossAxisSpacing: 0,
                            mainAxisSpacing: 0,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final book = filteredBooks[index];
                        return BookCard(
                          title: book['title'] ?? 'Untitled',
                          description: book['description'] ?? 'No description',
                          authorName:
                              book['users']?['full_name'] ?? 'Anonymous',
                          genres: List<String>.from(book['genres'] ?? []),
                          coverImageUrl: book['cover_image_url'] ?? '',
                          views: book['views'] ?? 0,
                          likes: book['likes'] ?? 0,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookDetailPage(
                                  bookId: book['id'],
                                  title: book['title'],
                                  authorName:
                                      book['users']?['full_name'] ??
                                      'Anonymous',
                                  coverImageUrl: book['cover_image_url'],
                                ),
                              ),
                            );
                          },
                        );
                      }, childCount: filteredBooks.length),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
    );
  }
}
