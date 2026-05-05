import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../data/models/hostel_model.dart';
import '../../providers/hostel_image_fetch_provider.dart';

class HostelListRow extends ConsumerStatefulWidget {
  final HostelModel hostel;
  final VoidCallback onTap;
  final Widget? trailingBadge;

  const HostelListRow({
    super.key,
    required this.hostel,
    required this.onTap,
    this.trailingBadge,
  });

  @override
  ConsumerState<HostelListRow> createState() => _HostelListRowState();
}

class _HostelListRowState extends ConsumerState<HostelListRow> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) triggerHostelImageFetch(ref, widget.hostel);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the stable image state — only updates once when fetch completes.
    final imageUrls = ref.watch(hostelImageUrlsProvider(widget.hostel.hostelId));
    final firstUrl = imageUrls.isNotEmpty ? imageUrls.first : null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: firstUrl != null
                  ? CachedNetworkImage(
                      imageUrl: firstUrl,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      memCacheWidth: kIsWeb ? null : 200,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFE0E0E0),
                        highlightColor: isDark ? const Color(0xFF3A3A4A) : const Color(0xFFF5F5F5),
                        child: Container(width: 72, height: 72, color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => _buildFallback(isDark),
                    )
                  : _buildFallback(isDark),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.hostel.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.trailingBadge != null) widget.trailingBadge!,
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${widget.hostel.area}, ${widget.hostel.city}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Rs. ${widget.hostel.minRent.toInt()}/m',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallback(bool isDark) {
    return Container(
      width: 72,
      height: 72,
      color: isDark ? const Color(0xFF2A2A3A) : AppColors.surfaceAlt,
      child: Icon(Icons.apartment, color: AppColors.textTertiary),
    );
  }
}
