import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppColors.surfaceContainerLowest,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Privacy Policy', style: AppTypography.headlineSmall),
            const SizedBox(height: 8),
            Text('Last Updated: April 2026', 
                style: AppTypography.bodySmall.copyWith(color: AppColors.outline)),
            const SizedBox(height: 24),
            
            _PolicySection(
              title: '1. Information We Collect',
              content: 'We collect information you provide directly to us, such as when you create an account, update your profile, or book a service. This includes your name, email address, phone number, and location data.',
            ),
            _PolicySection(
              title: '2. How We Use Information',
              content: 'We use your information to facilitate bookings, process payments, and provide customer support. Location data is used only to find artisans near you and for job tracking purposes.',
            ),
            _PolicySection(
              title: '3. Data Security',
              content: 'We implement industry-standard security measures to protect your data. Your payment information is encrypted and processed by professional third-party providers.',
            ),
            _PolicySection(
              title: '4. Your Choices',
              content: 'You can update your account information and preferences at any time through the app settings. You can also request the deletion of your account and data by contacting our support team.',
            ),
            _PolicySection(
              title: '5. Contact Us',
              content: 'If you have any questions about this Privacy Policy, please reach out to us at privacy@skilllink.com.',
            ),
            
            const SizedBox(height: 40),
            Center(
              child: Text('© 2026 SkillLink Africa. All Rights Reserved.', 
                  style: AppTypography.labelSmall.copyWith(color: AppColors.outline)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;
  const _PolicySection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleMedium.copyWith(color: AppColors.primary)),
          const SizedBox(height: 12),
          Text(content, 
              style: AppTypography.bodyMedium.copyWith(height: 1.6, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}
