import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';
import '../services/data_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isOperacao => _userProfile?.isOperacao ?? false;
  bool get isOficina => _userProfile?.isOficina ?? false;

  AuthProvider() {
    print('AuthProvider: Inicializando...');
    _initializeAuth();
  }

  void _initializeAuth() {
    print('AuthProvider: Inicializando autenticação...');
    _currentUser = SupabaseService.currentUser;
    print('AuthProvider: Usuário atual: ${_currentUser?.email}');

    if (_currentUser != null) {
      _loadUserProfile();
    }

    SupabaseService.authStateChanges.listen((data) {
      print('AuthProvider: Mudança de estado de autenticação detectada');
      print('AuthProvider: Session: ${data.session != null}');
      print('AuthProvider: User: ${data.session?.user?.email}');

      _currentUser = data.session?.user;
      if (_currentUser != null) {
        _loadUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserProfile() async {
    if (_currentUser == null) return;

    print('AuthProvider: Carregando perfil do usuário: ${_currentUser!.email}');

    try {
      _isLoading = true;
      notifyListeners();

      _userProfile = await DataService.getUserProfile(_currentUser!.id);

      if (_userProfile == null) {
        _error = 'Perfil do usuário não encontrado';
        print(
          'AuthProvider: Perfil não encontrado para usuário: ${_currentUser!.id}',
        );
      } else {
        _error =
            null; // Limpar erro anterior se perfil foi carregado com sucesso
        print(
          'AuthProvider: Perfil carregado com sucesso: ${_userProfile!.fullName}',
        );
      }
    } catch (e) {
      _error = 'Erro ao carregar perfil: $e';
      print('AuthProvider: Erro ao carregar perfil: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    print('AuthProvider: Tentando fazer login com email: $email');

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await SupabaseService.signInWithEmail(
        email: email,
        password: password,
      );

      print('AuthProvider: Resposta do login: ${response.user?.email}');
      print('AuthProvider: Session: ${response.session != null}');

      if (response.user != null) {
        _currentUser = response.user;
        print('AuthProvider: Login bem-sucedido, carregando perfil...');
        await _loadUserProfile();
        return true;
      } else {
        _error = 'Falha na autenticação';
        print('AuthProvider: Falha na autenticação - usuário é null');
        return false;
      }
    } catch (e) {
      print('AuthProvider: Erro no login: $e');

      // Tratar especificamente o erro de email não confirmado
      if (e.toString().contains('email_not_confirmed')) {
        _error =
            'Email não confirmado. Verifique sua caixa de entrada ou entre em contato com o administrador.';

        // Tentar reenviar email de confirmação
        try {
          await SupabaseService.resendConfirmationEmail(email);
          _error =
              'Email de confirmação reenviado. Verifique sua caixa de entrada.';
        } catch (resendError) {
          print('AuthProvider: Erro ao reenviar email: $resendError');
        }
      } else {
        _error = 'Erro no login: $e';
      }

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    print('AuthProvider: Tentando fazer cadastro com email: $email');

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await SupabaseService.signUpWithEmail(
        email: email,
        password: password,
        userData: {'full_name': fullName, 'role': role},
      );

      print('AuthProvider: Resposta do cadastro: ${response.user?.email}');

      if (response.user != null) {
        // Criar perfil do usuário
        final profile = UserProfile(
          id: response.user!.id,
          fullName: fullName,
          role: role,
          createdAt: DateTime.now(),
        );

        print('AuthProvider: Criando perfil do usuário...');
        try {
          await DataService.upsertUserProfile(profile);
          _userProfile = profile;
        } catch (profileError) {
          print(
            'AuthProvider: Erro ao criar perfil, tentando carregar existente: $profileError',
          );
          // Se falhar ao criar, tentar carregar o perfil existente
          await _loadUserProfile();
        }

        _currentUser = response.user;
        print('AuthProvider: Cadastro bem-sucedido');
        return true;
      } else {
        _error = 'Falha no cadastro';
        print('AuthProvider: Falha no cadastro - usuário é null');
        return false;
      }
    } catch (e) {
      _error = 'Erro no cadastro: $e';
      print('AuthProvider: Erro no cadastro: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    print('AuthProvider: Fazendo logout...');

    try {
      _isLoading = true;
      notifyListeners();

      await SupabaseService.signOut();

      // Limpar email salvo ao fazer logout
      await StorageService.clearSavedEmail();

      _currentUser = null;
      _userProfile = null;
      _error = null;
      print('AuthProvider: Logout bem-sucedido');
    } catch (e) {
      _error = 'Erro no logout: $e';
      print('AuthProvider: Erro no logout: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
