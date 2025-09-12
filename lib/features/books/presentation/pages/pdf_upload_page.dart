import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/cover_media_manager.dart';
import '../widgets/pdf_media_manager.dart';
import '../../../../core/services/logger_service.dart';

class PdfUploadPage extends StatefulWidget {
  const PdfUploadPage({super.key});

  @override
  State<PdfUploadPage> createState() => _PdfUploadPageState();
}

class _PdfUploadPageState extends State<PdfUploadPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _bookAuthorController = TextEditingController();
  final _publicationYearController = TextEditingController();
  final _pagesController = TextEditingController();
  final _isbnController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedCategory = 'Fiksi';
  String _selectedLanguage = 'Indonesian';
  bool _isUploading = false;
  String? _coverImageUrl;

  // File upload variables
  String? _selectedPdfUrl;
  String? _selectedPdfFileName;
  int? _selectedPdfFileSize;
  String? _uploadError;

  final List<String> _categories = [
    'Fiksi',
    'Non-Fiksi',
    'Pendidikan',
    'Teknologi',
    'Sejarah',
    'Biografi',
    'Sains',
    'Agama',
    'Kesehatan',
    'Bisnis',
    'Seni',
    'Lainnya',
  ];

  final List<String> _languages = [
    'Indonesian',
    'English',
    'Arabic',
    'Javanese',
    'Sundanese',
    'Lainnya',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _bookAuthorController.dispose();
    _publicationYearController.dispose();
    _pagesController.dispose();
    _isbnController.dispose();
    super.dispose();
  }

  Future<void> _openPdfManager() async {
    showDialog(
      context: context,
      builder: (context) => PdfMediaManager(
        selectedPdfUrl: _selectedPdfUrl,
        onPdfSelected: (pdfUrl, fileName, fileSize) {
          setState(() {
            _selectedPdfUrl = pdfUrl;
            _selectedPdfFileName = fileName;
            _selectedPdfFileSize = fileSize;
            _uploadError = null;
          });
        },
      ),
    );
  }

  Future<void> _openMediaManager() async {
    showDialog(
      context: context,
      builder: (context) => CoverMediaManager(
        selectedImageUrl: _coverImageUrl,
        onImageSelected: (imageUrl) {
          setState(() {
            _coverImageUrl = imageUrl;
          });
        },
      ),
    );
  }

  Future<void> _savePdfBook() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPdfUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih file PDF terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadError = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Save to database
      final insertPayload = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'author_id': userId,
        'pdf_url': _selectedPdfUrl,
        'file_name': _selectedPdfFileName,
        'file_size': _selectedPdfFileSize,
        'upload_status': 'completed',
        'cover_image_url': _coverImageUrl,
        'book_author': _bookAuthorController.text.trim().isEmpty
            ? null
            : _bookAuthorController.text.trim(),
        'publication_year': _publicationYearController.text.trim().isEmpty
            ? null
            : int.tryParse(_publicationYearController.text.trim()),
        'category': _selectedCategory,
        'language': _selectedLanguage,
        'pages': _pagesController.text.trim().isEmpty
            ? null
            : int.tryParse(_pagesController.text.trim()),
        'isbn': _isbnController.text.trim().isEmpty
            ? null
            : _isbnController.text.trim(),
        // created_at, updated_at: biarkan default
      };
      logger.debug('Insert payload:');
      logger.debug(insertPayload.toString());
      final response = await supabase
          .from('pdf_books')
          .insert(insertPayload)
          .select();
      logger.info('Insert response: $response');
      if (response.isEmpty) {
        throw Exception('Failed to insert PDF book. Response: $response');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF book saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e, st) {
      logger.error('Error inserting PDF book: $e');
      logger.error(st.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save PDF book: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload PDF Book'),
        actions: [
          if (!_isUploading)
            TextButton(
              onPressed: _savePdfBook,
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PDF File Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PDF File',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_selectedPdfUrl != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedPdfFileName ?? 'PDF File',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (_selectedPdfFileSize != null)
                                      Text(
                                        '${(_selectedPdfFileSize! / 1024 / 1024).toStringAsFixed(2)} MB',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _selectedPdfUrl = null;
                                    _selectedPdfFileName = null;
                                    _selectedPdfFileSize = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        InkWell(
                          onTap: _openPdfManager,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.upload_file,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tap to select PDF file',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  'Max 50MB',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (_uploadError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _uploadError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Cover Image
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cover Image',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: GestureDetector(
                          onTap: _openMediaManager,
                          child: Container(
                            width: 120,
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _coverImageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _coverImageUrl!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate,
                                        size: 32,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Add Cover',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Book Details Form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Book Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Title is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          hintText: 'Brief description of the book...',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Author
                      TextFormField(
                        controller: _bookAuthorController,
                        decoration: const InputDecoration(
                          labelText: 'Author',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Category and Language
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                              ),
                              items: _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedLanguage,
                              decoration: const InputDecoration(
                                labelText: 'Language',
                                border: OutlineInputBorder(),
                              ),
                              items: _languages.map((language) {
                                return DropdownMenuItem(
                                  value: language,
                                  child: Text(language),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedLanguage = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Publication Year, Pages, ISBN
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _publicationYearController,
                              decoration: const InputDecoration(
                                labelText: 'Publication Year',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _pagesController,
                              decoration: const InputDecoration(
                                labelText: 'Pages',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ISBN
                      TextFormField(
                        controller: _isbnController,
                        decoration: const InputDecoration(
                          labelText: 'ISBN',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
