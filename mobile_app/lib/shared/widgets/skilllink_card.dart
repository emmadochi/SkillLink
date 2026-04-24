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
        width: 190,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
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
                // Premium "Top Rated" Label
                if (rating >= 4.5)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFFB84D)),
                          const SizedBox(width: 4),
                          Text('TOP RATED', 
                            style: TextStyle(
                              fontSize: 9, 
                              fontWeight: FontWeight.w800, 
                              color: Colors.black.withOpacity(0.8),
                              letterSpacing: 0.5,
                            )),
                        ],
                      ),
                    ),
                  ),
                // Verified Badge - Modern Style
                if (isVerified)
                  Positioned(
                    bottom: -12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Icon(Icons.verified,
                          size: 14, color: Colors.white),
                    ),
                  ),
              ],
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  // Specialty Chip style text
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(craft,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary.withOpacity(0.8),
                        ),
                        maxLines: 1),
                  ),
                  const SizedBox(height: 12),
                  // Location Indicator
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 12, color: AppColors.outline),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(location,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.outline,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Divider for visual structure
                  Container(height: 1, color: AppColors.outline.withOpacity(0.08)),
                  const SizedBox(height: 12),
                  // Price and Rating footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('STARTING FROM', 
                            style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: AppColors.outline.withOpacity(0.6))),
                          Text(price,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            )),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB84D).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB84D)),
                            const SizedBox(width: 2),
                            Text(rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF996B00))),
                          ],
                        ),
                      ),
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
