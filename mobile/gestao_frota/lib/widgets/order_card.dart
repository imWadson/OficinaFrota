import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/service_order.dart';
import '../constants/app_theme.dart';

class OrderCard extends StatelessWidget {
  final ServiceOrder order;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: AppTheme.borderRadiusLarge,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppTheme.borderRadiusLarge,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header com número da OS e status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'OS #${order.id.toString().padLeft(6, '0')}',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                            ),
                            Text(
                              'Criada em ${DateFormat('dd/MM/yyyy').format(order.createdAt)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusChip(),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Informações do veículo
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: AppTheme.borderRadiusMedium,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor.withOpacity(0.1),
                            borderRadius: AppTheme.borderRadiusMedium,
                          ),
                          child: Icon(
                            Icons.directions_car,
                            color: AppTheme.secondaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.vehicle?.toString() ??
                                    'Veículo não encontrado',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                              ),
                              if (order.vehicle?.model != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  order.vehicle!.model!,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppTheme.textSecondary),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Informações adicionais
                  if (order.workshopReceiver != null ||
                      order.pickupUser != null) ...[
                    const SizedBox(height: 12),
                    _buildUserInfo(),
                  ],

                  // Defeitos (se houver)
                  if (order.defects.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDefectsSection(),
                  ],

                  // Footer com ações
                  const SizedBox(height: 16),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    final statusColor = AppTheme.getStatusColor(
      _statusToSnakeCase(order.status),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: AppTheme.borderRadiusMedium,
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Text(
        order.statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: AppTheme.borderRadiusMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (order.workshopReceiver != null) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: AppTheme.borderRadiusSmall,
                  ),
                  child: Icon(
                    Icons.build,
                    color: AppTheme.accentColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recebido por',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        order.workshopReceiver!.fullName,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (order.pickupUser != null) const SizedBox(height: 8),
          ],
          if (order.pickupUser != null) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: AppTheme.borderRadiusSmall,
                  ),
                  child: Icon(
                    Icons.person,
                    color: AppTheme.primaryColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Retirado por',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        order.pickupUser!.fullName,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefectsSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: AppTheme.borderRadiusMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.statusRejected.withOpacity(0.1),
                  borderRadius: AppTheme.borderRadiusSmall,
                ),
                child: Icon(
                  Icons.warning,
                  color: AppTheme.statusRejected,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Defeitos Reportados',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: order.defects.map((defect) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.statusRejected.withOpacity(0.1),
                  borderRadius: AppTheme.borderRadiusSmall,
                  border: Border.all(
                    color: AppTheme.statusRejected.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  defect,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.statusRejected,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Timestamp
        Expanded(
          child: Text(
            'Entregue em ${DateFormat('dd/MM/yyyy HH:mm').format(order.dropoffTimestamp)}',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        // Ações baseadas no status
        if (order.canBeAccepted || order.canBeRejected || order.canBePickedUp)
          Row(
            children: [
              if (order.canBeAccepted) ...[
                _buildActionButton(
                  'Aceitar',
                  Icons.check,
                  Colors.green,
                  () {},
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  'Rejeitar',
                  Icons.close,
                  AppTheme.statusRejected,
                  () {},
                ),
              ] else if (order.canBePickedUp) ...[
                _buildActionButton(
                  'Retirar',
                  Icons.directions_car,
                  AppTheme.primaryColor,
                  () {},
                ),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppTheme.borderRadiusSmall,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppTheme.borderRadiusSmall,
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
