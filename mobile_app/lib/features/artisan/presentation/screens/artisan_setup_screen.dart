import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/skilllink_button.dart';
import '../../../../shared/widgets/skilllink_input.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/location_provider.dart';

class ArtisanSetupScreen extends ConsumerStatefulWidget {
  const ArtisanSetupScreen({super.key});

  @override
  ConsumerState<ArtisanSetupScreen> createState() => _ArtisanSetupScreenState();
}

class _ArtisanSetupScreenState extends ConsumerState<ArtisanSetupScreen> {
  final _skillCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_skillCtrl.text.isEmpty || _bioCtrl.text.isEmpty || _expCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dio = ref.read(dioProvider);
      final apiClient = ApiClient(dio);
      final location = ref.read(currentLocationProvider).value ?? 'Unknown';

      final response = await apiClient.updateArtisanProfile({
        'skill': _skillCtrl.text,
        'bio': _bioCtrl.text,
        'experience_years': int.tryParse(_expCtrl.text) ?? 0,
        'location_name': location,
        'latitude': 0.0, // Should use real coordinates
        'longitude': 0.0,
      });

      if (response.status == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Professional profile updated!')),
          );
          context.go(AppRoutes.artisanDashboard);
        }
      } else {
        throw response.message ?? 'Update failed';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Professional Setup'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Complete your profile', style: AppTypography.headlineSm),
            const SizedBox(height: 8),
            Text(
              'Tell us about your skills and experience so customers can find you.',
              style: AppTypography.bodyMd.copyWith(color: AppColors.outline),
            ),
            const SizedBox(height: 32),
            SkillLinkInput(
              label: 'Primary Skill / Profession',
              hint: 'e.g. Master Plumber, Electrician',
              controller: _skillCtrl,
            ),
            const SizedBox(height: 20),
            SkillLinkInput(
              label: 'Years of Experience',
              hint: 'e.g. 5',
              controller: _expCtrl,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            SkillLinkInput(
              label: 'Short Bio',
              hint: 'Tell customers about your expertise...',
              controller: _bioCtrl,
              maxLines: 4,
            ),
            const SizedBox(height: 40),
            SkillLinkButton.gradient(
              label: 'Save Professional Profile',
              isLoading: _isLoading,
              width: double.infinity,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
