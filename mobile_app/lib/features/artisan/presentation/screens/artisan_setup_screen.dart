import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
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
  final _businessAddrCtrl = TextEditingController();
  final _guarantorNameCtrl = TextEditingController();
  final _guarantorPhoneCtrl = TextEditingController();
  final _idNumberCtrl = TextEditingController();
  
  String _idType = 'national_id';
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_skillCtrl.text.isEmpty || _bioCtrl.text.isEmpty || _expCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required professional fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dio = ref.read(dioProvider);
      final apiClient = ApiClient(dio);
      final location = ref.read(currentLocationProvider).value ?? 'Unknown';

      // 1. Update Profile
      final profileResponse = await apiClient.updateArtisanProfile({
        'skill': _skillCtrl.text,
        'bio': _bioCtrl.text,
        'experience_years': int.tryParse(_expCtrl.text) ?? 0,
        'location_name': location,
        'business_address': _businessAddrCtrl.text,
        'guarantor_name': _guarantorNameCtrl.text,
        'guarantor_phone': _guarantorPhoneCtrl.text,
        'latitude': 0.0,
        'longitude': 0.0,
      });

      if (profileResponse.status != 'success') throw profileResponse.message ?? 'Update failed';

      // 2. Submit Verification if ID number is provided
      if (_idNumberCtrl.text.isNotEmpty) {
        await apiClient.submitVerification({
          'id_type': _idType,
          'id_number': _idNumberCtrl.text,
          'id_image_front': '', // To be handled with file picker
          'id_image_back': '',
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Professional profile and security details saved!')),
        );
        context.go(AppRoutes.artisanDashboard);
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (e is DioException) {
        final response = e.response;
        if (response != null && response.data is Map) {
          errorMessage = response.data['message'] ?? response.data['error'] ?? e.message;
        } else {
          errorMessage = e.message ?? 'Unknown server error';
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMessage'),
            backgroundColor: Colors.redAccent,
          ),
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
            _buildSectionHeader('Professional Details', 'Showcase your skills'),
            const SizedBox(height: 20),
            SkillLinkInput(
              label: 'Primary Skill / Profession',
              hint: 'e.g. Master Plumber, Electrician',
              controller: _skillCtrl,
            ),
            const SizedBox(height: 16),
            SkillLinkInput(
              label: 'Years of Experience',
              hint: 'e.g. 5',
              controller: _expCtrl,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SkillLinkInput(
              label: 'Short Bio',
              hint: 'Tell customers about your expertise...',
              controller: _bioCtrl,
              maxLines: 3,
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader('Business & Trust', 'Essential for security tracking'),
            const SizedBox(height: 20),
            SkillLinkInput(
              label: 'Business Address (Optional)',
              hint: 'Workshop or office address',
              controller: _businessAddrCtrl,
            ),
            const SizedBox(height: 16),
            SkillLinkInput(
              label: 'Guarantor Name',
              hint: 'A person who can vouch for you',
              controller: _guarantorNameCtrl,
            ),
            const SizedBox(height: 16),
            SkillLinkInput(
              label: 'Guarantor Phone',
              hint: 'Phone number of guarantor',
              controller: _guarantorPhoneCtrl,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 32),
            _buildSectionHeader('Identity Verification', 'Upload documents for a "Verified" badge'),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _idType,
              decoration: const InputDecoration(
                labelText: 'ID Document Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'national_id', child: Text('National ID')),
                DropdownMenuItem(value: 'drivers_license', child: Text('Driver\'s License')),
                DropdownMenuItem(value: 'voters_card', child: Text('Voter\'s Card')),
                DropdownMenuItem(value: 'passport', child: Text('International Passport')),
              ],
              onChanged: (val) => setState(() => _idType = val!),
            ),
            const SizedBox(height: 16),
            SkillLinkInput(
              label: 'ID Number',
              hint: 'Enter the number on your ID card',
              controller: _idNumberCtrl,
            ),

            const SizedBox(height: 40),
            SkillLinkButton.gradient(
              label: 'Save Professional Profile',
              isLoading: _isLoading,
              width: double.infinity,
              onPressed: _submit,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.titleLg.copyWith(fontWeight: FontWeight.bold)),
        Text(subtitle, style: AppTypography.bodySm.copyWith(color: AppColors.outline)),
      ],
    );
  }
}
