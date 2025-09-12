import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/cover_media_manager.dart';

class PdfEditPage extends StatefulWidget {
  final String bookId;
  final Map<String, dynamic> bookData;

  const PdfEditPage({
    super.key,
    required this.bookId,
    required this.bookData,
  });

  @override
  State<PdfEditPage> createState() => _PdfEditPageState();
}

class _PdfEditPageState extends State<PdfEditPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pdfUrlController = TextEditingController();
  final _bookAuthorController = TextEditingController();
  final _publicationYearController = TextEditingController();
  final _pagesController = TextEditingController();
  final _isbnController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  String _selectedCategory = 'Fiksi';
  String _selectedLanguage = 'Indonesian';
  bool _isLoading = false;
  String? _coverImageUrl;

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
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // Initialize controllers with existing data
    _titleController.text = widget.bookData['title'] ?? '';
    _descriptionController.text = widget.bookData['description'] ?? '';
    _pdfUrlController.text = widget.bookData['pdf_url'] ?? '';
    _bookAuthorController.text = widget.bookData['book_author'] ?? '';
    _publicationYearController.text = widget.bookData['publication_year']?.toString() ?? '';
    _pagesController.text = widget.bookData['pages']?.toString() ?? '';
    _isbnController.text = widget.bookData['isbn'] ?? '';
    
    // Initialize dropdowns and cover image
    setState(() {
      _selectedCategory = widget.bookData['category'] ?? 'Fiksi';
      _selectedLanguage = widget.bookData['language'] ?? 'Indonesian';
      _coverImageUrl = widget.bookData['cover_image_url'];
    });
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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pdfUrlController.dispose();
    _bookAuthorController.dispose();
    _publicationYearController.dispose();
    _pagesController.dispose();
    _isbnController.dispose();
    super.dispose();
  }

  Future<void> _updatePdfBook() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      
      // Update database
      final now = DateTime.now().toIso8601String();
      await supabase.from('pdf_books').update({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        'pdf_url': _pdfUrlController.text.trim(),
        'cover_image_url': _coverImageUrl,
        'book_author': _bookAuthorController.text.trim().isEmpty
            ? null
            : _bookAuthorController.text.trim(),
        'publication_year': _publicationYearController.text.trim().isEmpty
            ? null
            : int.parse(_publicationYearController.text.trim()),
        'category': _selectedCategory,
        'language': _selectedLanguage,
        'pages': _pagesController.text.trim().isEmpty
            ? null
            : int.parse(_pagesController.text.trim()),
        'isbn': _isbnController.text.trim().isEmpty
            ? null
            : _isbnController.text.trim(),
        'updated_at': now,
      }).eq('id', widget.bookId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF book updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update PDF book: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit PDF Book'),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _updatePdfBook,
              child: const Text(
                'Save',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Updating PDF book...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Cover Image Section
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.image,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Cover Image (Optional)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_coverImageUrl != null) ...[
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(_coverImageUrl!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _openMediaManager,
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Change Image'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _coverImageUrl = null;
                                      });
                                    },
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Remove'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: InkWell(
                                onTap: _openMediaManager,
                                borderRadius: BorderRadius.circular(8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 48,
                                      color: Colors.grey.shade500,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap to add cover image',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Recommended: 600x900px (Book ratio)',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Title Field
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Book Title',
                        hintText: 'Enter the title of your PDF book',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Description Field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'Enter a brief description of your book',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Book Author Field
                    TextFormField(
                      controller: _bookAuthorController,
                      decoration: const InputDecoration(
                        labelText: 'Author (Optional)',
                        hintText: 'Enter the author name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Category and Language Row
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.category),
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
                              prefixIcon: Icon(Icons.language),
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
                    
                    // Publication Year and Pages Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _publicationYearController,
                            decoration: const InputDecoration(
                              labelText: 'Publication Year (Optional)',
                              hintText: '2024',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final year = int.tryParse(value);
                                if (year == null || year < 1000 || year > DateTime.now().year + 1) {
                                  return 'Enter valid year';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _pagesController,
                            decoration: const InputDecoration(
                              labelText: 'Pages (Optional)',
                              hintText: '100',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.book),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final pages = int.tryParse(value);
                                if (pages == null || pages <= 0) {
                                  return 'Enter valid pages';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // ISBN Field
                    TextFormField(
                      controller: _isbnController,
                      decoration: const InputDecoration(
                        labelText: 'ISBN (Optional)',
                        hintText: '978-0-123456-78-9',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.qr_code),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Save Button
                    ElevatedButton.icon(
                      onPressed: !_isLoading ? _updatePdfBook : null,
                      icon: const Icon(Icons.save),
                      label: const Text('Update PDF Book'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
