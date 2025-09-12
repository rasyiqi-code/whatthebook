import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../bloc/profile_bloc.dart';
import '../../../../core/injection/injection_container.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../books/presentation/bloc/book_bloc.dart';
import '../../../books/presentation/bloc/book_event.dart';
import '../../../books/presentation/bloc/book_state.dart';
import '../../../books/presentation/pages/book_reader_page.dart';
import '../../../books/presentation/pages/simple_pdf_viewer.dart';
import '../../../books/presentation/bloc/bookmark_bloc.dart';
import '../../../../core/injection/injection_container.dart' as di;
import 'package:whatthebook/core/services/logger_service.dart';

class FeedItem {
  final String id;
  final String type; // 'book', 'review', 'achievement'
  final String content;
  final DateTime createdAt;
  FeedItem({
    required this.id,
    required this.type,
    required this.content,
    required this.createdAt,
  });
}

class PublicUserProfilePage extends StatefulWidget {
  final String userId;
  final String? userName;

  const PublicUserProfilePage({super.key, required this.userId, this.userName});

  @override
  State<PublicUserProfilePage> createState() => _PublicUserProfilePageState();
}

class _PublicUserProfilePageState extends State<PublicUserProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Map<String, dynamic>>> _lastReadFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _lastReadFuture = _loadLastReadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _loadLastReadData() async {
    try {
      final readingProgressData = await Supabase.instance.client
          .from('reading_progress')
          .select()
          .eq('user_id', widget.userId)
          .order('last_read_at', ascending: false);

      final bookIds = readingProgressData
          .where((p) => p['book_id'] != null)
          .map((p) => p['book_id'] as String)
          .toSet()
          .toList();
      final pdfBookIds = readingProgressData
          .where((p) => p['pdf_book_id'] != null)
          .map((p) => p['pdf_book_id'] as String)
          .toSet()
          .toList();

      List<Map<String, dynamic>> books = [];
      if (bookIds.isNotEmpty) {
        books = List<Map<String, dynamic>>.from(
          await Supabase.instance.client
              .from('books')
              .select('*, users(email, full_name)')
              .inFilter('id', bookIds),
        );
      }
      List<Map<String, dynamic>> pdfBooks = [];
      if (pdfBookIds.isNotEmpty) {
        pdfBooks = List<Map<String, dynamic>>.from(
          await Supabase.instance.client
              .from('pdf_books')
              .select('*')
              .inFilter('id', pdfBookIds),
        );
      }
      final lastReadItems = <Map<String, dynamic>>[];
      for (final progress in readingProgressData) {
        if (progress['book_id'] != null) {
          final book = books.firstWhere(
            (b) => b['id'] == progress['book_id'],
            orElse: () => {},
          );
          if (book.isNotEmpty) {
            lastReadItems.add({
              'type': 'book',
              'data': book,
              'last_read_at': progress['last_read_at'],
              'progress': progress['progress_percentage'],
            });
          }
        } else if (progress['pdf_book_id'] != null) {
          final pdf = pdfBooks.firstWhere(
            (b) => b['id'] == progress['pdf_book_id'],
            orElse: () => {},
          );
          if (pdf.isNotEmpty) {
            lastReadItems.add({
              'type': 'pdf',
              'data': pdf,
              'last_read_at': progress['last_read_at'],
              'progress': progress['progress_percentage'],
            });
          }
        }
      }
      lastReadItems.sort(
        (a, b) => DateTime.parse(
          b['last_read_at'],
        ).compareTo(DateTime.parse(a['last_read_at'])),
      );
      return lastReadItems;
    } catch (e) {
      logger.error('Error loading last read data: $e');
      return [];
    }
  }

  Widget _buildStatColumn(String label, String count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 204),
          ),
        ),
      ],
    );
  }

  // Published Books Tab
  Widget _buildPublishedBooksTab() {
    return BlocProvider(
      create: (context) =>
          sl<BookBloc>()..add(GetMyBooksEvent(userId: widget.userId)),
      child: BlocConsumer<BookBloc, BookState>(
        listener: (context, state) {
          if (state is BookError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BookLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BookError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi kesalahan saat memuat buku: ${state.message}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (state is MyBooksLoaded) {
            // Filter only published books for public view
            final publishedBooks = state.books
                .where((book) => book.status.isPublic)
                .toList();

            if (publishedBooks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.book_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum ada buku yang dipublikasikan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<BookBloc>().add(
                  GetMyBooksEvent(userId: widget.userId),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: publishedBooks.length,
                itemBuilder: (context, index) {
                  final book = publishedBooks[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        logger.debug(
                          'Opening book in reader mode: ${book.id} - ${book.title}',
                        );
                        try {
                          if (!mounted) return;

                          final page = BlocProvider<BookmarkBloc>(
                            create: (_) => di.sl<BookmarkBloc>(),
                            child: BookReaderPage(
                              bookId: book.id,
                              bookTitle: book.title,
                            ),
                          );
                          logger.debug('Created BookReaderPage instance');

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => page),
                          );
                          logger.debug('Navigation completed');
                        } catch (e, stackTrace) {
                          logger.error('Error opening book: $e');
                          logger.error('Stack trace: $stackTrace');
                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal membuka buku: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          // Book Cover
                          Container(
                            width: 80,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                            ),
                            child: book.coverImageUrl?.isNotEmpty == true
                                ? Image.network(
                                    book.coverImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                          Icons.book,
                                          size: 32,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                  )
                                : Icon(
                                    Icons.book,
                                    size: 32,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                          ),
                          // Content area
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (book.description?.isNotEmpty == true) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      book.description!,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.book,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${book.totalChapters} chapters',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.text_fields,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${book.totalWords} words',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // Feed Tab
  Widget _buildFeedTab() {
    // Dummy data, ganti dengan fetch dari backend/Supabase
    final List<FeedItem> feedItems = [
      FeedItem(
        id: '1',
        type: 'book',
        content: 'Menerbitkan buku "Petualangan Si Kancil"',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
      ),
      FeedItem(
        id: '2',
        type: 'review',
        content: 'Menulis review untuk "Bulan di Atas Kuburan"',
        createdAt: DateTime.now().subtract(Duration(days: 2)),
      ),
      FeedItem(
        id: '3',
        type: 'achievement',
        content: 'Mendapatkan badge "First Chapter Published"',
        createdAt: DateTime.now().subtract(Duration(days: 3)),
      ),
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: feedItems.length,
      itemBuilder: (context, i) {
        final item = feedItems[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: Icon(_iconForType(item.type)),
            title: Text(item.content),
            subtitle: Text(_formatDate(item.createdAt)),
          ),
        );
      },
    );
  }

  Widget _buildLastReadTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _lastReadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final lastReadItems = snapshot.data ?? [];
        if (lastReadItems.isEmpty) {
          return const Center(child: Text('Belum ada progress membaca.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: lastReadItems.length,
          itemBuilder: (context, index) {
            final item = lastReadItems[index];
            final data = item['data'] as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: data['cover_image_url'] != null
                    ? Image.network(
                        data['cover_image_url'],
                        width: 48,
                        height: 64,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        item['type'] == 'pdf'
                            ? Icons.picture_as_pdf
                            : Icons.book,
                      ),
                title: Row(
                  children: [
                    Expanded(child: Text(data['title'] ?? 'Tanpa Judul')),
                    if (item['type'] == 'pdf')
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                          size: 18,
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.menu_book,
                          color: Colors.blue,
                          size: 18,
                        ),
                      ),
                  ],
                ),
                subtitle: Builder(
                  builder: (context) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (data['description'] != null)
                          Text(
                            data['description'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        Text(
                          'Progress: ${item['progress']?.toStringAsFixed(1) ?? '-'}%',
                        ),
                      ],
                    );
                  },
                ),
                onTap: () {
                  if (item['type'] == 'book') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider<BookmarkBloc>(
                          create: (_) => di.sl<BookmarkBloc>(),
                          child: BookReaderPage(
                            bookId: data['id'],
                            bookTitle: data['title'] ?? '',
                          ),
                        ),
                      ),
                    );
                  } else if (item['type'] == 'pdf') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdvancedPdfViewer(
                          bookId: data['id'],
                          pdfUrl: data['pdf_url'] ?? '',
                          title: data['title'] ?? '',
                        ),
                      ),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAboutTab() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          final user = state.user;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user.bio != null) ...[
                  const Text(
                    'Tentang Penulis',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(user.bio!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),
                ],
                const Text(
                  'Statistik',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Buku', user.booksCount.toString()),
                    _buildStatCard('Followers', user.followersCount.toString()),
                    _buildStatCard('Following', user.followingCount.toString()),
                  ],
                ),
                const SizedBox(height: 24),
                if (user.email.isNotEmpty) ...[
                  const Text(
                    'Kontak',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(user.email, style: const TextStyle(fontSize: 16)),
                ],
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'book':
        return Icons.book;
      case 'review':
        return Icons.rate_review;
      case 'achievement':
        return Icons.emoji_events;
      default:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<ProfileBloc>()..add(LoadUserProfile(widget.userId)),
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return Scaffold(
              appBar: AppBar(title: Text(widget.userName ?? 'Profile')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is ProfileError) {
            return Scaffold(
              appBar: AppBar(title: Text(widget.userName ?? 'Profile')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProfileBloc>().add(
                          LoadUserProfile(widget.userId),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final user = state is ProfileLoaded ? state.user : null;
          final isFollowing = state is ProfileLoaded
              ? state.isFollowing
              : false;

          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: MediaQuery.of(context).size.height,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 204),
                              Theme.of(context).primaryColor,
                            ],
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 8),
                                // Profile Picture
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.white,
                                  backgroundImage: user?.avatarUrl != null
                                      ? NetworkImage(user!.avatarUrl!)
                                      : null,
                                  child: user?.avatarUrl == null
                                      ? Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Theme.of(context).primaryColor,
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 8),

                                // User Name
                                Text(
                                  user?.fullName ??
                                      widget.userName ??
                                      'User Name',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (user?.username != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '@${user!.username}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withValues(
                                        alpha: 204,
                                      ),
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 8),

                                // Stats Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildStatColumn(
                                      'Books',
                                      user?.booksCount.toString() ?? '0',
                                    ),
                                    const SizedBox(width: 32),
                                    _buildStatColumn(
                                      'Followers',
                                      user?.followersCount.toString() ?? '0',
                                    ),
                                    const SizedBox(width: 32),
                                    _buildStatColumn(
                                      'Following',
                                      user?.followingCount.toString() ?? '0',
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // Action Buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        context.read<ProfileBloc>().add(
                                          ToggleFollowUser(
                                            widget.userId,
                                            isFollowing,
                                          ),
                                        );
                                      },
                                      icon: Icon(
                                        isFollowing
                                            ? Icons.person_remove
                                            : Icons.person_add,
                                      ),
                                      label: Text(
                                        isFollowing ? 'Unfollow' : 'Follow',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Theme.of(
                                          context,
                                        ).primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => ChatPage(
                                              userId: widget.userId,
                                              userName:
                                                  user?.fullName ??
                                                  widget.userName ??
                                                  'User',
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.message),
                                      label: const Text('Message'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: const BorderSide(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: Column(
                children: [
                  // Tab Bar
                  Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Buku'),
                        Tab(text: 'Feed'),
                        Tab(text: 'Terakhir Dibaca'),
                        Tab(text: 'Tentang'),
                      ],
                    ),
                  ),

                  // Tab Bar View
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPublishedBooksTab(),
                        _buildFeedTab(),
                        _buildLastReadTab(),
                        _buildAboutTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
