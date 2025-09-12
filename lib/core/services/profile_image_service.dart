import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileImageService {
  static const String _bucketName = 'book-covers'; // Using existing bucket
  static const String _profileFolder =
      'profiles'; // Subfolder for profile images

  final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400, // Profile image size
        maxHeight: 400,
        imageQuality: 85,
      );
    } catch (e) {
      throw Exception('Failed to pick image from gallery: $e');
    }
  }

  /// Take photo with camera
  Future<XFile?> takePhotoWithCamera() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 85,
      );
    } catch (e) {
      throw Exception('Failed to take photo: $e');
    }
  }

  /// Upload image to Supabase storage
  Future<String> uploadProfileImage(XFile image, String userId) async {
    try {
      // Get image bytes
      final bytes = await image.readAsBytes();

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExt = image.name.split('.').last.toLowerCase();
      final fileName = 'profile_${userId}_$timestamp.$fileExt';
      final storagePath = '$_profileFolder/$fileName';

      // Determine MIME type
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
        case 'webp':
          mimeType = 'image/webp';
          break;
        default:
          throw Exception('Unsupported file type: $fileExt');
      }

      // Upload to Supabase storage
      final response = await Supabase.instance.client.storage
          .from(_bucketName)
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(contentType: mimeType),
          );

      if (response.isEmpty) {
        throw Exception('Upload failed - empty response');
      }

      // Get public URL
      final publicUrl = Supabase.instance.client.storage
          .from(_bucketName)
          .getPublicUrl(storagePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Delete profile image from storage
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Find the storage path from URL
      // URL format: https://[project].supabase.co/storage/v1/object/public/[bucket]/[path]
      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1) {
        throw Exception('Invalid image URL format');
      }

      final storagePath = pathSegments.sublist(bucketIndex + 1).join('/');

      await Supabase.instance.client.storage.from(_bucketName).remove([
        storagePath,
      ]);
    } catch (e) {
      throw Exception('Failed to delete profile image: $e');
    }
  }

  /// Validate image file
  Future<bool> validateImage(XFile image) async {
    try {
      final bytes = await image.readAsBytes();

      // Check file size (max 5MB for profile images)
      if (bytes.length > 5 * 1024 * 1024) {
        return false;
      }

      // Check file extension
      final fileExt = image.name.split('.').last.toLowerCase();
      final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      if (!allowedExtensions.contains(fileExt)) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
