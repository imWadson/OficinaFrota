import 'vehicle.dart';
import 'user_profile.dart';

enum ServiceOrderStatus {
  aguardandoAceite,
  recebido,
  rejeitado,
  analisando,
  consertoIniciado,
  finalizadoConserto,
  prontoRetirada,
  concluido,
}

class ServiceOrder {
  final int id;
  final String vehicleId;
  final ServiceOrderStatus status;
  final String creatorUserId;
  final DateTime dropoffTimestamp;
  final String dropoffPhotoUrl;
  final String? workshopReceiverUserId;
  final DateTime? workshopReceivedTimestamp;
  final String? workshopReceivedPhotoUrl;
  final String? pickupUserId;
  final DateTime? pickupTimestamp;
  final DateTime createdAt;

  // Relacionamentos
  final Vehicle? vehicle;
  final UserProfile? creator;
  final UserProfile? workshopReceiver;
  final UserProfile? pickupUser;
  final List<String> defects;

  ServiceOrder({
    required this.id,
    required this.vehicleId,
    required this.status,
    required this.creatorUserId,
    required this.dropoffTimestamp,
    required this.dropoffPhotoUrl,
    this.workshopReceiverUserId,
    this.workshopReceivedTimestamp,
    this.workshopReceivedPhotoUrl,
    this.pickupUserId,
    this.pickupTimestamp,
    required this.createdAt,
    this.vehicle,
    this.creator,
    this.workshopReceiver,
    this.pickupUser,
    this.defects = const [],
  });

  factory ServiceOrder.fromJson(Map<String, dynamic> json) {
    print('ServiceOrder.fromJson: Dados recebidos: $json');
    print('ServiceOrder.fromJson: Creator data: ${json['creator']}');

    final order = ServiceOrder(
      id: json['id'] as int,
      vehicleId: json['vehicle_id'] as String,
      status: _statusFromSnakeCase(json['status'] as String),
      creatorUserId: json['creator_user_id'] as String,
      dropoffTimestamp: DateTime.parse(json['dropoff_timestamp'] as String),
      dropoffPhotoUrl: json['dropoff_photo_url'] as String,
      workshopReceiverUserId: json['workshop_receiver_user_id'] as String?,
      workshopReceivedTimestamp: json['workshop_received_timestamp'] != null
          ? DateTime.parse(json['workshop_received_timestamp'] as String)
          : null,
      workshopReceivedPhotoUrl: json['workshop_received_photo_url'] as String?,
      pickupUserId: json['pickup_user_id'] as String?,
      pickupTimestamp: json['pickup_timestamp'] != null
          ? DateTime.parse(json['pickup_timestamp'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      vehicle: json['vehicle'] != null
          ? Vehicle.fromJson(json['vehicle'])
          : null,
      creator: json['creator'] != null
          ? UserProfile.fromJson(json['creator'])
          : null,
      workshopReceiver: json['workshop_receiver'] != null
          ? UserProfile.fromJson(json['workshop_receiver'])
          : null,
      pickupUser: json['pickup_user'] != null
          ? UserProfile.fromJson(json['pickup_user'])
          : null,
      defects: (json['defects'] as List<dynamic>?)?.cast<String>() ?? [],
    );

    print(
      'ServiceOrder.fromJson: Order criada com creator: ${order.creator?.fullName}',
    );
    return order;
  }

  Map<String, dynamic> toJson() {
    final statusValue = _statusToSnakeCase(status);
    print(
      'ServiceOrder.toJson: Status original: $status, convertido para: $statusValue',
    );

    return {
      'id': id,
      'vehicle_id': vehicleId,
      'status': statusValue,
      'creator_user_id': creatorUserId,
      'dropoff_timestamp': dropoffTimestamp.toIso8601String(),
      'dropoff_photo_url': dropoffPhotoUrl,
      'workshop_receiver_user_id': workshopReceiverUserId,
      'workshop_received_timestamp': workshopReceivedTimestamp
          ?.toIso8601String(),
      'workshop_received_photo_url': workshopReceivedPhotoUrl,
      'pickup_user_id': pickupUserId,
      'pickup_timestamp': pickupTimestamp?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  String _statusToSnakeCase(ServiceOrderStatus status) {
    print('ServiceOrder._statusToSnakeCase: Convertendo status: $status');
    String result;
    switch (status) {
      case ServiceOrderStatus.aguardandoAceite:
        result = 'aguardando_aceite';
        break;
      case ServiceOrderStatus.recebido:
        result = 'recebido';
        break;
      case ServiceOrderStatus.rejeitado:
        result = 'rejeitado';
        break;
      case ServiceOrderStatus.analisando:
        result = 'analisando';
        break;
      case ServiceOrderStatus.consertoIniciado:
        result = 'conserto_iniciado';
        break;
      case ServiceOrderStatus.finalizadoConserto:
        result = 'finalizado_conserto';
        break;
      case ServiceOrderStatus.prontoRetirada:
        result = 'pronto_retirada';
        break;
      case ServiceOrderStatus.concluido:
        result = 'concluido';
        break;
    }
    print('ServiceOrder._statusToSnakeCase: Resultado: $result');
    return result;
  }

  static ServiceOrderStatus _statusFromSnakeCase(String status) {
    switch (status) {
      case 'aguardando_aceite':
        return ServiceOrderStatus.aguardandoAceite;
      case 'recebido':
        return ServiceOrderStatus.recebido;
      case 'rejeitado':
        return ServiceOrderStatus.rejeitado;
      case 'analisando':
        return ServiceOrderStatus.analisando;
      case 'conserto_iniciado':
        return ServiceOrderStatus.consertoIniciado;
      case 'finalizado_conserto':
        return ServiceOrderStatus.finalizadoConserto;
      case 'pronto_retirada':
        return ServiceOrderStatus.prontoRetirada;
      case 'concluido':
        return ServiceOrderStatus.concluido;
      default:
        return ServiceOrderStatus.aguardandoAceite;
    }
  }

  ServiceOrder copyWith({
    int? id,
    String? vehicleId,
    ServiceOrderStatus? status,
    String? creatorUserId,
    DateTime? dropoffTimestamp,
    String? dropoffPhotoUrl,
    String? workshopReceiverUserId,
    DateTime? workshopReceivedTimestamp,
    String? workshopReceivedPhotoUrl,
    String? pickupUserId,
    DateTime? pickupTimestamp,
    DateTime? createdAt,
    Vehicle? vehicle,
    UserProfile? creator,
    UserProfile? workshopReceiver,
    UserProfile? pickupUser,
    List<String>? defects,
  }) {
    return ServiceOrder(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      status: status ?? this.status,
      creatorUserId: creatorUserId ?? this.creatorUserId,
      dropoffTimestamp: dropoffTimestamp ?? this.dropoffTimestamp,
      dropoffPhotoUrl: dropoffPhotoUrl ?? this.dropoffPhotoUrl,
      workshopReceiverUserId:
          workshopReceiverUserId ?? this.workshopReceiverUserId,
      workshopReceivedTimestamp:
          workshopReceivedTimestamp ?? this.workshopReceivedTimestamp,
      workshopReceivedPhotoUrl:
          workshopReceivedPhotoUrl ?? this.workshopReceivedPhotoUrl,
      pickupUserId: pickupUserId ?? this.pickupUserId,
      pickupTimestamp: pickupTimestamp ?? this.pickupTimestamp,
      createdAt: createdAt ?? this.createdAt,
      vehicle: vehicle ?? this.vehicle,
      creator: creator ?? this.creator,
      workshopReceiver: workshopReceiver ?? this.workshopReceiver,
      pickupUser: pickupUser ?? this.pickupUser,
      defects: defects ?? this.defects,
    );
  }

  String get statusText {
    switch (status) {
      case ServiceOrderStatus.aguardandoAceite:
        return 'Aguardando Aceite';
      case ServiceOrderStatus.recebido:
        return 'Recebido na Oficina';
      case ServiceOrderStatus.rejeitado:
        return 'Rejeitado';
      case ServiceOrderStatus.analisando:
        return 'Analisando Defeitos';
      case ServiceOrderStatus.consertoIniciado:
        return 'Conserto Iniciado';
      case ServiceOrderStatus.finalizadoConserto:
        return 'Conserto Finalizado';
      case ServiceOrderStatus.prontoRetirada:
        return 'Pronto para Retirada';
      case ServiceOrderStatus.concluido:
        return 'Concluído';
    }
  }

  bool get canBeAccepted => status == ServiceOrderStatus.aguardandoAceite;
  bool get canBeRejected => status == ServiceOrderStatus.aguardandoAceite;
  bool get canBePickedUp => status == ServiceOrderStatus.prontoRetirada;
  bool get isCompleted => status == ServiceOrderStatus.concluido;
}
