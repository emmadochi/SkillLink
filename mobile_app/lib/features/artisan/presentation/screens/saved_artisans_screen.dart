import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/skilllink_card.dart';
import '../providers/artisan_provider.dart';

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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border_rounded, size: 64, color: AppColors.outlineVariant),
                  const SizedBox(height: 16),
                  Text('No saved artisans yet', style: AppTypography.titleSmall),
                  const SizedBox(height: 8),
                  Text('Artisans you save will appear here', style: AppTypography.labelMd.copyWith(color: AppColors.outline)),
                ],
              ),
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
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        artisan.user?.avatarUrl ?? 'https://i.pravatar.cc/100?u=${artisan.userId}',
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceContainerHigh, child: const Icon(Icons.person)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(artisan.user?.name ?? 'Artisan', style: AppTypography.titleSm),
                          const SizedBox(height: 4),
                          Text(artisan.skill ?? 'Professional', style: AppTypography.labelMd.copyWith(color: AppColors.outline)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB84D)),
                              const SizedBox(width: 4),
                              Text('${artisan.rating}', style: AppTypography.labelSm),
                              const SizedBox(width: 12),
                              const Icon(Icons.location_on_rounded, size: 14, color: AppColors.outline),
                              const SizedBox(width: 4),
                              Expanded(child: Text(artisan.locationName ?? 'Lagos', style: AppTypography.labelSm, overflow: TextOverflow.ellipsis)),
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
        error: (e, __) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
