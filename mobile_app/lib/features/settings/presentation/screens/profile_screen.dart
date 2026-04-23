import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/skilllink_button.dart';
import '../../../../shared/widgets/skilllink_input.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink_app/features/auth/presentation/providers/user_provider.dart';

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

  @override
  void initState() {
    super.initState();
    final user = ref.read(userStateProvider).value;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _addressCtrl = TextEditingController(text: '');
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
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(ref.watch(userStateProvider).value?.avatarUrl ??
                      'https://i.pravatar.cc/150?u=${ref.watch(userStateProvider).value?.id ?? 0}'),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {},
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
            SkillLinkButton.gradient(label: 'Save Changes', width: double.infinity, onPressed: () => context.pop()),
          ],
        ),
      ),
    );
  }
}
