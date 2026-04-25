import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink_app/features/notifications/data/models/notification_model.dart';
import 'package:skilllink_app/features/notifications/data/repositories/notification_repository.dart';

final notificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getNotifications();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider).value ?? [];
  return notifications.where((n) => !n.isRead).length;
});
