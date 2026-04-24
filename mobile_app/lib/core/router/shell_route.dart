import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/dashboard/presentation/screens/customer_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/artisan_dashboard_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import 'app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/user_provider.dart';

class AppShellRoute {
  static final route = StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return _AppShell(navigationShell: navigationShell);
    },
    branches: [
      // 0: Home
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (_, __) => const HomeScreen(),
          ),
        ],
      ),
      // 1: Customer Dashboard
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.customerDashboard,
            name: 'customer-dashboard',
            builder: (_, __) => const CustomerDashboardScreen(),
          ),
        ],
      ),
      // 2: Artisan Dashboard
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.artisanDashboard,
            name: 'artisan-dashboard',
            builder: (_, __) => const ArtisanDashboardScreen(),
          ),
        ],
      ),
      // 3: Chat List
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.chatList,
            name: 'chat-list',
            builder: (_, __) => const ChatListScreen(),
          ),
        ],
      ),
      // 4: Notifications
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.notifications,
            name: 'notifications',
            builder: (_, __) => const NotificationsScreen(),
          ),
        ],
      ),
      // 5: Settings
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (_, __) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}

class _AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const _AppShell({required this.navigationShell});

  List<int> _getBranchIndices(String? role) {
    if (role == 'artisan') {
      return [2, 3, 4, 5]; // Artisan: Dashboard, Chat, Alerts, Profile
    }
    return [0, 1, 3, 5]; // Customer: Home, Bookings, Chat, Profile
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(userStateProvider).value?.role;
    final branchIndices = _getBranchIndices(userRole);
    
    // Find the current selected index in the filtered list
    int selectedIndex = branchIndices.indexOf(navigationShell.currentIndex);
    if (selectedIndex == -1) selectedIndex = 0;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _GlassBottomNav(
        selectedIndex: selectedIndex,
        role: userRole,
        onTap: (index) {
          navigationShell.goBranch(
            branchIndices[index],
            initialLocation: branchIndices[index] == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

class _GlassBottomNav extends StatelessWidget {
  final int selectedIndex;
  final String? role;
  final ValueChanged<int> onTap;

  const _GlassBottomNav({
    required this.selectedIndex,
    required this.role,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<_NavItem> items;
    if (role == 'artisan') {
      items = [
        _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
        _NavItem(icon: Icons.chat_bubble_rounded, label: 'Messages'),
        _NavItem(icon: Icons.notifications_rounded, label: 'Alerts'),
        _NavItem(icon: Icons.person_rounded, label: 'Profile'),
      ];
    } else {
      items = [
        _NavItem(icon: Icons.home_rounded, label: 'Home'),
        _NavItem(icon: Icons.calendar_month_rounded, label: 'Bookings'),
        _NavItem(icon: Icons.chat_bubble_rounded, label: 'Chat'),
        _NavItem(icon: Icons.person_rounded, label: 'Profile'),
      ];
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.glassBackground.withOpacity(0.8),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / items.length;
                
                return Stack(
                  children: [
                    // Sliding Indicator
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.fastOutSlowIn,
                      left: selectedIndex * itemWidth,
                      top: 10,
                      bottom: 10,
                      width: itemWidth,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    
                    // Nav Items
                    Row(
                      children: List.generate(items.length, (i) {
                        final selected = selectedIndex == i;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => onTap(i),
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedScale(
                              scale: selected ? 1.05 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    items[i].icon,
                                    color: selected ? AppColors.primary : AppColors.outline,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    items[i].label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.labelSm.copyWith(
                                      color: selected ? AppColors.primary : AppColors.outline,
                                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem({required this.icon, required this.label});
}
