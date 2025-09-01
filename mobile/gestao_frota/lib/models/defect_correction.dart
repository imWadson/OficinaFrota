import 'user_profile.dart';

class DefectCorrection {
  final int id;
  final int orderId;
  final int defectId;
  final String correctedByUserId;
  final DateTime correctedAt;
  final String? notes;

  // Relacionamentos
  final UserProfile? correctedBy;

  DefectCorrection({
    required this.id,
    required this.orderId,
    required this.defectId,
    required this.correctedByUserId,
    required this.correctedAt,
    this.notes,
    this.correctedBy,
  });

  factory DefectCorrection.fromJson(Map<String, dynamic> json) {
    return DefectCorrection(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      defectId: json['defect_id'] as int,
      correctedByUserId: json['corrected_by_user_id'] as String,
      correctedAt: DateTime.parse(json['corrected_at'] as String),
      notes: json['notes'] as String?,
      correctedBy: json['corrected_by'] != null
          ? UserProfile.fromJson(json['corrected_by'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'defect_id': defectId,
      'corrected_by_user_id': correctedByUserId,
      'corrected_at': correctedAt.toIso8601String(),
      'notes': notes,
    };
  }

  DefectCorrection copyWith({
    int? id,
    int? orderId,
    int? defectId,
    String? correctedByUserId,
    DateTime? correctedAt,
    String? notes,
    UserProfile? correctedBy,
  }) {
    return DefectCorrection(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      defectId: defectId ?? this.defectId,
      correctedByUserId: correctedByUserId ?? this.correctedByUserId,
      correctedAt: correctedAt ?? this.correctedAt,
      notes: notes ?? this.notes,
      correctedBy: correctedBy ?? this.correctedBy,
    );
  }
}
