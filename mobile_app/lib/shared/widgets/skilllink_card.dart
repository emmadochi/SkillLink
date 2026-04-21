import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// SkillLinkCard — xl rounding (24px), tonal lift, ambient shadow.
/// No borders. Background shifts define depth per the "No-Line Rule".
class SkillLinkCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double borderRadius;
  final bool elevated;

  const SkillLinkCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.onTap,
    this.borderRadius = 24,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: elevated
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Artisan card with portrait "breaking the bounds" effect
class SkillLinkArtisanCard extends StatelessWidget {
  final String name;
  final String craft;
  final String imageUrl;
  final double rating;
  final String price;
  final String location;
  final bool isVerified;
  final VoidCallback? onTap;

  const SkillLinkArtisanCard({
    super.key,
    required this.name,
    required this.craft,
    required this.imageUrl,
    required this.rating,
    required this.price,
    required this.location,
    this.isVerified = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portrait — breaks top bounds via negative margin effect
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 140,
                      color: AppColors.surfaceContainerLow,
                      child: const Icon(Icons.person,
                          size: 48, color: AppColors.outline),
                    ),
                  ),
                ),
                if (isVerified)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified,
                          size: 12, color: AppColors.onPrimary),
                    ),
                  ),
              ],
            ),

            // Info section — tonal shift
            Container(
              padding: const EdgeInsets.all(14),
              color: AppColors.surfaceContainerLow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(craft,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 14, color: Color(0xFFFFB84D)),
                      const SizedBox(width: 3),
                      Text(rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.labelMedium),
                      const Spacer(),
                      Text(price,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
