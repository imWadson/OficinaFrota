import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/service_order_provider.dart';
import '../models/service_order.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../widgets/order_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    final orderProvider = context.read<ServiceOrderProvider>();
    await orderProvider.loadOrders();

    if (!mounted) return;

    if (context.read<AuthProvider>().isOficina) {
      await orderProvider.loadPendingOrders();
    } else {
      await orderProvider.loadMyOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isOficina = authProvider.isOficina;

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: _buildModernAppBar(authProvider),
          body: Consumer<ServiceOrderProvider>(
            builder: (context, orderProvider, child) {
              if (orderProvider.isLoading) {
                return _buildLoadingState();
              }

              if (orderProvider.error != null) {
                return _buildErrorState(orderProvider.error!);
              }

              return Column(
                children: [
                  _buildWelcomeHeader(authProvider, isOficina),
                  const SizedBox(height: 16),
                  if (isOficina) ...[
                    _buildOficinaTabs(orderProvider),
                  ] else ...[
                    _buildOperacaoTabs(orderProvider),
                  ],
                ],
              );
            },
          ),
          floatingActionButton: authProvider.isOperacao
              ? _buildModernFAB()
              : null,
        );
      },
    );
  }

  PreferredSizeWidget _buildModernAppBar(AuthProvider authProvider) {
    return AppBar(
      backgroundColor: AppTheme.surfaceColor,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: AppTheme.borderRadiusMedium,
            ),
            child: const Icon(
              Icons.build_circle,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.appName,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                authProvider.isOficina ? 'Oficina' : 'Operação',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: IconButton(
            onPressed: () => _showLogoutDialog(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.statusRejected.withOpacity(0.1),
                borderRadius: AppTheme.borderRadiusMedium,
              ),
              child: Icon(
                Icons.logout,
                color: AppTheme.statusRejected,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader(AuthProvider authProvider, bool isOficina) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: AppTheme.borderRadiusLarge,
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: AppTheme.borderRadiusXLarge,
            ),
            child: Center(
              child: Text(
                authProvider.userProfile?.fullName
                        .substring(0, 1)
                        .toUpperCase() ??
                    'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, ${authProvider.userProfile?.fullName ?? 'Usuário'}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOficina
                      ? 'Gerencie as ordens de serviço da oficina'
                      : 'Acompanhe suas ordens de serviço',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: AppTheme.borderRadiusMedium,
            ),
            child: Text(
              isOficina ? 'OFICINA' : 'OPERAÇÃO',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOficinaTabs(ServiceOrderProvider orderProvider) {
    return Expanded(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: AppTheme.borderRadiusMedium,
                boxShadow: AppTheme.cardShadow,
              ),
              child: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.pending_actions), text: 'Pendentes'),
                  Tab(icon: Icon(Icons.build), text: 'Em Andamento'),
                ],
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: AppTheme.textSecondary,
                indicatorColor: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                children: [
                  _buildOrdersList(
                    orderProvider.pendingOrders,
                    'Nenhuma ordem pendente',
                    Icons.check_circle_outline,
                    'Todas as ordens foram processadas!',
                  ),
                  _buildOrdersList(
                    orderProvider.orders
                        .where(
                          (order) =>
                              order.status !=
                                  ServiceOrderStatus.aguardandoAceite &&
                              order.status != ServiceOrderStatus.rejeitado &&
                              order.status != ServiceOrderStatus.concluido,
                        )
                        .toList(),
                    'Nenhuma ordem em andamento',
                    Icons.build,
                    'Nenhuma ordem está sendo processada no momento.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperacaoTabs(ServiceOrderProvider orderProvider) {
    return Expanded(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: AppTheme.borderRadiusMedium,
                boxShadow: AppTheme.cardShadow,
              ),
              child: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.list_alt), text: 'Minhas OS'),
                  Tab(
                    icon: Icon(Icons.done_all),
                    text: 'Prontas para Retirada',
                  ),
                ],
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: AppTheme.textSecondary,
                indicatorColor: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                children: [
                  _buildOrdersList(
                    orderProvider.myOrders,
                    'Você ainda não criou nenhuma ordem de serviço',
                    Icons.add_circle_outline,
                    'Crie sua primeira ordem de serviço!',
                  ),
                  _buildOrdersList(
                    orderProvider.orders
                        .where(
                          (order) =>
                              order.status ==
                                  ServiceOrderStatus.prontoRetirada &&
                              order.creatorUserId ==
                                  context.read<AuthProvider>().currentUser?.id,
                        )
                        .toList(),
                    'Nenhum veículo pronto para retirada',
                    Icons.done_all_outlined,
                    'Nenhum veículo está pronto para retirada.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(
    List<ServiceOrder> orders,
    String emptyTitle,
    IconData emptyIcon,
    String emptySubtitle,
  ) {
    if (orders.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: AppTheme.borderRadiusLarge,
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: AppTheme.borderRadiusXLarge,
                ),
                child: Icon(emptyIcon, size: 48, color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 24),
              Text(
                emptyTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                emptySubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OrderCard(
              order: order,
              onTap: () => context.go('/order/${order.id}'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: AppTheme.borderRadiusXLarge,
            ),
            child: const CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Carregando...',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: AppTheme.borderRadiusLarge,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.statusRejected.withOpacity(0.1),
                borderRadius: AppTheme.borderRadiusXLarge,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: AppTheme.statusRejected,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Erro ao carregar dados',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFAB() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppTheme.borderRadiusXLarge,
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: FloatingActionButton.extended(
        onPressed: () => context.go('/create-order'),
        icon: const Icon(Icons.add),
        label: const Text('Nova OS'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadiusLarge),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.statusRejected.withOpacity(0.1),
                borderRadius: AppTheme.borderRadiusMedium,
              ),
              child: Icon(
                Icons.logout,
                color: AppTheme.statusRejected,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Sair'),
          ],
        ),
        content: const Text('Tem certeza que deseja sair do aplicativo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusRejected,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().signOut();
    }
  }
}
