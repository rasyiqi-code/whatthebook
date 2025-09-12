import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../data/datasources/review_remote_data_source.dart';
import '../../../../core/services/logger_service.dart';

class BookReviewSection extends StatefulWidget {
  final String bookId;
  final String? title;

  const BookReviewSection({super.key, required this.bookId, this.title});

  @override
  State<BookReviewSection> createState() => _BookReviewSectionState();
}

class _BookReviewSectionState extends State<BookReviewSection> {
  List<Review> _reviews = [];
  Review? _userReview;
  final TextEditingController _reviewController = TextEditingController();
  late final ReviewRepository _reviewRepository;

  @override
  void initState() {
    super.initState();
    _reviewRepository = ReviewRepositoryImpl(
      remoteDataSource: ReviewRemoteDataSourceImpl(
        client: Supabase.instance.client,
      ),
    );
    _loadReviews();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = await _reviewRepository.getReviewsForBook(widget.bookId);
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      Review? userReview;
      if (currentUserId != null) {
        userReview = await _reviewRepository.getUserReviewForBook(
          widget.bookId,
          currentUserId,
        );
      }

      // Debug: Print review info
      logger.info(
        'Loaded ${reviews.length} reviews for book: ${widget.bookId}',
      );
      logger.debug('Current user: $currentUserId');
      logger.debug(
        'User review: ${userReview?.id} - ${userReview?.reviewText}',
      );

      setState(() {
        _reviews = reviews;
        _userReview = userReview;
      });
    } catch (e) {
      logger.error('Error loading reviews: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading reviews: $e')));
    }
  }

  void _showAddReviewDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int tempRating = 0;
        TextEditingController tempController = TextEditingController();
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Tulis Review'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < tempRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          tempRating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tempController,
                  decoration: const InputDecoration(
                    hintText: 'Tulis review Anda...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: tempRating > 0
                    ? () {
                        _addReviewDialog(
                          tempRating,
                          tempController.text.trim(),
                        );
                        Navigator.pop(context);
                      }
                    : null,
                child: const Text('Kirim'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditReviewDialog() {
    if (_userReview == null) return;
    showDialog(
      context: context,
      builder: (context) {
        int tempRating = _userReview!.rating;
        TextEditingController tempController = TextEditingController(
          text: _userReview!.reviewText,
        );
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Edit Review'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < tempRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          tempRating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tempController,
                  decoration: const InputDecoration(
                    hintText: 'Tulis review Anda...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: tempRating > 0
                    ? () {
                        _editReviewDialog(
                          tempRating,
                          tempController.text.trim(),
                        );
                        Navigator.pop(context);
                      }
                    : null,
                child: const Text('Update'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addReviewDialog(int rating, String reviewText) async {
    try {
      await _reviewRepository.addReview(
        bookId: widget.bookId,
        rating: rating,
        reviewText: reviewText,
      );
      _loadReviews();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review berhasil ditambahkan!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding review: $e')));
    }
  }

  Future<void> _editReviewDialog(int rating, String reviewText) async {
    if (_userReview == null) return;
    try {
      await _reviewRepository.updateReview(
        reviewId: _userReview!.id,
        rating: rating,
        reviewText: reviewText,
      );
      _loadReviews();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review berhasil diupdate!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating review: $e')));
    }
  }

  Future<void> _deleteReview() async {
    if (_userReview == null) return;

    // Debug: Print review info
    logger.debug('Attempting to delete review: ${_userReview!.id}');
    logger.debug(
      'Current user: ${Supabase.instance.client.auth.currentUser?.id}',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Review'),
        content: const Text('Apakah Anda yakin ingin menghapus review ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      logger.debug('Deleting review with ID: ${_userReview!.id}');
      await _reviewRepository.deleteReview(_userReview!.id);
      logger.info('Review deleted successfully');
      _loadReviews();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Review berhasil dihapus!')));
    } catch (e) {
      logger.error('Error in _deleteReview: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting review: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double _getAverageRating() {
    if (_reviews.isEmpty) return 0.0;
    final totalRating = _reviews.fold<int>(
      0,
      (sum, review) => sum + review.rating,
    );
    return totalRating / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 8.0,
            ),
            child: Text(
              'Review untuk ${widget.title}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        // Card review summary
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: theme.colorScheme.surfaceContainerHighest,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Rating summary
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 26),
                        const SizedBox(width: 3),
                        Text(
                          _getAverageRating().toStringAsFixed(1),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < _getAverageRating()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_reviews.length} review',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Divider vertical
                Container(
                  width: 1,
                  height: 38,
                  color: theme.dividerColor.withValues(alpha: 0.2),
                ),
                const SizedBox(width: 16),
                // Action button
                Expanded(
                  child: _userReview == null
                      ? ElevatedButton.icon(
                          onPressed: _showAddReviewDialog,
                          icon: const Icon(
                            Icons.rate_review,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: const Text('Tulis Review'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 10,
                            ),
                            textStyle: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _showEditReviewDialog,
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                label: const Text('Edit Review'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 10,
                                  ),
                                  textStyle: theme.textTheme.labelLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Tooltip(
                              message: 'Hapus Review',
                              child: IconButton(
                                onPressed: _deleteReview,
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                splashRadius: 20,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
