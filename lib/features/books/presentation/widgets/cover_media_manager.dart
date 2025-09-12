import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image/image.dart' as img; // Tambahkan import image

class CoverMediaManager extends StatefulWidget {
  final String? selectedImageUrl;
  final Function(String imageUrl) onImageSelected;

  const CoverMediaManager({
    super.key,
    this.selectedImageUrl,
    required this.onImageSelected,
  });

  @override
  State<CoverMediaManager> createState() => _CoverMediaManagerState();
}

class _CoverMediaManagerState extends State<CoverMediaManager> {
  List<Map<String, dynamic>> _userImages = [];
  bool _isLoading = true;
  bool _isUploading = false; // Tambahan: state untuk upload
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserImages();
  }

  Future<void> _loadUserImages() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final List<FileObject> files = await Supabase.instance.client.storage
          .from('book-covers')
          .list();

      final List<Map<String, dynamic>> images = [];
      // Hanya file gambar yang diambil
      for (var file in files) {
        final name = file.name.toLowerCase();
        if (!(name.endsWith('.jpg') ||
            name.endsWith('.jpeg') ||
            name.endsWith('.png') ||
            name.endsWith('.gif') ||
            name.endsWith('.webp') ||
            name.endsWith('.svg'))) {
          continue;
        }
        final url = Supabase.instance.client.storage
            .from('book-covers')
            .getPublicUrl(file.name);
        images.add({'name': file.name, 'url': url, 'created': file.createdAt});
      }

      // Sort by newest first
      images.sort((a, b) => b['created'].compareTo(a['created']));

      setState(() {
        _userImages = images;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading images: $e')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadNewImage() async {
    setState(() {
      _isUploading = true;
    });
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600, // Standard book cover width
        maxHeight: 900, // Height for 1.5:1 ratio
        imageQuality: 85,
      );

      if (image == null) {
        setState(() {
          _isUploading = false;
        });
        return;
      }

      // Baca bytes dan decode image
      final bytes = await image.readAsBytes();
      img.Image? decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) {
        throw Exception('Gagal membaca gambar');
      }

      // Resize ke 600x900 pixel jika tidak sesuai
      if (decodedImage.width != 600 || decodedImage.height != 900) {
        decodedImage = img.copyResize(decodedImage, width: 600, height: 900);
      }
      final resizedBytes = img.encodeJpg(decodedImage, quality: 85);

      final fileExt = image.name.split('.').last.toLowerCase();
      final fileName =
          'cover_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      String mimeType;
      switch (fileExt) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        case 'svg':
          mimeType = 'image/svg+xml';
          break;
        default:
          throw Exception('Unsupported file type');
      }

      await Supabase.instance.client.storage
          .from('book-covers')
          .uploadBinary(
            fileName,
            resizedBytes,
            fileOptions: FileOptions(contentType: mimeType),
          );

      await _loadUserImages();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cover berhasil diupload!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _deleteImage(String fileName) async {
    try {
      await Supabase.instance.client.storage.from('book-covers').remove([
        fileName,
      ]);

      await _loadUserImages();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cover berhasil dihapus!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isUploading) const LinearProgressIndicator(),
            if (_isUploading) const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Media Manager',
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
              onPressed: _uploadNewImage,
              icon: const Icon(Icons.upload),
              label: const Text('Upload Cover Baru'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gambar akan di resize jika ukurannya jika rasio tidak sesuai, rasio yang di rekomendasikan adalah 2:3 (direkomendasikan untuk ukuran 600x900 pixel)',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_userImages.isEmpty)
              const Expanded(
                child: Center(child: Text('Belum ada cover yang diupload')),
              )
            else
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.67, // Book cover ratio (width/height)
                  ),
                  itemCount: _userImages.length,
                  itemBuilder: (context, index) {
                    final image = _userImages[index];
                    final isSelected = widget.selectedImageUrl == image['url'];

                    return Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            widget.onImageSelected(image['url']);
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.grey,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Image.network(
                              image['url'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteImage(image['name']),
                          ),
                        ),
                      ],
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
