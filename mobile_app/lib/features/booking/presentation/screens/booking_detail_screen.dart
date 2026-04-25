import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/skilllink_button.dart';
import '../providers/booking_provider.dart';
import '../../data/models/booking_model.dart';

class BookingDetailScreen extends ConsumerWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingHistoryProvider);
    
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: AppColors.surfaceContainerLowest,
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          final booking = bookings.firstWhere(
            (b) => b.id.toString() == bookingId,
            orElse: () => throw Exception('Booking not found'),
          );
          
          return _buildBody(context, ref, booking);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, Booking booking) {
    final isCompleted = booking.status == 'completed';
    
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
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Artisan Info
          Text('Artisan Info', style: AppTypography.titleMd),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(
                  booking.partnerAvatar ?? 'https://i.pravatar.cc/100?u=${booking.artisanId}'
                ),
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
          
          const SizedBox(height: 32),
          
          // Service Details
          Text('Service Details', style: AppTypography.titleMd),
          const SizedBox(height: 12),
          _detailItem(Icons.description_outlined, 'Description', booking.serviceDescription ?? 'No description'),
          _detailItem(Icons.calendar_today_rounded, 'Date & Time', _formatDate(booking.scheduledAt)),
          _detailItem(Icons.payments_outlined, 'Total Price', '₦${NumberFormat('#,###').format(booking.price)}'),
          
          const SizedBox(height: 40),
          
          // Actions
          if (isCompleted) ...[
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => context.push(
                  '${AppRoutes.bookingDetail}/review/$bookingId?name=${Uri.encodeComponent(booking.partnerName ?? 'Artisan')}'
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
              height: 56,
              child: SkillLinkButton.outlined(
                label: 'Rebook this Artisan',
                icon: const Icon(Icons.refresh_rounded, size: 18),
                onPressed: () => context.push('${AppRoutes.booking}/${booking.artisanId}'),
              ),
            ),
          ],
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
      return DateFormat('MMM d, yyyy - h:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
