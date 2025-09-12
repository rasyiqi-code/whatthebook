import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/injection/injection_container.dart' as di;
import '../../../../../core/services/logger_service.dart';
import '../../bloc/book_bloc.dart';
import '../../bloc/book_event.dart';
import '../../bloc/book_state.dart';
import 'book_details_page.dart';
import 'chapter_editor_page.dart';
import '../pdf_upload_page.dart';
import '../pdf_edit_page.dart';
import '../simple_pdf_viewer.dart';
import '../../../../auth/domain/entities/user.dart';
import '../../../../auth/domain/services/role_service.dart';

class MyBooksPage extends StatelessWidget {
  const MyBooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    logger.debug('MyBooksPage - Building with BlocProvider');
    return BlocProvider(
      create: (context) {
        logger.debug(
          'MyBooksPage - Creating BookBloc and adding GetMyBooksEvent',
        );
        return di.sl<BookBloc>()..add(GetMyBooksEvent());
      },
      child: const MyBooksView(),
    );
  }
}

class MyBooksView extends StatefulWidget {
  const MyBooksView({super.key});

  @override
  State<MyBooksView> createState() => _MyBooksViewState();
}

class _MyBooksViewState extends State<MyBooksView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _pdfBooks = [];
  bool _isLoadingPdf = true;
  late RoleService _roleService;
  UserRole? _userRole;

  @override
  void initState() {
    super.initState();
    _roleService = di.sl<RoleService>();
    _loadUserRole();
    _loadPdfBooks();
  }

  void _initializeTabController() {
    // Publisher hanya 1 tab: Buku PDF, Author/Admin: 2 tab
    final tabCount =
        (_userRole == UserRole.author || _userRole == UserRole.admin) ? 2 : 1;
    _tabController = TabController(length: tabCount, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  Future<void> _loadUserRole() async {
    try {
      final role = await _roleService.getCurrentUserRole();
      if (mounted) {
        setState(() {
          _userRole = role;
          _initializeTabController();
        });
      }
    } catch (e) {
      logger.error('MyBooksPage - Error loading user role', e);
      if (mounted) {
        setState(() {
          _userRole = UserRole.reader; // Default fallback
          _initializeTabController();
        });
      }
    }
  }

  void _handleTabChange() {
    if (_tabController.index == 1) {
      // PDF Books tab
      _loadPdfBooks();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPdfBooks() async {
    try {
      setState(() {
        _isLoadingPdf = true;
      });

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Only load PDF books if user is publisher or admin
      if (_userRole != UserRole.publisher && _userRole != UserRole.admin) {
        setState(() {
          _pdfBooks = [];
          _isLoadingPdf = false;
        });
        return;
      }

      logger.debug(
        'MyBooksPage - Loading PDF books for user: ${currentUser.id}',
      );

      final response = await Supabase.instance.client
          .from('pdf_books')
          .select('*')
          .eq('author_id', currentUser.id)
          .order('created_at', ascending: false);

      logger.debug('MyBooksPage - PDF books query executed successfully');
      logger.debug(
        'MyBooksPage - PDF books response type: ${response.runtimeType}',
      );
      logger.debug(
        'MyBooksPage - PDF books count: ${(response as List).length}',
      );

      setState(() {
        _pdfBooks = List<Map<String, dynamic>>.from(response);
        _isLoadingPdf = false;
      });
    } catch (e) {
      logger.error('MyBooksPage - Error loading PDF books', e);
      setState(() {
        _isLoadingPdf = false;
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()}y ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()}mo ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userRole == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Check if user has access to MyBooksPage
    final hasAccess =
        _userRole == UserRole.author ||
        _userRole == UserRole.publisher ||
        _userRole == UserRole.admin;

    if (!hasAccess) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Books'),
          automaticallyImplyLeading: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
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
                  'You need author role or higher to access this page',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 32,
                          color: Colors.blue[600],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Want to become an Author?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Contact our admin to request author privileges and start writing your own books!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                _showContactInfo(context);
                              },
                              icon: const Icon(Icons.contact_support),
                              label: const Text('Contact Admin'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                _showAuthorInfo(context);
                              },
                              icon: const Icon(Icons.info),
                              label: const Text('Learn More'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Publisher hanya bisa upload PDF, tidak bisa create buku tulis
    final canCreateBooks =
        _userRole == UserRole.author || _userRole == UserRole.admin;
    final isPublisher = _userRole == UserRole.publisher;

    return Scaffold(
      appBar: (_userRole == UserRole.author || _userRole == UserRole.admin)
          ? PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: Theme.of(context).primaryColor,
                child: SafeArea(
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    labelStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: const [
                      Tab(
                        text: 'Buku Tulis',
                        icon: Icon(Icons.create, size: 18),
                        iconMargin: EdgeInsets.only(bottom: 2),
                      ),
                      Tab(
                        text: 'Buku PDF',
                        icon: Icon(Icons.picture_as_pdf, size: 18),
                        iconMargin: EdgeInsets.only(bottom: 2),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : isPublisher
          ? AppBar(
              title: const Text('Buku PDF'),
              automaticallyImplyLeading: true,
            )
          : null,
      floatingActionButton: canCreateBooks
          ? FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.create),
                          title: const Text('Tulis Buku Baru'),
                          subtitle: const Text('Mulai menulis cerita baru'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const BookDetailsPage.create(),
                              ),
                            );
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.picture_as_pdf),
                          title: const Text('Upload PDF'),
                          subtitle: const Text('Tambahkan buku PDF dari file'),
                          onTap: () async {
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            final uploaded = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PdfUploadPage(),
                              ),
                            );
                            if (uploaded == true && context.mounted) {
                              context.read<BookBloc>().add(GetMyBooksEvent());
                              _loadPdfBooks(); // Refresh PDF books list
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Buku'),
              heroTag: 'add_book',
            )
          : isPublisher
          ? FloatingActionButton.extended(
              onPressed: () async {
                final uploaded = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PdfUploadPage(),
                  ),
                );
                if (uploaded == true && context.mounted) {
                  _loadPdfBooks();
                }
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Upload PDF'),
              heroTag: 'upload_pdf',
            )
          : null,
      body: (_userRole == UserRole.author || _userRole == UserRole.admin)
          ? TabBarView(
              controller: _tabController,
              children: [_buildRegularBooksTab(), _buildPdfBooksTab()],
            )
          : isPublisher
          ? _buildPdfBooksTab()
          : _buildRegularBooksTab(),
    );
  }

  Widget _buildRegularBooksTab() {
    return BlocBuilder<BookBloc, BookState>(
      builder: (context, state) {
        logger.debug('MyBooksPage - Current state: ${state.runtimeType}');
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
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<BookBloc>().add(GetMyBooksEvent());
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (state is MyBooksLoaded) {
          logger.debug(
            'MyBooksPage - MyBooksLoaded with ${state.books.length} books',
          );
          if (state.books.isEmpty) {
            // Check if user can create books
            final canCreateBooks =
                _userRole == UserRole.author || _userRole == UserRole.admin;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.book_outlined, size: 64, color: Colors.grey),
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
                        : 'Anda belum memiliki buku yang ditulis',
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
              context.read<BookBloc>().add(GetMyBooksEvent());
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
                      // Navigate to chapter editor for the first chapter
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
                            ).colorScheme.primary.withValues(alpha: 0.1),
                          ),
                          child: book.coverImageUrl?.isNotEmpty == true
                              ? Image.network(
                                  book.coverImageUrl!,
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
    );
  }

  Widget _buildPdfBooksTab() {
    if (_isLoadingPdf) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pdfBooks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada buku PDF',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unggah buku PDF dari file',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPdfBooks,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pdfBooks.length,
        itemBuilder: (context, index) {
          final book = _pdfBooks[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
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
                    child: book['cover_image_url'] != null
                        ? Image.network(
                            book['cover_image_url'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.picture_as_pdf,
                                size: 32,
                                color: Theme.of(context).colorScheme.primary,
                              );
                            },
                          )
                        : Icon(
                            Icons.picture_as_pdf,
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
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  book['title'] ?? 'Untitled',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () {
                                  _showDeletePdfDialog(
                                    context,
                                    book['id'],
                                    book['title'] ?? 'Untitled',
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PdfEditPage(
                                        bookId: book['id'],
                                        bookData: book,
                                      ),
                                    ),
                                  ).then((updated) {
                                    if (updated == true) {
                                      _loadPdfBooks(); // Refresh PDF books list
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                          if (book['description'] != null &&
                              book['description'].toString().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              book['description'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.picture_as_pdf,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'PDF',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                _formatDate(book['created_at']),
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

  void _showDeletePdfDialog(BuildContext context, String bookId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Buku PDF'),
        content: Text('Apakah Anda yakin ingin menghapus "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Supabase.instance.client
                    .from('pdf_books')
                    .delete()
                    .eq('id', bookId);

                if (!mounted) return;
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Buku PDF berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                _loadPdfBooks(); // Refresh the list
              } catch (e) {
                if (!mounted) return;
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus buku: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showContactInfo(BuildContext context) async {
    // Show loading dialog first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Loading admin contact information...'),
          ],
        ),
      ),
    );

    try {
      // Fetch admin users from database
      final response = await Supabase.instance.client
          .from('users')
          .select('full_name, contact, email')
          .eq('role', 'admin')
          .not('contact', 'is', null);

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (response.isEmpty) {
        // Close loading dialog
        if (context.mounted) {
          Navigator.pop(context);
        }
        // Show fallback contact info if no admin found
        if (context.mounted) {
          _showFallbackContactInfo(context);
        }
        return;
      }

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show contact info with admin data
      if (context.mounted) {
        _showAdminContactInfo(context, response);
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show error and fallback
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading contact info: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (context.mounted) {
        _showFallbackContactInfo(context);
      }
    }
  }

  void _showAdminContactInfo(BuildContext context, List<dynamic> adminUsers) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.contact_support, color: Colors.blue[600]),
            const SizedBox(width: 8),
            const Text('Contact Admin'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To request author privileges, please contact our admin team:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ...adminUsers.map((admin) => _buildAdminContactItem(admin)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, size: 16, color: Colors.blue[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Request Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Please include your username and reason for requesting author privileges in your message.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminContactItem(Map<String, dynamic> admin) {
    final fullName = admin['full_name'] as String? ?? 'Admin';
    final contact = admin['contact'] as String? ?? '';
    final email = admin['email'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 20,
                color: Colors.blue[600],
              ),
              const SizedBox(width: 8),
              Text(
                fullName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (contact.isNotEmpty) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _launchPhone(contact),
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    contact,
                    style: TextStyle(fontSize: 12, color: Colors.blue[600]),
                  ),
                ],
              ),
            ),
          ],
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            InkWell(
              onTap: () => _launchEmail(email),
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: [
                  Icon(Icons.email, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    email,
                    style: TextStyle(fontSize: 12, color: Colors.blue[600]),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFallbackContactInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.contact_support, color: Colors.blue[600]),
            const SizedBox(width: 8),
            const Text('Contact Admin'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To request author privileges, please contact our admin team:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              Icons.email,
              'Email',
              'admin@whatthebook.com',
              () => _launchEmail('admin@whatthebook.com'),
            ),
            const SizedBox(height: 8),
            _buildContactItem(
              Icons.phone,
              'Phone',
              '+62 812-3456-7890',
              () => _launchPhone('+62 812-3456-7890'),
            ),
            const SizedBox(height: 8),
            _buildContactItem(
              Icons.chat,
              'WhatsApp',
              '+62 812-3456-7890',
              () => _launchWhatsApp('+62 812-3456-7890'),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, size: 16, color: Colors.blue[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Request Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Please include your username and reason for requesting author privileges in your message.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String title,
    String value,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _launchEmail(String emailAddress) {
    // In a real app, you would use url_launcher package
    // For now, we'll show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening email client to $emailAddress...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _launchPhone(String phoneNumber) {
    // In a real app, you would use url_launcher package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening phone dialer to $phoneNumber...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _launchWhatsApp(String phoneNumber) {
    // In a real app, you would use url_launcher package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening WhatsApp to $phoneNumber...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAuthorInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.green[600]),
            const SizedBox(width: 8),
            const Text('About Author Role'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'As an author, you can:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                Icons.create,
                'Create Books',
                'Write and publish your own stories',
              ),
              _buildFeatureItem(
                Icons.edit,
                'Edit Books',
                'Modify your books anytime',
              ),
              _buildFeatureItem(
                Icons.menu_book,
                'Manage Chapters',
                'Add, edit, and organize chapters',
              ),
              _buildFeatureItem(
                Icons.image,
                'Upload Covers',
                'Add beautiful cover images',
              ),
              _buildFeatureItem(
                Icons.analytics,
                'View Analytics',
                'Track views, likes, and comments',
              ),
              _buildFeatureItem(
                Icons.picture_as_pdf,
                'Upload PDF Books',
                'Share existing PDF books',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.green[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Benefits',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '• Build your author profile\n• Connect with readers\n• Earn recognition\n• Share your creativity',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showContactInfo(context);
            },
            child: const Text('Request Access'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.green[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
