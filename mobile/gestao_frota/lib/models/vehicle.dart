class Vehicle {
  final String id;
  final String licensePlate;
  final String type;
  final String? model;
  final DateTime createdAt;

  Vehicle({
    required this.id,
    required this.licensePlate,
    required this.type,
    this.model,
    required this.createdAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      licensePlate: json['license_plate'] as String,
      type: json['type'] as String,
      model: json['model'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'license_plate': licensePlate,
      'type': type,
      'model': model,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return '$licensePlate - $type${model != null ? ' ($model)' : ''}';
  }
} 