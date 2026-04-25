import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/skilllink_card.dart';
import '../../../booking/presentation/providers/booking_provider.dart';
import '../../../artisan/presentation/providers/artisan_provider.dart';
import '../../../../core/utils/url_utils.dart';

class ArtisanDashboardScreen extends ConsumerStatefulWidget {
  const ArtisanDashboardScreen({super.key});

  @override
  ConsumerState<ArtisanDashboardScreen> createState() => _ArtisanDashboardScreenState();
}

class _ArtisanDashboardScreenState extends ConsumerState<ArtisanDashboardScreen> {
  bool _isAvailable = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Set up auto-refresh every 30 seconds for new job requests
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
          final newRequests = bookings.where((b) => b.status == 'pending').toList();
          final completedJobs = bookings.where((b) => b.status == 'completed').length;
          final activeJobs = bookings.where((b) => b.status == 'confirmed' || b.status == 'in_progress' || b.status == 'arrived').toList();
          
          double totalEarnings = 0;
          for (var b in bookings) {
            if (b.status == 'completed') totalEarnings += b.artisanPayout;
          }

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
                              onChanged: _toggleAvailability,
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
                                  backgroundImage: b.partnerAvatar != null && b.partnerAvatar!.isNotEmpty
                                      ? NetworkImage(UrlUtils.resolveImageUrl(b.partnerAvatar))
                                      : null,
                                  child: b.partnerAvatar == null || b.partnerAvatar!.isEmpty
                                      ? const Icon(Icons.person, size: 18, color: AppColors.outline)
                                      : null,
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
                              if (b.status == 'pending' && b.negotiationStatus == 'pending_customer')
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Waiting for Customer response...',
                                      style: AppTypography.labelMd.copyWith(color: AppColors.primary),
                                    ),
                                  ),
                                )
                              else if (b.status == 'pending')
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
                                          style: AppTypography.labelMd.copyWith(
                                              color: AppColors.outline)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _showCounterDialog(b),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: AppColors.primary),
                                        shape: const StadiumBorder(),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                      child: Text('Counter',
                                          style: AppTypography.labelMd.copyWith(
                                              color: AppColors.primary)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
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
                                          style: AppTypography.labelMd.copyWith(
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
                                  backgroundImage: b.partnerAvatar != null && b.partnerAvatar!.isNotEmpty
                                      ? NetworkImage(UrlUtils.resolveImageUrl(b.partnerAvatar))
                                      : null,
                                  child: b.partnerAvatar == null || b.partnerAvatar!.isEmpty
                                      ? const Icon(Icons.person, size: 18, color: AppColors.outline)
                                      : null,
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
                              if (b.status == 'confirmed')
                                ElevatedButton(
                                  onPressed: () => _updateStatus(b.id, 'arrived'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: const StadiumBorder(),
                                    minimumSize: const Size(double.infinity, 44),
                                  ),
                                  child: const Text('Mark as Arrived'),
                                )
                              else if (b.status == 'arrived')
                                ElevatedButton(
                                  onPressed: () => _updateStatus(b.id, 'in_progress'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    foregroundColor: Colors.white,
                                    shape: const StadiumBorder(),
                                    minimumSize: const Size(double.infinity, 44),
                                  ),
                                  child: const Text('Start Job'),
                                )
                              else if (b.status == 'in_progress')
                                ElevatedButton(
                                  onPressed: () => _updateStatus(b.id, 'completed'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0A6E3A),
                                    foregroundColor: Colors.white,
                                    shape: const StadiumBorder(),
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
          ),
        );
      },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.tertiary)),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.signal_wifi_off_outlined, size: 64, color: AppColors.outline),
                const SizedBox(height: 16),
                Text(
                  'Connection Problem',
                  style: AppTypography.titleLg,
                ),
                const SizedBox(height: 8),
                Text(
                  'We couldn\'t load your dashboard. Please check your internet connection and try again.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMd.copyWith(color: AppColors.outline),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(bookingHistoryProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tertiary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleAvailability(bool value) async {
    setState(() => _isAvailable = value);
    try {
      final repo = ref.read(artisanRepositoryProvider);
      await repo.updateArtisanProfile({
        'is_available': value ? 1 : 0,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value ? 'You are now Online' : 'You are now Offline'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isAvailable = !value); // Revert on failure
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e'), backgroundColor: AppColors.error),
        );
      }
    }
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

  Future<void> _showCounterDialog(b) async {
    final ctrl = TextEditingController(text: b.price.toStringAsFixed(0));
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Counter Offer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Original Price: ₦${b.price}'),
            if (b.offerPrice != null) ...[
              const SizedBox(height: 4),
              Text('Customer Offered: ₦${b.offerPrice}', 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Your New Price',
                prefixText: '₦ ',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(ctrl.text);
              if (price != null) {
                Navigator.pop(context);
                _submitCounterOffer(b.id, price);
              }
            },
            child: const Text('Send Offer'),
          ),
        ],
      ),
    );
  }

  void _submitCounterOffer(int id, double price) async {
    try {
      final repo = ref.read(bookingRepositoryProvider);
      await repo.negotiateBooking(id, price, 'pending_customer');
      ref.invalidate(bookingHistoryProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Counter offer sent!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send offer: $e'), backgroundColor: AppColors.error),
        );
      }
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
