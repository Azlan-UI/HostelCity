import 'dart:typed_data';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import '../core/config/cloudinary_config.dart';

class StorageService {
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    CloudinaryConfig.cloudName,
    CloudinaryConfig.uploadPreset,
    cache: false,
  );

  // Upload user profile image
  Future<String> uploadUserProfileImage(String userId, XFile imageFile) async {
    try {
      return await _uploadImage(imageFile, folder: 'users/$userId');
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // Upload hostel images
  Future<List<String>> uploadHostelImages(String hostelId, List<XFile> imageFiles) async {
    try {
      final List<String> urls = [];
      for (final file in imageFiles) {
        final url = await _uploadImage(file, folder: 'hostels/$hostelId');
        urls.add(url);
      }
      return urls;
    } catch (e) {
      throw Exception('Failed to upload hostel images: $e');
    }
  }

  // Upload complaint images (batch)
  Future<List<String>> uploadComplaintImages(
    String hostelId,
    String complaintId,
    List<XFile> imageFiles,
  ) async {
    try {
      final List<String> urls = [];
      for (final file in imageFiles) {
        final url = await _uploadImage(file, folder: 'complaints/$hostelId/$complaintId');
        urls.add(url);
      }
      return urls;
    } catch (e) {
      throw Exception('Failed to upload complaint images: $e');
    }
  }

  // Upload single complaint image (for student form)
  Future<String> uploadComplaintImage(String userId, XFile imageFile) async {
    try {
      return await _uploadImage(imageFile, folder: 'complaints/user_$userId');
    } catch (e) {
      throw Exception('Failed to upload complaint image: $e');
    }
  }

  // Helper method for actual upload
  Future<String> _uploadImage(XFile imageFile, {required String folder}) async {
    try {
      // Create a CloudinaryFile from the XFile path/bytes
      // This handles both mobile (path) and web (bytes) automatically by the package
      CloudinaryFile cFile;
      
      try {
        // Try path first (Mobile)
        cFile = CloudinaryFile.fromFile(
          imageFile.path, 
          resourceType: CloudinaryResourceType.Image,
          folder: folder,
        );
      } catch (_) {
        // Fallback to bytes (Web)
        final bytes = await imageFile.readAsBytes();
        cFile = CloudinaryFile.fromByteData(
          ByteData.view(bytes.buffer),
          identifier: imageFile.name,
          resourceType: CloudinaryResourceType.Image,
          folder: folder,
        );
      }

      CloudinaryResponse response = await _cloudinary.uploadFile(cFile);
      return response.secureUrl;
      
    } catch (e) {
      print('❌ Cloudinary upload failed!');
      print('Error details: $e');
      if (e is CloudinaryException) {
        print('Status Code: ${e.statusCode}');
        print('Response: ${e.responseString}');
      }
      throw Exception('Image upload failed: $e');
    }
  }

  // Upload student card
  Future<String> uploadStudentCard(String userId, XFile imageFile) async {
    try {
      return await _uploadImage(imageFile, folder: 'verification/student_cards/$userId');
    } catch (e) {
      throw Exception('Failed to upload student card: $e');
    }
  }

  // Upload certificate
  Future<String> uploadCertificate(String userId, XFile imageFile) async {
    try {
      return await _uploadImage(imageFile, folder: 'verification/certificates/$userId');
    } catch (e) {
      throw Exception('Failed to upload certificate: $e');
    }
  }

  // Upload CNIC
  Future<String> uploadCNIC(String userId, XFile imageFile) async {
    try {
      return await _uploadImage(imageFile, folder: 'verification/cnic/$userId');
    } catch (e) {
      throw Exception('Failed to upload CNIC: $e');
    }
  }

  // Upload hostel registration document
  Future<String> uploadHostelRegistrationDoc(String userId, XFile imageFile) async {
    try {
      return await _uploadImage(imageFile, folder: 'verification/hostel_registration/$userId');
    } catch (e) {
      throw Exception('Failed to upload hostel registration: $e');
    }
  }

  // Delete image (Optional implementation for Cloudinary)
  // Note: Client-side deletion requires signed uploads usually, or Admin API.
  // For unsigned uploads, we might skip deletion or use a Cloud Function.
  // We'll keep method purely for compatibility but it might not delete from Cloud
  // without an API Key/Secret which are unsafe to expose in app.
  Future<void> deleteImage(String imageUrl) async {
    // Cloudinary unsigned deletion is restricted by default for security.
    // We can just return for now as it doesn't break app flow.
    print('Warning: Cloudinary client-side deletion requires Admin API signature');
  }

  Future<void> deleteImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      await deleteImage(url);
    }
  }

  Future<void> deleteFolder(String folderPath) async {
    // Not supported in client-side unsigned preset
  }
}
