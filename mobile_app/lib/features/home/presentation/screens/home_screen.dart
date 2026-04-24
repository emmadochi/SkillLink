import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import 'package:skilllink_app/features/artisan/presentation/providers/category_provider.dart';
import '../../../../shared/widgets/skilllink_card.dart';
import '../../../../shared/widgets/skilllink_input.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink_app/features/auth/presentation/providers/user_provider.dart';
import 'package:skilllink_app/features/artisan/presentation/providers/artisan_provider.dart';
import 'package:skilllink_app/features/booking/presentation/providers/booking_provider.dart';
import 'package:skilllink_app/core/network/location_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String? _selectedCategory;

  static const _categoryIcons = <String, IconData>{
    'Plumbing': Icons.water_drop_outlined,
    'Electrical': Icons.bolt_outlined,
    'Carpentry': Icons.handyman_outlined,
    'Cleaning': Icons.cleaning_services_outlined,
    'Painting': Icons.format_paint_outlined,
    'Tiling': Icons.grid_4x4_outlined,
    'Welding': Icons.whatshot_outlined,
    'AC Repair': Icons.ac_unit_outlined,
    'Landscaping': Icons.grass_outlined,
    'Moving': Icons.local_shipping_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(categoriesProvider);
          ref.invalidate(artisansProvider);
          ref.invalidate(bookingHistoryProvider);
          // Wait for the main data to reload
          await ref.read(categoriesProvider.future);
          await ref.read(artisansProvider(query: _searchCtrl.text).future);
        },
        edgeOffset: MediaQuery.of(context).padding.top + 20,
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          // ── Hero Header ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.heroGradient),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 24,
                right: 24,
                bottom: 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Brand logo mark
                      Image.asset(
                        'assets/images/logo2.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Good Morning 👋',
                                style: AppTypography.labelLg.copyWith(
                                    color: AppColors.onPrimary.withOpacity(0.70))),
                            const SizedBox(height: 2),
                            ref.watch(userStateProvider).when(
                                  data: (user) => Text(user?.name ?? 'Guest User',
                                      style: AppTypography.headlineSm.copyWith(
                                          color: AppColors.onPrimary,
                                          fontSize: 18)),
                                  loading: () => const Text('...',
                                      style: TextStyle(color: Colors.white)),
                                  error: (_, __) => const Text('Error',
                                      style: TextStyle(color: Colors.white)),
                                ),
                          ],
                        ),
                      ),
                      // Notifications
                      IconButton(
                        onPressed: () => context.push(AppRoutes.notifications),
                        icon: const Icon(Icons.notifications_outlined,
                            color: Colors.white),
                      ),
                      // Avatar
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.surfaceTint,
                        child: Icon(Icons.person_rounded,
                            size: 20, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Location pill
                  GestureDetector(
                    onTap: () => ref.read(currentLocationProvider.notifier).detectLocation(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 14, color: AppColors.tertiaryFixed),
                          const SizedBox(width: 6),
                          ref.watch(currentLocationProvider).when(
                                data: (loc) => Text(loc.name,
                                    style: AppTypography.labelMd.copyWith(
                                        color: Colors.white)),
                                loading: () => const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white)),
                                error: (_, __) => Text('Error detecting',
                                    style: AppTypography.labelMd.copyWith(
                                        color: Colors.white)),
                              ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down_rounded,
                              size: 16, color: Colors.white70),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: SkillLinkInput(
                      hint: 'Search for a service or artisan...',
                      controller: _searchCtrl,
                      prefixIcon: const Icon(Icons.search_rounded,
                          size: 20, color: AppColors.outline),
                      onChanged: (v) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Categories ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Row(
                children: [
                  Text('Categories',
                      style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  TextButton(
                    onPressed: () =>
                        context.push(AppRoutes.artisanListing),
                    child: Text('See All',
                        style: AppTypography.labelLg.copyWith(
                            color: AppColors.primary)),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: ref.watch(categoriesProvider).when(
              data: (categories) => SizedBox(
                height: 110,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, i) {
                    final cat = categories[i];
                    final selected = _selectedCategory == cat.name;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategory = selected ? null : cat.name);
                        context.push('${AppRoutes.artisanListing}?category=${cat.name}&categoryId=${cat.id}');
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 14),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _categoryIcons[cat.name] ?? Icons.build_outlined,
                              size: 24,
                              color: selected ? AppColors.onPrimary : AppColors.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(cat.name,
                                style: AppTypography.labelSm.copyWith(
                                    color: selected ? AppColors.onPrimary : AppColors.onSurface)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              loading: () => const SizedBox(height: 110, child: Center(child: CircularProgressIndicator())),
              error: (err, _) => const SizedBox.shrink(),
            ),
          ),

          // ── Featured Artisans ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Row(children: [
                const Icon(Icons.auto_awesome_rounded, size: 20, color: Color(0xFFFFB84D)),
                const SizedBox(width: 8),
                Text('Featured Artisans',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push(AppRoutes.artisanListing),
                  child: Text('See All',
                      style: AppTypography.labelLg.copyWith(
                          color: AppColors.primary)),
                ),
              ]),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 310,
              child: ref.watch(artisansProvider(query: _searchCtrl.text)).when(
                    data: (artisans) {
                      if (artisans.isEmpty) {
                        return const Center(child: Text('No artisans available'));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        scrollDirection: Axis.horizontal,
                        itemCount: artisans.length > 5 ? 5 : artisans.length,
                        itemBuilder: (context, i) {
                          final artisan = artisans[i];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: SkillLinkArtisanCard(
                              name: artisan.user?.name ?? 'Artisan',
                              craft: artisan.skill ?? artisan.bio ?? 'Professional Artisan',
                              imageUrl: artisan.user?.avatarUrl != null 
                                  ? (artisan.user!.avatarUrl!.startsWith('http') ? artisan.user!.avatarUrl! : 'http://localhost/SkillLink/api/public/${artisan.user!.avatarUrl}')
                                  : 'https://i.pravatar.cc/200?u=${artisan.userId}',
                              rating: artisan.rating.toDouble(),
                              price: '₦${NumberFormat('#,###').format(artisan.hourlyRate)}/hr',
                              location: artisan.locationName ?? 'Lagos',
                              isVerified: true,
                              onTap: () => context.push(
                                  '${AppRoutes.artisanProfile}/${artisan.userId}'),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                        child: CircularProgressIndicator(color: AppColors.primary)),
                    error: (err, __) => Center(child: Text('Error: $err')),
                  ),
            ),
          ),

          // ── Recent Bookings ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
              child: Text('Recent Activity',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          ),

          ref.watch(bookingHistoryProvider).when(
                data: (bookings) {
                  if (bookings.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('No recent activity')),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final booking = bookings[i];
                        final statusColor = _getStatusColor(booking.status);
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                          child: SkillLinkCard(
                            padding: const EdgeInsets.all(12),
                            onTap: () => context.push('${AppRoutes.bookingDetail}/${booking.id}'),
                            child: Row(
                              children: [
                                // Artisan Avatar or Category Icon
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 54,
                                    height: 54,
                                    color: AppColors.surfaceContainerHigh,
                                    child: booking.partnerAvatar != null
                                        ? Image.network(
                                            booking.partnerAvatar!.startsWith('http') 
                                              ? booking.partnerAvatar! 
                                              : 'http://localhost/SkillLink/api/public/${booking.partnerAvatar}',
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.outline),
                                          )
                                        : const Icon(Icons.handyman_rounded, color: AppColors.primary),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        booking.partnerName ?? 'Artisan',
                                        style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        booking.categoryName ?? 'Service',
                                        style: AppTypography.labelSm.copyWith(color: AppColors.outline),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today_rounded, size: 10, color: AppColors.outline.withOpacity(0.6)),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDate(booking.scheduledAt),
                                            style: TextStyle(fontSize: 10, color: AppColors.outline.withOpacity(0.6)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₦${NumberFormat('#,###').format(booking.price)}',
                                      style: AppTypography.titleSm.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      child: Text(
                                        booking.status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w800,
                                          color: statusColor,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: bookings.length > 3 ? 3 : bookings.length,
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, __) => SliverToBoxAdapter(
                  child: Center(child: Text('Error: $err')),
                ),
              ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
     ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return const Color(0xFF0A6E3A);
      case 'confirmed': return AppColors.primary;
      case 'pending': return const Color(0xFF856404);
      case 'cancelled': return AppColors.error;
      default: return AppColors.outline;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, h:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
}
