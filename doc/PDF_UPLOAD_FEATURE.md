# PDF Books Feature Documentation

## Overview
Fitur PDF Books memungkinkan pengguna untuk menambahkan buku dalam format PDF dari berbagai sumber online (Google Drive, Internet Archive, dll) dan membacanya menggunakan embedded PDF viewer. Fitur ini menggunakan pendekatan "URL embed" untuk menghemat storage dan memberikan pengalaman reading yang optimal.

## Architecture

### 1. **Storage Strategy**
- **External Storage**: PDF disimpan di layanan eksternal (Google Drive, Internet Archive, dll)
- **URL Reference**: Hanya menyimpan URL ke PDF di database
- **Embed URL**: Menggunakan PDF.js viewer untuk menampilkan PDF
- **Zero Local Storage**: Tidak ada file PDF yang disimpan di device atau server

### 2. **Database Schema**
```sql
CREATE TABLE pdf_books (
    id UUID PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    author_id UUID REFERENCES auth.users(id),
    pdf_url TEXT NOT NULL,
    embed_url TEXT NOT NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

### 3. **File Structure**
```
lib/features/books/
├── domain/entities/pdf_book.dart
├── data/
│   ├── models/pdf_book_model.dart
│   ├── datasources/pdf_book_remote_data_source.dart
│   └── repositories/pdf_book_repository_impl.dart
├── domain/repositories/pdf_book_repository.dart
└── presentation/pages/
    ├── pdf_upload_page.dart
    ├── pdf_viewer_page.dart
    └── pdf_books_page.dart
```

## Features

### 1. **PDF Upload**
- **File Picker**: Memilih file PDF dari device
- **Validation**: Hanya file PDF yang diizinkan
- **Upload Progress**: Loading indicator saat upload
- **Metadata**: Input title dan description
- **Auto URL Generation**: Generate embed URL otomatis

### 2. **PDF Viewer**
- **Embedded Viewer**: Menggunakan PDF.js untuk viewing
- **Cross Platform**: Works di web, mobile, desktop
- **Navigation**: Built-in PDF navigation controls
- **Responsive**: Adaptive dengan ukuran screen

### 3. **PDF Library**
- **List View**: Menampilkan semua PDF books
- **Card Layout**: Konsisten dengan book cards lainnya
- **Author Info**: Menampilkan informasi author
- **Date Info**: Relative time (e.g., "2h ago")

### 4. **Integration**
- **Bottom Navigation**: Tab "PDF Books" di main navigation
- **Upload Button**: Floating action button di MyBooksPage
- **Consistent UI**: Mengikuti design system yang ada

## Usage

### 1. **Upload PDF**
```dart
// Navigate to upload page
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const PdfUploadPage(),
  ),
);
```

### 2. **View PDF**
```dart
// Navigate to PDF viewer
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PdfViewerPage(
      title: pdfBook.title,
      embedUrl: pdfBook.embedUrl,
      description: pdfBook.description,
    ),
  ),
);
```

### 3. **List PDF Books**
```dart
// PDF books are automatically loaded in PdfBooksPage
// Accessible via bottom navigation tab
```

## Security

### 1. **Row Level Security (RLS)**
- Users can only upload/edit/delete their own PDFs
- All users can view published PDFs
- Proper authentication checks

### 2. **Storage Policies**
- Authenticated users can upload to `pdf-books` bucket
- Public read access for viewing
- Users can only delete their own files

### 3. **File Validation**
- Only PDF files allowed
- File size limits (configurable)
- Proper error handling

## Benefits

### 1. **Storage Efficiency**
- ✅ **Zero local storage** - PDFs stored in cloud
- ✅ **Streaming content** - No need to download entire file
- ✅ **Cost effective** - Pay only for cloud storage
- ✅ **Scalable** - No device storage limitations

### 2. **User Experience**
- ✅ **Fast loading** - Progressive loading
- ✅ **Cross-platform** - Works everywhere
- ✅ **Native feel** - Embedded viewer
- ✅ **Offline capable** - With proper caching

### 3. **Developer Experience**
- ✅ **Simple implementation** - Minimal code required
- ✅ **Easy maintenance** - Standard web technologies
- ✅ **Flexible** - Easy to extend and customize

## Future Enhancements

### 1. **Advanced Features**
- [ ] PDF text extraction for search
- [ ] Bookmarks and annotations
- [ ] Reading progress tracking
- [ ] Offline reading capability

### 2. **Performance Optimizations**
- [ ] PDF compression before upload
- [ ] Lazy loading for large PDFs
- [ ] Caching strategies
- [ ] CDN integration

### 3. **User Features**
- [ ] PDF categories and tags
- [ ] Rating and reviews
- [ ] Download for offline reading
- [ ] Share PDF links

## Setup Instructions

### 1. **Database Setup**
```bash
# Run the SQL script in Supabase
psql -f scripts/create_pdf_books_table.sql
```

### 2. **Storage Setup**
- Bucket `pdf-books` will be created automatically
- Ensure proper policies are applied
- Configure file size limits if needed

### 3. **Dependencies**
```yaml
dependencies:
  file_picker: ^10.2.0
  flutter_pdfview: ^1.3.2
  webview_flutter: ^4.4.2
```

### 4. **Permissions**
- Add file access permissions for mobile platforms
- Configure web permissions for file upload

## Testing

### 1. **Upload Flow**
- Test file picker functionality
- Verify upload progress and error handling
- Check metadata validation

### 2. **Viewing Flow**
- Test PDF rendering in different devices
- Verify navigation controls
- Check error handling for invalid URLs

### 3. **Integration**
- Test navigation between pages
- Verify data consistency
- Check permission handling

## Troubleshooting

### Common Issues:
1. **PDF not loading**: Check embed URL format
2. **Upload fails**: Verify storage permissions
3. **Viewer not working**: Check webview configuration
4. **File picker issues**: Verify platform permissions

### Debug Tips:
- Check browser console for PDF.js errors
- Verify Supabase storage policies
- Test with different PDF file sizes
- Check network connectivity
