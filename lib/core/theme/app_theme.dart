import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized ThemeData for the HMS "PropTech" aesthetic.
/// Two themes share identical geometry — only colors differ.
/// Use [AppTheme.darkTheme] (default) and [AppTheme.lightTheme].
class AppTheme {
  AppTheme._();

  // ── Shared geometry constants ─────────────────────────────────────────────
  static const double _cardRadius   = 24.0;
  static const double _buttonRadius = 28.0;
  static const double _inputRadius  = 16.0;
  static const double _chipRadius   = 20.0;

  // ── Text factory helpers ──────────────────────────────────────────────────
  static TextStyle _head(double size, Color color, {FontWeight w = FontWeight.w700}) =>
      GoogleFonts.plusJakartaSans(fontSize: size, fontWeight: w, color: color);

  static TextStyle _body(double size, Color color, {FontWeight w = FontWeight.w400}) =>
      GoogleFonts.plusJakartaSans(fontSize: size, fontWeight: w, color: color);

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK THEME
  // ═══════════════════════════════════════════════════════════════════════════
  static ThemeData get darkTheme {
    const bg   = AppColors.background;
    const surf = AppColors.surface;
    const primary = AppColors.accent;      // Electric Blue used as scheme primary
    const onPrimary = AppColors.black;
    const textHi  = AppColors.textPrimary;
    const textMid = AppColors.textSecondary;
    const textLo  = AppColors.textTertiary;
    const bord    = AppColors.border;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: ColorScheme.dark(
        primary:     primary,
        onPrimary:   onPrimary,
        secondary:   AppColors.accentMint,
        onSecondary: AppColors.black,
        surface:     surf,
        onSurface:   textHi,
        error:       AppColors.error,
        onError:     AppColors.white,
        surfaceContainerHighest: AppColors.surfaceAlt,
      ),

      scaffoldBackgroundColor: bg,

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: _head(20, textHi, w: FontWeight.w700),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      // ── Card ───────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: surf,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
          side: BorderSide(color: bord),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Input ──────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide(color: bord),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: _body(14, textLo),
        labelStyle: _body(14, textMid),
        floatingLabelStyle: _body(12, primary, w: FontWeight.w600),
      ),

      // ── Elevated Button ────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
          textStyle: _head(15, AppColors.black, w: FontWeight.w700),
        ),
      ),

      // ── Text Button ────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: _body(14, primary, w: FontWeight.w600),
        ),
      ),

      // ── Outlined Button ────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textHi,
          side: BorderSide(color: bord, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
          textStyle: _head(15, textHi, w: FontWeight.w600),
        ),
      ),

      // ── FAB ────────────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // ── Bottom Nav ─────────────────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surf,
        selectedItemColor: primary,
        unselectedItemColor: textLo,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: _body(11, primary, w: FontWeight.w600),
        unselectedLabelStyle: _body(11, textLo),
      ),

      // ── Navigation Bar (M3) ────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surf,
        indicatorColor: primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected)
            ? _body(11, primary, w: FontWeight.w600)
            : _body(11, textLo)),
        iconTheme: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected)
            ? const IconThemeData(color: AppColors.accent, size: 24)
            : IconThemeData(color: textLo, size: 24)),
      ),

      // ── Chip ───────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceAlt,
        selectedColor: primary.withValues(alpha: 0.12),
        labelStyle: _body(12, textHi, w: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_chipRadius),
          side: BorderSide(color: bord),
        ),
      ),

      // ── Dialog ─────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: surf,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_cardRadius)),
        ),
        titleTextStyle: _head(18, textHi),
        contentTextStyle: _body(14, textMid),
      ),

      // ── Bottom Sheet ───────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surf,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(_cardRadius)),
        ),
        elevation: 0,
        dragHandleColor: AppColors.border,
        showDragHandle: true,
      ),

      // ── Divider ────────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // ── List Tile ──────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: surf,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: _body(14, textHi, w: FontWeight.w600),
        subtitleTextStyle: _body(12, textMid),
      ),

      // ── Tab Bar ────────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: textMid,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primary, width: 2.5),
        ),
        labelStyle: _body(14, primary, w: FontWeight.w700),
        unselectedLabelStyle: _body(14, textMid, w: FontWeight.w500),
      ),

      // ── Slider ─────────────────────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: bord,
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.12),
        valueIndicatorColor: primary,
        valueIndicatorTextStyle: _body(12, onPrimary, w: FontWeight.w600),
      ),

      // ── Switch / Checkbox ──────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.black : textLo),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primary : AppColors.surfaceAlt),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primary : Colors.transparent),
        side: BorderSide(color: textLo),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),

      // ── Progress ───────────────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
        linearTrackColor: AppColors.border,
        circularTrackColor: AppColors.border,
      ),

      // ── SnackBar ───────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        contentTextStyle: _body(14, textHi),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Text Theme ─────────────────────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge:  _head(32, textHi),
        displayMedium: _head(28, textHi),
        displaySmall:  _head(24, textHi),
        headlineLarge:  _head(22, textHi),
        headlineMedium: _head(20, textHi),
        headlineSmall:  _head(18, textHi),
        titleLarge:  _head(16, textHi),
        titleMedium: _head(14, textHi),
        titleSmall:  _head(12, textHi),
        bodyLarge:   _body(16, textHi),
        bodyMedium:  _body(14, textMid),
        bodySmall:   _body(12, textLo),
        labelLarge:  _body(14, textHi, w: FontWeight.w500),
        labelMedium: _body(12, textMid, w: FontWeight.w500),
        labelSmall:  _body(10, textLo, w: FontWeight.w500),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME  — same geometry, light color swap
  // ═══════════════════════════════════════════════════════════════════════════
  static ThemeData get lightTheme {
    const bg   = AppLightColors.background;
    const surf = AppLightColors.surface;
    const primary = AppLightColors.accent;     // Refined Indigo
    const onPrimary = AppColors.white;
    const textHi  = AppLightColors.textPrimary;
    const textMid = AppLightColors.textSecondary;
    const textLo  = AppLightColors.textTertiary;
    const bord    = AppLightColors.border;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      colorScheme: ColorScheme.light(
        primary:     primary,
        onPrimary:   onPrimary,
        secondary:   AppLightColors.accentMint,
        onSecondary: AppColors.white,
        surface:     surf,
        onSurface:   textHi,
        error:       AppLightColors.error,
        onError:     AppColors.white,
        surfaceContainerHighest: AppLightColors.surfaceAlt,
      ),

      scaffoldBackgroundColor: bg,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: _head(20, textHi, w: FontWeight.w700),
        iconTheme: const IconThemeData(color: AppLightColors.textPrimary),
      ),

      cardTheme: CardThemeData(
        color: surf,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
          side: BorderSide(color: bord),
        ),
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppLightColors.surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide(color: bord),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: const BorderSide(color: AppLightColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: const BorderSide(color: AppLightColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: _body(14, textLo),
        labelStyle: _body(14, textMid),
        floatingLabelStyle: _body(12, primary, w: FontWeight.w600),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppLightColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
          textStyle: _head(15, AppColors.white, w: FontWeight.w700),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: _body(14, primary, w: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textHi,
          side: BorderSide(color: bord, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
          textStyle: _head(15, textHi, w: FontWeight.w600),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surf,
        selectedItemColor: primary,
        unselectedItemColor: textLo,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: _body(11, primary, w: FontWeight.w600),
        unselectedLabelStyle: _body(11, textLo),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surf,
        indicatorColor: primary.withValues(alpha: 0.10),
        labelTextStyle: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected)
            ? _body(11, primary, w: FontWeight.w600)
            : _body(11, textLo)),
        iconTheme: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected)
            ? const IconThemeData(color: AppLightColors.accent, size: 24)
            : IconThemeData(color: textLo, size: 24)),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppLightColors.surfaceAlt,
        selectedColor: primary.withValues(alpha: 0.10),
        labelStyle: _body(12, textHi, w: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_chipRadius),
          side: BorderSide(color: bord),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surf,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_cardRadius)),
        ),
        titleTextStyle: _head(18, textHi),
        contentTextStyle: _body(14, textMid),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surf,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(_cardRadius)),
        ),
        elevation: 0,
        dragHandleColor: AppLightColors.border,
        showDragHandle: true,
      ),

      dividerTheme: const DividerThemeData(
        color: AppLightColors.border,
        thickness: 1,
        space: 1,
      ),

      listTileTheme: ListTileThemeData(
        tileColor: surf,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: _body(14, textHi, w: FontWeight.w600),
        subtitleTextStyle: _body(12, textMid),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: textMid,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primary, width: 2.5),
        ),
        labelStyle: _body(14, primary, w: FontWeight.w700),
        unselectedLabelStyle: _body(14, textMid, w: FontWeight.w500),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: bord,
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.10),
        valueIndicatorColor: primary,
        valueIndicatorTextStyle: _body(12, onPrimary, w: FontWeight.w600),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.white : textLo),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primary : AppLightColors.surfaceAlt),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primary : Colors.transparent),
        side: BorderSide(color: textLo),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: bord,
        circularTrackColor: bord,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppLightColors.primary,
        contentTextStyle: _body(14, AppColors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),

      textTheme: TextTheme(
        displayLarge:  _head(32, textHi),
        displayMedium: _head(28, textHi),
        displaySmall:  _head(24, textHi),
        headlineLarge:  _head(22, textHi),
        headlineMedium: _head(20, textHi),
        headlineSmall:  _head(18, textHi),
        titleLarge:  _head(16, textHi),
        titleMedium: _head(14, textHi),
        titleSmall:  _head(12, textHi),
        bodyLarge:   _body(16, textHi),
        bodyMedium:  _body(14, textMid),
        bodySmall:   _body(12, textLo),
        labelLarge:  _body(14, textHi, w: FontWeight.w500),
        labelMedium: _body(12, textMid, w: FontWeight.w500),
        labelSmall:  _body(10, textLo, w: FontWeight.w500),
      ),
    );
  }

  // Keep deprecated alias for any old references
  @Deprecated('Use darkTheme or lightTheme explicitly')
  static ThemeData get theme => darkTheme;
}

// Re-export AppLightColors from app_colors.dart so app_theme.dart compiles
// (AppLightColors is defined in app_colors.dart)
