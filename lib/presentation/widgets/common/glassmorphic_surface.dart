import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';


class GlassmorphicSurface extends StatelessWidget {
  final Widget child;
  final double blurStrength;
  final BorderRadiusGeometry? borderRadius;

  const GlassmorphicSurface({
    super.key,
    required this.child,
    this.blurStrength = 16.0,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(16);
    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurStrength, sigmaY: blurStrength),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.9),
            borderRadius: br,
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
