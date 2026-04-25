import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/skilllink_button.dart';
import '../../../../shared/widgets/skilllink_input.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink_app/features/auth/presentation/providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/presentation/providers/auth_repository_provider.dart';
import '../../../../core/utils/url_utils.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userStateProvider).value;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _addressCtrl = TextEditingController(text: '');
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() => _isUploading = true);
      try {
        final repo = ref.read(authRepositoryProvider);
        await repo.uploadAvatar(image.path);
        
        // Refresh user state to show new avatar
        ref.invalidate(userStateProvider);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e'), backgroundColor: AppColors.error),
          );
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userStateProvider).value;
    
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Edit Profile',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontFamily: 'PlusJakartaSans',
                )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.surfaceContainerLow,
                    backgroundImage: user?.avatarUrl != null 
                        ? NetworkImage(UrlUtils.resolveImageUrl(user!.avatarUrl)) 
                        : null,
                    child: user?.avatarUrl == null || user!.avatarUrl!.isEmpty
                        ? const Icon(Icons.person, size: 50, color: AppColors.outline)
                        : null,
                  ),
                ),
                if (_isUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                    ),
                  ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        gradient: AppColors.buttonGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_outlined,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SkillLinkInput(label: 'Full Name', hint: 'Your name', controller: _nameCtrl),
            const SizedBox(height: 16),
            SkillLinkInput(label: 'Email', hint: 'you@example.com', controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            SkillLinkInput(label: 'Phone', hint: '+234...', controller: _phoneCtrl, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            SkillLinkInput(label: 'Default Address', hint: 'Your address', controller: _addressCtrl, maxLines: 2),
            const SizedBox(height: 32),
            SkillLinkButton.gradient(
              label: 'Save Changes', 
              width: double.infinity, 
              onPressed: () => context.pop()
            ),
          ],
        ),
      ),
    );
  }
}
