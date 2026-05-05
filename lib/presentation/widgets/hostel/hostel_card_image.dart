import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../data/models/hostel_model.dart';

class HostelCardImage extends StatelessWidget {
  final HostelModel hostel;
  
  const HostelCardImage({super.key, required this.hostel});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          // Hero Image
          AspectRatio(
            aspectRatio: 16 / 9,
            child: hostel.imageUrls.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: hostel.imageUrls.first,
                    fit: BoxFit.cover,
                    memCacheWidth: kIsWeb ? null : 800,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: AppColors.surface,
                      highlightColor: AppColors.accent.withValues(alpha: 0.1),
                      child: Container(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.surfaceAlt,
                      child: Icon(Icons.home_work_rounded, size: 56, color: AppColors.textTertiary),
                    ),
                  )
                : Container(
                    color: AppColors.surfaceAlt,
                    child: Icon(Icons.home_work_rounded, size: 56, color: AppColors.textTertiary),
                  ),
          ),

          // Image overlay gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    AppColors.surface.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // Verification badge
          if (hostel.approved)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  border: Border.all(color: AppColors.accent, width: 1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 14, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Text('Verified', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

          // Image counter
          if (hostel.imageUrls.isNotEmpty)
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '1/${hostel.imageUrls.length}',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
