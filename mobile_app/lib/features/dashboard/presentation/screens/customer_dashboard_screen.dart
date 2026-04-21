import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/skilllink_card.dart';
import '../../../../shared/widgets/skilllink_button.dart';

class CustomerDashboardScreen extends StatelessWidget {
  const CustomerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // Header
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
                  Text('My Dashboard',
                      style: AppTypography.headlineSm.copyWith(
                          color: AppColors.onPrimary)),
                  const SizedBox(height: 4),
                  Text('Manage your bookings and activity',
                      style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onPrimary.withOpacity(0.70))),
                  const SizedBox(height: 20),
                  // Stats row
                  Row(children: [
                    _DashStat(value: '12', label: 'Total\nBookings', isWhite: true),
                    _DashStat(value: '3', label: 'Active\nJobs', isWhite: true),
                    _DashStat(value: '8', label: 'Saved\nArtisans', isWhite: true),
                  ]),
                ],
              ),
            ),
          ),

          // Active bookings
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Text('Active Bookings',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: SkillLinkCard(
                  elevated: true,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                              'https://i.pravatar.cc/60?img=${i + 5}'),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Emmanuel Okafor',
                                style: Theme.of(context).textTheme.titleSmall),
                            Text('Electrician',
                                style: Theme.of(context).textTheme.labelMedium),
                          ],
                        ),
                        const Spacer(),
                        _StatusBadge(status: i == 0 ? 'In Progress' : 'Pending'),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 14, color: AppColors.outline),
                        const SizedBox(width: 6),
                        Text('Tomorrow, 10:00 AM',
                            style: Theme.of(context).textTheme.labelLarge),
                        const Spacer(),
                        Text('₦5,000/hr',
                            style: AppTypography.titleSm.copyWith(
                                color: AppColors.primary)),
                      ]),
                      const SizedBox(height: 14),
                      // Service progress tracker
                      _ServiceProgressTracker(step: i == 0 ? 2 : 1),
                    ],
                  ),
                ),
              ),
              childCount: 2,
            ),
          ),

          // Bookings history
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Row(children: [
                Text('Booking History',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: Text('View All',
                      style: AppTypography.labelLg.copyWith(
                          color: AppColors.primary)),
                ),
              ]),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: SkillLinkCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.bolt_outlined,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Electrical Wiring', style: Theme.of(context).textTheme.titleSmall),
                        Text('Chukwudi A. • ${i + 2} days ago',
                            style: Theme.of(context).textTheme.labelSmall),
                      ],
                    )),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const _StatusBadge(status: 'Completed'),
                        const SizedBox(height: 4),
                        Text('₦15,000',
                            style: AppTypography.labelLg.copyWith(
                                color: AppColors.primary)),
                      ],
                    ),
                  ]),
                ),
              ),
              childCount: 4,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _DashStat extends StatelessWidget {
  final String value;
  final String label;
  final bool isWhite;

  const _DashStat({
    required this.value,
    required this.label,
    this.isWhite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(value,
                style: AppTypography.headlineSm.copyWith(
                    color: Colors.white)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: AppTypography.labelSm.copyWith(
                    color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case 'Completed': return const Color(0xFF0A6E3A);
      case 'In Progress': return AppColors.primary;
      case 'Pending': return const Color(0xFF7A5232);
      default: return AppColors.outline;
    }
  }

  Color get _bgColor {
    switch (status) {
      case 'Completed': return const Color(0xFFD6FFE8);
      case 'In Progress': return AppColors.secondaryContainer;
      case 'Pending': return AppColors.tertiaryFixed;
      default: return AppColors.surfaceContainerLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(status,
          style: AppTypography.labelSm.copyWith(color: _color)),
    );
  }
}

class _ServiceProgressTracker extends StatelessWidget {
  final int step; // 0-3

  const _ServiceProgressTracker({required this.step});

  static const _steps = ['Booked', 'Confirmed', 'Arrived', 'Done'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final filled = (i ~/ 2) < step;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 3,
              color: filled ? AppColors.primary : AppColors.surfaceContainerHighest,
            ),
          );
        }
        final idx = i ~/ 2;
        final active = idx <= step;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary
                : AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(100),
            boxShadow: active
                ? [BoxShadow(color: AppColors.primary.withOpacity(0.04), blurRadius: 8)]
                : null,
          ),
          child: Text(_steps[idx],
              style: AppTypography.labelSm.copyWith(
                color: active ? Colors.white : AppColors.outline,
                fontSize: 9,
              )),
        );
      }),
    );
  }
}
