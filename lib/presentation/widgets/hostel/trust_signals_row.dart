import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';


class TrustSignalsRow extends StatelessWidget {
  final bool isVerified;
  
  const TrustSignalsRow({super.key, this.isVerified = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isVerified) ...[
          _TrustSignal(
            icon: Icons.check_circle,
            label: 'Verified',
            color: AppColors.accent,
          ),
          SizedBox(width: 16.0),
        ],
        _TrustSignal(
          icon: Icons.people,
          label: '200+ students',
          color: AppColors.accent.withValues(alpha: 0.7),
        ),
        SizedBox(width: 16.0),
        _TrustSignal(
          icon: Icons.access_time,
          label: 'Usually 2hrs',
          color: AppColors.accent.withValues(alpha: 0.7),
        ),
      ],
    );
  }
}

class _TrustSignal extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _TrustSignal({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(color: color),
        ),
      ],
    );
  }
}
