import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/skilllink_card.dart';
import '../../../../shared/widgets/skilllink_input.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink_app/features/artisan/presentation/providers/artisan_provider.dart';
import 'package:skilllink_app/features/artisan/data/models/artisan_model.dart';

class ArtisanListingScreen extends ConsumerStatefulWidget {
  final String? category;
  final int? categoryId;
  const ArtisanListingScreen({super.key, this.category, this.categoryId});

  @override
  ConsumerState<ArtisanListingScreen> createState() => _ArtisanListingScreenState();
}

class _ArtisanListingScreenState extends ConsumerState<ArtisanListingScreen> {
  String _sortBy = 'Rating';
  String? _selectedFilter;
  final _searchCtrl = TextEditingController();

  static const _filters = ['Rating', 'Price: Low', 'Price: High', 'Nearest'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(widget.category ?? 'All Artisans',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.onSurface,
                  fontFamily: 'PlusJakartaSans',
                )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search + Sort
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: SkillLinkInput(
              hint: 'Search artisans...',
              controller: _searchCtrl,
              prefixIcon: const Icon(Icons.search_rounded,
                  size: 18, color: AppColors.outline),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // Filter chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, i) {
                final f = _filters[i];
                final selected = _sortBy == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: FilterChip(
                    label: Text(f),
                    selected: selected,
                    onSelected: (_) => setState(() => _sortBy = f),
                    selectedColor: AppColors.secondaryContainer,
                    checkmarkColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceContainerLowest,
                    side: BorderSide.none,
                    labelStyle: AppTypography.labelMd.copyWith(
                      color: selected ? AppColors.primary : AppColors.onSurface,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Artisan list
          Expanded(
            child: ref.watch(artisansProvider(
              categoryId: widget.categoryId,
              query: _searchCtrl.text.isEmpty ? null : _searchCtrl.text,
            )).when(
                  data: (artisans) {
                    if (artisans.isEmpty) {
                      return Center(
                        child: Text('No artisans found',
                            style: AppTypography.bodyLg),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: artisans.length,
                      itemBuilder: (context, i) {
                        final artisan = artisans[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SkillLinkCard(
                            elevated: true,
                            onTap: () => context.push(
                                '${AppRoutes.artisanProfile}/${artisan.userId}'),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(24),
                                    bottomLeft: Radius.circular(24),
                                  ),
                                  child: Image.network(
                                    artisan.user?.avatarUrl ??
                                        'https://i.pravatar.cc/120?u=${artisan.userId}',
                                    width: 110,
                                    height: 130,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 110,
                                      height: 130,
                                      color: AppColors.surfaceContainerLow,
                                      child: const Icon(Icons.person,
                                          size: 40, color: AppColors.outline),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Info
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                            vertical: 16)
                                        .copyWith(right: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Expanded(
                                            child: Text(artisan.user?.name ?? 'Artisan',
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(Icons.verified,
                                              size: 14,
                                              color: AppColors.primary),
                                        ]),
                                        const SizedBox(height: 3),
                                        Text(artisan.skill ?? artisan.bio ?? 'Professional Artisan',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall),
                                        const SizedBox(height: 10),
                                        Row(children: [
                                          const Icon(Icons.star_rounded,
                                              size: 14,
                                              color: Color(0xFFFFB84D)),
                                          const SizedBox(width: 3),
                                          Text('${artisan.rating}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium),
                                          const SizedBox(width: 8),
                                          Text('(${artisan.experienceYears} yrs exp)',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall),
                                        ]),
                                        const SizedBox(height: 6),
                                        Row(children: [
                                          const Icon(Icons.location_on_outlined,
                                              size: 12,
                                              color: AppColors.outline),
                                          const SizedBox(width: 4),
                                          Text(
                                              artisan.locationName ??
                                                  'Nearby',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium),
                                        ]),
                                        const SizedBox(height: 10),
                                        Text('₦5,000/hr', // Default or from model if added
                                            style: AppTypography.titleSm
                                                .copyWith(
                                                    color: AppColors.primary)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (err, stack) => Center(
                    child: Text('Error: $err',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMd
                            .copyWith(color: AppColors.error)),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter Options',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text('Distance', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: ['< 2 km', '< 5 km', '< 10 km', 'Any']
                  .map((d) => FilterChip(
                        label: Text(d),
                        selected: false,
                        onSelected: (_) {},
                        side: BorderSide.none,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
