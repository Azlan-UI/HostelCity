import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/hostel_model.dart';
import '../images/dynamic_hostel_image.dart';
import 'trust_signals_row.dart';

class HostelCard extends StatefulWidget {
  final HostelModel hostel;
  final VoidCallback onTap;

  const HostelCard({
    super.key,
    required this.hostel,
    required this.onTap,
  });

  @override
  State<HostelCard> createState() => _HostelCardState();
}

class _HostelCardState extends State<HostelCard> {
  bool _isHovered = false;

  void _setHovered(bool hovered) {
    setState(() {
      _isHovered = hovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hostel = widget.hostel;

    return GestureDetector(
      onTapDown: (_) => _setHovered(true),
      onTapUp: (_) {
        _setHovered(false);
        widget.onTap();
      },
      onTapCancel: () => _setHovered(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(bottom: 24.0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? AppColors.accent.withValues(alpha: 0.3)
                : AppColors.border,
            width: 1,
          ),
          boxShadow: _isHovered ? [const BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))] : AppColors.softShadow,
        ),
        transform: _isHovered ? (Matrix4.identity()..scale(1.02)) : Matrix4.identity(),
        transformAlignment: Alignment.center,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with overlay
            DynamicHostelImage(hostel: hostel),

            // Content section
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trust signals row
                  TrustSignalsRow(isVerified: hostel.approved),
                  SizedBox(height: 8.0),

                  // Name + location + rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hostel.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 12, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${hostel.area}, ${hostel.city}',
                                    style: Theme.of(context).textTheme.bodySmall!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),

                  // Price + rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rs. ${hostel.minRent.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}/mo',
                            style: Theme.of(context).textTheme.titleLarge!.copyWith(color: AppColors.accent),
                          ),
                          Text('from', style: Theme.of(context).textTheme.bodySmall!),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('4.5', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                          Text('(248)', style: Theme.of(context).textTheme.bodySmall!),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),

                  // Facilities chips (horizontal scroll)
                  if (hostel.facilities.isNotEmpty) ...[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: hostel.facilities.take(4).map((f) {
                          return Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(f, style: Theme.of(context).textTheme.bodySmall!),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 16.0),
                  ],

                  // Stats & Gender badge
                  Row(
                    children: [
                      if (hostel.totalBeds != null) ...[
                        _StatChip(
                          icon: Icons.bed_rounded,
                          label: '${hostel.totalBeds} Beds',
                        ),
                        const SizedBox(width: 8),
                      ],
                      _StatChip(
                        icon: Icons.people_alt_rounded,
                        label: '${hostel.occupancyRate.toStringAsFixed(0)}%',
                        color: hostel.occupancyRate > 80 ? AppColors.error : AppColors.success,
                      ),
                      const Spacer(),
                      // Gender badge (right-aligned)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: hostel.genderType.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: hostel.genderType.color.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(hostel.genderType.icon, size: 12, color: hostel.genderType.color),
                            const SizedBox(width: 4),
                            Text(
                              hostel.genderType.displayName,
                              style: TextStyle(
                                color: hostel.genderType.color,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
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
}

// ─── Stat chip ────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _StatChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: c),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
