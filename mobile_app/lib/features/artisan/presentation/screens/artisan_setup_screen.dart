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
import '../providers/category_provider.dart';
import '../../data/models/category_model.dart';

class ArtisanSetupScreen extends ConsumerStatefulWidget {
  const ArtisanSetupScreen({super.key});

  @override
  ConsumerState<ArtisanSetupScreen> createState() => _ArtisanSetupScreenState();
}

class _ArtisanSetupScreenState extends ConsumerState<ArtisanSetupScreen> {
  final _bioCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _businessAddrCtrl = TextEditingController();
  final _guarantorNameCtrl = TextEditingController();
  final _guarantorPhoneCtrl = TextEditingController();
  final _idNumberCtrl = TextEditingController();
  
  String _idType = 'national_id';
  Category? _selectedCategory;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_selectedCategory == null || _bioCtrl.text.isEmpty || _expCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required professional fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dio = ref.read(dioProvider);
      final apiClient = ApiClient(dio);
      
      final locationState = ref.read(currentLocationProvider);
      final locationData = locationState.value;

      // 1. Update Profile
      final profileResponse = await apiClient.updateArtisanProfile({
        'skill': _selectedCategory!.name,
        'bio': _bioCtrl.text,
        'experience_years': int.tryParse(_expCtrl.text) ?? 0,
        'location_name': locationData?.name ?? 'Unknown',
        'latitude': locationData?.latitude ?? 0.0,
        'longitude': locationData?.longitude ?? 0.0,
        'business_address': _businessAddrCtrl.text,
        'guarantor_name': _guarantorNameCtrl.text,
        'guarantor_phone': _guarantorPhoneCtrl.text,
      });

      if (profileResponse.status != 'success') throw profileResponse.message ?? 'Update failed';

      // 2. Submit Verification if ID number is provided
      if (_idNumberCtrl.text.isNotEmpty) {
        await apiClient.submitVerification({
          'id_type': _idType,
          'id_number': _idNumberCtrl.text,
          'passport_photo': '', // Placeholder for now
          'id_image_front': '', 
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
            const Text('Primary Skill / Profession', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ref.watch(categoriesProvider).when(
              data: (categories) => DropdownButtonFormField<Category>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  hintText: 'Select your primary skill',
                  border: OutlineInputBorder(),
                ),
                items: categories.map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat.name),
                )).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error loading categories: $e'),
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
            const SizedBox(height: 16),
            _buildLocationPicker(),
            
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

  Widget _buildLocationPicker() {
    final locationState = ref.watch(currentLocationProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Based Location', style: AppTypography.titleMd),
              const Spacer(),
              TextButton.icon(
                onPressed: () => ref.read(currentLocationProvider.notifier).detectLocation(),
                icon: const Icon(Icons.my_location, size: 16),
                label: const Text('Detect'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          locationState.when(
            data: (loc) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.name, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                Text('${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}', 
                     style: AppTypography.bodySm.copyWith(color: AppColors.outline)),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error detecting location: $e', style: const TextStyle(color: Colors.red)),
          ),
        ],
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
