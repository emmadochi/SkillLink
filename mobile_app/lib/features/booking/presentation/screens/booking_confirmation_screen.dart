import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/skilllink_button.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success animation placeholder
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    size: 56, color: AppColors.primary),
              ),
              const SizedBox(height: 32),
              Text('Booking Confirmed! 🎉',
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineMd),
              const SizedBox(height: 12),
              Text(
                'Emmanuel Okafor has been notified and will confirm shortly. You\'ll receive an update within 30 minutes.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMd.copyWith(
                    color: AppColors.outline, height: 1.6),
              ),
              const SizedBox(height: 48),
              SkillLinkButton.gradient(
                label: 'Track My Booking',
                width: double.infinity,
                icon: const Icon(Icons.track_changes_rounded,
                    size: 16, color: Colors.white),
                onPressed: () => context.go(AppRoutes.customerDashboard),
              ),
              const SizedBox(height: 16),
              SkillLinkButton.outlined(
                label: 'Back to Home',
                width: double.infinity,
                onPressed: () => context.go(AppRoutes.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
