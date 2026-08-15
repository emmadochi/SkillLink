import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class BookingProgressStepper extends StatelessWidget {
  final String status;
  final String? cancellationReason;

  const BookingProgressStepper({
    super.key,
    required this.status,
    this.cancellationReason,
  });

  static const List<Map<String, dynamic>> _steps = [
    {
      'key': 'pending',
      'title': 'Booked',
      'subtitle': 'Request Sent',
      'icon': Icons.calendar_today_rounded,
    },
    {
      'key': 'confirmed',
      'title': 'Confirmed',
      'subtitle': 'Artisan Accepted',
      'icon': Icons.thumb_up_alt_rounded,
    },
    {
      'key': 'arrived',
      'title': 'Arrived',
      'subtitle': 'At Location',
      'icon': Icons.location_on_rounded,
    },
    {
      'key': 'in_progress',
      'title': 'In Progress',
      'subtitle': 'Work Ongoing',
      'icon': Icons.build_circle_rounded,
    },
    {
      'key': 'completed',
      'title': 'Completed',
      'subtitle': 'Job Done',
      'icon': Icons.verified_rounded,
    },
  ];

  int _getCurrentStepIndex(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0;
      case 'confirmed':
        return 1;
      case 'arrived':
        return 2;
      case 'in_progress':
        return 3;
      case 'completed':
        return 4;
      default:
        return -1; // e.g. cancelled
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCancelled = status.toLowerCase() == 'cancelled';
    final currentIndex = _getCurrentStepIndex(status);

    if (isCancelled) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cancel_rounded, color: AppColors.error, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking Cancelled',
                        style: AppTypography.titleSm.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'This service request has been cancelled.',
                        style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (cancellationReason != null && cancellationReason!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withOpacity(0.2)),
                ),
                child: Text(
                  'Reason: $cancellationReason',
                  style: AppTypography.bodySm.copyWith(color: AppColors.error),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceVariant.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
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
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.timeline_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Artisan Job Progress',
                    style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getBadgeColor(currentIndex).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _steps[currentIndex.clamp(0, _steps.length - 1)]['title'],
                  style: TextStyle(
                    color: _getBadgeColor(currentIndex),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Horizontal Stepper Bar
          Row(
            children: List.generate(_steps.length * 2 - 1, (index) {
              if (index.isEven) {
                final stepIdx = index ~/ 2;
                final isDone = stepIdx < currentIndex;
                final isCurrent = stepIdx == currentIndex;

                return _buildStepCircle(
                  icon: _steps[stepIdx]['icon'] as IconData,
                  isDone: isDone,
                  isCurrent: isCurrent,
                  stepNumber: stepIdx + 1,
                );
              } else {
                final lineIdx = index ~/ 2;
                final isPassed = lineIdx < currentIndex;
                return Expanded(
                  child: Container(
                    height: 3,
                    color: isPassed ? AppColors.surfaceTint : AppColors.surfaceVariant,
                  ),
                );
              }
            }),
          ),
          const SizedBox(height: 16),
          // Current step info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  _steps[currentIndex.clamp(0, _steps.length - 1)]['icon'],
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _steps[currentIndex.clamp(0, _steps.length - 1)]['title'],
                        style: AppTypography.titleSm.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        _getStepDescription(currentIndex),
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle({
    required IconData icon,
    required bool isDone,
    required bool isCurrent,
    required int stepNumber,
  }) {
    Color bg;
    Color iconColor;
    Widget child;

    if (isDone) {
      bg = const Color(0xFF0A6E3A); // Success green
      iconColor = Colors.white;
      child = const Icon(Icons.check_rounded, size: 16, color: Colors.white);
    } else if (isCurrent) {
      bg = AppColors.surfaceTint;
      iconColor = Colors.white;
      child = Icon(icon, size: 16, color: iconColor);
    } else {
      bg = AppColors.surfaceContainerHigh;
      iconColor = AppColors.outline;
      child = Text(
        '$stepNumber',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: iconColor,
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCurrent ? 36 : 28,
      height: isCurrent ? 36 : 28,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppColors.surfaceTint.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Center(child: child),
    );
  }

  Color _getBadgeColor(int index) {
    if (index >= 4) return const Color(0xFF0A6E3A);
    if (index >= 1) return AppColors.surfaceTint;
    return const Color(0xFFD97706);
  }

  String _getStepDescription(int index) {
    switch (index) {
      case 0:
        return 'Waiting for the artisan to review and accept the booking.';
      case 1:
        return 'Artisan has confirmed and is preparing to head to your location.';
      case 2:
        return 'Artisan has arrived at the job site.';
      case 3:
        return 'Artisan is actively working on the requested service.';
      case 4:
        return 'Service is completed. Payment has been released.';
      default:
        return 'Active booking in progress.';
    }
  }
}
