import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core
import '../network/network_info.dart';
import '../services/logger_service.dart';
import '../services/profile_image_service.dart';

// Auth Feature
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/services/role_service.dart';
import '../../features/auth/presentation/bloc/profile_bloc.dart';

// Books Feature
import '../../features/books/data/datasources/book_local_data_source.dart';
import '../../features/books/data/datasources/book_remote_data_source.dart';
import '../../features/books/data/datasources/library_remote_data_source.dart';
import '../../features/books/data/repositories/book_repository_impl.dart';
import '../../features/books/data/repositories/library_repository_impl.dart';
import '../../features/books/domain/repositories/book_repository.dart';
import '../../features/books/domain/repositories/library_repository.dart';
import '../../features/books/domain/usecases/get_books.dart';
import '../../features/books/domain/usecases/create_book.dart';
import '../../features/books/domain/usecases/get_book_detail.dart';
import '../../features/books/domain/usecases/update_book.dart';
import '../../features/books/domain/usecases/delete_book.dart';
import '../../features/books/domain/usecases/get_my_books.dart';
import '../../features/books/domain/usecases/search_books.dart';
import '../../features/books/domain/usecases/get_user_library_books.dart';
import '../../features/books/domain/usecases/get_chapters_by_book_id.dart';
import '../../features/books/domain/usecases/create_chapter.dart';
import '../../features/books/domain/usecases/update_chapter.dart';
import '../../features/books/domain/usecases/delete_chapter.dart';
import '../../features/books/presentation/bloc/book_bloc.dart';
import '../../features/books/presentation/bloc/library_bloc.dart';
import '../../features/books/presentation/bloc/chapter_bloc.dart';
import '../../features/books/domain/repositories/chapter_repository.dart';
import '../../features/books/data/repositories/chapter_repository_impl.dart';
import '../../features/books/data/datasources/chapter_remote_data_source.dart';

// Bookmark Feature
import '../../features/books/data/datasources/bookmark_remote_data_source.dart';
import '../../features/books/data/repositories/bookmark_repository_impl.dart';
import '../../features/books/domain/repositories/bookmark_repository.dart';
import '../../features/books/domain/usecases/add_bookmark.dart';
import '../../features/books/domain/usecases/get_bookmarks_by_book_id.dart';
import '../../features/books/domain/usecases/delete_bookmark.dart';
import '../../features/books/domain/usecases/update_bookmark.dart';
import '../../features/books/domain/usecases/get_all_bookmarks.dart';
import '../../features/books/presentation/bloc/bookmark_bloc.dart';

// Social Feature
import '../../features/social/data/datasources/social_remote_data_source.dart';
import '../../features/social/data/repositories/social_repository_impl.dart';
import '../../features/social/domain/repositories/social_repository.dart';
import '../../features/social/domain/usecases/create_reading_list.dart';
import '../../features/social/domain/usecases/update_reading_list.dart';
import '../../features/social/domain/usecases/delete_reading_list.dart';
import '../../features/social/domain/usecases/get_user_reading_lists.dart';
import '../../features/social/domain/usecases/like_book.dart';
import '../../features/social/domain/usecases/unlike_book.dart';
import '../../features/social/domain/usecases/check_book_like_status.dart';
import '../../features/social/domain/usecases/track_book_view.dart';
import '../../features/social/domain/usecases/get_book_comments.dart';
import '../../features/social/domain/usecases/get_chapter_comments.dart';
import '../../features/social/domain/usecases/add_comment.dart';
import '../../features/social/domain/usecases/update_comment.dart';
import '../../features/social/domain/usecases/delete_comment.dart';
import '../../features/social/presentation/bloc/social_bloc.dart';

// PDF Bookmark Feature
import '../../features/books/data/datasources/pdf_bookmark_remote_data_source.dart';
import '../../features/books/data/repositories/pdf_bookmark_repository_impl.dart';
import '../../features/books/domain/repositories/pdf_bookmark_repository.dart';
import '../../features/books/domain/usecases/get_pdf_bookmarks_by_pdf_id.dart';
import '../../features/books/domain/usecases/add_pdf_bookmark.dart';
import '../../features/books/domain/usecases/delete_pdf_bookmark.dart';
import '../../features/books/domain/usecases/update_pdf_bookmark.dart';
import '../../features/books/presentation/bloc/pdf_bookmark_bloc.dart';

// Unified Bookmark Feature
import '../../features/books/data/datasources/unified_bookmark_remote_data_source.dart';
import '../../features/books/data/repositories/unified_bookmark_repository_impl.dart';
import '../../features/books/domain/repositories/unified_bookmark_repository.dart';
import '../../features/books/domain/usecases/get_all_unified_bookmarks.dart';
import '../../features/books/presentation/bloc/unified_bookmark_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(() => ProfileBloc(authRepository: sl()));

  // Services
  sl.registerLazySingleton<RoleService>(() => RoleService(client: sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );

  //! Features - Books
  // Bloc
  sl.registerFactory(
    () => BookBloc(
      getBooks: sl(),
      getBookDetail: sl(),
      createBook: sl(),
      updateBook: sl(),
      deleteBook: sl(),
      getMyBooks: sl(),
      searchBooks: sl(),
    ),
  );

  // Chapter Bloc
  sl.registerFactory(
    () => ChapterBloc(
      getChaptersByBookId: sl(),
      createChapter: sl(),
      updateChapter: sl(),
      deleteChapter: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetBooks(sl()));
  sl.registerLazySingleton(() => CreateBook(sl()));
  sl.registerLazySingleton(() => GetBookDetail(sl()));
  sl.registerLazySingleton(() => UpdateBook(sl()));
  sl.registerLazySingleton(() => DeleteBook(sl()));
  sl.registerLazySingleton(() => GetMyBooks(sl()));
  sl.registerLazySingleton(() => SearchBooks(sl()));

  // Chapter use cases
  sl.registerLazySingleton(() => GetChaptersByBookId(sl()));
  sl.registerLazySingleton(() => CreateChapter(sl()));
  sl.registerLazySingleton(() => UpdateChapter(sl()));
  sl.registerLazySingleton(() => DeleteChapter(sl()));

  // Repository
  sl.registerLazySingleton<BookRepository>(
    () => BookRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Chapter Repository
  sl.registerLazySingleton<ChapterRepository>(
    () => ChapterRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<BookRemoteDataSource>(
    () => BookRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<BookLocalDataSource>(
    () => BookLocalDataSourceImpl(),
  );

  // Chapter Data sources
  sl.registerLazySingleton<ChapterRemoteDataSource>(
    () => ChapterRemoteDataSourceImpl(client: sl()),
  );

  //! Features - Bookmark
  // Bloc
  sl.registerFactory(
    () => BookmarkBloc(
      getBookmarksByBookId: sl(),
      addBookmark: sl(),
      deleteBookmark: sl(),
      updateBookmark: sl(),
      getAllBookmarks: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetBookmarksByBookId(sl()));
  sl.registerLazySingleton(() => AddBookmark(sl()));
  sl.registerLazySingleton(() => DeleteBookmark(sl()));
  sl.registerLazySingleton(() => UpdateBookmark(sl()));
  sl.registerLazySingleton(() => GetAllBookmarks(sl()));

  // Repository
  sl.registerLazySingleton<BookmarkRepository>(
    () => BookmarkRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<BookmarkRemoteDataSource>(
    () => BookmarkRemoteDataSourceImpl(client: sl()),
  );

  //! Features - Library
  // Bloc
  sl.registerFactory(() => LibraryBloc(getUserLibraryBooks: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetUserLibraryBooks(sl()));

  // Repository
  sl.registerLazySingleton<LibraryRepository>(
    () => LibraryRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<LibraryRemoteDataSource>(
    () => LibraryRemoteDataSourceImpl(supabase: sl()),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // Logger Service
  sl.registerLazySingleton<LoggerService>(() => LoggerService());

  // Profile Image Service
  sl.registerLazySingleton<ProfileImageService>(() => ProfileImageService());

  //! Features - Social
  // Bloc
  sl.registerFactory(
    () => SocialBloc(
      createReadingList: sl(),
      updateReadingList: sl(),
      deleteReadingList: sl(),
      getUserReadingLists: sl(),
      likeBook: sl(),
      unlikeBook: sl(),
      checkBookLikeStatus: sl(),
      trackBookView: sl(),
      getBookComments: sl(),
      getChapterComments: sl(),
      addComment: sl(),
      updateComment: sl(),
      deleteComment: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => CreateReadingList(sl()));
  sl.registerLazySingleton(() => UpdateReadingList(sl()));
  sl.registerLazySingleton(() => DeleteReadingList(sl()));
  sl.registerLazySingleton(() => GetUserReadingLists(sl()));
  sl.registerLazySingleton(() => LikeBook(sl()));
  sl.registerLazySingleton(() => UnlikeBook(sl()));
  sl.registerLazySingleton(() => CheckBookLikeStatus(sl()));
  sl.registerLazySingleton(() => TrackBookView(sl()));
  sl.registerLazySingleton(() => GetBookComments(sl()));
  sl.registerLazySingleton(() => GetChapterComments(sl()));
  sl.registerLazySingleton(() => AddComment(sl()));
  sl.registerLazySingleton(() => UpdateComment(sl()));
  sl.registerLazySingleton(() => DeleteComment(sl()));

  // Repository
  sl.registerLazySingleton<SocialRepository>(
    () => SocialRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<SocialRemoteDataSource>(
    () => SocialRemoteDataSourceImpl(client: sl()),
  );

  //! Features - PDF Bookmark
  // Bloc
  sl.registerFactory(
    () => PdfBookmarkBloc(
      getBookmarksByPdfId: sl(),
      addBookmark: sl(),
      deleteBookmark: sl(),
      updateBookmark: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPdfBookmarksByPdfId(sl()));
  sl.registerLazySingleton(() => AddPdfBookmark(sl()));
  sl.registerLazySingleton(() => DeletePdfBookmark(sl()));
  sl.registerLazySingleton(() => UpdatePdfBookmark(sl()));

  // Repository
  sl.registerLazySingleton<PdfBookmarkRepository>(
    () => PdfBookmarkRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<PdfBookmarkRemoteDataSource>(
    () => PdfBookmarkRemoteDataSourceImpl(sl()),
  );

  //! Features - Unified Bookmark
  // Bloc
  sl.registerFactory(
    () => UnifiedBookmarkBloc(
      getAllUnifiedBookmarks: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllUnifiedBookmarks(sl()));

  // Repository
  sl.registerLazySingleton<UnifiedBookmarkRepository>(
    () => UnifiedBookmarkRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<UnifiedBookmarkRemoteDataSource>(
    () => UnifiedBookmarkRemoteDataSourceImpl(client: sl()),
  );

  //! External
  sl.registerLazySingleton(() => Supabase.instance.client);
}
