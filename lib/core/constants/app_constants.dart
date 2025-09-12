class AppConstants {
  // App Info
  static const String appName = 'Alhuda Library';
  static const String appVersion = '1.0.0';

  // Database
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String offlineBooksKey = 'offline_books';
  static const String readingProgressKey = 'reading_progress';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxChapterLength = 10000;

  // Routes
  static const String homeRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String bookDetailRoute = '/book-detail';
  static const String chapterRoute = '/chapter';
  static const String writeBookRoute = '/write-book';
  static const String writeChapterRoute = '/write-chapter';
}
