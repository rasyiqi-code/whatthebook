import 'package:flutter/material.dart';
import '../../domain/entities/reading_list.dart';

class ReadingListCard extends StatelessWidget {
  final ReadingList readingList;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ReadingListCard({
    super.key,
    required this.readingList,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      readingList.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                      onPressed: onDelete,
                    ),
                ],
              ),

              if (readingList.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  readingList.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 16),

              // Footer Row
              Row(
                children: [
                  // Privacy Icon
                  Icon(
                    readingList.isPublic ? Icons.public : Icons.lock,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    readingList.isPublic ? 'Public' : 'Private',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const Spacer(),

                  // Book Count
                  Icon(Icons.book, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${readingList.books?.length ?? 0} books',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
