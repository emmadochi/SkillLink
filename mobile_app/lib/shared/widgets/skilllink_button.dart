import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// SkillLinkButton — Pill-shaped (StadiumBorder) with gradient support.
/// Golden Path actions (Book Now, Pay) use the primary→primaryContainer gradient.
class SkillLinkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isGradient;
  final bool isLoading;
  final bool isOutlined;
  final Widget? icon;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const SkillLinkButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isGradient = false,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.padding,
  });

  const SkillLinkButton.gradient({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.padding,
  })  : isGradient = true,
        isOutlined = false;

  const SkillLinkButton.outlined({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.padding,
  })  : isGradient = false,
        isOutlined = true;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.onPrimary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleMd.copyWith(
                    color: isOutlined ? AppColors.primary : AppColors.onPrimary,
                  ),
                ),
              ),
            ],
          );

    if (isOutlined) {
      return SizedBox(
        width: width,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            shape: const StadiumBorder(),
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          child: child,
        ),
      );
    }

    if (isGradient) {
      return GestureDetector(
        onTap: isLoading ? null : onPressed,
        child: Container(
          width: width,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            gradient: AppColors.buttonGradient,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.30),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(child: child),
        ),
      );
    }

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          shape: const StadiumBorder(),
        ),
        child: child,
      ),
    );
  }
}
