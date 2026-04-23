import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/skilllink_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userStateProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.heroGradient),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 24,
                right: 24,
                bottom: 28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand logo wordmark at top
                  Image.asset(
                    'assets/images/logo2.png',
                    height: 36,
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                  ),
                  const SizedBox(height: 20),
                  userAsync.when(
                    data: (user) => Row(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundImage: NetworkImage(user?.avatarUrl ??
                              'https://i.pravatar.cc/100?u=${user?.id ?? 0}'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user?.name ?? 'Guest User',
                                  style: AppTypography.titleLg
                                      .copyWith(color: Colors.white)),
                              Text(user?.email ?? 'Sign in to sync your data',
                                  style: AppTypography.bodyMd
                                      .copyWith(color: Colors.white70)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                    user != null
                                        ? '${user.role[0].toUpperCase()}${user.role.substring(1)} Account'
                                        : 'Account Type',
                                    style: AppTypography.labelSm
                                        .copyWith(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: Colors.white),
                          onPressed: () => context.go(AppRoutes.profile),
                        ),
                      ],
                    ),
                    loading: () => const Center(
                        child: CircularProgressIndicator(color: Colors.white)),
                    error: (err, __) => Text('Error: $err'),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _SettingsGroup(
                    title: 'Account',
                    items: [
                      _SettingsItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Edit Profile',
                        onTap: () => context.go(AppRoutes.profile),
                      ),
                      _SettingsItem(
                        icon: Icons.location_on_outlined,
                        label: 'Saved Addresses',
                        onTap: () => context.go(AppRoutes.savedAddresses),
                      ),
                      _SettingsItem(
                        icon: Icons.payment_outlined,
                        label: 'Payment Methods',
                        onTap: () => context.go(AppRoutes.paymentMethods),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SettingsGroup(
                    title: 'Preferences',
                    items: [
                      _SettingsItem(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        onTap: () {},
                        trailing: Switch(
                          value: true,
                          onChanged: (_) {},
                          activeColor: AppColors.primary,
                        ),
                      ),
                      _SettingsItem(
                        icon: Icons.language_outlined,
                        label: 'Language',
                        onTap: () {},
                        value: 'English',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SettingsGroup(
                    title: 'Support',
                    items: [
                      _SettingsItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & FAQ',
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy Policy',
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.info_outline_rounded,
                        label: 'About SkillLink',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SkillLinkCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    onTap: () async {
                      await ref.read(userStateProvider.notifier).clearUser();
                      if (context.mounted) context.go(AppRoutes.login);
                    },
                    child: Row(children: [
                      const Icon(Icons.logout_rounded,
                          color: AppColors.error, size: 20),
                      const SizedBox(width: 14),
                      Text('Sign Out',
                          style: AppTypography.titleSm.copyWith(
                              color: AppColors.error)),
                    ]),
                  ),
                  const SizedBox(height: 32),
                  Text('SkillLink v1.0.0',
                      style: AppTypography.labelSm.copyWith(
                          color: AppColors.outlineVariant)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        SkillLinkCard(
          child: Column(
            children: List.generate(items.length, (i) {
              final item = items[i];
              return Column(
                children: [
                  _SettingsTile(item: item),
                  if (i < items.length - 1)
                    Divider(
                      height: 1,
                      indent: 52,
                      color: AppColors.surfaceContainerLow,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? value;
  final Widget? trailing;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
    this.trailing,
  });
}

class _SettingsTile extends StatelessWidget {
  final _SettingsItem item;
  const _SettingsTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: item.onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(item.icon, size: 18, color: AppColors.primary),
      ),
      title: Text(item.label, style: Theme.of(context).textTheme.bodyMedium),
      trailing: item.trailing ??
          (item.value != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.value!,
                        style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded,
                        size: 16, color: AppColors.outline),
                  ],
                )
              : const Icon(Icons.chevron_right_rounded,
                  size: 16, color: AppColors.outline)),
    );
  }
}
