import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/skilllink_input.dart';
import '../providers/review_provider.dart';

class ReviewSubmitScreen extends ConsumerStatefulWidget {
  final String bookingId;
  final String artisanName;

  const ReviewSubmitScreen({
    super.key,
    required this.bookingId,
    required this.artisanName,
  });

  @override
  ConsumerState<ReviewSubmitScreen> createState() => _ReviewSubmitScreenState();
}

class _ReviewSubmitScreenState extends ConsumerState<ReviewSubmitScreen> {
  int _rating = 0;
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    final success = await ref.read(reviewControllerProvider.notifier).submitReview(
      bookingId: int.parse(widget.bookingId),
      rating: _rating,
      comment: _commentCtrl.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
      context.pop(true); // Return success to previous screen
    } else if (mounted) {
      final error = ref.read(reviewControllerProvider).error?.toString() ?? 'Failed to submit review';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(reviewControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Rate Your Experience'),
        backgroundColor: AppColors.surfaceContainerLowest,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              'How was your service with',
              style: AppTypography.bodyLg,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.artisanName,
              style: AppTypography.headlineSm.copyWith(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            // Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => setState(() => _rating = index + 1),
                  icon: Icon(
                    index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 48,
                    color: index < _rating ? const Color(0xFFFFB84D) : AppColors.outline,
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Text(
              _getRatingText(_rating),
              style: AppTypography.labelLg.copyWith(color: AppColors.outline),
            ),
            
            const SizedBox(height: 40),
            
            // Comment Field
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Add a comment (optional)',
                style: AppTypography.titleSm,
              ),
            ),
            const SizedBox(height: 12),
            SkillLinkInput(
              hint: 'Describe your experience...',
              controller: _commentCtrl,
              maxLines: 5,
            ),
            
            const SizedBox(height: 48),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Submit Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1: return 'Terrible';
      case 2: return 'Poor';
      case 3: return 'Fair';
      case 4: return 'Good';
      case 5: return 'Excellent';
      default: return 'Tap to rate';
    }
  }
}
