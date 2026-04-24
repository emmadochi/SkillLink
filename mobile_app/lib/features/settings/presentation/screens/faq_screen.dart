import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/skilllink_card.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Help & FAQ'),
        backgroundColor: AppColors.surfaceContainerLowest,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('How can we help?', style: AppTypography.headlineSm),
          const SizedBox(height: 8),
          Text('Find answers to common questions about using SkillLink.', 
              style: AppTypography.bodyMd.copyWith(color: AppColors.outline)),
          const SizedBox(height: 24),
          
          _FAQItem(
            question: 'How do I book an artisan?',
            answer: 'Simply browse categories, select an artisan, and click "Book Now". You can choose specific services and schedule a time that works for you.',
          ),
          _FAQItem(
            question: 'Is my payment secure?',
            answer: 'Yes, SkillLink uses industry-standard encryption and professional payment gateways to ensure your transactions are always safe.',
          ),
          _FAQItem(
            question: 'What if an artisan doesn\'t show up?',
            answer: 'If an artisan fails to arrive, you can cancel the job and report the issue through the dashboard. We will investigate and refund any deposits if applicable.',
          ),
          _FAQItem(
            question: 'How do I become an artisan?',
            answer: 'Go to your profile settings and select "Become an Artisan". You will need to provide professional details and identification for verification.',
          ),
          _FAQItem(
            question: 'How do I change my location?',
            answer: 'You can update your service or delivery address in the "Addresses" section of your profile settings.',
          ),
          
          const SizedBox(height: 32),
          SkillLinkCard(
            padding: const EdgeInsets.all(20),
            backgroundColor: AppColors.primary.withOpacity(0.05),
            child: Column(
              children: [
                const Icon(Icons.support_agent_rounded, color: AppColors.primary, size: 32),
                const SizedBox(height: 12),
                Text('Still need help?', style: AppTypography.titleMd),
                const SizedBox(height: 4),
                Text('Our support team is available 24/7', 
                    style: AppTypography.bodySm, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Contact Support'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;
  const _FAQItem({required this.question, required this.answer});

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SkillLinkCard(
        onTap: () => setState(() => _expanded = !_expanded),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(widget.question, style: AppTypography.titleSm),
                ),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.outline,
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Text(widget.answer, 
                  style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
            ],
          ],
        ),
      ),
    );
  }
}
