import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chapter_editor_page.dart';
import '../../widgets/cover_media_manager.dart';
import 'package:whatthebook/core/services/logger_service.dart';

class BookDetailsPage extends StatefulWidget {
  final String bookId; // For edit mode

  const BookDetailsPage({super.key, required this.bookId});

  // Named constructor for creating a new book
  const BookDetailsPage.create({super.key}) : bookId = '';

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedGenre;
  String? _coverImageUrl;
  String? _previousFileName; // Track previous uploaded file

  final _genres = [
    'Fiksi',
    'Non-Fiksi',
    'Fantasi',
    'Sains Fiksi',
    'Romansa',
    'Misteri',
    'Horor',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.bookId.isNotEmpty) {
      _loadBookData();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();

    // Clean up temporary image if not saved
    if (_previousFileName != null && _coverImageUrl == null) {
      try {
        Supabase.instance.client.storage.from('book-covers').remove([
          _previousFileName!,
        ]);
      } catch (e) {
        logger.error('Error cleaning up temporary image: $e');
      }
    }

    super.dispose();
  }

  Future<void> _loadBookData() async {
    try {
      final response = await Supabase.instance.client
          .from('books')
          .select()
          .eq('id', widget.bookId)
          .single();

      if (!mounted) return;

      setState(() {
        _titleController.text = response['title'] ?? '';
        _descriptionController.text = response['description'] ?? '';
        _selectedGenre = response['genre'];
        _coverImageUrl = response['cover_image_url'];
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading book data: $e')));
    }
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

  Future<void> _saveBook() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Judul buku harus diisi')));
      return;
    }

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User tidak terautentikasi')),
        );
        return;
      }

      final bookData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'genre': _selectedGenre,
        'cover_image_url': _coverImageUrl ?? '',
      };

      if (widget.bookId.isNotEmpty) {
        // Update existing book
        await Supabase.instance.client
            .from('books')
            .update(bookData)
            .eq('id', widget.bookId)
            .select()
            .single();

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChapterEditorPage(bookId: widget.bookId),
          ),
        );
      } else {
        // Create new book
        bookData['author_id'] = userId;
        bookData['status'] = 'draft';
        bookData['total_chapters'] = '0';

        final Map<String, dynamic> response = await Supabase.instance.client
            .from('books')
            .insert(bookData)
            .select()
            .single();

        if (!mounted) return;

        // Get the ID from response and convert to string
        final responseId = response['id'];
        if (responseId == null) {
          throw Exception('Failed to get book ID from response');
        }

        // Convert to string safely
        final String newBookId = responseId.toString();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChapterEditorPage(bookId: newBookId),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pastikan _selectedGenre valid
    if (_selectedGenre != null && !_genres.contains(_selectedGenre)) {
      _selectedGenre = null;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Buku'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Cover Image at the top
              Center(
                child: GestureDetector(
                  onTap: _openMediaManager,
                  child: Container(
                    width:
                        MediaQuery.of(context).size.width *
                        0.4, // 40% of screen width
                    height:
                        MediaQuery.of(context).size.width *
                        0.6, // 1.5x the width for book ratio
                    decoration: BoxDecoration(color: Colors.grey[200]),
                    child: _coverImageUrl != null
                        ? Image.network(_coverImageUrl!, fit: BoxFit.cover)
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Klik untuk upload cover\nSVG, PNG, JPG atau GIF (Maks. 600x900px)',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Form content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Judul',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan judul buku',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Deskripsi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan deskripsi buku',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Genre',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedGenre,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Pilih genre',
                    ),
                    items: _genres.map((genre) {
                      return DropdownMenuItem(value: genre, child: Text(genre));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGenre = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 100,
                  ), // Extra space for bottom navigation
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _saveBook,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Lanjutkan'),
          ),
        ),
      ),
    );
  }
}
