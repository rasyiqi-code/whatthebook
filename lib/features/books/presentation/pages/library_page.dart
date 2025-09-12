import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'simple_pdf_viewer.dart';
import '../pages/book_detail_page.dart';
import '../widgets/book_cover_card.dart';
import 'search_page.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with SingleTickerProviderStateMixin {
  List<String> categories = [];
  TabController? _tabController;
  final Map<String, List<Map<String, dynamic>>> _booksByCategory = {};
  final Map<String, bool> _loadingByCategory = {};
  final Map<String, bool> _errorByCategory = {};
  bool _loadingCategories = true;
  bool _errorCategories = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _loadingCategories = true;
      _errorCategories = false;
    });
    try {
      // Ambil kategori dari pdf_books
      final pdfCategories = await Supabase.instance.client
          .from('pdf_books')
          .select('category')
          .neq('category', '');
      // Ambil genre dari books
      final bookGenres = await Supabase.instance.client
          .from('books')
          .select('genre')
          .neq('genre', '');
      // Gabungkan dan ambil yang unik, hilangkan null/empty
      final allCategories =
          [
                ...pdfCategories.map((e) => e['category']),
                ...bookGenres.map((e) => e['genre']),
              ]
              .where((e) => e != null && (e as String).trim().isNotEmpty)
              .toSet()
              .toList();
      allCategories.sort();
      setState(() {
        categories = allCategories.cast<String>();
        _tabController = TabController(length: categories.length, vsync: this);
        // Inisialisasi loading/error map
        for (var cat in categories) {
          _loadingByCategory[cat] = true;
          _errorByCategory[cat] = false;
          _fetchBooksForCategory(cat);
        }
        _loadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _loadingCategories = false;
        _errorCategories = true;
      });
    }
  }

  Future<void> _fetchBooksForCategory(String category) async {
    setState(() {
      _loadingByCategory[category] = true;
      _errorByCategory[category] = false;
    });
    try {
      // Fetch from pdf_books
      final pdfBooks = await Supabase.instance.client
          .from('pdf_books')
          .select()
          .eq('category', category);
      // Fetch from books
      final books = await Supabase.instance.client
          .from('books')
          .select()
          .eq('genre', category);

      setState(() {
        _booksByCategory[category] = [
          ...List<Map<String, dynamic>>.from(pdfBooks),
          ...List<Map<String, dynamic>>.from(books),
        ];
        _loadingByCategory[category] = false;
      });
    } catch (e) {
      setState(() {
        _loadingByCategory[category] = false;
        _errorByCategory[category] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingCategories) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5DC),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF8B4513)),
        ),
      );
    }
    if (_errorCategories) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5DC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Gagal memuat kategori',
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchCategories,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5DC),
        appBar: AppBar(
          title: const Text('Perpustakaan Saya'),
          backgroundColor: const Color(0xFF8B4513),
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                );
              },
            ),
          ],
          bottom: _tabController == null
              ? null
              : TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: categories.map((cat) => Tab(text: cat)).toList(),
                  onTap: (index) {
                    final cat = categories[index];
                    if (_booksByCategory[cat] == null) {
                      _fetchBooksForCategory(cat);
                    }
                  },
                ),
        ),
        body: _tabController == null
            ? const SizedBox.shrink()
            : TabBarView(
                controller: _tabController,
                children: categories.map((cat) {
                  if (_loadingByCategory[cat] == true) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8B4513),
                      ),
                    );
                  }
                  if (_errorByCategory[cat] == true) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Gagal memuat buku kategori ini',
                            style: TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _fetchBooksForCategory(cat),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B4513),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    );
                  }
                  final books = _booksByCategory[cat] ?? [];
                  if (books.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_stories,
                            size: 80,
                            color: Colors.brown[300],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Belum ada buku di kategori ini',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown[700],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      const cardWidth = 120.0;
                      const cardHeight =
                          171.43; // Match homepage SmallBookCard height (120/0.7)
                      const spacing = 16.0;
                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: cardWidth + spacing,
                          mainAxisExtent: cardHeight,
                          childAspectRatio: cardWidth / cardHeight,
                          crossAxisSpacing: 1.0,
                          mainAxisSpacing: 1.0,
                        ),
                        itemCount: books.length,
                        itemBuilder: (context, idx) {
                          final book = books[idx];
                          final String coverImageUrl =
                              book['cover_image_url'] ?? '';
                          return BookCoverCard(
                            coverImageUrl: coverImageUrl,
                            onTap: () {
                              if (book.containsKey('pdf_url')) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AdvancedPdfViewer(
                                      bookId: book['id'],
                                      pdfUrl: book['pdf_url'] ?? '',
                                      title: book['title'] ?? 'Untitled',
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookDetailPage(
                                      bookId: book['id'],
                                      title: book['title'],
                                      authorName:
                                          book['users']?['full_name'] ??
                                          book['users']?['email'] ??
                                          'Anonymous',
                                      coverImageUrl: book['cover_image_url'],
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                  );
                }).toList(),
              ),
      ),
    );
  }
}
