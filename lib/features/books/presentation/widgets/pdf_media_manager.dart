import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../../../core/services/logger_service.dart';

class PdfMediaManager extends StatefulWidget {
  final String? selectedPdfUrl;
  final Function(String pdfUrl, String fileName, int fileSize) onPdfSelected;

  const PdfMediaManager({
    super.key,
    this.selectedPdfUrl,
    required this.onPdfSelected,
  });

  @override
  State<PdfMediaManager> createState() => _PdfMediaManagerState();
}

class _PdfMediaManagerState extends State<PdfMediaManager> {
  List<Map<String, dynamic>> _userPdfs = [];
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    try {
      logger.debug('Initializing storage...');
      // Test if bucket exists by trying to list files
      await Supabase.instance.client.storage.from('pdf-books').list();
      logger.info('Bucket pdf-books is accessible');
      await _loadUserPdfs();
    } catch (e) {
      logger.error('Error initializing storage: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accessing storage: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserPdfs() async {
    try {
      logger.debug('Loading user PDFs...');
      setState(() {
        _isLoading = true;
      });

      final List<FileObject> files = await Supabase.instance.client.storage
          .from('pdf-books')
          .list(); // Ambil dari root bucket saja
      logger.info('Found ${files.length} PDF files in storage');

      final List<Map<String, dynamic>> pdfs = [];
      for (var file in files) {
        // Ambil semua file yang mengandung .pdf (di root bucket)
        if (!file.name.toLowerCase().endsWith('.pdf')) continue;
        final url = Supabase.instance.client.storage
            .from('pdf-books')
            .getPublicUrl(file.name);
        final createdRaw = file.createdAt;
        DateTime? created;
        if (createdRaw is String) {
          created = DateTime.tryParse(createdRaw);
        } else if (createdRaw is DateTime) {
          created = createdRaw;
        }
        pdfs.add({
          'name': file.name,
          'url': url,
          'created': created,
          'size': file.metadata?['size'] ?? 0,
        });
        logger.debug(
          'PDF: ${file.name}, URL: $url, Size: ${file.metadata?['size'] ?? 0}, Created: $created',
        );
      }

      // Sort by newest first, null-safe
      pdfs.sort((a, b) {
        final ca = a['created'] as DateTime?;
        final cb = b['created'] as DateTime?;
        if (ca == null && cb == null) return 0;
        if (ca == null) return 1;
        if (cb == null) return -1;
        return cb.compareTo(ca);
      });

      setState(() {
        _userPdfs = pdfs;
        _isLoading = false;
      });
      logger.info('Loaded ${pdfs.length} PDFs successfully');
    } catch (e) {
      logger.error('Error loading PDFs: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading PDFs: $e')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadNewPdf() async {
    try {
      logger.debug('Starting PDF upload process...');

      // Check if user is authenticated
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      logger.debug('User authenticated: ${user.id}');

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        logger.warning('No file selected');
        return;
      }

      final file = result.files.first;
      logger.debug('Selected file: ${file.name}, size: ${file.size} bytes');

      // Validate file size (max 50MB)
      if (file.size > 50 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File terlalu besar. Maksimal 50MB.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isUploading = true;
      });

      logger.debug('Getting file data...');
      // Get file data safely
      dynamic fileData;
      if (file.bytes != null) {
        fileData = file.bytes;
        logger.debug('Using file bytes, length: ${file.bytes!.length}');
      } else if (!kIsWeb && file.path != null) {
        fileData = File(file.path!);
        logger.debug('Using file path: ${file.path}');
      } else {
        throw Exception(
          'File data not found - bytes: ${file.bytes != null}, path: ${file.path != null}',
        );
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${user.id}_${timestamp}_${file.name}';
      final storagePath = fileName; // Simpan di root bucket

      logger.debug('Uploading to storage path: $storagePath');

      try {
        String response;
        if (kIsWeb && fileData is List<int>) {
          // Use uploadBinary for web platform
          logger.debug('Using uploadBinary for web platform');
          final uint8List = Uint8List.fromList(fileData);
          response = await Supabase.instance.client.storage
              .from('pdf-books')
              .uploadBinary(storagePath, uint8List);
        } else {
          // Use regular upload for mobile/desktop
          logger.debug('Using regular upload for mobile/desktop');
          response = await Supabase.instance.client.storage
              .from('pdf-books')
              .upload(storagePath, fileData);
        }

        logger.info('Upload response: $response');

        if (response.isEmpty) {
          throw Exception('Upload failed - empty response');
        }
      } catch (uploadError) {
        logger.error('Upload error details: $uploadError');
        logger.debug('File data type: ${fileData.runtimeType}');
        if (fileData is List<int>) {
          logger.debug(
            'File data is List<int> with length: ${fileData.length}',
          );
        }
        rethrow;
      }

      logger.debug('Reloading PDF list...');
      await _loadUserPdfs();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF berhasil diupload!'),
          backgroundColor: Colors.green,
        ),
      );
      logger.info('Upload completed successfully');
    } catch (e) {
      logger.error('Error during upload: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _deletePdf(String filePath) async {
    try {
      logger.debug('Deleting file: $filePath');
      final response = await Supabase.instance.client.storage
          .from('pdf-books')
          .remove([filePath]);
      logger.info('Delete response: $response');
      await _loadUserPdfs();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF berhasil dihapus!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e, st) {
      logger.error('Error deleting PDF: $e');
      logger.error(st.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PDF Media Manager',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadNewPdf,
              icon: _isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload),
              label: Text(_isUploading ? 'Uploading...' : 'Upload PDF Baru'),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_userPdfs.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Belum ada PDF yang diupload',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _userPdfs.length,
                  itemBuilder: (context, index) {
                    final pdf = _userPdfs[index];
                    final isSelected = widget.selectedPdfUrl == pdf['url'];
                    final fileName = pdf['name']
                        .split('_')
                        .skip(2)
                        .join('_'); // Remove timestamp prefix
                    final fileSize = pdf['size'] as int;
                    final createdDate = pdf['created'] as DateTime;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.picture_as_pdf,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                        ),
                        title: Text(
                          fileName,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? Colors.blue : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Size: ${_formatFileSize(fileSize)}'),
                            Text('Uploaded: ${_formatDate(createdDate)}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.blue,
                                size: 20,
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deletePdf(pdf['name']),
                            ),
                          ],
                        ),
                        onTap: () {
                          widget.onPdfSelected(pdf['url'], fileName, fileSize);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
