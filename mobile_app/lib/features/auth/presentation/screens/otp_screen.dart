import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/skilllink_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  int _resendTimer = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() => _resendTimer--);
        _startTimer();
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _verify() {
    if (_otp.length < 6) return;
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        final user = ref.read(userStateProvider).value;
        if (user?.role == 'artisan') {
          context.go(AppRoutes.artisanProfileSetup);
        } else {
          context.go(AppRoutes.home);
        }
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text('Verify Your\nPhone 📲',
                style: AppTypography.headlineLg.copyWith(height: 1.15)),
            const SizedBox(height: 8),
            Text(
              'Enter the 6-digit code sent to\n${widget.phone}',
              style:
                  AppTypography.bodyMd.copyWith(color: AppColors.outline, height: 1.5),
            ),
            const SizedBox(height: 48),

            // OTP boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) => _OtpBox(
                controller: _controllers[i],
                focusNode: _nodes[i],
                onChanged: (val) {
                  if (val.isNotEmpty && i < 5) {
                    _nodes[i + 1].requestFocus();
                  }
                  if (val.isEmpty && i > 0) {
                    _nodes[i - 1].requestFocus();
                  }
                  setState(() {});
                },
              )),
            ),

            const SizedBox(height: 32),

            SkillLinkButton.gradient(
              label: 'Verify Code',
              width: double.infinity,
              isLoading: _isLoading,
              onPressed: _otp.length == 6 ? _verify : null,
            ),

            const SizedBox(height: 24),

            Center(
              child: _resendTimer > 0
                  ? Text(
                      'Resend code in ${_resendTimer}s',
                      style: AppTypography.labelLg,
                    )
                  : TextButton(
                      onPressed: () {
                        setState(() => _resendTimer = 30);
                        _startTimer();
                      },
                      child: Text('Resend Code',
                          style: AppTypography.labelLg.copyWith(
                              color: AppColors.primary)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
        style: AppTypography.headlineSm,
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: controller.text.isNotEmpty
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
