import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/small_book_card.dart';
import '../widgets/category_card.dart';
import '../widgets/section_header.dart';
import 'book_detail_page.dart';
import 'books_list_page.dart';
import 'category_page.dart';
import '../../../auth/presentation/pages/login_page.dart';
import 'simple_pdf_viewer.dart';
import 'official_books_page.dart';
import '../widgets/banner_widget.dart';

class HomePage extends StatefulWidget {
  final bool showAppBar;
  const HomePage({super.key, this.showAppBar = true});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Map<String, dynamic>>> _future;

  // Tambahan untuk kategori dinamis
  List<String> categories = [];
  bool _loadingCategories = true;
  bool _errorCategories = false;

  @override
  void initState() {
    super.initState();
    _future = Supabase.instance.client
        .from('books')
        .select('*, users(full_name)')
        .eq('status', 'published')
        .order('created_at', ascending: false);
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _loadingCategories = true;
      _errorCategories = false;
    });
    try {
      final pdfCategories = await Supabase.instance.client
          .from('pdf_books')
          .select('category')
          .neq('category', '');
      final bookGenres = await Supabase.instance.client
          .from('books')
          .select('genre')
          .neq('genre', '');
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
        _loadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _loadingCategories = false;
        _errorCategories = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text(
                'Alhuda Library',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              backgroundColor: const Color(0xFF7AC142),
              foregroundColor: Colors.white,
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _future = Supabase.instance.client
                .from('books')
                .select('*, users(full_name)')
                .eq('status', 'published')
                .order('created_at', ascending: false);
          });
        },
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final books = snapshot.data!;
            if (books.isEmpty) {
              return const Center(child: Text('No books found'));
            }

            // Show more books in each section - use all available books
            final recommendedBooks = books.skip(1).toList();
            final trendingBooks = books.toList(); // Show all books in trending

            return FutureBuilder<List<Map<String, dynamic>>>(
              future: Supabase.instance.client
                  .from('banners')
                  .select()
                  .eq('is_active', true)
                  .order('created_at', ascending: false)
                  .limit(1),
              builder: (context, bannerSnapshot) {
                String? bannerUrl;
                if (bannerSnapshot.hasData && bannerSnapshot.data!.isNotEmpty) {
                  bannerUrl =
                      bannerSnapshot.data!.first['image_url'] as String?;
                }
                return CustomScrollView(
                  slivers: [
                    // Banner Section (Full Width, No Padding)
                    if (bannerUrl != null)
                      SliverToBoxAdapter(
                        child: BannerWidget(imageUrl: bannerUrl),
                      ),

                    // Recommended Books Section
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            title: 'Rekomendasi',
                            onSeeAll: () {
                              final user =
                                  Supabase.instance.client.auth.currentUser;
                              if (user == null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BooksListPage(
                                    title: 'Recommended Books',
                                    filterType: 'recommended',
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            height: 240,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(left: 16),
                              scrollDirection: Axis.horizontal,
                              clipBehavior: Clip.none,
                              itemCount: () {
                                // Calculate max books that can fit + 1 for peek effect
                                final screenWidth = MediaQuery.of(
                                  context,
                                ).size.width;
                                const cardWidth = 120.0; // Fixed card width
                                const padding = 16.0; // Left padding only
                                const spacing = 16.0; // Margin between cards

                                final availableWidth = screenWidth - padding;
                                final maxBooks =
                                    ((availableWidth + spacing) /
                                            (cardWidth + spacing))
                                        .floor();

                                // Show max books that fit + 1 for peek effect, but not more than total books
                                final showCount = maxBooks + 1;
                                return recommendedBooks.length > showCount
                                    ? showCount
                                    : recommendedBooks.length;
                              }(),
                              itemBuilder: (context, index) {
                                final book = recommendedBooks[index];
                                return SmallBookCard(
                                  title: book['title'] ?? 'Untitled',
                                  authorName:
                                      book['users']?['full_name'] ??
                                      'Anonymous',
                                  coverImageUrl: book['cover_image_url'] ?? '',
                                  views: book['views'] ?? 0,
                                  likes: book['likes'] ?? 0,
                                  onTap: () {
                                    final user = Supabase
                                        .instance
                                        .client
                                        .auth
                                        .currentUser;
                                    if (user == null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginPage(),
                                        ),
                                      );
                                      return;
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BookDetailPage(
                                          bookId: book['id'],
                                          title: book['title'],
                                          authorName:
                                              book['users']?['full_name'] ??
                                              'Anonymous',
                                          coverImageUrl:
                                              book['cover_image_url'],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Trending Books Section
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            title: 'Buku Terlaris',
                            onSeeAll: () {
                              final user =
                                  Supabase.instance.client.auth.currentUser;
                              if (user == null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BooksListPage(
                                    title: 'Trending Books',
                                    filterType: 'trending',
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            height: 240,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(left: 16),
                              scrollDirection: Axis.horizontal,
                              clipBehavior: Clip.none,
                              itemCount: () {
                                final screenWidth = MediaQuery.of(
                                  context,
                                ).size.width;
                                const cardWidth = 120.0;
                                const padding = 16.0;
                                const spacing = 16.0;

                                final availableWidth = screenWidth - padding;
                                final maxBooks =
                                    ((availableWidth + spacing) /
                                            (cardWidth + spacing))
                                        .floor();

                                final showCount = maxBooks + 1;
                                return trendingBooks.length > showCount
                                    ? showCount
                                    : trendingBooks.length;
                              }(),
                              itemBuilder: (context, index) {
                                final book = trendingBooks[index];
                                return SmallBookCard(
                                  title: book['title'] ?? 'Untitled',
                                  authorName:
                                      book['users']?['full_name'] ??
                                      'Anonymous',
                                  coverImageUrl: book['cover_image_url'] ?? '',
                                  views: book['views'] ?? 0,
                                  likes: book['likes'] ?? 0,
                                  onTap: () {
                                    final user = Supabase
                                        .instance
                                        .client
                                        .auth
                                        .currentUser;
                                    if (user == null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginPage(),
                                        ),
                                      );
                                      return;
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BookDetailPage(
                                          bookId: book['id'],
                                          title: book['title'],
                                          authorName:
                                              book['users']?['full_name'] ??
                                              'Anonymous',
                                          coverImageUrl:
                                              book['cover_image_url'],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Categories Section
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(title: 'Kategori Unggulan'),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _loadingCategories
                                ? const SizedBox(
                                    height: 120,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : _errorCategories
                                ? const SizedBox(
                                    height: 120,
                                    child: Center(
                                      child: Text('Gagal memuat kategori'),
                                    ),
                                  )
                                : LayoutBuilder(
                                    builder: (context, constraints) {
                                      const cardWidth = 120.0;
                                      const spacing = 16.0;
                                      return SizedBox(
                                        height: 120 + 32,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: List.generate(categories.length, (
                                              i,
                                            ) {
                                              final cat = categories[i];
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                  right: spacing,
                                                ),
                                                child: SizedBox(
                                                  width: cardWidth,
                                                  child: CategoryCard(
                                                    title: cat,
                                                    icon: Icons.category,
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                    onTap: () {
                                                      final user = Supabase
                                                          .instance
                                                          .client
                                                          .auth
                                                          .currentUser;
                                                      if (user == null) {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                const LoginPage(),
                                                          ),
                                                        );
                                                        return;
                                                      }
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder:
                                                              (
                                                                context,
                                                              ) => CategoryPage(
                                                                category: cat,
                                                                title: cat,
                                                                icon: Icons
                                                                    .category,
                                                                color: Theme.of(
                                                                  context,
                                                                ).colorScheme.primary,
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),

                    // Latest Books Section
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            title: 'Buku Terbaru',
                            onSeeAll: () {
                              final user =
                                  Supabase.instance.client.auth.currentUser;
                              if (user == null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BooksListPage(
                                    title: 'Latest Books',
                                    filterType: 'latest',
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            height: 240,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(left: 16),
                              scrollDirection: Axis.horizontal,
                              clipBehavior: Clip.none,
                              itemCount: () {
                                final screenWidth = MediaQuery.of(
                                  context,
                                ).size.width;
                                const cardWidth = 120.0;
                                const padding = 16.0;
                                const spacing = 16.0;

                                final availableWidth = screenWidth - padding;
                                final maxBooks =
                                    ((availableWidth + spacing) /
                                            (cardWidth + spacing))
                                        .floor();

                                final showCount = maxBooks + 1;
                                return books.length > showCount
                                    ? showCount
                                    : books.length;
                              }(),
                              itemBuilder: (context, index) {
                                final book = books[index];
                                return SmallBookCard(
                                  title: book['title'] ?? 'Untitled',
                                  authorName:
                                      book['users']?['full_name'] ??
                                      'Anonymous',
                                  coverImageUrl: book['cover_image_url'] ?? '',
                                  views: book['views'] ?? 0,
                                  likes: book['likes'] ?? 0,
                                  onTap: () {
                                    final user = Supabase
                                        .instance
                                        .client
                                        .auth
                                        .currentUser;
                                    if (user == null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginPage(),
                                        ),
                                      );
                                      return;
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BookDetailPage(
                                          bookId: book['id'],
                                          title: book['title'],
                                          authorName:
                                              book['users']?['full_name'] ??
                                              'Anonymous',
                                          coverImageUrl:
                                              book['cover_image_url'],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),

                    // Official PDF Books Section
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            title: 'Official Books',
                            onSeeAll: () {
                              final user =
                                  Supabase.instance.client.auth.currentUser;
                              if (user == null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const OfficialBooksPage(),
                                ),
                              );
                            },
                          ),
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: Supabase.instance.client
                                .from('pdf_books')
                                .select()
                                .order('created_at', ascending: false)
                                .limit(5),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox(
                                  height: 240,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final pdfBooks = snapshot.data!;
                              if (pdfBooks.isEmpty) {
                                return const SizedBox(
                                  height: 240,
                                  child: Center(
                                    child: Text('No PDF books available'),
                                  ),
                                );
                              }

                              return SizedBox(
                                height: 240,
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(left: 16),
                                  scrollDirection: Axis.horizontal,
                                  clipBehavior: Clip.none,
                                  itemCount: pdfBooks.length,
                                  itemBuilder: (context, index) {
                                    final book = pdfBooks[index];
                                    return SmallBookCard(
                                      title: book['title'] ?? 'Untitled',
                                      authorName:
                                          book['book_author'] ?? 'Anonymous',
                                      coverImageUrl: book['cover_image_url'],
                                      views: book['views'] ?? 0,
                                      likes: book['likes'] ?? 0,
                                      onTap: () {
                                        final user = Supabase
                                            .instance
                                            .client
                                            .auth
                                            .currentUser;
                                        if (user == null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const LoginPage(),
                                            ),
                                          );
                                          return;
                                        }
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AdvancedPdfViewer(
                                                  bookId: book['id'],
                                                  pdfUrl: book['pdf_url'] ?? '',
                                                  title:
                                                      book['title'] ??
                                                      'Untitled',
                                                ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
