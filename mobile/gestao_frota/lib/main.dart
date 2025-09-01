import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'services/supabase_service.dart';
import 'providers/auth_provider.dart';
import 'providers/service_order_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/create_order_screen.dart';
import 'screens/order_details_screen.dart';
import 'constants/app_constants.dart';
import 'constants/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializar Supabase
    await SupabaseService.initialize();
    print('Supabase inicializado com sucesso');

    // Verificar se há usuário atual
    final currentUser = SupabaseService.currentUser;
    print('Usuário atual: ${currentUser?.email}');
    print('Email confirmado: ${currentUser?.emailConfirmedAt != null}');
  } catch (e) {
    print('Erro ao inicializar Supabase: $e');
    print('Stack trace: ${StackTrace.current}');
    // Continuar mesmo com erro para testar a interface
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ServiceOrderProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp.router(
            title: AppConstants.appName,
            theme: AppTheme.lightTheme,
            routerConfig: _createRouter(authProvider),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  GoRouter _createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoginRoute = state.matchedLocation == '/login';

        if (!isAuthenticated && !isLoginRoute) {
          return '/login';
        }

        if (isAuthenticated && isLoginRoute) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/create-order',
          builder: (context, state) => const CreateOrderScreen(),
        ),
        GoRoute(
          path: '/order/:id',
          builder: (context, state) {
            final orderId = int.parse(state.pathParameters['id']!);
            return OrderDetailsScreen(orderId: orderId);
          },
        ),
      ],
    );
  }
}
