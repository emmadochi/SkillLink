import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/skilllink_card.dart';
import '../../../../shared/widgets/skilllink_input.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      body: CustomScrollView(
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
                            Text('John Doe',
                                style: AppTypography.headlineSm.copyWith(
                                    color: AppColors.onPrimary,
                                    fontSize: 18)),
                          ],
                        ),
                      ),
                      // Notifications
                      IconButton(
                        onPressed: () => context.go(AppRoutes.notifications),
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
                  Container(
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
                        Text('Lagos, Nigeria',
                            style: AppTypography.labelMd.copyWith(
                                color: Colors.white)),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            size: 16, color: Colors.white70),
                      ],
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
                        context.go(AppRoutes.artisanListing),
                    child: Text('See All',
                        style: AppTypography.labelLg.copyWith(
                            color: AppColors.primary)),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 110,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                scrollDirection: Axis.horizontal,
                itemCount: AppConstants.serviceCategories.length,
                itemBuilder: (context, i) {
                  final cat = AppConstants.serviceCategories[i];
                  final selected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory =
                          selected ? null : cat);
                      context.go('${AppRoutes.artisanListing}?category=$cat');
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 14),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : AppColors.surfaceContainerLowest,
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
                            _categoryIcons[cat] ?? Icons.build_outlined,
                            size: 24,
                            color:
                                selected ? AppColors.onPrimary : AppColors.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(cat,
                              style: AppTypography.labelSm.copyWith(
                                  color: selected
                                      ? AppColors.onPrimary
                                      : AppColors.onSurface)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Featured Artisans ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Row(children: [
                Text('Featured Artisans',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go(AppRoutes.artisanListing),
                  child: Text('See All',
                      style: AppTypography.labelLg.copyWith(
                          color: AppColors.primary)),
                ),
              ]),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 280,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SkillLinkArtisanCard(
                      name: 'Emmanuel O.',
                      craft: 'Master Plumber',
                      imageUrl: 'https://i.pravatar.cc/200?img=${i + 10}',
                      rating: 4.8,
                      price: '₦5,000/hr',
                      location: 'Lagos Island',
                      isVerified: i % 2 == 0,
                      onTap: () =>
                          context.go('${AppRoutes.artisanProfile}/${i + 1}'),
                    ),
                  );
                },
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

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                child: SkillLinkCard(
                  padding: const EdgeInsets.all(16),
                  onTap: () {},
                  child: Row(children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.bolt_outlined,
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Electrical Repair',
                              style:
                                  Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 3),
                          Text('Chukwudi A. • Yesterday',
                              style: Theme.of(context).textTheme.labelMedium),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6FFE8),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text('Completed',
                          style: AppTypography.labelSm.copyWith(
                              color: const Color(0xFF0A6E3A))),
                    ),
                  ]),
                ),
              ),
              childCount: 3,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
