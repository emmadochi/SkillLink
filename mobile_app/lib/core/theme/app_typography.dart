import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography System – "Editorial Voice"
/// Headlines / Display : Plus Jakarta Sans (loaded as local font + Google fallback)
/// Body / Labels       : Inter (Google Fonts)

class AppTypography {
  AppTypography._();

  // ── DISPLAY (Plus Jakarta Sans — tight letter-spacing) ────────────────
  static TextStyle get displayLg => GoogleFonts.plusJakartaSans(
    fontSize: 57,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.14, // -0.02em of 57px
    color: AppColors.onSurface,
    height: 1.12,
  );

  static TextStyle get displayMd => GoogleFonts.plusJakartaSans(
    fontSize: 45,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.90,
    color: AppColors.onSurface,
    height: 1.15,
  );

  // ── HEADLINES (Plus Jakarta Sans) ─────────────────────────────────────
  static TextStyle get headlineLg => GoogleFonts.plusJakartaSans(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.64,
    color: AppColors.onSurface,
    height: 1.25,
  );

  static TextStyle get headlineMd => GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.56,
    color: AppColors.onSurface,
    height: 1.29,
  );

  static TextStyle get headlineSm => GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.48,
    color: AppColors.onSurface,
    height: 1.33,
  );

  // ── TITLES (Inter) ────────────────────────────────────────────────────
  static TextStyle get titleLg => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    height: 1.27,
  );

  static TextStyle get titleMd => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    height: 1.5,
  );

  static TextStyle get titleSm => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    height: 1.43,
  );

  // ── BODY (Inter) ──────────────────────────────────────────────────────
  static TextStyle get bodyLg => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
    height: 1.5,
  );

  static TextStyle get bodyMd => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
    height: 1.43,
  );

  static TextStyle get bodySm => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
    height: 1.33,
  );

  // ── LABELS (Inter — "quiet zone" metadata) ────────────────────────────
  static TextStyle get labelLg => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.outline,
    height: 1.43,
  );

  static TextStyle get labelMd => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.outline,
    height: 1.33,
  );

  static TextStyle get labelSm => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.outline,
    letterSpacing: 0.5,
    height: 1.45,
  );
}
