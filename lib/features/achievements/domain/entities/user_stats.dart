class UserStats {
  final int totalWords;
  final int booksPublished;
  final int chaptersPublished;
  final int reviewsWritten;
  final int likesReceived;
  final int readingStreak;
  final List<int>? activityGraph;

  const UserStats({
    required this.totalWords,
    required this.booksPublished,
    required this.chaptersPublished,
    required this.reviewsWritten,
    required this.likesReceived,
    required this.readingStreak,
    this.activityGraph,
  });
}

class UserProductivityPoint {
  final String yearMonth;
  final int totalWords;
  final int booksPublished;
  final int chaptersPublished;
  final int reviewsWritten;
  final int likesReceived;

  UserProductivityPoint({
    required this.yearMonth,
    required this.totalWords,
    required this.booksPublished,
    required this.chaptersPublished,
    required this.reviewsWritten,
    required this.likesReceived,
  });

  factory UserProductivityPoint.fromJson(Map<String, dynamic> json) {
    return UserProductivityPoint(
      yearMonth: json['year_month'] as String,
      totalWords: (json['total_words'] ?? 0) as int,
      booksPublished: (json['books_published'] ?? 0) as int,
      chaptersPublished: (json['chapters_published'] ?? 0) as int,
      reviewsWritten: (json['reviews_written'] ?? 0) as int,
      likesReceived: (json['likes_received'] ?? 0) as int,
    );
  }
}

class UserProductivityTimeSeries {
  final List<UserProductivityPoint> points;
  UserProductivityTimeSeries({required this.points});
}
