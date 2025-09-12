import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/logger_service.dart';
import '../models/chapter_model.dart';

final logger = LoggerService();

abstract class ChapterRemoteDataSource {
  Future<List<ChapterModel>> getChaptersByBookId(String bookId);
  Future<ChapterModel> getChapterById(String chapterId);
  Future<ChapterModel> createChapter({
    required String bookId,
    required int chapterNumber,
    required String title,
    String? content,
  });
  Future<ChapterModel> updateChapter({
    required String chapterId,
    String? title,
    String? content,
    int? wordCount,
    String? status,
  });
  Future<void> deleteChapter(String chapterId);
  Future<ChapterModel> reorderChapter({
    required String chapterId,
    required int newChapterNumber,
  });
}

class ChapterRemoteDataSourceImpl implements ChapterRemoteDataSource {
  final SupabaseClient client;

  ChapterRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ChapterModel>> getChaptersByBookId(String bookId) async {
    try {
      logger.debug('🔍 Getting chapters for book: $bookId');
      
      final response = await client
          .from('chapters')
          .select()
          .eq('book_id', bookId)
          .order('chapter_number');

      logger.info('✅ Found ${(response as List).length} chapters');
      
      return (response as List)
          .map((chapter) => ChapterModel.fromSupabase(chapter))
          .toList();
    } catch (e) {
      logger.error('❌ Failed to get chapters for book $bookId: $e (Type: ${e.runtimeType})');
      
      if (e is PostgrestException) {
        logger.error('  Code: ${e.code}, Message: ${e.message}, Details: ${e.details}');
        throw ServerFailure('Database error: ${e.message} (Code: ${e.code})');
      }
      
      throw ServerFailure('Failed to get chapters: ${e.toString()}');
    }
  }

  @override
  Future<ChapterModel> getChapterById(String chapterId) async {
    try {
      logger.debug('🔍 Getting chapter by ID: $chapterId');
      
      final response = await client
          .from('chapters')
          .select()
          .eq('id', chapterId)
          .single();

      logger.info('✅ Chapter found: ${response['title']}');
      return ChapterModel.fromSupabase(response);
    } catch (e) {
      logger.error('❌ Failed to get chapter $chapterId: $e (Type: ${e.runtimeType})');
      
      if (e is PostgrestException) {
        logger.error('  Code: ${e.code}, Message: ${e.message}, Details: ${e.details}');
        throw ServerFailure('Database error: ${e.message} (Code: ${e.code})');
      }
      
      throw ServerFailure('Failed to get chapter: ${e.toString()}');
    }
  }

  @override
  Future<ChapterModel> createChapter({
    required String bookId,
    required int chapterNumber,
    required String title,
    String? content,
  }) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        logger.error('❌ Chapter Creation Error: User not authenticated');
        throw const ServerFailure('User not authenticated');
      }

      logger.debug('🔍 Creating chapter: Book ID: $bookId, Chapter Number: $chapterNumber, Title: $title, User ID: $userId');

      final insertData = {
        'book_id': bookId,
        'chapter_number': chapterNumber,
        'title': title,
        'content': content ?? '',
        'word_count': 0,
        'status': 'draft',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      logger.debug('📤 Sending data to Supabase: $insertData');

      final response = await client.from('chapters').insert(insertData).select().single();

      logger.info('✅ Chapter created successfully: ${response['id']}');
      return ChapterModel.fromSupabase(response);
    } catch (e) {
      logger.error('❌ Chapter creation failed: $e (Type: ${e.runtimeType})');
      
      if (e is PostgrestException) {
        logger.error('  Code: ${e.code}, Message: ${e.message}, Details: ${e.details}, Hint: ${e.hint}');
        throw ServerFailure('Database error: ${e.message} (Code: ${e.code})');
      }
      
      throw ServerFailure('Chapter creation failed: ${e.toString()}');
    }
  }

  @override
  Future<ChapterModel> updateChapter({
    required String chapterId,
    String? title,
    String? content,
    int? wordCount,
    String? status,
  }) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        logger.error('❌ Chapter Update Error: User not authenticated');
        throw const ServerFailure('User not authenticated');
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (title != null) updateData['title'] = title;
      if (content != null) updateData['content'] = content;
      if (wordCount != null) updateData['word_count'] = wordCount;
      if (status != null) updateData['status'] = status;

      logger.debug('🔍 Updating chapter: $chapterId, Update data: $updateData');

      final response = await client
          .from('chapters')
          .update(updateData)
          .eq('id', chapterId)
          .select()
          .single();

      logger.info('✅ Chapter updated successfully');
      return ChapterModel.fromSupabase(response);
    } catch (e) {
      logger.error('❌ Chapter update failed: Chapter ID: $chapterId, Error: $e (Type: ${e.runtimeType})');
      
      if (e is PostgrestException) {
        logger.error('  Code: ${e.code}, Message: ${e.message}, Details: ${e.details}');
        throw ServerFailure('Database error: ${e.message} (Code: ${e.code})');
      }
      
      throw ServerFailure('Chapter update failed: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteChapter(String chapterId) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        logger.error('❌ Chapter Delete Error: User not authenticated');
        throw const ServerFailure('User not authenticated');
      }

      logger.debug('🔍 Deleting chapter: $chapterId');
      await client.from('chapters').delete().eq('id', chapterId);
      logger.info('✅ Chapter deleted successfully');
    } catch (e) {
      logger.error('❌ Chapter delete failed: Chapter ID: $chapterId, Error: $e (Type: ${e.runtimeType})');
      
      if (e is PostgrestException) {
        logger.error('  Code: ${e.code}, Message: ${e.message}, Details: ${e.details}');
        throw ServerFailure('Database error: ${e.message} (Code: ${e.code})');
      }
      
      throw ServerFailure('Chapter delete failed: ${e.toString()}');
    }
  }

  @override
  Future<ChapterModel> reorderChapter({
    required String chapterId,
    required int newChapterNumber,
  }) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) throw const ServerFailure('User not authenticated');

      final response = await client
          .from('chapters')
          .update({
            'chapter_number': newChapterNumber,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', chapterId)
          .select()
          .single();

      return ChapterModel.fromSupabase(response);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
