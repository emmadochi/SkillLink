import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/skilllink_card.dart';
import '../../../booking/presentation/providers/booking_provider.dart';

class ArtisanDashboardScreen extends ConsumerStatefulWidget {
  const ArtisanDashboardScreen({super.key});

  @override
  ConsumerState<ArtisanDashboardScreen> createState() => _ArtisanDashboardScreenState();
}

class _ArtisanDashboardScreenState extends ConsumerState<ArtisanDashboardScreen> {
  bool _isAvailable = true;

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(bookingHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: historyAsync.when(
        data: (bookings) {
          final newRequests = bookings.where((b) => b.status == 'pending').toList();
          final completedJobs = bookings.where((b) => b.status == 'completed').length;
          final activeJobs = bookings.where((b) => b.status == 'confirmed' || b.status == 'in_progress' || b.status == 'arrived').toList();
          
          double totalEarnings = 0;
          for (var b in bookings) {
            if (b.status == 'completed') totalEarnings += b.artisanPayout;
          }

          return CustomScrollView(
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
                      Row(children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Artisan Dashboard',
                                  style: AppTypography.headlineSm.copyWith(
                                      color: Colors.white)),
                              Text('Welcome Back',
                                  style: AppTypography.bodyMd.copyWith(
                                      color: Colors.white70)),
                            ],
                          ),
                        ),
                        // Availability toggle
                        Column(
                          children: [
                            Text(_isAvailable ? 'Available' : 'Offline',
                                style: AppTypography.labelSm.copyWith(
                                    color: Colors.white70)),
                            const SizedBox(height: 4),
                            Switch(
                              value: _isAvailable,
                              onChanged: (v) => setState(() => _isAvailable = v),
                              activeColor: Colors.green.shade400,
                              trackColor: WidgetStateProperty.all(
                                  Colors.white.withOpacity(0.20)),
                            ),
                          ],
                        ),
                      ]),
                      const SizedBox(height: 20),
                      Row(children: [
                        _DashStat(value: '₦${(totalEarnings / 1000).toStringAsFixed(1)}k', label: 'Earnings'),
                        _DashStat(value: '$completedJobs', label: 'Completed\nJobs'),
                        _DashStat(value: '${activeJobs.length}', label: 'Active\nJobs'),
                      ]),
                    ],
                  ),
                ),
              ),

              // Job requests
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Row(children: [
                    Text('New Job Requests',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryFixed,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text('${newRequests.length}',
                          style: AppTypography.labelSm.copyWith(
                              color: AppColors.onTertiaryFixed,
                              fontWeight: FontWeight.w700)),
                    ),
                  ]),
                ),
              ),

              if (newRequests.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(child: Text('No new job requests at the moment.')),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final b = newRequests[i];
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
                                  radius: 18,
                                  backgroundImage: NetworkImage(
                                      b.partnerAvatar ?? 'https://i.pravatar.cc/150'),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(b.partnerName ?? 'Customer',
                                        style: Theme.of(context).textTheme.titleSmall),
                                    Text(b.categoryName ?? 'Service',
                                        style: Theme.of(context).textTheme.labelMedium),
                                  ],
                                ),
                                const Spacer(),
                                Text('₦${b.price}',
                                    style: AppTypography.titleSm.copyWith(
                                        color: AppColors.primary)),
                              ]),
                              const SizedBox(height: 12),
                              Row(children: [
                                const Icon(Icons.calendar_today_outlined,
                                    size: 14, color: AppColors.outline),
                                const SizedBox(width: 4),
                                Text(_formatDate(b.scheduledAt),
                                    style: Theme.of(context).textTheme.labelMedium),
                              ]),
                              if (b.serviceDescription != null && b.serviceDescription!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(b.serviceDescription!, style: AppTypography.bodySm.copyWith(color: AppColors.outline)),
                              ],
                              const SizedBox(height: 14),
                              Row(children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _updateStatus(b.id, 'cancelled'),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppColors.outline),
                                      shape: const StadiumBorder(),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                    ),
                                    child: Text('Decline',
                                        style: AppTypography.labelLg.copyWith(
                                            color: AppColors.outline)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _updateStatus(b.id, 'confirmed'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: const StadiumBorder(),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                    ),
                                    child: Text('Accept',
                                        style: AppTypography.labelLg.copyWith(
                                            color: Colors.white)),
                                  ),
                                ),
                              ]),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: newRequests.length,
                  ),
                ),
                
              // Accepted jobs can be added here if needed
              if (activeJobs.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: Text('Active Jobs',
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final b = activeJobs[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        child: SkillLinkCard(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage: NetworkImage(
                                      b.partnerAvatar ?? 'https://i.pravatar.cc/150'),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(b.partnerName ?? 'Customer',
                                        style: Theme.of(context).textTheme.titleSmall),
                                    Text(b.categoryName ?? 'Service',
                                        style: Theme.of(context).textTheme.labelMedium),
                                  ],
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryContainer,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text('Active', style: AppTypography.labelSm.copyWith(color: AppColors.primary)),
                                ),
                              ]),
                              const SizedBox(height: 12),
                              Row(children: [
                                const Icon(Icons.calendar_today_outlined,
                                    size: 14, color: AppColors.outline),
                                const SizedBox(width: 4),
                                Text(_formatDate(b.scheduledAt),
                                    style: Theme.of(context).textTheme.labelMedium),
                              ]),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => _updateStatus(b.id, 'completed'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0A6E3A),
                                  foregroundColor: Colors.white,
                                  shape: const StadiumBorder(),
                                  elevation: 0,
                                  minimumSize: const Size(double.infinity, 44),
                                ),
                                child: const Text('Mark as Completed'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: activeJobs.length,
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading dashboard: $e')),
      ),
    );
  }

  void _updateStatus(int id, String status) async {
    String? reason;
    if (status == 'cancelled') {
      reason = await _showRejectionDialog();
      if (reason == null) return; // User cancelled the dialog
    }

    try {
      final repo = ref.read(bookingRepositoryProvider);
      await repo.updateBookingStatus(id, status, reason: reason);
      // Refresh bookings
      ref.invalidate(bookingHistoryProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'confirmed' ? 'Job Accepted!' : 'Job Declined'),
            backgroundColor: status == 'confirmed' ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<String?> _showRejectionDialog() async {
    String? selectedReason;
    final List<String> reasons = [
      'Schedule Conflict',
      'Outside Service Area',
      'Price Too Low',
      'I\'m currently unavailable',
      'Other'
    ];

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please select a reason for declining this job:'),
            const SizedBox(height: 16),
            ...reasons.map((r) => ListTile(
              title: Text(r),
              onTap: () => Navigator.pop(context, r),
              dense: true,
              trailing: const Icon(Icons.chevron_right, size: 16),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
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
  const _DashStat({required this.value, required this.label});

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
            Text(value, style: AppTypography.headlineSm.copyWith(color: Colors.white)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center,
                style: AppTypography.labelSm.copyWith(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
