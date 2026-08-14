import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/skilllink_button.dart';
import '../../../../shared/widgets/skilllink_card.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink_app/features/artisan/presentation/providers/artisan_provider.dart';
import 'package:skilllink_app/features/artisan/data/models/artisan_model.dart';
import 'package:skilllink_app/features/artisan/data/models/review_model.dart';
import '../../../../core/utils/url_utils.dart';

class ArtisanProfileScreen extends ConsumerStatefulWidget {
  final String artisanId;
  const ArtisanProfileScreen({super.key, required this.artisanId});

  @override
  ConsumerState<ArtisanProfileScreen> createState() => _ArtisanProfileScreenState();
}

class _ArtisanProfileScreenState extends ConsumerState<ArtisanProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    final artisanId = int.tryParse(widget.artisanId);
    if (artisanId == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Invalid Artisan ID')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: ref.watch(artisanProfileProvider(artisanId)).when(
            data: (artisan) {
              final isAvailable = artisan.isAvailable;
              final hasPortfolio = artisan.portfolio != null && artisan.portfolio!.isNotEmpty;
              final hasReviews = artisan.reviews != null && artisan.reviews!.isNotEmpty;
              final Review? topReview = hasReviews ? artisan.reviews!.first : null;

              return CustomScrollView(
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
                          artisan.isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          final success = await ref.read(artisanRepositoryProvider).toggleSaveArtisan(artisan.userId);
                          if (success) {
                            ref.invalidate(artisanProfileProvider(artisan.userId));
                            ref.invalidate(savedArtisansProvider);
                          }
                        },
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Cached Portrait
                          CachedNetworkImage(
                            imageUrl: UrlUtils.resolveImageUrl(artisan.user?.avatarUrl),
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: AppColors.primaryContainer,
                              child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.primaryContainer,
                              child: const Icon(Icons.person, size: 80, color: Colors.white38),
                            ),
                          ),
                          // Gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppColors.primary.withOpacity(0.92),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          // Name & Badges Overlay
                          Positioned(
                            bottom: 20,
                            left: 24,
                            right: 24,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Expanded(
                                    child: Text(
                                      artisan.user?.name ?? 'Artisan',
                                      style: AppTypography.headlineSm.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (artisan.identityVerified || artisan.identityStatus == 'approved') ...[
                                    const SizedBox(width: 6),
                                    const Icon(Icons.verified, size: 20, color: Color(0xFF60A5FA)),
                                  ],
                                ]),
                                const SizedBox(height: 4),
                                Text(
                                  '${artisan.bio ?? artisan.skill ?? 'Professional Artisan'} • ${artisan.experienceYears} yrs experience',
                                  style: AppTypography.bodyMd.copyWith(color: Colors.white70),
                                ),
                                const SizedBox(height: 10),
                                Row(children: [
                                  const Icon(Icons.star_rounded, size: 18, color: Color(0xFFFFB84D)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${artisan.rating.toStringAsFixed(1)} (${artisan.reviews?.length ?? 0} reviews)',
                                    style: AppTypography.labelLg.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: isAvailable ? const Color(0xFF10B981) : Colors.grey,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                                        const SizedBox(width: 6),
                                        Text(
                                          isAvailable ? 'Available' : 'Busy',
                                          style: AppTypography.labelSm.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
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
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Row(
                        children: [
                          _StatChip(label: 'Jobs', value: '${artisan.reviews?.length ?? 0}+'),
                          _StatChip(label: 'Rating', value: '${artisan.rating.toStringAsFixed(1)} ★'),
                          _StatChip(
                            label: 'Rate',
                            value: artisan.hourlyRate > 0 ? '₦${artisan.hourlyRate.toInt()}/hr' : '₦5k/hr',
                          ),
                          _StatChip(label: 'Response', value: '< 20m'),
                        ],
                      ),
                    ),
                  ),

                  // ── Above-the-fold Visual Highlights: Portfolio Strip ─────────
                  if (hasPortfolio)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Verified Work Portfolio', style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.bold)),
                                  GestureDetector(
                                    onTap: () => _tabController.animateTo(1),
                                    child: Text('View All', style: AppTypography.labelMd.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 100,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                scrollDirection: Axis.horizontal,
                                itemCount: artisan.portfolio!.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 10),
                                itemBuilder: (context, idx) {
                                  final item = artisan.portfolio![idx];
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: CachedNetworkImage(
                                      imageUrl: UrlUtils.resolveImageUrl(item.imageUrl),
                                      width: 120,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                        width: 120,
                                        height: 100,
                                        color: AppColors.surfaceContainerHigh,
                                        child: const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
                                      ),
                                      errorWidget: (_, __, ___) => Container(width: 120, color: AppColors.surfaceContainerHigh),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ── Above-the-fold Social Proof: Featured Review Snippet ───────
                  if (topReview != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.format_quote_rounded, color: Color(0xFFD97706), size: 24),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '"${topReview.comment ?? 'Excellent professional service and punctuality!'}"',
                                      style: AppTypography.bodySm.copyWith(
                                        fontStyle: FontStyle.italic,
                                        color: const Color(0xFF78350F),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '— ${topReview.customerName ?? 'Verified Customer'} (${topReview.rating}★)',
                                      style: AppTypography.labelSm.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF92400E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
                          fontWeight: FontWeight.w700),
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
                        _PortfolioTab(portfolio: artisan.portfolio ?? []),
                        _ReviewsTab(reviews: artisan.reviews ?? []),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
            error: (err, __) => Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text('Failed to load profile', style: AppTypography.titleLg),
                      const SizedBox(height: 8),
                      Text(err.toString(), textAlign: TextAlign.center, style: AppTypography.bodyMd.copyWith(color: AppColors.outline)),
                      const SizedBox(height: 24),
                      SkillLinkButton(
                        label: 'Retry',
                        onPressed: () => ref.invalidate(artisanProfileProvider(artisanId)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      bottomNavigationBar: Container(
        height: 86 + MediaQuery.of(context).padding.bottom,
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
          border: Border(top: BorderSide(color: AppColors.outlineVariant.withOpacity(0.4))),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SkillLinkButton.outlined(
                    label: 'Message',
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: AppColors.primary),
                    onPressed: () {
                      final artisan = ref.read(artisanProfileProvider(artisanId)).value;
                      final name = Uri.encodeComponent(artisan?.user?.name ?? 'Artisan');
                      final avatar = Uri.encodeComponent(artisan?.user?.avatarUrl ?? '');
                      context.push('${AppRoutes.chat}/${widget.artisanId}?name=$name&avatar=$avatar');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: SkillLinkButton.gradient(
                    label: 'Book Service',
                    icon: const Icon(Icons.calendar_month_outlined, size: 18, color: Colors.white),
                    onPressed: () => context.push('${AppRoutes.booking}/${widget.artisanId}'),
                  ),
                ),
              ],
            ),
          ),
        ),
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
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value,
                style: AppTypography.titleSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 2),
            Text(label, style: AppTypography.labelSm.copyWith(fontSize: 10)),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bio & Experience', style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            artisan.bio ?? 'Professional registered artisan ready to deliver quality craftsmanship.',
            style: AppTypography.bodyMd.copyWith(height: 1.6),
          ),
          const SizedBox(height: 20),
          Text('Service Location', style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(artisan.locationName ?? 'Lagos, Nigeria', style: AppTypography.bodyMd),
          ]),
          if (artisan.businessAddress != null && artisan.businessAddress!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Workshop Address', style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(artisan.businessAddress!, style: AppTypography.bodyMd),
          ],
          const SizedBox(height: 20),
          _SecurityCard(artisan: artisan),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SecurityCard extends StatelessWidget {
  final Artisan artisan;
  const _SecurityCard({required this.artisan});

  @override
  Widget build(BuildContext context) {
    final bool isVerified = artisan.identityVerified || artisan.identityStatus == 'approved';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isVerified ? const Color(0xFFEFF6FF) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerified ? const Color(0xFFBFDBFE) : const Color(0xFFFED7AA),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(
              isVerified ? Icons.verified_user_rounded : Icons.gpp_maybe_rounded,
              color: isVerified ? const Color(0xFF1D4ED8) : const Color(0xFFC2410C),
            ),
            const SizedBox(width: 12),
            Text(
              isVerified ? 'SkillLink Verified Artisan' : 'Identity Verification Pending',
              style: AppTypography.labelLg.copyWith(
                color: isVerified ? const Color(0xFF1E3A8A) : const Color(0xFF7C2D12),
                fontWeight: FontWeight.bold,
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Text(
            isVerified 
              ? 'This artisan has verified their national identity and is approved by SkillLink compliance.'
              : 'This artisan is currently undergoing verification. Please follow platform safety guidelines.',
            style: AppTypography.bodySm.copyWith(
              color: isVerified ? const Color(0xFF1E40AF) : const Color(0xFF9A3412),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioTab extends StatelessWidget {
  final List<PortfolioItem> portfolio;
  const _PortfolioTab({required this.portfolio});

  @override
  Widget build(BuildContext context) {
    if (portfolio.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.collections_outlined, size: 48, color: AppColors.outlineVariant),
            const SizedBox(height: 16),
            Text('No portfolio items uploaded yet', style: AppTypography.bodyMd),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: portfolio.length,
      itemBuilder: (context, i) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: UrlUtils.resolveImageUrl(portfolio[i].imageUrl),
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            color: AppColors.surfaceContainerLow,
            child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
          ),
          errorWidget: (_, __, ___) =>
              Container(color: AppColors.surfaceContainerLow, child: const Icon(Icons.broken_image_outlined)),
        ),
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  final List<Review> reviews;
  const _ReviewsTab({required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 48, color: AppColors.outlineVariant),
            const SizedBox(height: 16),
            Text('No customer reviews yet', style: AppTypography.bodyMd),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: reviews.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final review = reviews[i];
        return SkillLinkCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                CircleAvatar(
                  radius: 18,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: UrlUtils.resolveImageUrl(review.customerAvatar),
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const Icon(Icons.person, size: 18, color: AppColors.outline),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.customerName ?? 'Customer',
                        style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.bold)),
                    if (review.createdAt != null)
                      Text(_formatTime(review.createdAt!), style: AppTypography.labelSm),
                  ],
                )),
                Row(children: List.generate(5, (j) => Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: j < review.rating ? const Color(0xFFFFB84D) : AppColors.outlineVariant,
                ))),
              ]),
              if (review.comment != null && review.comment!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  review.comment!,
                  style: AppTypography.bodyMd.copyWith(height: 1.5),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
