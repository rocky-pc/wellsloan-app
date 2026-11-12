class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String deepLink;
  final String priority;
  final bool isRead;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.deepLink,
    required this.priority,
    required this.isRead,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      deepLink: json['deep_link'] ?? json['deepLink'] ?? 'home',
      priority: json['priority'] ?? 'normal',
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}
