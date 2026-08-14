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

      colorScheme: const ColorScheme(
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

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.tertiary,
          textStyle: AppTypography.labelLg.copyWith(fontWeight: FontWeight.w700),
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

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

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkSurface,

      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFF60A5FA),
        onPrimary: Color(0xFF000C47),
        primaryContainer: Color(0xFF1E3A8A),
        onPrimaryContainer: Colors.white,
        secondary: Color(0xFF94A3B8),
        onSecondary: Color(0xFF0B101B),
        secondaryContainer: Color(0xFF334155),
        onSecondaryContainer: Colors.white,
        tertiary: AppColors.tertiary,
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFF7C2D12),
        onTertiaryContainer: Color(0xFFFFDDB8),
        error: Color(0xFFF87171),
        onError: Color(0xFF450A0A),
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        onSurfaceVariant: AppColors.darkOnSurfaceVariant,
        outline: Color(0xFF64748B),
        outlineVariant: Color(0xFF334155),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        iconTheme: IconThemeData(color: AppColors.darkOnSurface),
        centerTitle: false,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: const StadiumBorder(),
          textStyle: AppTypography.titleMd,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.darkSurfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      textTheme: TextTheme(
        displayLarge: AppTypography.displayLg.copyWith(color: AppColors.darkOnSurface),
        displayMedium: AppTypography.displayMd.copyWith(color: AppColors.darkOnSurface),
        headlineLarge: AppTypography.headlineLg.copyWith(color: AppColors.darkOnSurface),
        headlineMedium: AppTypography.headlineMd.copyWith(color: AppColors.darkOnSurface),
        headlineSmall: AppTypography.headlineSm.copyWith(color: AppColors.darkOnSurface),
        titleLarge: AppTypography.titleLg.copyWith(color: const Color(0xFF93C5FD)),
        titleMedium: AppTypography.titleMd.copyWith(color: AppColors.darkOnSurface),
        titleSmall: AppTypography.titleSm.copyWith(color: AppColors.darkOnSurface),
        bodyLarge: AppTypography.bodyLg.copyWith(color: AppColors.darkOnSurface),
        bodyMedium: AppTypography.bodyMd.copyWith(color: AppColors.darkOnSurface),
        bodySmall: AppTypography.bodySm.copyWith(color: AppColors.darkOnSurfaceVariant),
        labelLarge: AppTypography.labelLg.copyWith(color: AppColors.darkOnSurfaceVariant),
        labelMedium: AppTypography.labelMd.copyWith(color: AppColors.darkOnSurfaceVariant),
        labelSmall: AppTypography.labelSm.copyWith(color: AppColors.darkOnSurfaceVariant),
      ),
    );
  }
}
