class AuthorLeaderboardEntry {
  final String userId;
  final String name;
  final String avatarUrl;
  final double avgRating;
  final int reviewCount;
  final int bookCount;

  const AuthorLeaderboardEntry({
    required this.userId,
    required this.name,
    required this.avatarUrl,
    required this.avgRating,
    required this.reviewCount,
    required this.bookCount,
  });
}
