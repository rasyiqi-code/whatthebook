import '../../domain/entities/pdf_book.dart';

class PdfBookModel extends PdfBook {
  const PdfBookModel({
    required super.id,
    required super.title,
    required super.authorId,
    required super.pdfUrl,
    super.description,
    required super.createdAt,
    required super.updatedAt,
    super.fileSize,
    super.fileName,
    super.uploadStatus,
    super.bookAuthor,
    super.publicationYear,
    super.category,
    super.language,
    super.pages,
    super.isbn,
    super.coverImageUrl,
  });

  factory PdfBookModel.fromSupabase(Map<String, dynamic> map) {
    return PdfBookModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      authorId: map['author_id'] as String,
      pdfUrl: map['pdf_url'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      fileSize: map['file_size'] as int?,
      fileName: map['file_name'] as String?,
      uploadStatus: map['upload_status'] as String? ?? 'completed',
      bookAuthor: map['book_author'] as String?,
      publicationYear: map['publication_year'] as int?,
      category: map['category'] as String?,
      language: map['language'] as String?,
      pages: map['pages'] as int?,
      isbn: map['isbn'] as String?,
      coverImageUrl: map['cover_image_url'] as String?,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'author_id': authorId,
      'pdf_url': pdfUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'file_size': fileSize,
      'file_name': fileName,
      'upload_status': uploadStatus,
      'book_author': bookAuthor,
      'publication_year': publicationYear,
      'category': category,
      'language': language,
      'pages': pages,
      'isbn': isbn,
      'cover_image_url': coverImageUrl,
    };
  }

  factory PdfBookModel.fromEntity(PdfBook pdfBook) {
    return PdfBookModel(
      id: pdfBook.id,
      title: pdfBook.title,
      description: pdfBook.description,
      authorId: pdfBook.authorId,
      pdfUrl: pdfBook.pdfUrl,
      createdAt: pdfBook.createdAt,
      updatedAt: pdfBook.updatedAt,
      fileSize: pdfBook.fileSize,
      fileName: pdfBook.fileName,
      uploadStatus: pdfBook.uploadStatus,
      bookAuthor: pdfBook.bookAuthor,
      publicationYear: pdfBook.publicationYear,
      category: pdfBook.category,
      language: pdfBook.language,
      pages: pdfBook.pages,
      isbn: pdfBook.isbn,
      coverImageUrl: pdfBook.coverImageUrl,
    );
  }

  PdfBook toEntity() {
    return PdfBook(
      id: id,
      title: title,
      description: description,
      authorId: authorId,
      pdfUrl: pdfUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      fileSize: fileSize,
      fileName: fileName,
      uploadStatus: uploadStatus,
      bookAuthor: bookAuthor,
      publicationYear: publicationYear,
      category: category,
      language: language,
      pages: pages,
      isbn: isbn,
      coverImageUrl: coverImageUrl,
    );
  }
}
