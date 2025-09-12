# Supabase Storage Setup untuk PDF Upload

## 1. Buat Bucket `pdf-books`

### Via Supabase Dashboard:
1. Buka [Supabase Dashboard](https://supabase.com/dashboard)
2. Pilih project Anda
3. Buka **Storage** di sidebar kiri
4. Klik **Create a new bucket**
5. Isi form:
   - **Name**: `pdf-books`
   - **Public bucket**: ✅ Checked (agar PDF bisa diakses publik)
   - **File size limit**: `50 MB`
   - **Allowed MIME types**: `application/pdf`

### Via SQL (Alternative):
```sql
-- Buat bucket pdf-books
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('pdf-books', 'pdf-books', true, 52428800, ARRAY['application/pdf']);
```

## 2. Set Storage Policies (SIMPLE VERSION)

### Hapus semua policies yang ada terlebih dahulu:
```sql
-- Hapus semua policies yang ada untuk bucket pdf-books
DELETE FROM storage.policies WHERE bucket_id = 'pdf-books';
```

### Buat policy sederhana untuk semua operasi:
```sql
-- Allow all operations for authenticated users on pdf-books bucket
CREATE POLICY "Allow all operations for authenticated users" ON storage.objects
FOR ALL TO authenticated
USING (bucket_id = 'pdf-books')
WITH CHECK (bucket_id = 'pdf-books');
```

### Atau jika ingin lebih permisif (untuk testing):
```sql
-- Allow all operations for everyone on pdf-books bucket (UNTUK TESTING SAJA)
CREATE POLICY "Allow all operations for everyone" ON storage.objects
FOR ALL TO public
USING (bucket_id = 'pdf-books')
WITH CHECK (bucket_id = 'pdf-books');
```

## 3. Test Setup

### Test Upload:
1. Buka aplikasi Flutter
2. Login dengan user yang valid
3. Buka PDF Upload page
4. Klik "Tap to select PDF file"
5. Klik "Upload PDF Baru"
6. Pilih file PDF
7. Cek console untuk log messages

### Expected Log Messages:
```
Initializing storage...
Bucket pdf-books is accessible
Loading user PDFs...
Found X PDF files in storage
Starting PDF upload process...
User authenticated: [user-id]
Selected file: [filename], size: [size] bytes
Getting file data...
Using file bytes, length: [length]
Uploading to storage path: pdf-books/[user-id]_[timestamp]_[filename]
Upload response: [response]
Reloading PDF list...
Loaded X PDFs successfully
Upload completed successfully
```

## 4. Troubleshooting

### Error: "Bucket not found"
- Pastikan bucket `pdf-books` sudah dibuat
- Cek nama bucket (case sensitive)

### Error: "User not authenticated"
- Pastikan user sudah login
- Cek Supabase auth configuration

### Error: "Upload failed - empty response"
- Cek storage policies
- Pastikan bucket public atau user punya permission

### Error: "File data not found"
- Cek file_picker configuration
- Pastikan file valid dan tidak corrupt

## 5. Storage Structure

```
pdf-books/
├── [user-id]_[timestamp]_document1.pdf
├── [user-id]_[timestamp]_document2.pdf
└── [user-id]_[timestamp]_document3.pdf
```

## 6. Security Considerations

- ✅ File size limit: 50MB
- ✅ MIME type restriction: PDF only
- ✅ User authentication required
- ✅ Users can only delete their own files
- ✅ Public read access for PDF viewing

## 7. Quick Fix untuk Testing

Jika masih ada masalah, coba policy yang sangat permisif ini:

```sql
-- SUPER PERMISSIVE - HANYA UNTUK TESTING
CREATE POLICY "Super permissive for testing" ON storage.objects
FOR ALL TO public
USING (true)
WITH CHECK (true);
```

**⚠️ PERINGATAN: Policy ini sangat tidak aman, hanya gunakan untuk testing!** 