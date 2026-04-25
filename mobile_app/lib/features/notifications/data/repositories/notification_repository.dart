import 'package:skilllink_app/core/network/api_client.dart';
import 'package:skilllink_app/core/network/api_providers.dart';
import 'package:skilllink_app/features/notifications/data/models/notification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead({int? id});
}

class NotificationRepositoryImpl implements NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepositoryImpl(this._apiClient);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _apiClient.getNotifications();
    if (response.status == 'success' && response.data != null) {
      return response.data!;
    }
    throw response.message ?? 'Failed to load notifications';
  }

  @override
  Future<void> markAsRead({int? id}) async {
    final response = await _apiClient.markNotificationsRead(id: id);
    if (response.status != 'success') {
      throw response.message ?? 'Failed to mark as read';
    }
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationRepositoryImpl(apiClient);
});
