import 'dart:io';
import 'package:image_picker/image_picker.dart';
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
import 'package:skilllink_app/features/auth/presentation/providers/user_provider.dart';
import '../providers/artisan_provider.dart';

import '../../../../core/utils/url_utils.dart';


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
  final List<int> _selectedSubServices = [];
  bool _isLoading = false;


  XFile? _profileImage;
  final List<XFile> _portfolioImages = [];
  final List<String> _existingPortfolioUrls = [];
  final _picker = ImagePicker();
  bool _isEditMode = false;
  bool _hasInitialized = false;


  Future<void> _pickProfileImage() async {
    final img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _profileImage = img);
  }

  Future<void> _pickPortfolioImages() async {
    final images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _portfolioImages.addAll(images);
        if (_portfolioImages.length > 5) {
          _portfolioImages.removeRange(5, _portfolioImages.length);
        }
      });
    }
  }

  void _initializeWithExistingProfile() async {
    final user = ref.read(userStateProvider).value;
    if (user == null || _hasInitialized) return;

    setState(() => _isLoading = true);
    try {
      final artisan = await ref.read(artisanProfileProvider(user.id).future);
      
      // If we got here, it means the artisan has a profile
      _isEditMode = true;
      _bioCtrl.text = artisan.bio ?? '';
      _expCtrl.text = artisan.experienceYears.toString();
      _businessAddrCtrl.text = artisan.businessAddress ?? '';
      _guarantorNameCtrl.text = artisan.guarantorName ?? '';
      _guarantorPhoneCtrl.text = artisan.guarantorPhone ?? '';
      
      // Handle category
      if (artisan.categoryId != null) {
        final categories = ref.read(categoriesProvider).value;
        if (categories != null) {
          _selectedCategory = categories.firstWhere(
            (c) => c.id == artisan.categoryId,
            orElse: () => categories.first,
          );
        }
      }

      // Handle sub-services
      if (artisan.subServices != null) {
        _selectedSubServices.clear();
        _selectedSubServices.addAll(artisan.subServices!.map((s) => s['id'] as int));
      }

      // Handle portfolio
      if (artisan.portfolio != null) {
        _existingPortfolioUrls.clear();
        _existingPortfolioUrls.addAll(artisan.portfolio!.map((p) => p.imageUrl));
      }


      _hasInitialized = true;
    } catch (e) {
      // Not an artisan yet or error fetching
      _isEditMode = false;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
      
      final locationState = ref.read(currentLocationProvider);
      final locationData = locationState.value;

      // Prepare Multipart Data
      final formData = FormData.fromMap({
        'skill': _selectedCategory!.name,
        'bio': _bioCtrl.text,
        'experience_years': int.tryParse(_expCtrl.text) ?? 0,
        'location_name': locationData?.name ?? 'Unknown',
        'latitude': locationData?.latitude ?? 0.0,
        'longitude': locationData?.longitude ?? 0.0,
        'business_address': _businessAddrCtrl.text,
        'guarantor_name': _guarantorNameCtrl.text,
        'guarantor_phone': _guarantorPhoneCtrl.text,
        'sub_services': _selectedSubServices.join(','),
      });


      // Add Profile Image
      if (_profileImage != null) {
        formData.files.add(MapEntry(
          'avatar',
          await MultipartFile.fromFile(_profileImage!.path),
        ));
      }

      // Add Portfolio Images
      for (var img in _portfolioImages) {
        formData.files.add(MapEntry(
          'portfolio[]',
          await MultipartFile.fromFile(img.path),
        ));
      }

      final response = await dio.post('artisan/update', data: formData);

      if (response.data['status'] != 'success') throw response.data['message'] ?? 'Update failed';

      // 2. Submit Verification if ID number is provided
      if (_idNumberCtrl.text.isNotEmpty) {
        await dio.post('artisan/verify', data: {
          'id_type': _idType,
          'id_number': _idNumberCtrl.text,
          'passport_photo': '', 
          'id_image_front': '', 
          'id_image_back': '',
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Professional profile and portfolio saved!')),
        );
        final user = ref.read(userStateProvider).value;
        if (user != null) {
          ref.invalidate(artisanProfileProvider(user.id));
        }
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
    // Trigger initialization once categories are ready
    ref.listen(categoriesProvider, (prev, next) {
      if (next.hasValue && !_hasInitialized) {
        _initializeWithExistingProfile();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Professional Profile' : 'Professional Setup'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Professional Identity', 'Upload a profile photo and portfolio'),
            const SizedBox(height: 20),
            
            // Profile Image Picker
            Center(
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.surfaceContainerHigh,
                      backgroundImage: _profileImage != null ? FileImage(File(_profileImage!.path)) : null,
                      child: _profileImage == null ? const Icon(Icons.person_add_rounded, size: 32, color: AppColors.primary) : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Portfolio Picker
            const Text('Portfolio / Work Pictures (3-5 recommended)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _existingPortfolioUrls.length + _portfolioImages.length + 1,
                itemBuilder: (context, i) {
                  // 1. Existing Portfolio Images
                  if (i < _existingPortfolioUrls.length) {
                    final url = _existingPortfolioUrls[i];
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(UrlUtils.resolveImageUrl(url)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }

                  // 2. New Portfolio Images
                  final newIdx = i - _existingPortfolioUrls.length;
                  if (newIdx < _portfolioImages.length) {
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(File(_portfolioImages[newIdx].path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 16,
                          child: GestureDetector(
                            onTap: () => setState(() => _portfolioImages.removeAt(newIdx)),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  // 3. Add Button
                  if (_existingPortfolioUrls.length + _portfolioImages.length >= 5) return const SizedBox.shrink();
                  return GestureDetector(
                    onTap: _pickPortfolioImages,
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary),
                    ),
                  );
                },

              ),
            ),
            
            const SizedBox(height: 32),
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
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val;
                    _selectedSubServices.clear(); // Reset sub-services when category changes
                  });
                },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error loading categories: $e'),
            ),
            const SizedBox(height: 16),

            // Sub-Services Selection
            if (_selectedCategory != null) ...[
              const Text('Specific Services / Expertise', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ref.watch(categoryServicesProvider(_selectedCategory!.id)).when(
                data: (services) => Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: services.map((service) {
                    final isSelected = _selectedSubServices.contains(service.id);
                    return FilterChip(
                      label: Text(service.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSubServices.add(service.id);
                          } else {
                            _selectedSubServices.remove(service.id);
                          }
                        });
                      },
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                    );
                  }).toList(),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error loading services: $e'),
              ),
              const SizedBox(height: 16),
            ],

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
              label: _isEditMode ? 'Update Professional Profile' : 'Save Professional Profile',
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
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => ref.read(currentLocationProvider.notifier).detectLocation(),
                    icon: const Icon(Icons.my_location, size: 16),
                    label: const Text('Detect'),
                  ),
                  TextButton.icon(
                    onPressed: () => context.push(AppRoutes.locationPicker),
                    icon: const Icon(Icons.map_outlined, size: 16),
                    label: const Text('Map'),
                  ),
                ],
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
