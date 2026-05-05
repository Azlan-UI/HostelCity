import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../data/models/hostel_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/hostel_image_fetch_provider.dart';
import '../hostel/favorite_heart_button.dart';
import 'image_dimension_calculator.dart';
import 'image_scroll_behavior.dart';

class DynamicHostelImage extends ConsumerStatefulWidget {
  final HostelModel hostel;

  const DynamicHostelImage({super.key, required this.hostel});

  @override
  ConsumerState<DynamicHostelImage> createState() => _DynamicHostelImageState();
}

class _DynamicHostelImageState extends ConsumerState<DynamicHostelImage> {
  @override
  void initState() {
    super.initState();
    // Trigger fetch once when widget mounts, NOT on every build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) triggerHostelImageFetch(ref, widget.hostel);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch only the resolved image URLs — this is a simple List<String> state,
    // it only changes once (when fetch completes). No infinite loop possible.
    final imageUrls = ref.watch(hostelImageUrlsProvider(widget.hostel.hostelId));

    final dims = ImageDimensionCalculator.calculate(context);
    final hasImage = imageUrls.isNotEmpty;
    final imageUrl = hasImage
        ? ImageDimensionCalculator.getOptimizedUnsplashUrl(
            imageUrls.first, MediaQuery.of(context).size.width)
        : null;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Hero(
      tag: 'hostel-image-${widget.hostel.hostelId}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        height: dims.height,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          color: AppColors.surfaceAlt,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 3. The actual image with parallax/zoom effects
            if (hasImage)
              ImageScrollBehavior(
                child: CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  // memCacheHeight causes canvas EncodingError on Flutter Web.
                  // Only apply on native platforms where it saves memory.
                  memCacheHeight: kIsWeb
                      ? null
                      : (dims.height * MediaQuery.of(context).devicePixelRatio)
                          .toInt(),
                  placeholder: (context, url) => _buildShimmer(isDark),
                  errorWidget: (context, url, error) => _buildFallback(),
                ),
              )
            else
              _buildShimmer(isDark),

            // 4. Gradient Overlay (Bottom 40%)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: dims.height * 0.4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
            ),

            // 5. Verification Badge (Top Left)
            if (widget.hostel.approved)
              Positioned(
                top: dims.padding,
                left: dims.padding,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: dims.padding * 0.6,
                      vertical: dims.padding * 0.4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    border: Border.all(color: AppColors.accent, width: 1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle,
                          size: dims.iconSize * 0.7, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: dims.badgeFontSize,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 6. Favorite Heart (Top Right)
            Positioned(
              top: dims.padding,
              right: dims.padding,
              child: Material(
                color: Colors.transparent,
                child: FavoriteHeartButton(
                  hostelId: widget.hostel.hostelId,
                  onTap: () {},
                ),
              ),
            ),

            // 7. Image Counter (Bottom Right)
            if (imageUrls.length > 1)
              Positioned(
                bottom: dims.padding,
                right: dims.padding,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: dims.padding * 0.6,
                      vertical: dims.padding * 0.3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '1/${imageUrls.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: dims.badgeFontSize,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),

            // 8. Availability Indicator (Bottom Left)
            Positioned(
              bottom: dims.padding,
              left: dims.padding,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: dims.padding * 0.6,
                    vertical: dims.padding * 0.3),
                decoration: BoxDecoration(
                  color: (widget.hostel.occupancyRate >= 80
                          ? AppColors.error
                          : AppColors.success)
                      .withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: dims.badgeFontSize * 0.6,
                      height: dims.badgeFontSize * 0.6,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.hostel.occupancyRate >= 80
                          ? 'Almost Full'
                          : 'Available',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: dims.badgeFontSize,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFE0E0E0),
      highlightColor:
          isDark ? const Color(0xFF3A3A4A) : const Color(0xFFF5F5F5),
      period: const Duration(seconds: 2),
      child: Container(color: Colors.white),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: AppColors.surfaceAlt,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_rounded,
              size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 8),
          Text(
            'Image unavailable',
            style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 10,
                decoration: TextDecoration.none),
          ),
        ],
      ),
    );
  }
}
