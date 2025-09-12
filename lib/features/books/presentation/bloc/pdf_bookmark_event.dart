import 'package:equatable/equatable.dart';

abstract class PdfBookmarkEvent extends Equatable {
  const PdfBookmarkEvent();
  @override
  List<Object?> get props => [];
}

class GetPdfBookmarksByPdfIdEvent extends PdfBookmarkEvent {
  final String pdfBookId;
  const GetPdfBookmarksByPdfIdEvent(this.pdfBookId);
  @override
  List<Object?> get props => [pdfBookId];
}

class AddPdfBookmarkEvent extends PdfBookmarkEvent {
  final String pdfBookId;
  final int page;
  final String? note;
  final String? bookmarkName;
  final String userId;
  const AddPdfBookmarkEvent({
    required this.pdfBookId,
    required this.page,
    this.note,
    this.bookmarkName,
    required this.userId,
  });
  @override
  List<Object?> get props => [pdfBookId, page, note, bookmarkName, userId];
}

class DeletePdfBookmarkEvent extends PdfBookmarkEvent {
  final String id;
  const DeletePdfBookmarkEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class UpdatePdfBookmarkEvent extends PdfBookmarkEvent {
  final String id;
  final String? note;
  final String? bookmarkName;
  const UpdatePdfBookmarkEvent({
    required this.id,
    this.note,
    this.bookmarkName,
  });
  @override
  List<Object?> get props => [id, note, bookmarkName];
} 