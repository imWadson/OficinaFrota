import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/vehicle.dart';
import '../models/service_order.dart';
import '../models/order_log.dart';
import '../models/defect_correction.dart';
import 'supabase_service.dart';

class DataService {
  static final SupabaseClient _client = SupabaseService.client;

  // ===== PERFIS DE USUÁRIO =====
  static Future<UserProfile?> getUserProfile(String userId) async {
    print('DataService: Buscando perfil do usuário: $userId');
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      print('DataService: Perfil encontrado: ${response['full_name']}');
      return UserProfile.fromJson(response);
    } catch (e) {
      print('DataService: Erro ao buscar perfil do usuário: $e');
      return null;
    }
  }

  static Future<void> createUserProfile(UserProfile profile) async {
    print('DataService: Criando perfil do usuário: ${profile.fullName}');
    try {
      // Verificar se o perfil já existe
      final existingProfile = await getUserProfile(profile.id);
      if (existingProfile != null) {
        print('DataService: Perfil já existe, atualizando...');
        await updateUserProfile(profile);
        return;
      }

      final profileData = profile.toJson();
      print('DataService: Dados do perfil: $profileData');

      await _client.from('profiles').insert(profileData);
      print('DataService: Perfil criado com sucesso');
    } catch (e) {
      print('DataService: Erro ao criar perfil do usuário: $e');
      rethrow;
    }
  }

  static Future<void> updateUserProfile(UserProfile profile) async {
    print('DataService: Atualizando perfil do usuário: ${profile.fullName}');
    try {
      await _client
          .from('profiles')
          .update(profile.toJson())
          .eq('id', profile.id);
      print('DataService: Perfil atualizado com sucesso');
    } catch (e) {
      print('DataService: Erro ao atualizar perfil do usuário: $e');
      rethrow;
    }
  }

  static Future<void> upsertUserProfile(UserProfile profile) async {
    print(
      'DataService: Criando/atualizando perfil do usuário: ${profile.fullName}',
    );
    try {
      await _client.from('profiles').upsert(profile.toJson(), onConflict: 'id');
      print('DataService: Perfil criado/atualizado com sucesso');
    } catch (e) {
      print('DataService: Erro ao criar/atualizar perfil do usuário: $e');
      rethrow;
    }
  }

  // ===== VEÍCULOS =====
  static Future<List<Vehicle>> getVehicles() async {
    try {
      final response = await _client
          .from('vehicles')
          .select()
          .order('license_plate');

      return (response as List).map((json) => Vehicle.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar veículos: $e');
      return [];
    }
  }

  static Future<Vehicle?> getVehicle(String id) async {
    try {
      final response = await _client
          .from('vehicles')
          .select()
          .eq('id', id)
          .single();

      return Vehicle.fromJson(response);
    } catch (e) {
      print('Erro ao buscar veículo: $e');
      return null;
    }
  }

  static Future<Vehicle> createVehicle(Vehicle vehicle) async {
    try {
      // Verificar se o veículo já existe pela placa
      final existingVehicle = await _client
          .from('vehicles')
          .select()
          .eq('license_plate', vehicle.licensePlate)
          .maybeSingle();

      if (existingVehicle != null) {
        print('DataService: Veículo já existe, retornando existente');
        return Vehicle.fromJson(existingVehicle);
      }

      // Se o ID está vazio, deixar o banco gerar um UUID
      final vehicleData = vehicle.toJson();
      if (vehicleData['id'] == '') {
        vehicleData.remove('id');
      }

      final response = await _client
          .from('vehicles')
          .insert(vehicleData)
          .select()
          .single();

      print(
        'DataService: Veículo criado com sucesso: ${response['license_plate']}',
      );
      return Vehicle.fromJson(response);
    } catch (e) {
      print('Erro ao criar veículo: $e');
      rethrow;
    }
  }

  // ===== ORDENS DE SERVIÇO =====
  static Future<List<ServiceOrder>> getServiceOrders({
    String? userId,
    String? status,
    bool includeRelations = true,
  }) async {
    try {
      String selectQuery = includeRelations
          ? '''
        *,
        vehicle:vehicles(*),
        creator:profiles!service_orders_creator_user_id_fkey(*),
        workshop_receiver:profiles!service_orders_workshop_receiver_user_id_fkey(*),
        pickup_user:profiles!service_orders_pickup_user_id_fkey(*)
      '''
          : '*';

      var query = _client.from('service_orders').select(selectQuery);

      if (userId != null) {
        query = query.eq('creator_user_id', userId);
      }

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.order('created_at', ascending: false);

      // Processar cada ordem para carregar relacionamentos se necessário
      List<ServiceOrder> orders = [];
      for (var json in response) {
        Map<String, dynamic> orderData = Map<String, dynamic>.from(json);

        // Carregar criador se não foi carregado
        if (orderData['creator'] == null &&
            orderData['creator_user_id'] != null) {
          try {
            final creatorResponse = await _client
                .from('profiles')
                .select()
                .eq('id', orderData['creator_user_id'])
                .single();
            orderData['creator'] = creatorResponse;
          } catch (e) {
            print('DataService.getServiceOrders: Erro ao carregar criador: $e');
          }
        }

        orders.add(ServiceOrder.fromJson(orderData));
      }

      return orders;
    } catch (e) {
      print('Erro ao buscar ordens de serviço: $e');
      return [];
    }
  }

  static Future<ServiceOrder?> getServiceOrder(int id) async {
    try {
      final response = await _client
          .from('service_orders')
          .select('''
            *,
            vehicle:vehicles(*),
            creator:profiles!service_orders_creator_user_id_fkey(*),
            workshop_receiver:profiles!service_orders_workshop_receiver_user_id_fkey(*),
            pickup_user:profiles!service_orders_pickup_user_id_fkey(*)
          ''')
          .eq('id', id)
          .single();

      print('DataService.getServiceOrder: Dados da ordem: $response');

      // Carregar o criador separadamente se não foi carregado pelo join
      Map<String, dynamic> orderData = Map<String, dynamic>.from(response);
      if (orderData['creator'] == null &&
          orderData['creator_user_id'] != null) {
        print(
          'DataService.getServiceOrder: Carregando criador separadamente...',
        );
        try {
          final creatorResponse = await _client
              .from('profiles')
              .select()
              .eq('id', orderData['creator_user_id'])
              .single();
          orderData['creator'] = creatorResponse;
          print(
            'DataService.getServiceOrder: Criador carregado: $creatorResponse',
          );
        } catch (e) {
          print('DataService.getServiceOrder: Erro ao carregar criador: $e');
        }
      }

      final order = ServiceOrder.fromJson(orderData);
      print(
        'DataService.getServiceOrder: Criador da ordem: ${order.creator?.fullName}',
      );

      return order;
    } catch (e) {
      print('Erro ao buscar ordem de serviço: $e');
      return null;
    }
  }

  static Future<ServiceOrder> createServiceOrder(ServiceOrder order) async {
    try {
      final orderData = order.toJson();
      print('DataService.createServiceOrder: Dados da ordem: $orderData');

      final response = await _client
          .from('service_orders')
          .insert(orderData)
          .select()
          .single();

      return ServiceOrder.fromJson(response);
    } catch (e) {
      print('Erro ao criar ordem de serviço: $e');
      rethrow;
    }
  }

  static Future<void> updateServiceOrder(ServiceOrder order) async {
    try {
      await _client
          .from('service_orders')
          .update(order.toJson())
          .eq('id', order.id);
    } catch (e) {
      print('Erro ao atualizar ordem de serviço: $e');
      rethrow;
    }
  }

  // ===== LOGS DE AUDITORIA =====
  static Future<List<OrderLog>> getOrderLogs(int orderId) async {
    try {
      final response = await _client
          .from('order_logs')
          .select('*, user:profiles!order_logs_user_id_fkey(*)')
          .eq('order_id', orderId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => OrderLog.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar logs da ordem: $e');
      return [];
    }
  }

  static Future<void> createOrderLog(OrderLog log) async {
    try {
      final logData = log.toJson();
      print('DataService.createOrderLog: Dados do log: $logData');

      // Se o ID é 0, remover para deixar o banco gerar automaticamente
      if (logData['id'] == 0) {
        logData.remove('id');
        print('DataService.createOrderLog: ID removido, deixando banco gerar');
      }

      await _client.from('order_logs').insert(logData);
      print('DataService.createOrderLog: Log criado com sucesso');
    } catch (e) {
      print('Erro ao criar log: $e');
      rethrow;
    }
  }

  // ===== DEFEITOS DA ORDEM =====
  static Future<void> createOrderDefects(
    int orderId,
    List<String> defects,
  ) async {
    try {
      final defectsData = defects
          .map((defect) => {'order_id': orderId, 'description': defect})
          .toList();

      await _client.from('order_defects').insert(defectsData);
    } catch (e) {
      print('Erro ao criar defeitos da ordem: $e');
      rethrow;
    }
  }

  static Future<List<String>> getOrderDefects(int orderId) async {
    try {
      print(
        'DataService.getOrderDefects: Buscando defeitos para ordem $orderId',
      );
      final response = await _client
          .from('order_defects')
          .select('description')
          .eq('order_id', orderId);

      print('DataService.getOrderDefects: Resposta do banco: $response');

      final defects = (response as List)
          .map((json) => json['description'] as String)
          .toList();

      print('DataService.getOrderDefects: Defeitos processados: $defects');
      return defects;
    } catch (e) {
      print('Erro ao buscar defeitos da ordem: $e');
      return [];
    }
  }

  // ===== CORREÇÃO DE DEFEITOS =====

  static Future<List<DefectCorrection>> getDefectCorrections(
    int orderId,
  ) async {
    try {
      final response = await _client
          .from('defect_corrections')
          .select(
            '*, corrected_by:profiles!defect_corrections_corrected_by_user_id_fkey(*)',
          )
          .eq('order_id', orderId)
          .order('corrected_at', ascending: false);

      return (response as List)
          .map((json) => DefectCorrection.fromJson(json))
          .toList();
    } catch (e) {
      print('Erro ao buscar correções de defeitos: $e');
      return [];
    }
  }

  static Future<void> markDefectAsCorrected(
    int orderId,
    int defectId,
    String correctedByUserId,
    String? notes,
  ) async {
    try {
      final correctionData = {
        'order_id': orderId,
        'defect_id': defectId,
        'corrected_by_user_id': correctedByUserId,
        'notes': notes,
      };

      await _client
          .from('defect_corrections')
          .upsert(correctionData, onConflict: 'order_id,defect_id');
    } catch (e) {
      print('Erro ao marcar defeito como corrigido: $e');
      rethrow;
    }
  }

  static Future<void> unmarkDefectAsCorrected(int orderId, int defectId) async {
    try {
      await _client
          .from('defect_corrections')
          .delete()
          .eq('order_id', orderId)
          .eq('defect_id', defectId);
    } catch (e) {
      print('Erro ao desmarcar defeito como corrigido: $e');
      rethrow;
    }
  }

  static Future<bool> areAllDefectsCorrected(int orderId) async {
    try {
      // Buscar todos os defeitos da ordem
      final defectsResponse = await _client
          .from('order_defects')
          .select('id')
          .eq('order_id', orderId);

      final defectIds = (defectsResponse as List)
          .map((json) => json['id'] as int)
          .toList();

      if (defectIds.isEmpty) return true;

      // Buscar correções para esses defeitos
      final correctionsResponse = await _client
          .from('defect_corrections')
          .select('defect_id')
          .eq('order_id', orderId);

      final correctedDefectIds = (correctionsResponse as List)
          .map((json) => json['defect_id'] as int)
          .toSet();

      // Verificar se todos os defeitos foram corrigidos
      return defectIds.every(
        (defectId) => correctedDefectIds.contains(defectId),
      );
    } catch (e) {
      print('Erro ao verificar se todos os defeitos foram corrigidos: $e');
      return false;
    }
  }
}
