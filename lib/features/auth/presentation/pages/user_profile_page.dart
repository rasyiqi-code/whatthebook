import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../bloc/profile_bloc.dart';
import '../../../../core/injection/injection_container.dart';
import '../../../books/presentation/bloc/book_bloc.dart';
import '../../../books/presentation/bloc/book_event.dart';
import '../../../books/presentation/bloc/book_state.dart';
import '../../../books/presentation/pages/write/book_details_page.dart';
import '../../../books/presentation/pages/write/chapter_editor_page.dart';
import '../../../books/presentation/pages/book_reader_page.dart';
import '../../../books/presentation/pages/publisher_dashboard_page.dart';
import 'admin/admin_panel_page.dart';
import '../../domain/services/role_service.dart';
import '../../domain/entities/user.dart';
import 'edit_profile_page.dart';
import 'settings/notifications_settings_page.dart';
import 'settings/privacy_security_page.dart';
import 'settings/help_page.dart';
import '../../../books/presentation/bloc/bookmark_bloc.dart';
import '../../../books/presentation/widgets/unified_bookmark_list_widget.dart';
import '../../../../core/injection/injection_container.dart' as di;
import '../../../../core/constants/app_constants.dart';
import 'package:whatthebook/core/services/logger_service.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;

  const UserProfilePage({super.key, required this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  late Future<Map<String, dynamic>> _libraryFuture;
  late RoleService _roleService;
  UserRole? _userRole;

  @override
  void initState() {
    super.initState();
    _roleService = sl<RoleService>();
    _libraryFuture = _loadLibraryData();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final role = await _roleService.getCurrentUserRole();
      if (!mounted) return;

      setState(() {
        _userRole = role;

        // Calculate tab count based on role
        int tabCount = 4; // Base tabs
        if (role == UserRole.publisher) {
          tabCount++; // Add Publisher Dashboard
        }
        if (role == UserRole.admin) {
          tabCount++; // Add Admin Panel
        }

        // Create TabController only after we know the final tab count
        _tabController?.dispose(); // Dispose old controller if exists
        _tabController = TabController(length: tabCount, vsync: this);
      });
    } catch (e) {
      logger.error('Error loading user role: $e');
      if (mounted && _tabController == null) {
        // Fallback to base tabs if role loading fails
        setState(() {
          _tabController = TabController(length: 4, vsync: this);
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _loadLibraryData() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Get all books with author information
      final allBooks = await Supabase.instance.client
          .from('books')
          .select('*, users!books_author_id_fkey(email)');

      // Get bookmarked books from bookmarks table for this user
      final bookmarksData = await Supabase.instance.client
          .from('bookmarks')
          .select('book_id')
          .eq('user_id', widget.userId)
          .order('created_at', ascending: false);

      final bookmarkedBooks = allBooks.where((book) {
        return bookmarksData.any(
          (bookmark) => bookmark['book_id'] == book['id'],
        );
      }).toList();

      // Get last read books from reading_progress table for this user
      final readingProgressData = await Supabase.instance.client
          .from('reading_progress')
          .select()
          .eq('user_id', widget.userId)
          .order('last_read_at', ascending: false);

      // Ambil semua book_id dan pdf_book_id yang pernah dibaca
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

      // Ambil detail buku biasa
      List<Map<String, dynamic>> books = [];
      if (bookIds.isNotEmpty) {
        books = List<Map<String, dynamic>>.from(
          await Supabase.instance.client
              .from('books')
              .select('*, users(email, full_name)')
              .inFilter('id', bookIds),
        );
      }
      // Ambil detail PDF books
      List<Map<String, dynamic>> pdfBooks = [];
      if (pdfBookIds.isNotEmpty) {
        pdfBooks = List<Map<String, dynamic>>.from(
          await Supabase.instance.client
              .from('pdf_books')
              .select('*')
              .inFilter('id', pdfBookIds),
        );
      }
      // Gabungkan dan urutkan berdasarkan last_read_at
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

      return {
        'books': allBooks,
        'bookmarked': bookmarkedBooks,
        'lastRead': lastReadItems,
      };
    } catch (e) {
      logger.error('Error loading library data: $e');
      return {'books': [], 'bookmarked': [], 'lastRead': []};
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
            color: Colors.white.withAlpha(204),
          ), // 0.8 * 255 = 204
        ),
      ],
    );
  }

  // Buku Saya Tab - moved from MyBooksPage
  Widget _buildBooksTab() {
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Terjadi kesalahan saat memuat buku: ${state.message}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<BookBloc>().add(
                          GetMyBooksEvent(userId: widget.userId),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is BookInitial) {
            context.read<BookBloc>().add(
              GetMyBooksEvent(userId: widget.userId),
            );
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MyBooksLoaded) {
            if (state.books.isEmpty) {
              // Check if user can create books
              final canCreateBooks =
                  _userRole == UserRole.author || _userRole == UserRole.admin;

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
                      'Belum ada buku',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      canCreateBooks
                          ? 'Mulai menulis cerita Anda'
                          : 'Belum ada buku yang ditulis',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    if (canCreateBooks) ...[
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const BookDetailsPage.create(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Buat Buku Baru'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
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
                itemCount: state.books.length,
                itemBuilder: (context, index) {
                  final book = state.books[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        // Profile sendiri, buka editor untuk edit
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ChapterEditorPage(bookId: book.id),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          // Book Cover - No padding, fills the left side
                          Container(
                            width: 80,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(10),
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
                          // Content area with padding
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          book.title,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        onSelected: (value) {
                                          switch (value) {
                                            case 'edit':
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      BookDetailsPage(
                                                        bookId: book.id,
                                                      ),
                                                ),
                                              );
                                              break;
                                            case 'delete':
                                              _showDeleteDialog(
                                                context,
                                                book.id,
                                                book.title,
                                              );
                                              break;
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit),
                                                SizedBox(width: 8),
                                                Text('Edit'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Hapus',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
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

  void _showDeleteDialog(BuildContext context, String bookId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Buku'),
        content: Text('Apakah Anda yakin ingin menghapus "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BookBloc>().add(DeleteBookEvent(bookId));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // Bookmark Tab - using unified bookmark widget
  Widget _buildBookmarkedTab() {
    return const UnifiedBookmarkListWidget();
  }

  // Terakhir Dibaca Tab - moved from LibraryPage
  Widget _buildLastReadTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _libraryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final lastReadItems = snapshot.data?['lastRead'] as List<dynamic>;

        if (lastReadItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Belum ada buku yang dibaca',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: lastReadItems.length,
          itemBuilder: (context, index) {
            final item = lastReadItems[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  if (item['type'] == 'book') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider<BookmarkBloc>(
                          create: (_) => di.sl<BookmarkBloc>(),
                          child: BookReaderPage(
                            bookId: item['data']['id'],
                            bookTitle: item['data']['title'],
                          ),
                        ),
                      ),
                    );
                  } else if (item['type'] == 'pdf') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider<BookmarkBloc>(
                          create: (_) => di.sl<BookmarkBloc>(),
                          child: BookReaderPage(
                            bookId: item['data']['id'],
                            bookTitle: item['data']['title'],
                          ),
                        ),
                      ),
                    );
                  }
                },
                child: Row(
                  children: [
                    // Book Cover - No padding, fills the left side
                    Container(
                      width: 80,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(10),
                      ),
                      child: item['type'] == 'book'
                          ? item['data']['cover_image_url'] != null &&
                                    item['data']['cover_image_url'].isNotEmpty
                                ? Image.network(
                                    item['data']['cover_image_url'],
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
                                  )
                          : item['data']['cover_image_url'] != null &&
                                item['data']['cover_image_url'].isNotEmpty
                          ? Image.network(
                              item['data']['cover_image_url'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
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
                              color: Theme.of(context).colorScheme.primary,
                            ),
                    ),
                    // Content area with padding
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['data']['title'] ?? 'Untitled',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActivityTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timeline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aktivitas Pengguna',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Riwayat aktivitas akan ditampilkan di sini',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildPublisherDashboardTab() {
    return const PublisherDashboardPage();
  }

  Widget _buildAdminPanelTab() {
    return const AdminPanelPage();
  }

  List<Tab> _buildTabs() {
    final baseTabs = [
      const Tab(text: 'Buku Saya'),
      const Tab(text: 'Bookmark'),
      const Tab(text: 'Terakhir Dibaca'),
      const Tab(text: 'Aktivitas'),
    ];

    if (_userRole == UserRole.publisher) {
      baseTabs.add(const Tab(text: 'Publisher Dashboard'));
    }
    if (_userRole == UserRole.admin) {
      baseTabs.add(const Tab(text: 'Admin Panel'));
    }

    return baseTabs;
  }

  List<Widget> _buildTabViews() {
    final baseViews = [
      _buildBooksTab(),
      _buildBookmarkedTab(),
      _buildLastReadTab(),
      _buildActivityTab(),
    ];

    if (_userRole == UserRole.publisher) {
      baseViews.add(_buildPublisherDashboardTab());
    }
    if (_userRole == UserRole.admin) {
      baseViews.add(_buildAdminPanelTab());
    }

    return baseViews;
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
              appBar: AppBar(),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is ProfileError) {
            return Scaffold(
              appBar: AppBar(),
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

          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 340,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.edit),
                                    title: const Text('Edit Profile'),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      if (!context.mounted) return;
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BlocProvider(
                                            create: (_) => sl<ProfileBloc>()
                                              ..add(
                                                LoadUserProfile(widget.userId),
                                              ),
                                            child: EditProfilePage(
                                              userId: widget.userId,
                                            ),
                                          ),
                                        ),
                                      );
                                      if (result == true && context.mounted) {
                                        context.read<ProfileBloc>().add(
                                          LoadUserProfile(widget.userId),
                                        );
                                      }
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.notifications),
                                    title: const Text('Notifikasi'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const NotificationsSettingsPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.security),
                                    title: const Text('Privasi & Keamanan'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const PrivacySecurityPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.help_outline),
                                    title: const Text('Bantuan'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const HelpPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.logout),
                                    title: const Text('Logout'),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      _roleService.clearCache();
                                      await Supabase.instance.client.auth
                                          .signOut();
                                      if (context.mounted) {
                                        Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          AppConstants.loginRoute,
                                          (route) => false,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Theme.of(context).primaryColor.withAlpha(204),
                              Theme.of(context).primaryColor,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const SizedBox(height: 16),
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
                                const SizedBox(height: 16),

                                // User Name
                                Text(
                                  user?.fullName ?? 'User Name',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (user?.username != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '@${user!.username}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withAlpha(204),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],

                                // Bio
                                if (user?.bio != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    user!.bio!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withAlpha(230),
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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

                                const SizedBox(height: 16),
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
                  if (_tabController != null) ...[
                    Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: TabBar(
                        controller: _tabController!,
                        isScrollable: true,
                        tabs: _buildTabs(),
                      ),
                    ),

                    // Tab Bar View
                    Expanded(
                      child: TabBarView(
                        controller: _tabController!,
                        children: _buildTabViews(),
                      ),
                    ),
                  ] else
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
