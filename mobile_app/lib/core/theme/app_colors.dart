import 'package:flutter/material.dart';

/// SkillLink Design System – "The Trusted Curator"
/// Palette: "Deep Sea" (primary) + "Golden Hour" (accent)
/// Source: DESIGN.md – Stitch AI Vanguard Blue

class AppColors {
  AppColors._();

  // ── Primary – "Deep Sea" ─────────────────────────────────────────────
  static const Color primary           = Color(0xFF000C47);
  static const Color primaryContainer  = Color(0xFF001B7A);
  static const Color onPrimary         = Color(0xFFFFFFFF);
  static const Color surfaceTint       = Color(0xFF2C4DE1);

  // ── Secondary ───────────────────────────────────────────────────────
  static const Color secondary          = Color(0xFF4C6180);
  static const Color secondaryContainer = Color(0xFFBFDDFE);
  static const Color onSecondary        = Color(0xFFFFFFFF);

  // ── Tertiary – "Golden Hour" ─────────────────────────────────────────
  static const Color tertiary          = Color(0xFFF97316); // Professional Orange
  static const Color tertiaryFixed     = Color(0xFFFFDDB8);
  static const Color onTertiaryFixed   = Color(0xFF2A1700);
  static const Color accent            = Color(0xFFF97316); // Alias for convenience

  // ── Error ────────────────────────────────────────────────────────────
  static const Color error             = Color(0xFFBA1A1A);
  static const Color onError           = Color(0xFFFFFFFF);

  // ── Surface Hierarchy (Tonal Layering) ───────────────────────────────
  static const Color surface                  = Color(0xFFF6FAFE);
  static const Color surfaceVariant           = Color(0xFFDFE3E7);
  static const Color surfaceContainerLowest   = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow      = Color(0xFFF0F4F8);
  static const Color surfaceContainer         = Color(0xFFE8ECF1);
  static const Color surfaceContainerHigh     = Color(0xFFDDE1E6);
  static const Color surfaceContainerHighest  = Color(0xFFD7DBE0);

  // ── Text / On-Surface ─────────────────────────────────────────────
  static const Color onSurface         = Color(0xFF171C1F); // never pure #000
  static const Color onSurfaceVariant  = Color(0xFF40484C);
  static const Color outline           = Color(0xFF74777E);
  static const Color outlineVariant    = Color(0xFFC3C6CE); // at 15% for ghost

  // ── Gradient helpers ─────────────────────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    transform: GradientRotation(2.356), // ~135°
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ── Glassmorphism ────────────────────────────────────────────────────
  static Color get glassBackground => surface.withOpacity(0.80);
}
