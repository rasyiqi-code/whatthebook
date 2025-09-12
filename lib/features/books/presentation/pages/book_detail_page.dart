import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../social/presentation/bloc/social_bloc.dart';
import '../../../social/presentation/bloc/social_event.dart';
import '../../../social/presentation/bloc/social_state.dart';
import '../../../../core/injection/injection_container.dart' as di;
import '../../../../core/services/logger_service.dart';
import 'book_reader_page.dart';
import '../../../auth/presentation/pages/public_user_profile_page.dart';
import '../bloc/bookmark_bloc.dart';
import '../widgets/book_review_section.dart';
import '../../../social/presentation/widgets/book_comment_section.dart';
import '../../../social/presentation/widgets/comment_widget.dart';

class BookDetailPage extends StatefulWidget {
  final String bookId;
  final String? title;
  final String? authorName;
  final String? coverImageUrl;

  const BookDetailPage({
    super.key,
    required this.bookId,
    this.title,
    this.authorName,
    this.coverImageUrl,
  });

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  Map<String, dynamic>? bookData;
  List<Map<String, dynamic>> chapters = [];
  bool isLoading = true;

  late final SocialBloc _socialBloc;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _socialBloc = di.sl<SocialBloc>();
    _loadBookDetails();
    _trackBookView();
    // Check like status after a small delay to ensure BlocProvider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLikeStatus();
    });
  }

  void _trackBookView() {
    _socialBloc.add(TrackBookViewRequested(widget.bookId));
  }

  void _checkLikeStatus() {
    _socialBloc.add(CheckBookLikeStatusRequested(widget.bookId));
  }

  void _handleLikePressed() {
    if (_isLiked) {
      _socialBloc.add(UnlikeBookRequested(widget.bookId));
    } else {
      _socialBloc.add(LikeBookRequested(widget.bookId));
    }
  }

  Future<void> _loadBookDetails() async {
    try {
      // Load book details with metadata (includes like and view counts)
      final bookResponse = await Supabase.instance.client
          .from('books_with_metadata')
          .select('*')
          .eq('id', widget.bookId)
          .single();

      // Load chapters
      final chaptersResponse = await Supabase.instance.client
          .from('chapters')
          .select()
          .eq('book_id', widget.bookId)
          .order('chapter_number');

      // Check if current user has liked this book
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      bool isLiked = false;
      if (currentUserId != null) {
        final likeStatus = await Supabase.instance.client
            .from('book_likes')
            .select('id')
            .eq('book_id', widget.bookId)
            .eq('user_id', currentUserId)
            .maybeSingle();
        isLiked = likeStatus != null;
      }

      setState(() {
        bookData = bookResponse;
        chapters = List<Map<String, dynamic>>.from(chaptersResponse);
        _isLiked = isLiked;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading book details: $e')));
    }
  }

  Future<void> _refreshBookData() async {
    try {
      final bookResponse = await Supabase.instance.client
          .from('books_with_metadata')
          .select('*')
          .eq('id', widget.bookId)
          .single();

      setState(() {
        bookData = bookResponse;
      });
    } catch (e) {
      logger.error('BookDetailPage - Error refreshing book data', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (bookData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Book Not Found')),
        body: const Center(child: Text('Book details could not be loaded.')),
      );
    }

    return BlocProvider.value(
      value: _socialBloc,
      child: BlocListener<SocialBloc, SocialState>(
        listener: (context, state) {
          logger.debug('BookDetailPage - SocialBloc state received: $state');
          if (state is BookLikeStatusLoaded) {
            logger.debug(
              'BookDetailPage - Like status loaded: ${state.isLiked} for book: ${state.bookId}',
            );
            if (state.bookId == widget.bookId) {
              setState(() {
                _isLiked = state.isLiked;
              });
            }
          } else if (state is BookLiked) {
            logger.debug('BookDetailPage - Book liked: ${state.bookId}');
            if (state.bookId == widget.bookId) {
              setState(() {
                _isLiked = true;
              });
              _refreshBookData(); // Refresh to get updated counts
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Book liked!')));
            }
          } else if (state is BookUnliked) {
            logger.debug('BookDetailPage - Book unliked: ${state.bookId}');
            if (state.bookId == widget.bookId) {
              setState(() {
                _isLiked = false;
              });
              _refreshBookData(); // Refresh to get updated counts
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Book unliked!')));
            }
          } else if (state is SocialError) {
            logger.error('BookDetailPage - Social error: ${state.message}');
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // App Bar with book cover
                  SliverAppBar(
                    expandedHeight: MediaQuery.of(context).size.height,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: const Text(''),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (bookData!['cover_image_url'] != null &&
                              bookData!['cover_image_url'].isNotEmpty)
                            Image.network(
                              bookData!['cover_image_url'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.3),
                                    child: const Icon(
                                      Icons.book,
                                      size: 64,
                                      color: Colors.white,
                                    ),
                                  ),
                            )
                          else
                            Container(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.3),
                              child: const Icon(
                                Icons.book,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.7),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Book Information
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Author and basic info
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'by ',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Navigate to author's profile if author_id is available
                                  final authorId = bookData!['author_id'];
                                  if (authorId != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PublicUserProfilePage(
                                              userId: authorId,
                                              userName:
                                                  bookData!['author_name'],
                                            ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Author profile not available',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  bookData!['author_name'] ?? 'Anonymous',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Stats
                          Row(
                            children: [
                              _buildStatChip(
                                icon: Icons.remove_red_eye,
                                label: '${bookData!['views_count'] ?? 0} views',
                              ),
                              const SizedBox(width: 8),
                              _buildStatChip(
                                icon: Icons.favorite,
                                label: '${bookData!['likes_count'] ?? 0} likes',
                              ),
                              const SizedBox(width: 8),
                              _buildStatChip(
                                icon: Icons.menu_book,
                                label: '${chapters.length} chapters',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Genres
                          if (bookData!['genres'] != null &&
                              (bookData!['genres'] as List).isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: (bookData!['genres'] as List<dynamic>)
                                  .map(
                                    (genre) => Chip(
                                      label: Text(genre.toString()),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.1),
                                    ),
                                  )
                                  .toList(),
                            ),
                          const SizedBox(height: 16),

                          // Description
                          Text(
                            'Description',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            bookData!['description'] ??
                                'No description available.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 24),

                          // Chapters section
                          Text(
                            'Chapters',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                  // Chapters list
                  if (chapters.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Text('No chapters available yet.'),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final chapter = chapters[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(child: Text('${index + 1}')),
                            title: Text(
                              chapter['title'] ?? 'Chapter ${index + 1}',
                            ),
                            subtitle: Text(
                              '${chapter['word_count'] ?? 0} words',
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              // Navigate to book reader at specific chapter
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BlocProvider<BookmarkBloc>(
                                        create: (_) => di.sl<BookmarkBloc>(),
                                        child: BookReaderPage(
                                          bookId: widget.bookId,
                                          initialChapterId: chapter['id'],
                                          bookTitle:
                                              bookData!['title'] ?? 'Untitled',
                                        ),
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      }, childCount: chapters.length),
                    ),

                  // Review & Comment sections
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  // Review
                  SliverToBoxAdapter(
                    child: BookReviewSection(
                      bookId: widget.bookId,
                      title: bookData!['title'],
                    ),
                  ),
                  // Comment Input (moved below review card)
                  SliverToBoxAdapter(
                    child: BlocProvider<SocialBloc>(
                      create: (_) => di.sl<SocialBloc>(),
                      child: _CommentInputAndSection(
                        bookId: widget.bookId,
                        title: bookData!['title'],
                      ),
                    ),
                  ),
                  // Bottom padding
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],
              ),

              // Like Button (bottom left) - Independent
              Positioned(
                left: 16,
                bottom: 16,
                child: FloatingActionButton.small(
                  heroTag: "like_button",
                  onPressed: _handleLikePressed,
                  backgroundColor: _isLiked
                      ? Colors.red.withAlpha(30)
                      : Colors.white.withValues(alpha: 0.9),
                  child: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.grey,
                    size: 20,
                  ),
                ),
              ),

              // Read Button (bottom right) - Independent
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton.small(
                  heroTag: "read_button",
                  onPressed: () {
                    logger.debug('BookDetailPage - Read button pressed');
                    logger.debug(
                      'BookDetailPage - Chapters count: ${chapters.length}',
                    );
                    if (chapters.isNotEmpty) {
                      logger.debug(
                        'BookDetailPage - Navigating to reader with chapter: ${chapters.first['id']}',
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider<BookmarkBloc>(
                            create: (_) => di.sl<BookmarkBloc>(),
                            child: BookReaderPage(
                              bookId: widget.bookId,
                              initialChapterId: chapters.first['id'],
                              bookTitle: bookData!['title'] ?? 'Untitled',
                            ),
                          ),
                        ),
                      );
                    } else {
                      logger.debug('BookDetailPage - No chapters available');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No chapters available')),
                      );
                    }
                  },
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.9),
                  child: const Icon(Icons.menu_book, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _CommentInputAndSection extends StatefulWidget {
  final String bookId;
  final String? title;
  const _CommentInputAndSection({required this.bookId, this.title});

  @override
  State<_CommentInputAndSection> createState() =>
      _CommentInputAndSectionState();
}

class _CommentInputAndSectionState extends State<_CommentInputAndSection> {
  String? _parentCommentId;

  void _handleSubmit(String content) {
    final bloc = context.read<SocialBloc>();
    bloc.add(
      AddCommentRequested(
        bookId: widget.bookId,
        content: content,
        parentCommentId: _parentCommentId,
      ),
    );
    setState(() {
      _parentCommentId = null;
    });
  }

  void _handleReply(String commentId) {
    setState(() {
      _parentCommentId = commentId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommentInputWidget(
          onSubmit: _handleSubmit,
          parentCommentId: _parentCommentId,
        ),
        SizedBox(
          height: 400,
          child: BookCommentSection(
            bookId: widget.bookId,
            title: widget.title,
            parentCommentId: _parentCommentId,
            onSubmitComment: _handleReply,
          ),
        ),
      ],
    );
  }
}
