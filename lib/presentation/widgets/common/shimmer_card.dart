import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';


/// Dark-aware shimmer skeleton that matches the HostelCard proportions.
/// Drop-in replacement while [filteredHostelsProvider] is loading.
class ShimmerHostelCard extends StatelessWidget {
  const ShimmerHostelCard({super.key});

  @override
  Widget build(BuildContext context) {
    final base      = AppColors.shimmerBase;
    final highlight = AppColors.shimmerHighlight;
    final surf      = AppColors.surface;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image placeholder
            Container(height: 220, width: double.infinity, color: base),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 18, decoration: _pill(base, 12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(width: 64, height: 26, decoration: _pill(base, 20)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Location
                  Container(width: 140, height: 13, decoration: _pill(base, 8)),
                  const SizedBox(height: 16),
                  // Price + occupancy
                  Row(
                    children: [
                      Container(width: 110, height: 22, decoration: _pill(base, 8)),
                      const SizedBox(width: 16),
                      Container(width: 60, height: 22, decoration: _pill(base, 8)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Tags
                  Row(
                    children: [
                      Container(width: 60, height: 26, decoration: _pill(base, 12)),
                      const SizedBox(width: 8),
                      Container(width: 70, height: 26, decoration: _pill(base, 12)),
                      const SizedBox(width: 8),
                      Container(width: 55, height: 26, decoration: _pill(base, 12)),
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

  BoxDecoration _pill(Color color, double radius) =>
      BoxDecoration(color: color, borderRadius: BorderRadius.circular(radius));
}

/// A compact horizontal shimmer — useful for list items.
class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({super.key});

  @override
  Widget build(BuildContext context) {
    final base      = AppColors.shimmerBase;
    final highlight = AppColors.shimmerHighlight;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(14))),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: double.infinity, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(8))),
                  const SizedBox(height: 8),
                  Container(height: 11, width: 160, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(8))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
