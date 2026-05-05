import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Deep Noir "PropTech" color palette.
/// Dark theme constants are the top-level statics.
/// Light theme constants live in [AppLightColors].
class AppColors {
  AppColors._();

  // ── Dark Primary (Accent / CTA) ────────────────────────────────────────────
  /// Use for primary CTAs on dark surfaces — shows as white pill button.
  static const Color primary      = Color(0xFFFFFFFF); // crisp white CTA
  static const Color primaryDark  = Color(0xFFCCCCCC);
  static const Color primaryLight = Color(0xFFFFFFFF);

  // ── Accent / Status ────────────────────────────────────────────────────────
  static const Color accent      = Color(0xFF00E5FF); // Electric Blue
  static const Color accentLight = Color(0xFF64EFFF);
  static const Color accentMint  = Color(0xFF00FFB3); // Mint Green (success)

  // ── Dark Backgrounds ───────────────────────────────────────────────────────
  static const Color background  = Color(0xFF0D0D0D); // deep noir
  static const Color surface     = Color(0xFF1A1A1A); // card surface
  static const Color surfaceAlt  = Color(0xFF242424); // input / alt surface
  static const Color surfaceLight = Color(0xFF2C2C2E); // elevated card
  static const Color border      = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color borderFocus = accent;

  // ── Text (dark theme) ─────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF); // 70%
  static const Color textTertiary  = Color(0x61FFFFFF); // 38%

  // ── Semantic / Status ─────────────────────────────────────────────────────
  static const Color success = Color(0xFF00FFB3); // mint
  static const Color warning = Color(0xFFFFB833); // amber
  static const Color error   = Color(0xFFFF5C7A); // soft red
  static const Color info    = Color(0xFF00E5FF); // electric blue

  // ── Payment Status ────────────────────────────────────────────────────────
  static const Color paid    = success;
  static const Color pending = warning;
  static const Color overdue = error;

  // ── Complaint Status ──────────────────────────────────────────────────────
  static const Color complaintOpen       = info;
  static const Color complaintInProgress = warning;
  static const Color complaintResolved   = success;
  static const Color complaintClosed     = textTertiary;

  // ── Gender Type ───────────────────────────────────────────────────────────
  static const Color boys  = Color(0xFF00E5FF);
  static const Color girls = Color(0xFFFF5C7A);
  static const Color mixed = Color(0xFFB48EFF);

  // ── Neutral ───────────────────────────────────────────────────────────────
  static const Color white     = Color(0xFFFFFFFF);
  static const Color black     = Color(0xFF000000);
  static const Color grey      = textTertiary;
  static const Color greyLight = textSecondary;
  static const Color greyDark  = Color(0xFF3A3A3A);

  // ── Legacy aliases (backwards compat) ─────────────────────────────────────
  static const Color accentGreen  = success;
  static const Color accentOrange = warning;
  static const Color accentBlue   = info;

  // ── Gradients (dark) ──────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF2C2C2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0D0D0D), Color(0xFF1A1A1A), Color(0xFF1C1C2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Cinematic image overlay — dark gradient for text legibility on images.
  static const LinearGradient imageOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0xE6000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.3, 1.0],
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFF00FFB3)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0D0D0D), Color(0xFF111118)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF5C7A), Color(0xFFFFB833)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Legacy alias
  static const LinearGradient teralCoralGradient = primaryGradient;

  // ── Shimmer (dark) ────────────────────────────────────────────────────────
  static const Color shimmerBase      = Color(0xFF242424);
  static const Color shimmerHighlight = Color(0xFF2E2E3A);

  // ── Shadows ───────────────────────────────────────────────────────────────
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: black.withValues(alpha: 0.30),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: black.withValues(alpha: 0.40),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: accent.withValues(alpha: 0.20),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ];
}

/// Light "PropTech" color palette — same design language, light background.
class AppLightColors {
  AppLightColors._();

  static const Color primary      = Color(0xFF1A1A2E); // near-black CTA
  static const Color primaryDark  = Color(0xFF0F0F1A);
  static const Color primaryLight = Color(0xFF2E2E50);

  static const Color accent      = Color(0xFF5C5FEF); // refined indigo
  static const Color accentLight = Color(0xFF8B8EFF);
  static const Color accentMint  = Color(0xFF00C896); // mint (slightly muted)

  static const Color background  = Color(0xFFF4F4F8);
  static const Color surface     = Color(0xFFFFFFFF);
  static const Color surfaceAlt  = Color(0xFFEEEEF5);
  static const Color surfaceLight = Color(0xFFE8E8F2);
  static const Color border      = Color(0x12000000); // rgba(0,0,0,0.07)

  static const Color textPrimary   = Color(0xFF0F0F1A);
  static const Color textSecondary = Color(0xFF4B4B6B);
  static const Color textTertiary  = Color(0xFF9090B0);

  static const Color success = Color(0xFF00B07A);
  static const Color warning = Color(0xFFE09000);
  static const Color error   = Color(0xFFE53060);
  static const Color info    = Color(0xFF5C5FEF);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF0F0FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF2E2E50), Color(0xFF5C5FEF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient imageOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.3, 1.0],
  );

  static const Color shimmerBase      = Color(0xFFE4E4EE);
  static const Color shimmerHighlight = Color(0xFFF5F5FF);
}
