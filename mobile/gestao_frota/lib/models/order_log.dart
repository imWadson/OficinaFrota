import 'user_profile.dart';

class OrderLog {
  final int id;
  final int orderId;
  final String userId;
  final String? previousStatus;
  final String newStatus;
  final String logMessage;
  final DateTime createdAt;

  // Relacionamentos
  final UserProfile? user;

  OrderLog({
    required this.id,
    required this.orderId,
    required this.userId,
    this.previousStatus,
    required this.newStatus,
    required this.logMessage,
    required this.createdAt,
    this.user,
  });

  factory OrderLog.fromJson(Map<String, dynamic> json) {
    return OrderLog(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      userId: json['user_id'] as String,
      previousStatus: json['previous_status'] as String?,
      newStatus: json['new_status'] as String,
      logMessage: json['log_message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      user: json['user'] != null ? UserProfile.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'user_id': userId,
      'previous_status': previousStatus,
      'new_status': newStatus,
      'log_message': logMessage,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
