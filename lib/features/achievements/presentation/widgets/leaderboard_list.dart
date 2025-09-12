import 'package:flutter/material.dart';
import '../../domain/entities/author_leaderboard_entry.dart';

class LeaderboardList extends StatelessWidget {
  final List<AuthorLeaderboardEntry> entries;
  final String currentUserId;
  final VoidCallback? onRetry;
  const LeaderboardList({
    super.key,
    required this.entries,
    required this.currentUserId,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(child: Text('Belum ada data leaderboard'));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final e = entries[i];
        final isCurrentUser = e.userId == currentUserId;
        final isTop3 = i < 3;
        return Card(
          color: isCurrentUser ? Colors.blue[50] : null,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isTop3 ? Colors.amber : Colors.grey[300],
              child: Text(
                '${i + 1}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Row(
              children: [
                Text(
                  '@${e.name}',
                  style: TextStyle(
                    fontWeight: isCurrentUser
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                if (isCurrentUser)
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'You',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              '⭐ ${e.avgRating.toStringAsFixed(2)}  |  ${e.reviewCount} review, ${e.bookCount} buku',
            ),
            trailing: isTop3
                ? Icon(Icons.emoji_events, color: Colors.amber)
                : null,
          ),
        );
      },
    );
  }
}
