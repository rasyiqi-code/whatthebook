import 'package:equatable/equatable.dart';

class PdfBook extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String authorId;
  final String pdfUrl; // Direct URL to PDF file in Supabase Storage
  final DateTime createdAt;
  final DateTime updatedAt;

  // File upload tracking
  final int? fileSize;
  final String? fileName;
  final String uploadStatus;
  final String? storagePath;

  // Additional metadata
  final String? bookAuthor;
  final int? publicationYear;
  final String? category;
  final String? language;
  final int? pages;
  final String? isbn;
  final String? coverImageUrl;

  const PdfBook({
    required this.id,
    required this.title,
    required this.authorId,
    required this.pdfUrl,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.fileSize,
    this.fileName,
    this.uploadStatus = 'completed',
    this.storagePath,
    this.bookAuthor,
    this.publicationYear,
    this.category,
    this.language,
    this.pages,
    this.isbn,
    this.coverImageUrl,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    authorId,
    pdfUrl,
    createdAt,
    updatedAt,
    fileSize,
    fileName,
    uploadStatus,
    storagePath,
    bookAuthor,
    publicationYear,
    category,
    language,
    pages,
    isbn,
    coverImageUrl,
  ];
}
