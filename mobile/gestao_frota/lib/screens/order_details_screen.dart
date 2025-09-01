import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../providers/service_order_provider.dart';
import '../models/service_order.dart';
import '../services/storage_service.dart';
import '../widgets/network_image_widget.dart';
import '../widgets/app_bar_with_back.dart';
import '../widgets/defect_correction_checklist.dart';
import '../constants/app_constants.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final _imagePicker = ImagePicker();
  final _rejectReasonController = TextEditingController();
  bool _isLoading = false;
  bool _allDefectsCorrected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrder();
    });
  }

  @override
  void dispose() {
    _rejectReasonController.dispose();
    super.dispose();
  }

  Future<void> _loadOrder() async {
    if (!mounted) return;

    final orderProvider = context.read<ServiceOrderProvider>();
    await orderProvider.loadOrder(widget.orderId);
  }

  Future<void> _takePhoto() async {
    if (!mounted) return;

    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (photo != null && mounted) {
        await _acceptOrder(File(photo.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao capturar foto: $e')));
      }
    }
  }

  Future<void> _acceptOrder(File photoFile) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (!mounted) return;

      final authProvider = context.read<AuthProvider>();
      final orderProvider = context.read<ServiceOrderProvider>();

      // Fazer upload da foto para o Supabase Storage
      String photoUrl = photoFile.path; // Fallback para caminho local

      try {
        print('OrderDetailsScreen: Fazendo upload da foto da oficina...');
        final uploadedUrl = await StorageService.uploadPhoto(
          photoFile,
          'workshop',
          widget.orderId.toString(),
        );

        if (uploadedUrl != null) {
          photoUrl = uploadedUrl;
          print('OrderDetailsScreen: Upload bem-sucedido. URL: $photoUrl');
        } else {
          print('OrderDetailsScreen: Upload falhou, usando caminho local');
        }
      } catch (e) {
        print('OrderDetailsScreen: Erro no upload: $e');
      }

      final success = await orderProvider.acceptOrder(
        widget.orderId,
        authProvider.currentUser!.id,
        photoUrl,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ordem aceita com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderProvider.error ?? 'Erro ao aceitar ordem'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _rejectOrder() async {
    if (!mounted) return;

    if (_rejectReasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe o motivo da rejeição'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (!mounted) return;

      final orderProvider = context.read<ServiceOrderProvider>();

      final success = await orderProvider.rejectOrder(
        widget.orderId,
        _rejectReasonController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ordem rejeitada'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.of(context).pop(); // Fechar dialog
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderProvider.error ?? 'Erro ao rejeitar ordem'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateStatus(ServiceOrderStatus newStatus) async {
    if (!mounted) return;

    // Verificar se está tentando marcar como "pronto para retirada" sem corrigir todos os defeitos
    if (newStatus == ServiceOrderStatus.prontoRetirada &&
        !_allDefectsCorrected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Todos os defeitos devem ser corrigidos antes de marcar como pronto para retirada!',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (!mounted) return;

      final orderProvider = context.read<ServiceOrderProvider>();

      final success = await orderProvider.updateOrderStatus(
        widget.orderId,
        newStatus,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderProvider.error ?? 'Erro ao atualizar status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickupVehicle() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (!mounted) return;

      final authProvider = context.read<AuthProvider>();
      final orderProvider = context.read<ServiceOrderProvider>();

      final success = await orderProvider.pickupVehicle(
        widget.orderId,
        authProvider.currentUser!.id,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veículo retirado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderProvider.error ?? 'Erro ao retirar veículo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejeitar Ordem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Informe o motivo da rejeição:'),
            const SizedBox(height: 16),
            TextField(
              controller: _rejectReasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _rejectOrder,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: _isLoading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Rejeitar'),
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog() {
    final currentOrder = context.read<ServiceOrderProvider>().selectedOrder;
    if (currentOrder == null) return;

    List<ServiceOrderStatus> availableStatuses = [];

    switch (currentOrder.status) {
      case ServiceOrderStatus.recebido:
        availableStatuses = [
          ServiceOrderStatus.analisando,
          ServiceOrderStatus.consertoIniciado,
        ];
        break;
      case ServiceOrderStatus.analisando:
        availableStatuses = [ServiceOrderStatus.consertoIniciado];
        break;
      case ServiceOrderStatus.consertoIniciado:
        availableStatuses = [ServiceOrderStatus.finalizadoConserto];
        break;
      case ServiceOrderStatus.finalizadoConserto:
        availableStatuses = [ServiceOrderStatus.prontoRetirada];
        break;
      default:
        break;
    }

    if (availableStatuses.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atualizar Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: availableStatuses.map((status) {
            return ListTile(
              title: Text(_getStatusText(status)),
              onTap: () {
                Navigator.of(context).pop();
                _updateStatus(status);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  String _getStatusText(ServiceOrderStatus status) {
    switch (status) {
      case ServiceOrderStatus.analisando:
        return 'Analisando Defeitos';
      case ServiceOrderStatus.consertoIniciado:
        return 'Conserto Iniciado';
      case ServiceOrderStatus.finalizadoConserto:
        return 'Conserto Finalizado';
      case ServiceOrderStatus.prontoRetirada:
        return 'Pronto para Retirada';
      default:
        return status.toString();
    }
  }

  void _onAllDefectsCorrected(bool allCorrected) {
    setState(() {
      _allDefectsCorrected = allCorrected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceOrderProvider>(
      builder: (context, orderProvider, child) {
        final order = orderProvider.selectedOrder;
        final authProvider = context.read<AuthProvider>();

        if (orderProvider.isLoading) {
          return const Scaffold(
            appBar: AppBarWithBack(title: 'Detalhes da OS'),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (order == null) {
          return const Scaffold(
            appBar: AppBarWithBack(title: 'Detalhes da OS'),
            body: Center(child: Text('Ordem não encontrada')),
          );
        }

        return Scaffold(
          appBar: AppBarWithBack(
            title: 'OS #${order.id.toString().padLeft(6, '0')}',
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card de status
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Status',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                order.statusText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Botões de ação baseados no status e perfil
                        if (authProvider.isOficina && order.canBeAccepted) ...[
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _takePhoto,
                                  icon: const Icon(Icons.camera_alt),
                                  label: const Text('Aceitar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading
                                      ? null
                                      : _showRejectDialog,
                                  icon: const Icon(Icons.close),
                                  label: const Text('Rejeitar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        if (authProvider.isOficina &&
                            order.status !=
                                ServiceOrderStatus.aguardandoAceite &&
                            order.status != ServiceOrderStatus.rejeitado &&
                            order.status != ServiceOrderStatus.concluido) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : _showStatusUpdateDialog,
                              icon: const Icon(Icons.update),
                              label: const Text('Atualizar Status'),
                            ),
                          ),
                        ],

                        if (authProvider.isOperacao && order.canBePickedUp) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _pickupVehicle,
                              icon: const Icon(Icons.directions_car),
                              label: const Text('Retirar Veículo'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Informações do veículo
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Veículo',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Placa',
                          order.vehicle?.licensePlate ?? 'N/A',
                        ),
                        _buildInfoRow('Tipo', order.vehicle?.type ?? 'N/A'),
                        if (order.vehicle?.model != null)
                          _buildInfoRow('Modelo', order.vehicle!.model!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Informações da ordem
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informações da Ordem',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Criada por',
                          order.creator?.fullName ?? 'N/A',
                        ),
                        _buildInfoRow(
                          'Data de criação',
                          DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(order.createdAt),
                        ),
                        _buildInfoRow(
                          'Data de entrega',
                          DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(order.dropoffTimestamp),
                        ),

                        if (order.workshopReceiver != null) ...[
                          _buildInfoRow(
                            'Recebido por',
                            order.workshopReceiver!.fullName,
                          ),
                          _buildInfoRow(
                            'Data de recebimento',
                            DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(order.workshopReceivedTimestamp!),
                          ),
                        ],

                        if (order.pickupUser != null) ...[
                          _buildInfoRow(
                            'Retirado por',
                            order.pickupUser!.fullName,
                          ),
                          _buildInfoRow(
                            'Data de retirada',
                            DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(order.pickupTimestamp!),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Defeitos
                if (order.defects.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Defeitos',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          ...order.defects.map(
                            (defect) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning,
                                    size: 16,
                                    color: Colors.orange[700],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(defect)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Checklist de Correção (apenas para oficina)
                if (authProvider.isOficina && order.defects.isNotEmpty) ...[
                  DefectCorrectionChecklist(
                    orderId: order.id,
                    defects: order.defects,
                    onAllDefectsCorrected: _onAllDefectsCorrected,
                  ),
                  const SizedBox(height: 16),
                ],

                // Fotos
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fotos',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),

                        // Foto da entrega
                        if (order.dropoffPhotoUrl.isNotEmpty) ...[
                          Text(
                            'Foto da Entrega',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: NetworkImageWidget(
                              imagePath: order.dropoffPhotoUrl,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],

                        // Foto do recebimento
                        if (order.workshopReceivedPhotoUrl != null &&
                            order.workshopReceivedPhotoUrl!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Foto do Recebimento',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: NetworkImageWidget(
                              imagePath: order.workshopReceivedPhotoUrl!,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Histórico
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Histórico',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        if (orderProvider.orderLogs.isEmpty)
                          const Text(
                            'Nenhum registro encontrado',
                            style: TextStyle(color: Colors.grey),
                          )
                        else
                          ...orderProvider.orderLogs.map(
                            (log) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          log.logMessage,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        DateFormat(
                                          'dd/MM HH:mm',
                                        ).format(log.createdAt),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (log.user != null)
                                    Text(
                                      'por ${log.user!.fullName}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getStatusColor(ServiceOrderStatus status) {
    switch (status) {
      case ServiceOrderStatus.aguardandoAceite:
        return Colors.orange;
      case ServiceOrderStatus.recebido:
        return Colors.blue;
      case ServiceOrderStatus.rejeitado:
        return Colors.red;
      case ServiceOrderStatus.analisando:
        return Colors.purple;
      case ServiceOrderStatus.consertoIniciado:
        return Colors.orange;
      case ServiceOrderStatus.finalizadoConserto:
        return Colors.green;
      case ServiceOrderStatus.prontoRetirada:
        return Colors.green;
      case ServiceOrderStatus.concluido:
        return Colors.grey;
    }
  }
}
