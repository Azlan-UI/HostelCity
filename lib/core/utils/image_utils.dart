import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_constants.dart';

class ImageUtils {
  ImageUtils._();

  static final ImagePicker _picker = ImagePicker();

  // Pick single image from gallery
  static Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: AppConstants.imageQuality,
      );
      
      if (image != null) {
        // Check file size
        final fileSize = await _getFileSize(image);
        if (fileSize > AppConstants.maxImageSize) {
          throw Exception('Image size must be less than 5MB');
        }
      }
      
      return image;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  // Pick single image from camera
  static Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: AppConstants.imageQuality,
      );
      
      if (image != null) {
        // Check file size
        final fileSize = await _getFileSize(image);
        if (fileSize > AppConstants.maxImageSize) {
          throw Exception('Image size must be less than 5MB');
        }
      }
      
      return image;
    } catch (e) {
      throw Exception('Failed to capture image: $e');
    }
  }

  // Pick multiple images from gallery
  static Future<List<XFile>> pickMultipleImages({int? maxImages}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: AppConstants.imageQuality,
      );
      
      // Limit number of images
      if (maxImages != null && images.length > maxImages) {
        throw Exception('You can select maximum $maxImages images');
      }
      
      // Check file sizes
      for (final image in images) {
        final fileSize = await _getFileSize(image);
        if (fileSize > AppConstants.maxImageSize) {
          throw Exception('Each image must be less than 5MB');
        }
      }
      
      return images;
    } catch (e) {
      throw Exception('Failed to pick images: $e');
    }
  }

  // Get file size
  static Future<int> _getFileSize(XFile file) async {
    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      return bytes.length;
    } else {
      final fileObj = File(file.path);
      return await fileObj.length();
    }
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }
}
