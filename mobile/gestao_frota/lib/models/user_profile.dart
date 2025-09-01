class UserProfile {
  final String id;
  final String fullName;
  final String role; // 'operacao' ou 'oficina'
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.role,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isOperacao => role == 'operacao';
  bool get isOficina => role == 'oficina';
} 