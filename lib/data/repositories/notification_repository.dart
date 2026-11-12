import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final ApiClient _client;

  NotificationRepository({ApiClient? client}) : _client = client ?? ApiClient();

  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await _client.get(ApiEndpoints.notifications);
      final data = response.data;
      final List rawList = data['notifications'] ?? [];
      final notifications = rawList.map((item) => NotificationModel.fromJson(Map<String, dynamic>.from(item))).toList();
      final unreadCount = data['unreadCount'] ?? 0;

      return {
        'notifications': notifications,
        'unreadCount': unreadCount,
      };
    } catch (_) {
      return {
        'notifications': <NotificationModel>[],
        'unreadCount': 0,
      };
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _client.patch(ApiEndpoints.markNotificationRead(id));
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _client.post(ApiEndpoints.markAllNotificationsRead);
    } catch (_) {}
  }
}
