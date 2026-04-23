import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('About SkillLink'),
        backgroundColor: AppColors.surfaceContainerLowest,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 48),
            // Logo placeholder
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 24),
            Text('SkillLink Africa', style: AppTypography.headlineMedium),
            Text('Version 1.0.4 (Production)', 
                style: AppTypography.bodySmall.copyWith(color: AppColors.outline)),
            
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text(
                    'Empowering Artisans, Building Dreams',
                    style: AppTypography.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'SkillLink is Africa\'s premier platform connecting high-quality, verified artisans with customers who value excellence. We believe in creating economic opportunities while delivering superior service across the continent.',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 64),
            const Divider(),
            _AboutTile(
              icon: Icons.language_rounded,
              title: 'Website',
              subtitle: 'www.skilllink.com',
              onTap: () {},
            ),
            _AboutTile(
              icon: Icons.email_outlined,
              title: 'Contact Email',
              subtitle: 'hello@skilllink.com',
              onTap: () {},
            ),
            _AboutTile(
              icon: Icons.share_rounded,
              title: 'Share the App',
              subtitle: 'Invite friends and artisans',
              onTap: () {},
            ),
            
            const SizedBox(height: 48),
            Text('Made with ❤️ in Lagos, Nigeria', 
                style: AppTypography.labelMedium.copyWith(color: AppColors.outline)),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AboutTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: AppTypography.titleSmall),
      subtitle: Text(subtitle, style: AppTypography.bodySmall),
      onTap: onTap,
    );
  }
}
