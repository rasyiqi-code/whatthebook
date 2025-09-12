import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reading_progress_model.dart';
import 'package:whatthebook/core/services/logger_service.dart';

class ReadingProgressService {
  final SupabaseClient supabase;

  ReadingProgressService({required this.supabase});

  Future<ReadingProgressModel?> getProgress({
    String? bookId,
    String? pdfBookId,
    String? userId,
  }) async {
    final uid = userId ?? supabase.auth.currentUser?.id;
    if (uid == null) return null;
    var query = supabase.from('reading_progress').select().eq('user_id', uid);
    if (bookId != null) {
      query = query.eq('book_id', bookId);
    } else if (pdfBookId != null) {
      query = query.eq('pdf_book_id', pdfBookId);
    } else {
      return null;
    }
    final response = await query
        .order('updated_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (response == null) return null;
    return ReadingProgressModel.fromJson(response);
  }

  Future<ReadingProgressModel?> getProgressForChapter({
    required String bookId,
    required String chapterId,
    String? userId,
  }) async {
    final uid = userId ?? supabase.auth.currentUser?.id;
    if (uid == null) return null;
    final response = await supabase
        .from('reading_progress')
        .select()
        .eq('book_id', bookId)
        .eq('chapter_id', chapterId)
        .eq('user_id', uid)
        .order('updated_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (response == null) return null;
    return ReadingProgressModel.fromJson(response);
  }

  Future<ReadingProgressModel?> getProgressForPdf({
    required String pdfBookId,
    String? userId,
  }) async {
    return getProgress(pdfBookId: pdfBookId, userId: userId);
  }

  Future<void> saveOrUpdateProgress({
    String? bookId,
    String? pdfBookId,
    String? chapterId,
    required double progressPercentage,
    String? userId,
  }) async {
    final uid = userId ?? supabase.auth.currentUser?.id;
    if (uid == null) return;

    final now = DateTime.now().toIso8601String();
    final data = <String, dynamic>{
      'chapter_id': chapterId,
      'progress_percentage': progressPercentage,
      'last_read_at': now,
      'updated_at': now,
      'user_id': uid,
    };

    try {
      if (bookId != null) {
        // For regular books
        data['book_id'] = bookId;
        data['pdf_book_id'] = null; // Explicitly set to null

        logger.debug(
          'Upsert reading_progress for book: data=$data, onConflict=user_id,book_id',
        );
        await supabase
            .from('reading_progress')
            .upsert(data, onConflict: 'user_id,book_id');
      } else if (pdfBookId != null) {
        // For PDF books
        data['pdf_book_id'] = pdfBookId;
        data['book_id'] = null; // Explicitly set to null

        logger.debug(
          'Upsert reading_progress for PDF: data=$data, onConflict=user_id,pdf_book_id',
        );
        await supabase
            .from('reading_progress')
            .upsert(data, onConflict: 'user_id,pdf_book_id');
      } else {
        logger.error('Error: Neither bookId nor pdfBookId provided');
        return;
      }
    } catch (e) {
      logger.error('Error in saveOrUpdateProgress: $e');
      rethrow;
    }
  }
}
