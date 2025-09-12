import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/book_card.dart';
import '../bloc/book_bloc.dart';
import '../bloc/book_event.dart';
import '../bloc/book_state.dart';
import '../../domain/usecases/search_books.dart';
import 'book_detail_page.dart';

class EnhancedSearchPage extends StatefulWidget {
  const EnhancedSearchPage({super.key});

  @override
  State<EnhancedSearchPage> createState() => _EnhancedSearchPageState();
}

class _EnhancedSearchPageState extends State<EnhancedSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedGenres = [];
  String? _selectedAuthor;
  String _sortBy = 'relevance';
  bool _showFilters = false;

  final List<String> _availableGenres = [
    'Romance',
    'Fantasy',
    'Mystery',
    'Thriller',
    'Science Fiction',
    'Horror',
    'Adventure',
    'Drama',
    'Comedy',
    'Historical Fiction',
    'Young Adult',
    'Contemporary',
    'Paranormal',
    'Action',
  ];

  final List<Map<String, String>> _sortOptions = [
    {'value': 'relevance', 'label': 'Relevance'},
    {'value': 'date_desc', 'label': 'Newest First'},
    {'value': 'date_asc', 'label': 'Oldest First'},
    {'value': 'title', 'label': 'Title A-Z'},
    {'value': 'author', 'label': 'Author A-Z'},
    {'value': 'popularity', 'label': 'Most Popular'},
    {'value': 'rating', 'label': 'Highest Rated'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    final filters = SearchFilters(
      genres: _selectedGenres.isNotEmpty ? _selectedGenres : null,
      author: _selectedAuthor,
      isPublished: true, // Only show published books
    );

    context.read<BookBloc>().add(
      SearchBooksRequested(query: query, filters: filters, sortBy: _sortBy),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _selectedGenres.clear();
      _selectedAuthor = null;
      _sortBy = 'relevance';
    });
    context.read<BookBloc>().add(ClearSearchRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Books'),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list : Icons.filter_list_off,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search books, authors, or descriptions...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onSubmitted: (_) => _performSearch(),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),

          // Filters Panel
          if (_showFilters) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sort Options
                  Row(
                    children: [
                      const Text(
                        'Sort by: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _sortBy,
                          isExpanded: true,
                          items: _sortOptions.map((option) {
                            return DropdownMenuItem<String>(
                              value: option['value'],
                              child: Text(option['label']!),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _sortBy = value!;
                            });
                            if (_searchController.text.isNotEmpty) {
                              _performSearch();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Genre Filters
                  const Text(
                    'Genres:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _availableGenres.map((genre) {
                      final isSelected = _selectedGenres.contains(genre);
                      return FilterChip(
                        label: Text(genre),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedGenres.add(genre);
                            } else {
                              _selectedGenres.remove(genre);
                            }
                          });
                          if (_searchController.text.isNotEmpty) {
                            _performSearch();
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Apply Filters Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _performSearch,
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Search Results
          Expanded(
            child: BlocBuilder<BookBloc, BookState>(
              builder: (context, state) {
                if (state is BookLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is BookError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _performSearch,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is SearchResultsLoaded) {
                  if (state.books.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No books found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search terms or filters',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          '${state.books.length} result${state.books.length == 1 ? '' : 's'} found',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.6,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
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
                      ),
                    ],
                  );
                }

                // Initial state - show search suggestions or popular books
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Search for books',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter keywords to find your next great read',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
