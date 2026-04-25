import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.surface,

      // ── Color Scheme ─────────────────────────────────────────────────
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSurface,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onPrimary,
        tertiaryContainer: AppColors.tertiaryFixed,
        onTertiaryContainer: AppColors.onTertiaryFixed,
        error: AppColors.error,
        onError: AppColors.onError,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),

      // ── App Bar ───────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        iconTheme: IconThemeData(color: AppColors.onSurface),
        centerTitle: false,
      ),

      // ── Elevated Button (Pill-shaped, gradient via custom widget) ─────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: const StadiumBorder(),
          textStyle: AppTypography.titleMd,
        ),
      ),

      // ── Text Button ───────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.tertiary,
          textStyle: AppTypography.labelLg.copyWith(fontWeight: FontWeight.w700),
        ),
      ),

      // ── Input Decoration ──────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant, // fallback from highest
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary.withOpacity(0.40),
            width: 1,
          ),
        ),
        hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.outline),
        labelStyle: AppTypography.bodyMd,
      ),

      // ── Card Theme (no borders — tonal layering only) ─────────────────
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // xl = 1.5rem ≈ 24px
        ),
      ),

      // ── Bottom Navigation ─────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        selectedItemColor: AppColors.tertiary,
        unselectedItemColor: AppColors.outline,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700),
      ),

      // ── Chip theme ────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        selectedColor: AppColors.secondaryContainer,
        labelStyle: AppTypography.labelMd,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ── Divider ───────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: Colors.transparent, // "No-Line Rule"
        thickness: 0,
      ),

      // ── Text Theme ────────────────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLg,
        displayMedium: AppTypography.displayMd,
        headlineLarge: AppTypography.headlineLg,
        headlineMedium: AppTypography.headlineMd,
        headlineSmall: AppTypography.headlineSm,
        titleLarge: AppTypography.titleLg,
        titleMedium: AppTypography.titleMd,
        titleSmall: AppTypography.titleSm,
        bodyLarge: AppTypography.bodyLg,
        bodyMedium: AppTypography.bodyMd,
        bodySmall: AppTypography.bodySm,
        labelLarge: AppTypography.labelLg,
        labelMedium: AppTypography.labelMd,
        labelSmall: AppTypography.labelSm,
      ),
    );
  }
}
