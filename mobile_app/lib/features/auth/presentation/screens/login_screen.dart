import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/skilllink_button.dart';
import '../../../../shared/widgets/skilllink_input.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink_app/features/auth/presentation/providers/auth_repository_provider.dart';
import 'package:skilllink_app/features/auth/presentation/providers/user_provider.dart';
import 'package:skilllink_app/core/constants/app_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final repository = ref.read(authRepositoryProvider);
      final authData = await repository.login(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );

      // Save token to secure storage
      const storage = FlutterSecureStorage();
      await storage.write(key: AppConstants.keyToken, value: authData.token);
      
      // Update User Provider
      await ref.read(userStateProvider.notifier).setUser(authData.user);

      if (mounted) {
        setState(() => _isLoading = false);
        if (authData.user.role == 'artisan') {
          context.go(AppRoutes.artisanDashboard);
        } else {
          context.go(AppRoutes.home);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Hero header
                Text('Welcome\nBack 👋',
                    style: AppTypography.headlineLg.copyWith(height: 1.15)),
                const SizedBox(height: 8),
                Text('Sign in to find the best artisans near you.',
                    style: AppTypography.bodyMd.copyWith(
                        color: AppColors.outline, height: 1.5)),

                const SizedBox(height: 48),

                // Email
                SkillLinkInput(
                  label: 'Email',
                  hint: 'you@example.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.mail_outline_rounded,
                      size: 18, color: AppColors.outline),
                  validator: (v) =>
                      v == null || !v.contains('@') ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 20),

                // Password
                SkillLinkInput(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  prefixIcon: const Icon(Icons.lock_outline_rounded,
                      size: 18, color: AppColors.outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 18,
                      color: AppColors.outline,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) => v == null || v.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                ),

                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text('Forgot Password?',
                        style: AppTypography.labelLg.copyWith(
                            color: AppColors.primary)),
                  ),
                ),

                const SizedBox(height: 32),

                SkillLinkButton.gradient(
                  label: 'Sign In',
                  width: double.infinity,
                  isLoading: _isLoading,
                  onPressed: _login,
                ),

                const SizedBox(height: 24),

                // Divider
                Row(children: [
                  const Expanded(child: Divider(color: AppColors.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR',
                        style: AppTypography.labelMd.copyWith(
                            color: AppColors.outline)),
                  ),
                  const Expanded(child: Divider(color: AppColors.outlineVariant)),
                ]),

                const SizedBox(height: 24),

                // Google social
                SkillLinkButton.outlined(
                  label: 'Continue with Google',
                  width: double.infinity,
                  icon: const Icon(Icons.g_mobiledata_rounded,
                      size: 22, color: AppColors.primary),
                  onPressed: () {},
                ),

                const SizedBox(height: 32),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ",
                        style: AppTypography.bodyMd.copyWith(
                            color: AppColors.outline)),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.signup),
                      child: Text('Sign Up',
                          style: AppTypography.bodyMd.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
