import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/skilllink_card.dart';
import '../../../../shared/widgets/skilllink_empty_state.dart';
import '../providers/artisan_provider.dart';
import '../../../../core/utils/url_utils.dart';

class SavedArtisansScreen extends ConsumerWidget {
  const SavedArtisansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(savedArtisansProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Saved Artisans'),
        backgroundColor: AppColors.surfaceContainerLowest,
      ),
      body: savedAsync.when(
        data: (artisans) {
          if (artisans.isEmpty) {
            return SkillLinkEmptyState(
              icon: Icons.bookmark_border_rounded,
              title: 'No Saved Artisans Yet',
              message: 'Bookmark trusted professionals you want to work with again for quick access.',
              buttonLabel: 'Explore Artisans',
              buttonIcon: Icons.search_rounded,
              onButtonPressed: () => context.push(AppRoutes.artisanListing),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: artisans.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final artisan = artisans[index];
              return SkillLinkCard(
                onTap: () => context.push('${AppRoutes.artisanProfile}/${artisan.userId}'),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: UrlUtils.resolveImageUrl(artisan.user?.avatarUrl),
                        width: 68,
                        height: 68,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 68,
                          height: 68,
                          color: AppColors.surfaceContainerHigh,
                          child: const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 68,
                          height: 68,
                          color: AppColors.surfaceContainerHigh,
                          child: const Icon(Icons.person, color: AppColors.outline),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  artisan.user?.name ?? 'Artisan',
                                  style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (artisan.identityVerified || artisan.identityStatus == 'approved') ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified, size: 15, color: AppColors.primary),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            artisan.skill ?? 'Professional Artisan',
                            style: AppTypography.labelMd.copyWith(color: AppColors.outline),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFB84D).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFB84D)),
                                    const SizedBox(width: 2),
                                    Text(
                                      artisan.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF996B00),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.location_on_rounded, size: 14, color: AppColors.outline),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  artisan.locationName ?? 'Nearby',
                                  style: AppTypography.labelSm.copyWith(color: AppColors.outline),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.outline),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => SkillLinkEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Unable to Load Saved Artisans',
          message: 'Error: $e',
          buttonLabel: 'Retry',
          onButtonPressed: () => ref.invalidate(savedArtisansProvider),
          accentColor: AppColors.error,
        ),
      ),
    );
  }
}
