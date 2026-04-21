import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/skilllink_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            onPressed: () {},
            child: Text('Mark All Read',
                style: AppTypography.labelLg.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          _NotifSection(label: 'Today', notifications: [
            _Notif(
              icon: Icons.check_circle_outline_rounded,
              color: Colors.green,
              title: 'Booking Confirmed',
              subtitle: 'Emmanuel has confirmed your booking for tomorrow at 10AM.',
              time: '2m ago',
              isRead: false,
            ),
            _Notif(
              icon: Icons.chat_bubble_outline_rounded,
              color: AppColors.primary,
              title: 'New Message',
              subtitle: 'Emmanuel: "I\'ll be there by 10am. Please make sure..."',
              time: '15m ago',
              isRead: false,
            ),
          ]),
          _NotifSection(label: 'Yesterday', notifications: [
            _Notif(
              icon: Icons.star_outline_rounded,
              color: const Color(0xFFFFB84D),
              title: 'Rate Your Experience',
              subtitle: 'How was your service with Chukwudi Adeyemi?',
              time: '1d ago',
              isRead: true,
            ),
            _Notif(
              icon: Icons.payment_outlined,
              color: AppColors.tertiary,
              title: 'Payment Received',
              subtitle: 'Your payment of ₦15,000 was processed successfully.',
              time: '1d ago',
              isRead: true,
            ),
          ]),
        ],
      ),
    );
  }
}

class _Notif {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;
  final bool isRead;

  const _Notif({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isRead,
  });
}

class _NotifSection extends StatelessWidget {
  final String label;
  final List<_Notif> notifications;

  const _NotifSection({required this.label, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(label, style: Theme.of(context).textTheme.titleSmall),
        ),
        ...notifications.map((n) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SkillLinkCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: n.isRead
                ? AppColors.surfaceContainerLowest
                : AppColors.primary.withOpacity(0.04),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: n.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(n.icon, color: n.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(n.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
                      )),
                      const Spacer(),
                      Text(n.time, style: Theme.of(context).textTheme.labelSmall),
                    ]),
                    const SizedBox(height: 4),
                    Text(n.subtitle,
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
