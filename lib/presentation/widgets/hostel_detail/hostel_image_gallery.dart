import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/hostel_model.dart';
import '../../providers/hostel_image_fetch_provider.dart';

/// Shows a single Hero image at the top of the hostel detail page.
/// Matches the same image displayed on the hostel card.
class HostelImageGallery extends ConsumerStatefulWidget {
  final HostelModel hostel;

  const HostelImageGallery({
    super.key,
    required this.hostel,
  });

  @override
  ConsumerState<HostelImageGallery> createState() => _HostelImageGalleryState();
}

class _HostelImageGalleryState extends ConsumerState<HostelImageGallery> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) triggerHostelImageFetch(ref, widget.hostel);
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = ref.watch(hostelImageUrlsProvider(widget.hostel.hostelId));
    final imageUrl = imageUrls.isNotEmpty ? imageUrls.first : null;

    return Hero(
      tag: 'hostel-image-${widget.hostel.hostelId}',
      child: SizedBox(
        height: 320,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Image ──────────────────────────────────────────────────────
            if (imageUrl != null)
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: kIsWeb ? null : 800,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: AppColors.surface,
                  highlightColor: AppColors.accent.withValues(alpha: 0.15),
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) => _buildPlaceholder(),
              )
            else
              _buildPlaceholder(),

            // ── Bottom gradient fade into page background ───────────────
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.1),
                      AppColors.surface.withValues(alpha: 0.7),
                      AppColors.surface,
                    ],
                    stops: const [0.0, 0.5, 0.85, 1.0],
                  ),
                ),
              ),
            ),

            // ── Verified badge ──────────────────────────────────────────
            if (widget.hostel.approved)
              Positioned(
                top: 56,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    border: Border.all(color: AppColors.accent, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, size: 14, color: AppColors.accent),
                      const SizedBox(width: 5),
                      const Text(
                        'Verified',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceAlt,
      child: Center(
        child: Icon(Icons.home_work_rounded, size: 72, color: AppColors.textTertiary),
      ),
    );
  }
}
