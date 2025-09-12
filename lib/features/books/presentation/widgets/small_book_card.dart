import 'package:flutter/material.dart';

class SmallBookCard extends StatelessWidget {
  final String title;
  final String authorName;
  final String coverImageUrl;
  final int views;
  final int likes;
  final VoidCallback onTap;

  const SmallBookCard({
    super.key,
    required this.title,
    required this.authorName,
    required this.coverImageUrl,
    required this.views,
    required this.likes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120, // Fixed width same as LibraryBookCard
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Cover
            AspectRatio(
              aspectRatio: 0.7,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: coverImageUrl.isNotEmpty
                    ? Image.network(
                        coverImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.book,
                            size: 32,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.book,
                          size: 32,
                          color: Colors.grey[600],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
