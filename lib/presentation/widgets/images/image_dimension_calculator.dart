import 'package:flutter/material.dart';

class ImageDimensions {
  final double height;
  final double padding;
  final double badgeFontSize;
  final double iconSize;

  const ImageDimensions({
    required this.height,
    required this.padding,
    required this.badgeFontSize,
    required this.iconSize,
  });
}

class ImageDimensionCalculator {
  /// Expert Judgement: Calculates exact height and paddings based on screen width
  /// to ensure maximum visual impact while keeping the list scrollable.
  static ImageDimensions calculate(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final width = size.width;

    double baseHeight;
    double padding;
    double badgeFontSize;
    double iconSize;

    if (width < 400) {
      // Small Phone
      baseHeight = width * 0.5; // 2:1 aspect ratio
      padding = 12.0;
      badgeFontSize = 9.0;
      iconSize = 16.0;
    } else if (width < 600) {
      // Standard Phone
      baseHeight = width * 0.55; // ~1.82:1 aspect ratio
      padding = 12.0;
      badgeFontSize = 10.0;
      iconSize = 18.0;
    } else if (width < 1000) {
      // Tablet
      baseHeight = width * 0.60;
      padding = 16.0;
      badgeFontSize = 12.0;
      iconSize = 20.0;
    } else {
      // Desktop
      baseHeight = width * 0.65;
      padding = 20.0;
      badgeFontSize = 14.0;
      iconSize = 24.0;
    }

    // Landscape adjustment: reduce height by 40% (x 0.6) so it doesn't consume 
    // the entire vertical space on phones
    if (isLandscape) {
      baseHeight *= 0.6;
    }

    return ImageDimensions(
      height: baseHeight,
      padding: padding,
      badgeFontSize: badgeFontSize,
      iconSize: iconSize,
    );
  }

  /// Appends appropriate quality tags for Unsplash to save memory
  static String getOptimizedUnsplashUrl(String url, double screenWidth) {
    if (!url.contains('unsplash.com')) return url;
    
    // Unsplash uses w= parameter to resize
    int targetWidth;
    int quality;

    if (screenWidth < 400) {
      targetWidth = 480;
      quality = 60;
    } else if (screenWidth < 600) {
      targetWidth = 720;
      quality = 75;
    } else if (screenWidth < 1000) {
      targetWidth = 1080;
      quality = 85;
    } else {
      targetWidth = 1440;
      quality = 90;
    }

    // Replace or append parameters
    final uri = Uri.parse(url);
    final params = Map<String, String>.from(uri.queryParameters);
    params['w'] = targetWidth.toString();
    params['q'] = quality.toString();
    params['fit'] = 'crop';

    return uri.replace(queryParameters: params).toString();
  }
}
