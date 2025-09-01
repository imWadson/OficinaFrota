import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String _supabaseUrl = 'https://rosqtcptnvpaaieqdiok.supabase.co';
  static const String _supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJvc3F0Y3B0bnZwYWFpZXFkaW9rIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NDQyMjQ5MywiZXhwIjoyMDY5OTk4NDkzfQ.TXDK2aXir7fiN4ye8N_Yf0N296daMyaLyxUe1DUsuOE';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    print('SupabaseService: Inicializando Supabase...');
    try {
      await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
      print('SupabaseService: Supabase inicializado com sucesso');
      print('SupabaseService: URL: $_supabaseUrl');

      // Testar conexão
      await _testConnection();
    } catch (e) {
      print('SupabaseService: Erro ao inicializar Supabase: $e');
      print('SupabaseService: Detalhes do erro: ${e.toString()}');
      rethrow;
    }
  }

  static Future<void> _testConnection() async {
    try {
      print('SupabaseService: Testando conexão...');
      // Fazer uma consulta simples para testar a conexão
      await client.from('profiles').select('count').limit(1);
      print('SupabaseService: Conexão testada com sucesso');
    } catch (e) {
      print('SupabaseService: Erro ao testar conexão: $e');
      // Não rethrow aqui, apenas log do erro
    }
  }

  // Métodos de autenticação
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    print('SupabaseService: Tentando login com email: $email');
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print(
        'SupabaseService: Login bem-sucedido para: ${response.user?.email}',
      );
      print('SupabaseService: Session: ${response.session != null}');
      return response;
    } catch (e) {
      print('SupabaseService: Erro no login: $e');
      print('SupabaseService: Tipo de erro: ${e.runtimeType}');
      print('SupabaseService: Mensagem de erro: ${e.toString()}');
      rethrow;
    }
  }

  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    print('SupabaseService: Tentando cadastro com email: $email');
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: userData,
      );
      print(
        'SupabaseService: Cadastro bem-sucedido para: ${response.user?.email}',
      );
      print('SupabaseService: Session: ${response.session != null}');
      return response;
    } catch (e) {
      print('SupabaseService: Erro no cadastro: $e');
      print('SupabaseService: Tipo de erro: ${e.runtimeType}');
      print('SupabaseService: Mensagem de erro: ${e.toString()}');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    print('SupabaseService: Fazendo logout...');
    try {
      await client.auth.signOut();
      print('SupabaseService: Logout bem-sucedido');
    } catch (e) {
      print('SupabaseService: Erro no logout: $e');
      print('SupabaseService: Tipo de erro: ${e.runtimeType}');
      rethrow;
    }
  }

  static Future<void> resendConfirmationEmail(String email) async {
    print('SupabaseService: Reenviando email de confirmação para: $email');
    try {
      await client.auth.resend(type: OtpType.signup, email: email);
      print('SupabaseService: Email de confirmação reenviado com sucesso');
    } catch (e) {
      print('SupabaseService: Erro ao reenviar email de confirmação: $e');
      print('SupabaseService: Tipo de erro: ${e.runtimeType}');
      rethrow;
    }
  }

  static User? get currentUser {
    final user = client.auth.currentUser;
    print('SupabaseService: Usuário atual: ${user?.email}');
    return user;
  }

  static Stream<AuthState> get authStateChanges {
    print('SupabaseService: Obtendo stream de mudanças de autenticação');
    return client.auth.onAuthStateChange;
  }

  // Método para verificar se há conexão com a internet
  static Future<bool> checkConnection() async {
    try {
      await _testConnection();
      return true;
    } catch (e) {
      print('SupabaseService: Sem conexão: $e');
      return false;
    }
  }
}
