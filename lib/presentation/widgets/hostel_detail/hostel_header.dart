import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../data/models/hostel_model.dart';

class HostelHeader extends ConsumerWidget {
  final HostelModel hostel;
  final double averageRating;
  final int reviewCount;

  const HostelHeader({
    super.key,
    required this.hostel,
    this.averageRating = 0,
    this.reviewCount = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + Gender badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  hostel.name,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: hostel.genderType.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: hostel.genderType.color.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(hostel.genderType.icon, color: hostel.genderType.color, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      hostel.genderType.displayName,
                      style: GoogleFonts.plusJakartaSans(
                        color: hostel.genderType.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 8.0),

          // Location row
          Row(
            children: [
              Icon(Icons.location_on_rounded, color: AppColors.accent, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  hostel.address,
                  style: Theme.of(context).textTheme.bodySmall!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.0),

          // Rating + Price row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Starting from', style: Theme.of(context).textTheme.bodySmall!),
                  Text(
                    'Rs. ${hostel.minRent.toInt()} / month',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(color: AppColors.accent),
                  ),
                ],
              ),

              // Rating
              if (averageRating > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (reviewCount > 0) ...[
                        const SizedBox(width: 4),
                        Text('($reviewCount)', style: Theme.of(context).textTheme.bodySmall!),
                      ],
                    ],
                  ),
                ),
            ],
          ),

          SizedBox(height: 16.0),

          // Trust signals row
          _TrustSignalsRow(hostel: hostel),
        ],
      ),
    );
  }
}

class _TrustSignalsRow extends StatelessWidget {
  final HostelModel hostel;
  const _TrustSignalsRow({required this.hostel});

  @override
  Widget build(BuildContext context) {
    final occupancy = hostel.occupancyRate;
    final occupancyColor = occupancy > 80
        ? AppColors.error
        : occupancy > 50
            ? AppColors.warning
            : AppColors.success;

    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _TrustItem(
            icon: Icons.people_rounded,
            label: '${hostel.totalBeds ?? 0} Beds',
            color: AppColors.accent,
          ),
          _Divider(),
          _TrustItem(
            icon: Icons.bed_rounded,
            label: '${occupancy.toInt()}% Full',
            color: occupancyColor,
          ),
          _Divider(),
          _TrustItem(
            icon: Icons.payment_rounded,
            label: hostel.securityFee > 0
                ? 'Rs.${hostel.securityFee.toInt()} Dep.'
                : 'No Deposit',
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _TrustItem({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: AppColors.border);
  }
}