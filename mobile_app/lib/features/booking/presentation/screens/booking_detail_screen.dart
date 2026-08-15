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
import '../widgets/booking_progress_stepper.dart';
import '../widgets/booking_live_tracking_map.dart';
import '../../../auth/presentation/providers/user_provider.dart';

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

  Future<void> _updateStatus(int bookingId, String newStatus, {String? reason}) async {
    setState(() => _isActionLoading = true);
    try {
      final repo = ref.read(bookingRepositoryProvider);
      final success = await repo.updateBookingStatus(bookingId, newStatus, reason: reason);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking status updated to ${newStatus.toUpperCase()}'),
            backgroundColor: const Color(0xFF0A6E3A),
          ),
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
    final user = ref.watch(userStateProvider).value;
    final isArtisanUser = user?.role == 'artisan' || user?.id == booking.artisanId;
    final isCompleted = booking.status.toLowerCase() == 'completed';
    final isPending = booking.status.toLowerCase() == 'pending';
    final isConfirmed = booking.status.toLowerCase() == 'confirmed';
    final isArrived = booking.status.toLowerCase() == 'arrived';
    final isInProgress = booking.status.toLowerCase() == 'in_progress';
    final isCancelled = booking.status.toLowerCase() == 'cancelled';
    final hasDispute = _activeDispute != null;
    final showLiveTracking = isConfirmed || isArrived || isInProgress;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual Job Progress Stepper
          BookingProgressStepper(
            status: booking.status,
            cancellationReason: booking.cancellationReason,
          ),

          // Real-time Live En-Route Map Tracking (When confirmed/arrived/in_progress)
          if (showLiveTracking) ...[
            const SizedBox(height: 20),
            BookingLiveTrackingMap(
              bookingId: booking.id,
              status: booking.status,
              artisanName: booking.partnerName,
            ),
          ],

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

          // Artisan / Customer Info
          Text(isArtisanUser ? 'Customer Info' : 'Artisan Info', style: AppTypography.titleMd),
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
                    Text(booking.partnerName ?? (isArtisanUser ? 'Customer' : 'Artisan'), style: AppTypography.titleSm),
                    Text(booking.categoryName ?? 'Service', style: AppTypography.labelMd.copyWith(color: AppColors.outline)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.push('${AppRoutes.chat}/${isArtisanUser ? booking.customerId : booking.artisanId}?name=${booking.partnerName}'),
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
          _detailItem(
            Icons.payments_outlined, 
            'Total Price', 
            '₦${NumberFormat('#,###').format(booking.price)}' + (booking.isNegotiated ? ' (Agreed Counter-Offer)' : '')
          ),

          // --- Negotiation Counter-Offer Banner ---
          if (booking.negotiationStatus == 'pending_artisan' || booking.negotiationStatus == 'pending_customer') ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.handshake_outlined, color: Color(0xFF1D4ED8), size: 20),
                          const SizedBox(width: 8),
                          Text('Active Counter-Offer', style: AppTypography.titleSm.copyWith(color: const Color(0xFF1D4ED8), fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D4ED8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '₦${NumberFormat('#,###').format(booking.counterPrice ?? booking.price)}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  if (booking.negotiationNote != null && booking.negotiationNote!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text('Note: "${booking.negotiationNote}"', style: AppTypography.bodySm.copyWith(color: const Color(0xFF1E3A8A), fontStyle: FontStyle.italic)),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    (booking.negotiationStatus == 'pending_artisan' && isArtisanUser) || (booking.negotiationStatus == 'pending_customer' && !isArtisanUser)
                        ? 'The other party proposed this counter-offer. You can accept, decline, or counter.'
                        : 'Awaiting response from the other party.',
                    style: AppTypography.labelSm.copyWith(color: const Color(0xFF3B82F6)),
                  ),

                  // Actions if user is the recipient of the counter-offer
                  if ((booking.negotiationStatus == 'pending_artisan' && isArtisanUser) || (booking.negotiationStatus == 'pending_customer' && !isArtisanUser)) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isActionLoading ? null : () => _respondNegotiation(booking.id, 'decline', booking.counterPrice ?? booking.price),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Decline'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isActionLoading ? null : () => _showNegotiateModal(booking, isArtisanUser),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Counter'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isActionLoading ? null : () => _respondNegotiation(booking.id, 'accept', booking.counterPrice ?? booking.price),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A6E3A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Accept Offer', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 28),

          // ── Status Action Buttons & Lifecycle Triggers ──
          if (isPending && isArtisanUser) ...[
            // Artisan: Counter-offer or Accept or Decline
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isActionLoading ? null : () => _updateStatus(booking.id, 'cancelled', reason: 'Declined by artisan'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Decline', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isActionLoading ? null : () => _showNegotiateModal(booking, isArtisanUser),
                    icon: const Icon(Icons.handshake_outlined, size: 16),
                    label: const Text('Negotiate'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isActionLoading ? null : () => _updateStatus(booking.id, 'confirmed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A6E3A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ] else if (isPending && !isArtisanUser && booking.negotiationStatus == 'none') ...[
            // Customer: Offer Negotiation button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _isActionLoading ? null : () => _showNegotiateModal(booking, isArtisanUser),
                icon: const Icon(Icons.handshake_outlined),
                label: const Text('Propose Price Counter-Offer', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ] else if (isConfirmed && isArtisanUser) ...[
            // Artisan: Mark as arrived
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isActionLoading ? null : () => _updateStatus(booking.id, 'arrived'),
                icon: const Icon(Icons.location_on_rounded),
                label: const Text('I Have Arrived at Location', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceTint,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ] else if (isArrived && isArtisanUser) ...[
            // Artisan: Start work
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isActionLoading ? null : () => _updateStatus(booking.id, 'in_progress'),
                icon: const Icon(Icons.build_circle_rounded),
                label: const Text('Start Service / Work', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A6E3A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ] else if (isInProgress) ...[
            // Complete Job (Artisan or Customer confirmation)
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isActionLoading ? null : () => _updateStatus(booking.id, 'completed'),
                icon: const Icon(Icons.check_circle_rounded),
                label: Text(
                  isArtisanUser ? 'Mark Service Completed' : 'Confirm Completion & Release Payment',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A6E3A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ] else if (isCompleted) ...[
            if (!isArtisanUser) ...[
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
          ],

          // Cancel Request Button for Pending Bookings (Customer)
          if (isPending && !isArtisanUser) ...[
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

  Future<void> _respondNegotiation(int bookingId, String action, double price) async {
    setState(() => _isActionLoading = true);
    try {
      final repo = ref.read(bookingRepositoryProvider);
      final success = await repo.negotiateBooking(bookingId, price, action);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Negotiation response sent: ${action.toUpperCase()}'),
            backgroundColor: action == 'accept' ? const Color(0xFF0A6E3A) : AppColors.primary,
          ),
        );
        ref.invalidate(bookingHistoryProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Negotiation error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  void _showNegotiateModal(Booking booking, bool isArtisanUser) {
    double currentPrice = booking.counterPrice ?? booking.price;
    final priceCtrl = TextEditingController(text: currentPrice.toStringAsFixed(0));
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          double parsedPrice = double.tryParse(priceCtrl.text.trim()) ?? currentPrice;
          double fee = parsedPrice * 0.10;
          double payout = parsedPrice - fee;

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
            child: SingleChildScrollView(
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
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.handshake_rounded, color: Color(0xFF1D4ED8), size: 22),
                          ),
                          const SizedBox(width: 12),
                          Text('Price Counter-Offer', style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Propose a new agreed service fee for booking #${booking.bookingNumber}.',
                    style: AppTypography.bodySm.copyWith(color: AppColors.outline),
                  ),
                  const SizedBox(height: 16),

                  // Current Price Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Current Listing Price', style: AppTypography.bodySm.copyWith(color: AppColors.outline)),
                        Text('₦${NumberFormat('#,###').format(booking.price)}', 
                          style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text('Your Counter-Offer (₦)', style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      prefixText: '₦ ',
                      hintText: 'Enter amount...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onChanged: (_) => setModalState(() {}),
                  ),
                  const SizedBox(height: 8),

                  // Quick adjustments chips
                  Row(
                    children: [
                      _negotiateChip('-₦1,000', -1000, priceCtrl, setModalState),
                      const SizedBox(width: 6),
                      _negotiateChip('+₦1,000', 1000, priceCtrl, setModalState),
                      const SizedBox(width: 6),
                      _negotiateChip('-10%', -0.10 * currentPrice, priceCtrl, setModalState),
                      const SizedBox(width: 6),
                      _negotiateChip('+10%', 0.10 * currentPrice, priceCtrl, setModalState),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Real-time Fee Split Breakdown Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Customer Total Amount:', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                            Text('₦${NumberFormat('#,###.00').format(parsedPrice)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('SkillLink Platform Fee (10%):', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                            Text('₦${NumberFormat('#,###.00').format(fee)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        ),
                        const Divider(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Artisan Net Payout (90%):', style: TextStyle(color: Color(0xFF0A6E3A), fontWeight: FontWeight.bold, fontSize: 12)),
                            Text('₦${NumberFormat('#,###.00').format(payout)}', style: const TextStyle(color: Color(0xFF0A6E3A), fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text('Reason / Note (optional)', style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  SkillLinkInput(
                    controller: noteCtrl,
                    hint: 'e.g. Additional materials required or job scope adjusted...',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                        if (price <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid price')));
                          return;
                        }
                        Navigator.pop(context);
                        setState(() => _isActionLoading = true);
                        try {
                          final repo = ref.read(bookingRepositoryProvider);
                          final success = await repo.negotiateBooking(
                            booking.id, 
                            price, 
                            'propose',
                            note: noteCtrl.text.trim(),
                          );
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Counter-offer sent to the other party.'),
                                backgroundColor: Color(0xFF0A6E3A),
                              ),
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
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Send Counter-Offer', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _negotiateChip(String label, double delta, TextEditingController ctrl, StateSetter setModalState) {
    return InkWell(
      onTap: () {
        double cur = double.tryParse(ctrl.text.trim()) ?? 0.0;
        double next = cur + delta;
        if (next < 500) next = 500;
        setModalState(() {
          ctrl.text = next.toStringAsFixed(0);
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
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
