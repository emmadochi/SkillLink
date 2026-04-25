import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:skilllink_app/core/theme/app_colors.dart';
import 'package:skilllink_app/core/theme/app_typography.dart';
import 'package:skilllink_app/shared/widgets/skilllink_card.dart';
import 'package:skilllink_app/features/notifications/data/models/notification_model.dart';
import 'package:skilllink_app/features/notifications/presentation/providers/notification_provider.dart';
import 'package:skilllink_app/features/notifications/data/repositories/notification_repository.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Notifications',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontFamily: 'PlusJakartaSans',
                  color: AppColors.onSurface,
                )),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(notificationRepositoryProvider).markAsRead();
              ref.invalidate(notificationsProvider);
            },
            child: Text('Mark All Read',
                style: AppTypography.labelLg.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(notificationsProvider.future),
        child: notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.notifications_none_rounded, size: 64, color: AppColors.outlineVariant),
                        const SizedBox(height: 16),
                        Text('No notifications yet', style: AppTypography.titleSm),
                      ],
                    ),
                  ),
                ],
              );
            }

            final grouped = _groupNotifications(notifications);

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: grouped.entries.map((entry) {
                return _NotifSection(
                  label: entry.key,
                  notifications: entry.value,
                  onMarkRead: (id) async {
                    await ref.read(notificationRepositoryProvider).markAsRead(id: id);
                    ref.invalidate(notificationsProvider);
                  },
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, __) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Map<String, List<NotificationModel>> _groupNotifications(List<NotificationModel> notifications) {
    final Map<String, List<NotificationModel>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final n in notifications) {
      final date = DateTime.parse(n.createdAt);
      final normalizedDate = DateTime(date.year, date.month, date.day);
      
      String label;
      if (normalizedDate == today) {
        label = 'Today';
      } else if (normalizedDate == yesterday) {
        label = 'Yesterday';
      } else {
        label = DateFormat('MMMM d, yyyy').format(date);
      }

      if (!grouped.containsKey(label)) {
        grouped[label] = [];
      }
      grouped[label]!.add(n);
    }
    return grouped;
  }
}

class _NotifSection extends StatelessWidget {
  final String label;
  final List<NotificationModel> notifications;
  final Function(int) onMarkRead;

  const _NotifSection({
    required this.label, 
    required this.notifications,
    required this.onMarkRead,
  });

  IconData _getIcon(String type) {
    switch (type) {
      case 'booking': return Icons.calendar_month_rounded;
      case 'message': return Icons.chat_bubble_outline_rounded;
      case 'payment': return Icons.payment_outlined;
      case 'review': return Icons.star_outline_rounded;
      default: return Icons.notifications_outlined;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'booking': return Colors.green;
      case 'message': return AppColors.primary;
      case 'payment': return AppColors.tertiary;
      case 'review': return const Color(0xFFFFB84D);
      default: return AppColors.outline;
    }
  }

  String _formatTime(String createdAt) {
    final date = DateTime.parse(createdAt);
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(label, style: Theme.of(context).textTheme.titleSmall),
        ),
        ...notifications.map((NotificationModel n) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SkillLinkCard(
            onTap: n.isRead ? null : () => onMarkRead(n.id),
            padding: const EdgeInsets.all(14),
            backgroundColor: n.isRead
                ? AppColors.surfaceContainerLowest
                : AppColors.primary.withOpacity(0.04),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _getColor(n.type).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_getIcon(n.type), color: _getColor(n.type), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(n.title, 
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
                          )
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(_formatTime(n.createdAt), style: Theme.of(context).textTheme.labelSmall),
                    ]),
                    const SizedBox(height: 4),
                    Text(n.message,
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.outline,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (!n.isRead)
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 2),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ]),
          ),
        )),
      ],
    );
  }
}
