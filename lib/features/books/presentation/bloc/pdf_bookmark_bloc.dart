import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_pdf_bookmarks_by_pdf_id.dart';
import '../../domain/usecases/add_pdf_bookmark.dart';
import '../../domain/usecases/delete_pdf_bookmark.dart';
import '../../domain/usecases/update_pdf_bookmark.dart';
import 'pdf_bookmark_event.dart';
import 'pdf_bookmark_state.dart';

class PdfBookmarkBloc extends Bloc<PdfBookmarkEvent, PdfBookmarkState> {
  final GetPdfBookmarksByPdfId getBookmarksByPdfId;
  final AddPdfBookmark addBookmark;
  final DeletePdfBookmark deleteBookmark;
  final UpdatePdfBookmark updateBookmark;

  PdfBookmarkBloc({
    required this.getBookmarksByPdfId,
    required this.addBookmark,
    required this.deleteBookmark,
    required this.updateBookmark,
  }) : super(PdfBookmarkInitial()) {
    on<GetPdfBookmarksByPdfIdEvent>(_onGetBookmarksByPdfId);
    on<AddPdfBookmarkEvent>(_onAddBookmark);
    on<DeletePdfBookmarkEvent>(_onDeleteBookmark);
    on<UpdatePdfBookmarkEvent>(_onUpdateBookmark);
  }

  Future<void> _onGetBookmarksByPdfId(
    GetPdfBookmarksByPdfIdEvent event,
    Emitter<PdfBookmarkState> emit,
  ) async {
    emit(PdfBookmarkLoading());
    try {
      final bookmarks = await getBookmarksByPdfId(event.pdfBookId);
      emit(PdfBookmarksLoaded(bookmarks));
    } catch (e) {
      emit(PdfBookmarkError(e.toString()));
    }
  }

  Future<void> _onAddBookmark(
    AddPdfBookmarkEvent event,
    Emitter<PdfBookmarkState> emit,
  ) async {
    emit(PdfBookmarkLoading());
    try {
      final bookmark = await addBookmark(
        pdfBookId: event.pdfBookId,
        page: event.page,
        note: event.note,
        bookmarkName: event.bookmarkName,
        userId: event.userId,
      );
      emit(PdfBookmarkAdded(bookmark));
    } catch (e) {
      emit(PdfBookmarkError(e.toString()));
    }
  }

  Future<void> _onDeleteBookmark(
    DeletePdfBookmarkEvent event,
    Emitter<PdfBookmarkState> emit,
  ) async {
    emit(PdfBookmarkLoading());
    try {
      await deleteBookmark(event.id);
      emit(PdfBookmarkDeleted(event.id));
    } catch (e) {
      emit(PdfBookmarkError(e.toString()));
    }
  }

  Future<void> _onUpdateBookmark(
    UpdatePdfBookmarkEvent event,
    Emitter<PdfBookmarkState> emit,
  ) async {
    emit(PdfBookmarkLoading());
    try {
      final bookmark = await updateBookmark(
        id: event.id,
        note: event.note,
        bookmarkName: event.bookmarkName,
      );
      emit(PdfBookmarkUpdated(bookmark));
    } catch (e) {
      emit(PdfBookmarkError(e.toString()));
    }
  }
}
