import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/skilllink_button.dart';
import '../../../../shared/widgets/skilllink_input.dart';
import '../providers/booking_provider.dart';
import '../../data/models/booking_model.dart';
import '../../../../core/utils/url_utils.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  ConsumerState<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  Map<String, dynamic>? _activeDispute;
  bool _isLoadingDispute = true;
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDisputeStatus();
  }

  Future<void> _fetchDisputeStatus() async {
    final bId = int.tryParse(widget.bookingId);
    if (bId == null) return;
    try {
      final repo = ref.read(bookingRepositoryProvider);
      final dispute = await repo.getBookingDispute(bId);
      if (mounted) {
        setState(() {
          _activeDispute = dispute;
          _isLoadingDispute = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingDispute = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(bookingHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: AppColors.surfaceContainerLowest,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(bookingHistoryProvider);
              _fetchDisputeStatus();
            },
          ),
        ],
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          final booking = bookings.firstWhere(
            (b) => b.id.toString() == widget.bookingId,
            orElse: () => throw Exception('Booking not found'),
          );

          return _buildBody(context, booking);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Booking booking) {
    final isCompleted = booking.status.toLowerCase() == 'completed';
    final isPending = booking.status.toLowerCase() == 'pending';
    final isCancelled = booking.status.toLowerCase() == 'cancelled';
    final hasDispute = _activeDispute != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Status Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _getStatusColor(booking.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getStatusColor(booking.status).withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Text(
                  'Status: ${booking.status.toUpperCase()}',
                  style: AppTypography.titleMd.copyWith(
                    color: _getStatusColor(booking.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Order #${booking.bookingNumber}',
                  style: AppTypography.labelMd.copyWith(color: AppColors.outline),
                ),
                if (booking.cancellationReason != null && booking.cancellationReason!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Reason: ${booking.cancellationReason}',
                      style: AppTypography.labelSm.copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Active Dispute Card
          if (hasDispute) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, color: Color(0xFFE65100), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Dispute Under Review',
                              style: AppTypography.titleSm.copyWith(
                                color: const Color(0xFFE65100),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE65100),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                (_activeDispute!['status'] ?? 'open').toString().toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Issue: ${_activeDispute!['reason'] ?? ''}',
                          style: AppTypography.bodySm.copyWith(color: const Color(0xFF5D4037)),
                        ),
                        if (_activeDispute!['resolution'] != null && _activeDispute!['resolution'].toString().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Resolution: ${_activeDispute!['resolution']}',
                            style: AppTypography.bodySm.copyWith(
                              color: const Color(0xFF0A6E3A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          'SkillLink Admin Mediation is handling this case.',
                          style: AppTypography.labelSm.copyWith(color: const Color(0xFF8D6E63)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 28),

          // Artisan Info
          Text('Artisan Info', style: AppTypography.titleMd),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: booking.partnerAvatar != null && booking.partnerAvatar!.isNotEmpty
                    ? NetworkImage(UrlUtils.resolveImageUrl(booking.partnerAvatar))
                    : null,
                child: booking.partnerAvatar == null || booking.partnerAvatar!.isEmpty
                    ? const Icon(Icons.person, size: 28, color: AppColors.outline)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.partnerName ?? 'Artisan', style: AppTypography.titleSm),
                    Text(booking.categoryName ?? 'Service', style: AppTypography.labelMd.copyWith(color: AppColors.outline)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.push('${AppRoutes.chat}/${booking.artisanId}?name=${booking.partnerName}'),
                icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Service Details
          Text('Service Details', style: AppTypography.titleMd),
          const SizedBox(height: 12),
          _detailItem(Icons.description_outlined, 'Description', booking.serviceDescription ?? 'No description provided'),
          _detailItem(Icons.calendar_today_rounded, 'Date & Time', _formatDate(booking.scheduledAt)),
          _detailItem(Icons.payments_outlined, 'Total Price', '₦${NumberFormat('#,###').format(booking.price)}'),

          const SizedBox(height: 32),

          // Actions Container
          if (isCompleted) ...[
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => context.push(
                  '${AppRoutes.bookingDetail}/review/${widget.bookingId}?name=${Uri.encodeComponent(booking.partnerName ?? 'Artisan')}',
                ),
                icon: const Icon(Icons.star_rounded),
                label: const Text('Rate Your Experience'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB84D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: SkillLinkButton.outlined(
                label: 'Rebook this Artisan',
                icon: const Icon(Icons.refresh_rounded, size: 18),
                onPressed: () => context.push('${AppRoutes.booking}/${booking.artisanId}'),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Cancel Request Button for Pending Bookings
          if (isPending) ...[
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: _isActionLoading ? null : () => _showCancelDialog(booking),
                icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                label: Text('Cancel Request', style: AppTypography.labelLg.copyWith(color: AppColors.error)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Report an Issue / Dispute Button (if not cancelled and no active dispute)
          if (!isCancelled && !hasDispute) ...[
            SizedBox(
              width: double.infinity,
              height: 54,
              child: TextButton.icon(
                onPressed: _isActionLoading ? null : () => _showDisputeModal(booking),
                icon: const Icon(Icons.report_problem_outlined, color: Color(0xFFD97706), size: 20),
                label: Text(
                  'Report an Issue / Lodge Dispute',
                  style: AppTypography.labelMd.copyWith(color: const Color(0xFFD97706), fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFBEB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFFDE68A)),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showDisputeModal(Booking booking) {
    String selectedReason = 'Artisan No-Show';
    final customReasonCtrl = TextEditingController();

    final commonReasons = [
      'Artisan No-Show',
      'Incomplete / Poor Workmanship',
      'Pricing / Overcharge Disagreement',
      'Excessive Delay / Abandoned Job',
      'Unprofessional Conduct',
      'Other Issue',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.gavel_rounded, color: Color(0xFFD97706), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Text('Lodge a Dispute', style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Our Admin Mediation Team will investigate and help resolve any contention with #${booking.bookingNumber}.',
                  style: AppTypography.bodySm.copyWith(color: AppColors.outline),
                ),
                const SizedBox(height: 18),
                Text('Select Issue Category', style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: commonReasons.map((reason) {
                    final isSelected = selectedReason == reason;
                    return ChoiceChip(
                      label: Text(
                        reason,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceContainerHigh,
                      onSelected: (val) {
                        if (val) setModalState(() => selectedReason = reason);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text('Detailed Description', style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                SkillLinkInput(
                  controller: customReasonCtrl,
                  hint: 'Explain the situation in detail...',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      final detail = customReasonCtrl.text.trim();
                      final fullReason = detail.isNotEmpty ? '$selectedReason: $detail' : selectedReason;
                      Navigator.pop(context);
                      await _submitDispute(booking.id, fullReason);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Submit to Mediation Support', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitDispute(int bookingId, String reason) async {
    setState(() => _isActionLoading = true);
    try {
      final repo = ref.read(bookingRepositoryProvider);
      final success = await repo.submitDispute(bookingId: bookingId, reason: reason);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dispute submitted successfully. Admin support has been alerted.'),
            backgroundColor: Color(0xFF0A6E3A),
          ),
        );
        ref.invalidate(bookingHistoryProvider);
        _fetchDisputeStatus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  void _showCancelDialog(Booking booking) {
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to cancel this booking request?'),
            const SizedBox(height: 12),
            SkillLinkInput(
              controller: reasonCtrl,
              hint: 'Reason for cancellation (optional)',
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Back'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isActionLoading = true);
              try {
                final repo = ref.read(bookingRepositoryProvider);
                final reason = reasonCtrl.text.trim().isNotEmpty
                    ? reasonCtrl.text.trim()
                    : 'Cancelled by customer';
                final success = await repo.updateBookingStatus(booking.id, 'cancelled', reason: reason);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking request cancelled.')),
                  );
                  ref.invalidate(bookingHistoryProvider);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                  );
                }
              } finally {
                if (mounted) setState(() => _isActionLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Request'),
          ),
        ],
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.outline),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.labelMd.copyWith(color: AppColors.outline)),
                const SizedBox(height: 2),
                Text(value, style: AppTypography.bodyMd),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF0A6E3A);
      case 'confirmed':
      case 'in_progress':
        return AppColors.primary;
      case 'pending':
        return const Color(0xFF856404);
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.outline;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy - h:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
