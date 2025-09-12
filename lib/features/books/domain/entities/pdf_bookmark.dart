import 'package:equatable/equatable.dart';

class PdfBookmark extends Equatable {
  final String id;
  final String pdfBookId;
  final int page;
  final String? note;
  final String? bookmarkName;
  final DateTime createdAt;
  final String userId;

  const PdfBookmark({
    required this.id,
    required this.pdfBookId,
    required this.page,
    this.note,
    this.bookmarkName,
    required this.createdAt,
    required this.userId,
  });

  @override
  List<Object?> get props => [
    id,
    pdfBookId,
    page,
    note,
    bookmarkName,
    createdAt,
    userId,
  ];
}
