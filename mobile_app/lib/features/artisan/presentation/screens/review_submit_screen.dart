import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
  int _rating = 5;
  final _commentCtrl = TextEditingController();
  final _picker = ImagePicker();

  final List<String> _selectedQualityTags = [];
  String? _beforePhotoLocal;
  String? _beforePhotoUrl;
  String? _afterPhotoLocal;
  String? _afterPhotoUrl;
  bool _isUploadingPhoto = false;

  static const _availableQualityTags = [
    '⏰ Punctual & On-Time',
    '🛠️ Expert Craftsmanship',
    '🧹 Clean Worksite',
    '🤝 Professional & Polite',
    '💰 Fair & Transparent',
    '💬 Great Communication',
    '⚡ Quick Resolution',
  ];

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(bool isBefore) async {
    try {
      final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (file == null) return;

      setState(() {
        _isUploadingPhoto = true;
        if (isBefore) {
          _beforePhotoLocal = file.path;
        } else {
          _afterPhotoLocal = file.path;
        }
      });

      final repo = ref.read(reviewRepositoryProvider);
      final uploadedUrl = await repo.uploadReviewPhoto(file.path);

      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
          if (isBefore) {
            _beforePhotoUrl = uploadedUrl;
          } else {
            _afterPhotoUrl = uploadedUrl;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${isBefore ? "Before" : "After"} photo uploaded!'),
            backgroundColor: const Color(0xFF0A6E3A),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload photo: $e'), backgroundColor: AppColors.error),
        );
      }
    }
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
      qualityTags: _selectedQualityTags,
      beforePhotoUrl: _beforePhotoUrl,
      afterPhotoUrl: _afterPhotoUrl,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you! Review and proof submitted successfully.'),
          backgroundColor: Color(0xFF0A6E3A),
        ),
      );
      context.pop(true);
    } else if (mounted) {
      final error = ref.read(reviewControllerProvider).error?.toString() ?? 'Failed to submit review';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(reviewControllerProvider).isLoading || _isUploadingPhoto;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Rate Your Experience'),
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Text(
              'How was your service with',
              style: AppTypography.bodyLg,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              widget.artisanName,
              style: AppTypography.headlineSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Star Rating Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final isSelected = index < _rating;
                return IconButton(
                  onPressed: () => setState(() => _rating = index + 1),
                  icon: Icon(
                    isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 46,
                    color: isSelected ? const Color(0xFFFFB84D) : AppColors.outline.withOpacity(0.4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Text(
                _getRatingText(_rating),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB45309), fontSize: 13),
              ),
            ),
            
            const SizedBox(height: 32),

            // Quality Compliment Tags
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What did this artisan do well?', style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('Select all quality compliment tags that apply', style: AppTypography.bodySm.copyWith(color: AppColors.outline)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableQualityTags.map((tag) {
                final isSelected = _selectedQualityTags.contains(tag);
                return ChoiceChip(
                  label: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.onSurface,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceContainerHighest,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedQualityTags.add(tag);
                      } else {
                        _selectedQualityTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Before & After Photo Proof Section
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Attach Work Photo Proof (Optional)', style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('Add photos of before and after the job for verified review status', style: AppTypography.bodySm.copyWith(color: AppColors.outline)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _photoUploadBox('Before Service', _beforePhotoLocal, () => _pickPhoto(true)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _photoUploadBox('After Completion', _afterPhotoLocal, () => _pickPhoto(false)),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Comment Field
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Share details of your experience',
                style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            SkillLinkInput(
              hint: 'Describe how the job went, quality of materials, communication...',
              controller: _commentCtrl,
              maxLines: 4,
            ),
            
            const SizedBox(height: 36),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 54,
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
                    : const Text('Submit Verified Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoUploadBox(String label, String? localPath, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline.withOpacity(0.2)),
        ),
        child: localPath != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(File(localPath), width: double.infinity, height: 130, fit: BoxFit.cover),
                  ),
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo_outlined, size: 28, color: AppColors.primary),
                  const SizedBox(height: 8),
                  Text(label, style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 2),
                  Text('Tap to upload', style: AppTypography.labelSm.copyWith(fontSize: 9, color: AppColors.outline)),
                ],
              ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1: return '⭐ 1.0 - Very Dissatisfied';
      case 2: return '⭐⭐ 2.0 - Poor Experience';
      case 3: return '⭐⭐⭐ 3.0 - Fair / Average';
      case 4: return '⭐⭐⭐⭐ 4.0 - Good Workmanship';
      case 5: return '⭐⭐⭐⭐⭐ 5.0 - Outstanding & Highly Recommended';
      default: return 'Tap to rate';
    }
  }
}
