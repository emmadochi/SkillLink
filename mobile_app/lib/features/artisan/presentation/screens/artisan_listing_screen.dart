import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/skilllink_card.dart';
import '../../../../shared/widgets/skilllink_input.dart';
import '../../../../shared/widgets/skilllink_empty_state.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink_app/features/artisan/presentation/providers/artisan_provider.dart';
import 'package:skilllink_app/features/artisan/data/models/artisan_model.dart';
import '../../../../core/utils/url_utils.dart';

class ArtisanListingScreen extends ConsumerStatefulWidget {
  final String? category;
  final int? categoryId;
  final String? skills;
  const ArtisanListingScreen({super.key, this.category, this.categoryId, this.skills});

  @override
  ConsumerState<ArtisanListingScreen> createState() => _ArtisanListingScreenState();
}

class _ArtisanListingScreenState extends ConsumerState<ArtisanListingScreen> {
  String _sortBy = 'Rating';
  final _searchCtrl = TextEditingController();

  static const _filters = ['Rating', 'Price: Low', 'Price: High', 'Nearest'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

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
                  fontWeight: FontWeight.bold,
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
              hint: 'Search artisans by name, skill...',
              controller: _searchCtrl,
              prefixIcon: const Icon(Icons.search_rounded,
                  size: 18, color: AppColors.outline),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () => setState(() => _searchCtrl.clear()),
                    )
                  : null,
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    labelStyle: AppTypography.labelMd.copyWith(
                      color: selected ? AppColors.primary : AppColors.onSurface,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
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
              skills: widget.skills,
            )).when(
                  data: (artisans) {
                    if (artisans.isEmpty) {
                      return SkillLinkEmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No Artisans Found',
                        message: _searchCtrl.text.isNotEmpty
                            ? 'No verified artisans match "${_searchCtrl.text}". Try another query or clear filters.'
                            : 'No artisans currently listed in this category. Check back soon or explore other services.',
                        buttonLabel: _searchCtrl.text.isNotEmpty ? 'Clear Search' : 'View All Artisans',
                        buttonIcon: _searchCtrl.text.isNotEmpty ? Icons.clear : Icons.grid_view_rounded,
                        onButtonPressed: () {
                          if (_searchCtrl.text.isNotEmpty) {
                            setState(() => _searchCtrl.clear());
                          } else {
                            context.push(AppRoutes.home);
                          }
                        },
                      );
                    }

                    // Sort client-side if needed
                    final sortedList = List<Artisan>.from(artisans);
                    if (_sortBy == 'Rating') {
                      sortedList.sort((a, b) => b.rating.compareTo(a.rating));
                    } else if (_sortBy == 'Price: Low') {
                      sortedList.sort((a, b) => a.hourlyRate.compareTo(b.hourlyRate));
                    } else if (_sortBy == 'Price: High') {
                      sortedList.sort((a, b) => b.hourlyRate.compareTo(a.hourlyRate));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: sortedList.length,
                      itemBuilder: (context, i) {
                        final artisan = sortedList[i];
                        final priceDisplay = artisan.hourlyRate > 0
                            ? '₦${NumberFormat('#,###').format(artisan.hourlyRate)}/hr'
                            : '₦5,000/hr';
                        final isAvailable = artisan.isAvailable;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: SkillLinkCard(
                            elevated: true,
                            onTap: () => context.push(
                                '${AppRoutes.artisanProfile}/${artisan.userId}'),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar with status indicator
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(24),
                                        bottomLeft: Radius.circular(24),
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl: UrlUtils.resolveImageUrl(artisan.user?.avatarUrl),
                                        width: 116,
                                        height: 146,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) => Container(
                                          width: 116,
                                          height: 146,
                                          color: AppColors.surfaceContainerLow,
                                          child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                                        ),
                                        errorWidget: (_, __, ___) => Container(
                                          width: 116,
                                          height: 146,
                                          color: AppColors.surfaceContainerLow,
                                          child: const Icon(Icons.person,
                                              size: 44, color: AppColors.outline),
                                        ),
                                      ),
                                    ),
                                    // Availability Pill Over Image
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.65),
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 7,
                                              height: 7,
                                              decoration: BoxDecoration(
                                                color: isAvailable ? const Color(0xFF10B981) : Colors.grey,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              isAvailable ? 'Available' : 'Busy',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(width: 14),

                                // Info Column
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 14).copyWith(right: 14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Name & Verification
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                artisan.user?.name ?? 'Artisan',
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                              ),
                                            ),
                                            if (artisan.identityVerified || artisan.identityStatus == 'approved') ...[
                                              const SizedBox(width: 4),
                                              const Icon(Icons.verified, size: 16, color: AppColors.primary),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 3),

                                        // Skill / Category
                                        Text(
                                          artisan.skill ?? artisan.bio ?? 'Professional Artisan',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.bodySm.copyWith(
                                            color: AppColors.outline,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        // Rating & Experience Row
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFB84D).withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB84D)),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    artisan.rating.toStringAsFixed(1),
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w700,
                                                      color: Color(0xFF996B00),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${artisan.experienceYears} yrs exp',
                                              style: AppTypography.labelSm.copyWith(color: AppColors.outline),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),

                                        // Location / Distance
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on_outlined, size: 13, color: AppColors.outline),
                                            const SizedBox(width: 3),
                                            Expanded(
                                              child: Text(
                                                artisan.locationName ?? 'Nearby',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppTypography.labelSm.copyWith(color: AppColors.outline),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),

                                        // Price Badge
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              priceDisplay,
                                              style: AppTypography.titleSm.copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary.withOpacity(0.08),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'View Profile',
                                                style: AppTypography.labelSm.copyWith(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
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
                  error: (err, stack) => SkillLinkEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Failed to Load Artisans',
                    message: 'Please check your connection and try again.',
                    buttonLabel: 'Retry',
                    onButtonPressed: () => ref.invalidate(artisansProvider),
                    accentColor: AppColors.error,
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
            Text('Filter Artisans',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Distance Radius', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: ['< 2 km', '< 5 km', '< 10 km', 'Any Distance']
                  .map((d) => FilterChip(
                        label: Text(d),
                        selected: d == 'Any Distance',
                        onSelected: (_) => Navigator.pop(context),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
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
