import 'package:flutter/material.dart';
import '../models/service_order.dart';
import '../models/order_log.dart';
import '../services/data_service.dart';
import '../services/supabase_service.dart';

class ServiceOrderProvider extends ChangeNotifier {
  List<ServiceOrder> _orders = [];
  List<ServiceOrder> _pendingOrders = [];
  List<ServiceOrder> _myOrders = [];
  ServiceOrder? _selectedOrder;
  List<OrderLog> _orderLogs = [];
  bool _isLoading = false;
  String? _error;

  List<ServiceOrder> get orders => _orders;
  List<ServiceOrder> get pendingOrders => _pendingOrders;
  List<ServiceOrder> get myOrders => _myOrders;
  ServiceOrder? get selectedOrder => _selectedOrder;
  List<OrderLog> get orderLogs => _orderLogs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Carregar todas as ordens
  Future<void> loadOrders() async {
    try {
      _isLoading = true;
      notifyListeners();

      _orders = await DataService.getServiceOrders();
      _filterOrders();
    } catch (e) {
      _error = 'Erro ao carregar ordens: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Carregar ordens pendentes (para oficina)
  Future<void> loadPendingOrders() async {
    try {
      _isLoading = true;
      notifyListeners();

      _pendingOrders = await DataService.getServiceOrders(
        status: 'aguardando_aceite',
      );
    } catch (e) {
      _error = 'Erro ao carregar ordens pendentes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Carregar minhas ordens (para operação)
  Future<void> loadMyOrders() async {
    try {
      _isLoading = true;
      notifyListeners();

      final currentUser = SupabaseService.currentUser;
      if (currentUser != null) {
        _myOrders = await DataService.getServiceOrders(userId: currentUser.id);
      }
    } catch (e) {
      _error = 'Erro ao carregar minhas ordens: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Carregar ordem específica
  Future<void> loadOrder(int orderId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _selectedOrder = await DataService.getServiceOrder(orderId);
      if (_selectedOrder != null) {
        await loadOrderLogs(orderId);
        await loadOrderDefects(orderId);
      }
    } catch (e) {
      _error = 'Erro ao carregar ordem: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Carregar logs da ordem
  Future<void> loadOrderLogs(int orderId) async {
    try {
      _orderLogs = await DataService.getOrderLogs(orderId);
    } catch (e) {
      _error = 'Erro ao carregar logs: $e';
    }
  }

  // Carregar defeitos da ordem
  Future<void> loadOrderDefects(int orderId) async {
    try {
      print('ServiceOrderProvider.loadOrderDefects: Carregando defeitos para ordem $orderId');
      final defects = await DataService.getOrderDefects(orderId);
      print('ServiceOrderProvider.loadOrderDefects: Defeitos encontrados: $defects');
      
      if (_selectedOrder != null) {
        _selectedOrder = _selectedOrder!.copyWith(defects: defects);
        print('ServiceOrderProvider.loadOrderDefects: Ordem atualizada com defeitos');
        notifyListeners();
      }
    } catch (e) {
      print('ServiceOrderProvider.loadOrderDefects: Erro ao carregar defeitos: $e');
      _error = 'Erro ao carregar defeitos: $e';
    }
  }

  // Criar nova ordem de serviço
  Future<bool> createServiceOrder(
    ServiceOrder order,
    List<String> defects,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final createdOrder = await DataService.createServiceOrder(order);
      await DataService.createOrderDefects(createdOrder.id, defects);

      // Criar log de criação
      final log = OrderLog(
        id: 0, // Será gerado pelo banco
        orderId: createdOrder.id,
        userId: order.creatorUserId,
        newStatus: _statusToSnakeCase(order.status),
        logMessage: 'Ordem de serviço criada',
        createdAt: DateTime.now(),
      );
      try {
        await DataService.createOrderLog(log);
      } catch (e) {
        print('ServiceOrderProvider: Erro ao criar log de criação: $e');
        // Continuar mesmo se o log falhar
      }

      // Recarregar listas
      await loadOrders();
      await loadMyOrders();

      return true;
    } catch (e) {
      _error = 'Erro ao criar ordem: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Aceitar ordem (oficina)
  Future<bool> acceptOrder(
    int orderId,
    String receiverUserId,
    String photoUrl,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final order = await DataService.getServiceOrder(orderId);
      if (order == null) {
        _error = 'Ordem não encontrada';
        return false;
      }

      final updatedOrder = order.copyWith(
        status: ServiceOrderStatus.recebido,
        workshopReceiverUserId: receiverUserId,
        workshopReceivedTimestamp: DateTime.now(),
        workshopReceivedPhotoUrl: photoUrl,
      );

      await DataService.updateServiceOrder(updatedOrder);

      // Criar log de aceite
      final log = OrderLog(
        id: 0,
        orderId: orderId,
        userId: receiverUserId,
        previousStatus: _statusToSnakeCase(order.status),
        newStatus: _statusToSnakeCase(updatedOrder.status),
        logMessage: 'Ordem aceita pela oficina',
        createdAt: DateTime.now(),
      );
      try {
        await DataService.createOrderLog(log);
      } catch (e) {
        print('ServiceOrderProvider: Erro ao criar log de aceite: $e');
        // Continuar mesmo se o log falhar
      }

      // Recarregar dados
      await loadOrders();
      await loadPendingOrders();
      await loadOrder(orderId);

      return true;
    } catch (e) {
      _error = 'Erro ao aceitar ordem: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Rejeitar ordem (oficina)
  Future<bool> rejectOrder(int orderId, String rejectReason) async {
    try {
      _isLoading = true;
      notifyListeners();

      final order = await DataService.getServiceOrder(orderId);
      if (order == null) {
        _error = 'Ordem não encontrada';
        return false;
      }

      final updatedOrder = order.copyWith(status: ServiceOrderStatus.rejeitado);

      await DataService.updateServiceOrder(updatedOrder);

      // Criar log de rejeição
      final log = OrderLog(
        id: 0,
        orderId: orderId,
        userId: SupabaseService.currentUser?.id ?? '',
        previousStatus: _statusToSnakeCase(order.status),
        newStatus: _statusToSnakeCase(updatedOrder.status),
        logMessage: 'Ordem rejeitada: $rejectReason',
        createdAt: DateTime.now(),
      );
      try {
        await DataService.createOrderLog(log);
      } catch (e) {
        print('ServiceOrderProvider: Erro ao criar log de rejeição: $e');
        // Continuar mesmo se o log falhar
      }

      // Recarregar dados
      await loadOrders();
      await loadPendingOrders();
      await loadOrder(orderId);

      return true;
    } catch (e) {
      _error = 'Erro ao rejeitar ordem: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Atualizar status da ordem
  Future<bool> updateOrderStatus(
    int orderId,
    ServiceOrderStatus newStatus,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final order = await DataService.getServiceOrder(orderId);
      if (order == null) {
        _error = 'Ordem não encontrada';
        return false;
      }

      final updatedOrder = order.copyWith(status: newStatus);
      await DataService.updateServiceOrder(updatedOrder);

      // Criar log de mudança de status
      final log = OrderLog(
        id: 0,
        orderId: orderId,
        userId: SupabaseService.currentUser?.id ?? '',
        previousStatus: _statusToSnakeCase(order.status),
        newStatus: _statusToSnakeCase(newStatus),
        logMessage: 'Status alterado para: ${updatedOrder.statusText}',
        createdAt: DateTime.now(),
      );
      try {
        await DataService.createOrderLog(log);
      } catch (e) {
        print(
          'ServiceOrderProvider: Erro ao criar log de atualização de status: $e',
        );
        // Continuar mesmo se o log falhar
      }

      // Recarregar dados
      await loadOrders();
      await loadMyOrders();
      await loadOrder(orderId);

      return true;
    } catch (e) {
      _error = 'Erro ao atualizar status: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Retirar veículo (operação)
  Future<bool> pickupVehicle(int orderId, String pickupUserId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final order = await DataService.getServiceOrder(orderId);
      if (order == null) {
        _error = 'Ordem não encontrada';
        return false;
      }

      final updatedOrder = order.copyWith(
        status: ServiceOrderStatus.concluido,
        pickupUserId: pickupUserId,
        pickupTimestamp: DateTime.now(),
      );

      await DataService.updateServiceOrder(updatedOrder);

      // Criar log de retirada
      final log = OrderLog(
        id: 0,
        orderId: orderId,
        userId: pickupUserId,
        previousStatus: _statusToSnakeCase(order.status),
        newStatus: _statusToSnakeCase(updatedOrder.status),
        logMessage: 'Veículo retirado pela operação',
        createdAt: DateTime.now(),
      );
      try {
        await DataService.createOrderLog(log);
      } catch (e) {
        print('ServiceOrderProvider: Erro ao criar log de retirada: $e');
        // Continuar mesmo se o log falhar
      }

      // Recarregar dados
      await loadOrders();
      await loadMyOrders();
      await loadOrder(orderId);

      return true;
    } catch (e) {
      _error = 'Erro ao retirar veículo: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _filterOrders() {
    final currentUser = SupabaseService.currentUser;
    if (currentUser != null) {
      _myOrders = _orders
          .where((order) => order.creatorUserId == currentUser.id)
          .toList();
    }

    _pendingOrders = _orders
        .where((order) => order.status == ServiceOrderStatus.aguardandoAceite)
        .toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void selectOrder(ServiceOrder order) {
    _selectedOrder = order;
    notifyListeners();
  }

  void clearSelectedOrder() {
    _selectedOrder = null;
    _orderLogs = [];
    notifyListeners();
  }

  String _statusToSnakeCase(ServiceOrderStatus status) {
    switch (status) {
      case ServiceOrderStatus.aguardandoAceite:
        return 'aguardando_aceite';
      case ServiceOrderStatus.recebido:
        return 'recebido';
      case ServiceOrderStatus.rejeitado:
        return 'rejeitado';
      case ServiceOrderStatus.analisando:
        return 'analisando';
      case ServiceOrderStatus.consertoIniciado:
        return 'conserto_iniciado';
      case ServiceOrderStatus.finalizadoConserto:
        return 'finalizado_conserto';
      case ServiceOrderStatus.prontoRetirada:
        return 'pronto_retirada';
      case ServiceOrderStatus.concluido:
        return 'concluido';
    }
  }
}
