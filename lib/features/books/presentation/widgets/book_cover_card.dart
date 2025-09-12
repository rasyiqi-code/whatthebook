import 'package:flutter/material.dart';

class BookCoverCard extends StatelessWidget {
  final String coverImageUrl;
  final VoidCallback onTap;

  const BookCoverCard({
    super.key,
    required this.coverImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 0.75,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: coverImageUrl.isNotEmpty
              ? Image.network(
                  coverImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.book, size: 32, color: Colors.grey[600]),
                  ),
                )
              : Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.book, size: 32, color: Colors.grey[600]),
                ),
        ),
      ),
    );
  }
}
