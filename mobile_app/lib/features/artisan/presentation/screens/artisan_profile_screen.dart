import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/skilllink_button.dart';
import '../../../../shared/widgets/skilllink_card.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink_app/features/artisan/presentation/providers/artisan_provider.dart';
import 'package:skilllink_app/features/artisan/data/models/artisan_model.dart';

class ArtisanProfileScreen extends ConsumerStatefulWidget {
  final String artisanId;
  const ArtisanProfileScreen({super.key, required this.artisanId});

  @override
  ConsumerState<ArtisanProfileScreen> createState() => _ArtisanProfileScreenState();
}

class _ArtisanProfileScreenState extends ConsumerState<ArtisanProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: ref.watch(artisanProfileProvider(int.parse(widget.artisanId))).when(
            data: (artisan) => CustomScrollView(
              slivers: [
                // ── Hero Header ──────────────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 320,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        _isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => setState(() => _isSaved = !_isSaved),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Portrait
                        Image.network(
                          artisan.user?.avatarUrl ?? 'https://i.pravatar.cc/400?u=${artisan.userId}',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              color: AppColors.primaryContainer),
                        ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.primary.withOpacity(0.85),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        // Name overlay
                        Positioned(
                          bottom: 24,
                          left: 24,
                          right: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Text(artisan.user?.name ?? 'Artisan',
                                    style: AppTypography.headlineSm.copyWith(
                                        color: Colors.white)),
                                const SizedBox(width: 8),
                                const Icon(Icons.verified,
                                    size: 18, color: AppColors.tertiaryFixed),
                              ]),
                              const SizedBox(height: 4),
                              Text('${artisan.bio ?? artisan.skill ?? 'Professional Artisan'} • ${artisan.experienceYears} yrs experience',
                                  style: AppTypography.bodyMd.copyWith(
                                      color: Colors.white70)),
                              const SizedBox(height: 10),
                              Row(children: [
                                const Icon(Icons.star_rounded,
                                    size: 16, color: Color(0xFFFFB84D)),
                                const SizedBox(width: 4),
                                Text('${artisan.rating} (0 reviews)',
                                    style: AppTypography.labelLg.copyWith(
                                        color: Colors.white70)),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade600,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text('Available',
                                      style: AppTypography.labelSm.copyWith(
                                          color: Colors.white)),
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Stats row ────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        _StatChip(label: 'Jobs', value: '0'),
                        _StatChip(label: 'Rating', value: '${artisan.rating}'),
                        _StatChip(label: 'Rate', value: '₦5k/hr'),
                        _StatChip(label: 'Resp.', value: '< 30m'),
                      ],
                    ),
                  ),
                ),

                // ── Tabs ─────────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.outline,
                    indicatorColor: AppColors.primary,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: AppTypography.labelLg.copyWith(
                        fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'About'),
                      Tab(text: 'Portfolio'),
                      Tab(text: 'Reviews'),
                    ],
                  ),
                ),

                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _AboutTab(artisan: artisan),
                      _PortfolioTab(),
                      _ReviewsTab(),
                    ],
                  ),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, __) => Center(child: Text('Error: $err')),
          ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Row(children: [
          Expanded(
            child: SkillLinkButton.outlined(
              label: 'Message',
              icon: const Icon(Icons.chat_bubble_outline_rounded,
                  size: 16, color: AppColors.primary),
              onPressed: () => context.go(
                  '${AppRoutes.chat}/${widget.artisanId}'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SkillLinkButton.gradient(
              label: 'Book Now',
              icon: const Icon(Icons.calendar_month_outlined,
                  size: 16, color: Colors.white),
              onPressed: () => context.go(
                  '${AppRoutes.booking}/${widget.artisanId}'),
            ),
          ),
        ]),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(value,
                style: AppTypography.titleMd.copyWith(color: AppColors.primary)),
            const SizedBox(height: 3),
            Text(label, style: AppTypography.labelSm),
          ],
        ),
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  final Artisan artisan;
  const _AboutTab({required this.artisan});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Bio', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Text(
          artisan.bio ?? 'No bio available.',
          style: AppTypography.bodyMd.copyWith(height: 1.6),
        ),
        const SizedBox(height: 20),
        Text('Location', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        Chip(
          label: Text(artisan.locationName ?? 'Lagos, Nigeria'),
          avatar: const Icon(Icons.location_on_outlined, size: 14),
        ),
      ],
    );
  }
}

class _PortfolioTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: 6,
      itemBuilder: (context, i) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          'https://picsum.photos/200/220?random=${i + 20}',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Container(color: AppColors.surfaceContainerLow),
        ),
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => SkillLinkCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage('https://i.pravatar.cc/60?img=${i + 30}'),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer ${i + 1}',
                      style: Theme.of(context).textTheme.titleSmall),
                  Text('3 days ago', style: Theme.of(context).textTheme.labelSmall),
                ],
              )),
              Row(children: List.generate(5, (j) => Icon(
                Icons.star_rounded,
                size: 14,
                color: j < 5 - (i % 2) ? const Color(0xFFFFB84D) : AppColors.outlineVariant,
              ))),
            ]),
            const SizedBox(height: 10),
            Text(
              'Excellent work! Very professional, arrived on time, and cleaned up after the job. Highly recommended!',
              style: AppTypography.bodyMd.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
