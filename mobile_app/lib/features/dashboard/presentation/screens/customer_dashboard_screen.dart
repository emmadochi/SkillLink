import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/skilllink_card.dart';
import '../../../../shared/widgets/skilllink_button.dart';
import '../../../booking/presentation/providers/booking_provider.dart';
import '../../../../core/utils/url_utils.dart';

class CustomerDashboardScreen extends ConsumerStatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  ConsumerState<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends ConsumerState<CustomerDashboardScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        ref.invalidate(bookingHistoryProvider);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(bookingHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: historyAsync.when(
        data: (bookings) {
          final activeBookings = bookings.where((b) => b.status != 'completed' && b.status != 'cancelled').toList();
          final pastBookings = bookings.where((b) => b.status == 'completed' || b.status == 'cancelled').toList();

          return RefreshIndicator(
            onRefresh: () => ref.refresh(bookingHistoryProvider.future),
            edgeOffset: MediaQuery.of(context).padding.top + 20,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                        _DashStat(value: '${bookings.length}', label: 'Total\nBookings', isWhite: true),
                        _DashStat(value: '${activeBookings.length}', label: 'Active\nJobs', isWhite: true),
                        _DashStat(value: '0', label: 'Saved\nArtisans', isWhite: true),
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

              if (activeBookings.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(child: Text('No active bookings')),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final b = activeBookings[i];
                      return Padding(
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
                                  backgroundImage: b.partnerAvatar != null && b.partnerAvatar!.isNotEmpty
                                      ? NetworkImage(UrlUtils.resolveImageUrl(b.partnerAvatar))
                                      : null,
                                  child: b.partnerAvatar == null || b.partnerAvatar!.isEmpty
                                      ? const Icon(Icons.person, size: 20, color: AppColors.outline)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(b.partnerName ?? 'Artisan',
                                        style: Theme.of(context).textTheme.titleSmall),
                                    Text(b.categoryName ?? 'Service',
                                        style: Theme.of(context).textTheme.labelMedium),
                                  ],
                                ),
                                const Spacer(),
                                _StatusBadge(status: _formatStatus(b.status)),
                              ]),
                              const SizedBox(height: 12),
                              Row(children: [
                                const Icon(Icons.calendar_today_outlined,
                                    size: 14, color: AppColors.outline),
                                const SizedBox(width: 6),
                                Text(_formatDate(b.scheduledAt),
                                    style: Theme.of(context).textTheme.labelLarge),
                                const Spacer(),
                                Text('₦${b.price}',
                                    style: AppTypography.titleSm.copyWith(
                                        color: AppColors.primary)),
                              ]),
                              const SizedBox(height: 14),
                              // Service progress tracker
                              if (b.negotiationStatus == 'pending_customer') ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Artisan Suggested Price: ₦${b.counterPrice}',
                                        style: AppTypography.titleSm.copyWith(color: AppColors.primary),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => _handleNegotiation(context, ref, b.id, b.price, 'rejected'),
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(color: AppColors.error),
                                              shape: const StadiumBorder(),
                                            ),
                                            child: Text('Reject', style: AppTypography.labelMd.copyWith(color: AppColors.error)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => _handleNegotiation(context, ref, b.id, b.counterPrice ?? b.price, 'accepted'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              foregroundColor: Colors.white,
                                              shape: const StadiumBorder(),
                                            ),
                                            child: Text('Accept', style: AppTypography.labelMd.copyWith(color: Colors.white)),
                                          ),
                                        ),
                                      ]),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                _ServiceProgressTracker(step: _getStatusStep(b.status)),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: activeBookings.length,
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

              if (pastBookings.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(child: Text('No past bookings')),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final b = pastBookings[i];
                      return Padding(
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
                              child: const Icon(Icons.check_circle_outline,
                                  color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(b.categoryName ?? 'Service', style: Theme.of(context).textTheme.titleSmall),
                                Text('${b.partnerName ?? 'Artisan'} • ${_formatDate(b.createdAt ?? b.scheduledAt)}',
                                    style: Theme.of(context).textTheme.labelSmall),
                                if (b.status == 'cancelled' && b.cancellationReason != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Reason: ${b.cancellationReason}',
                                      style: AppTypography.labelSm.copyWith(color: AppColors.error),
                                    ),
                                  ),
                              ],
                            )),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _StatusBadge(status: _formatStatus(b.status)),
                                const SizedBox(height: 4),
                                Text('₦${b.price}',
                                    style: AppTypography.labelLg.copyWith(
                                        color: AppColors.primary)),
                              ],
                            ),
                          ]),
                        ),
                      );
                    },
                    childCount: pastBookings.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading dashboard: $e')),
      ),
    );
  }

  String _formatStatus(String status) {
    if (status == 'pending') return 'Pending';
    if (status == 'confirmed') return 'Confirmed';
    if (status == 'in_progress') return 'In Progress';
    if (status == 'arrived') return 'Arrived';
    if (status == 'completed') return 'Completed';
    if (status == 'cancelled') return 'Cancelled';
    return status;
  }

  void _handleNegotiation(BuildContext context, WidgetRef ref, int bookingId, double price, String status) async {
    try {
      final repo = ref.read(bookingRepositoryProvider);
      await repo.negotiateBooking(bookingId, price, status);
      ref.invalidate(bookingHistoryProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'accepted' ? 'Price Accepted! Job Confirmed.' : 'Offer Rejected.'),
            backgroundColor: status == 'accepted' ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  int _getStatusStep(String status) {
    if (status == 'pending') return 0;
    if (status == 'confirmed') return 1;
    if (status == 'arrived') return 2;
    if (status == 'in_progress') return 2;
    if (status == 'completed') return 3;
    return 0;
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
      case 'Arrived': return AppColors.primary;
      case 'Confirmed': return AppColors.primary;
      case 'Pending': return const Color(0xFF7A5232);
      case 'Cancelled': return AppColors.error;
      default: return AppColors.outline;
    }
  }

  Color get _bgColor {
    switch (status) {
      case 'Completed': return const Color(0xFFD6FFE8);
      case 'In Progress': return AppColors.secondaryContainer;
      case 'Arrived': return AppColors.secondaryContainer;
      case 'Confirmed': return AppColors.secondaryContainer;
      case 'Pending': return AppColors.tertiaryFixed;
      case 'Cancelled': return AppColors.error.withOpacity(0.12);
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
