import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';

class StorageService {
  static const String _emailKey = 'saved_email';
  static const String _lastLoginKey = 'last_login_timestamp';
  static const String _bucketName = 'vehicle-photos';
  static const String _dropoffFolder = 'dropoff';
  static const String _workshopFolder = 'workshop';
  static const String _pickupFolder = 'pickup';

  // ===== EMAIL STORAGE =====

  // Salvar email do usuário
  static Future<void> saveEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_emailKey, email);
      await prefs.setInt(_lastLoginKey, DateTime.now().millisecondsSinceEpoch);
      print('StorageService: Email salvo: $email');
    } catch (e) {
      print('StorageService: Erro ao salvar email: $e');
    }
  }

  // Obter email salvo
  static Future<String?> getSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(_emailKey);
      print('StorageService: Email recuperado: $email');
      return email;
    } catch (e) {
      print('StorageService: Erro ao recuperar email: $e');
      return null;
    }
  }

  // Limpar email salvo
  static Future<void> clearSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_emailKey);
      await prefs.remove(_lastLoginKey);
      print('StorageService: Email removido');
    } catch (e) {
      print('StorageService: Erro ao remover email: $e');
    }
  }

  // Verificar se há email salvo
  static Future<bool> hasSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_emailKey);
    } catch (e) {
      print('StorageService: Erro ao verificar email salvo: $e');
      return false;
    }
  }

  // Obter timestamp do último login
  static Future<DateTime?> getLastLoginTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_lastLoginKey);
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      return null;
    } catch (e) {
      print('StorageService: Erro ao obter timestamp do último login: $e');
      return null;
    }
  }

  // Verificar se o email salvo é recente (últimos 30 dias)
  static Future<bool> isSavedEmailRecent() async {
    try {
      final lastLogin = await getLastLoginTime();
      if (lastLogin == null) return false;

      final daysSinceLastLogin = DateTime.now().difference(lastLogin).inDays;
      return daysSinceLastLogin <= 30;
    } catch (e) {
      print('StorageService: Erro ao verificar se email é recente: $e');
      return false;
    }
  }

  // ===== IMAGE STORAGE =====

  // Upload de foto para o Supabase Storage
  static Future<String?> uploadPhoto(
    File photoFile,
    String type,
    String orderId,
  ) async {
    try {
      print('StorageService: Iniciando upload de foto...');

      // Gerar nome único para o arquivo
      final uuid = const Uuid().v4();
      final extension = photoFile.path.split('.').last;
      final fileName = '${type}_${orderId}_$uuid.$extension';

      // Determinar pasta baseada no tipo
      String folder;
      switch (type) {
        case 'dropoff':
          folder = _dropoffFolder;
          break;
        case 'workshop':
          folder = _workshopFolder;
          break;
        case 'pickup':
          folder = _pickupFolder;
          break;
        default:
          folder = 'other';
      }

      final filePath = '$folder/$fileName';

      print('StorageService: Fazendo upload para: $_bucketName/$filePath');

      // Fazer upload do arquivo
      await Supabase.instance.client.storage
          .from(_bucketName)
          .upload(filePath, photoFile);

      // Obter URL pública
      final publicUrl = Supabase.instance.client.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      print('StorageService: Upload concluído. URL: $publicUrl');

      return publicUrl;
    } catch (e) {
      print('StorageService: Erro no upload da foto: $e');
      return null;
    }
  }

  // Download de foto do Supabase Storage
  static Future<Uint8List?> downloadPhoto(String photoUrl) async {
    try {
      print('StorageService: Baixando foto: $photoUrl');

      // Extrair caminho do arquivo da URL
      final uri = Uri.parse(photoUrl);
      final pathSegments = uri.pathSegments;

      if (pathSegments.length < 3) {
        print('StorageService: URL inválida para download');
        return null;
      }

      // Construir caminho do arquivo
      final filePath = pathSegments.sublist(2).join('/');

      print('StorageService: Caminho do arquivo: $filePath');

      // Fazer download
      final response = await Supabase.instance.client.storage
          .from(_bucketName)
          .download(filePath);

      print(
        'StorageService: Download concluído. Tamanho: ${response.length} bytes',
      );

      return response;
    } catch (e) {
      print('StorageService: Erro no download da foto: $e');
      return null;
    }
  }

  // Verificar se uma URL é do Supabase Storage
  static bool isSupabaseUrl(String url) {
    return url.startsWith('https://') && url.contains('supabase.co');
  }

  // Verificar se uma URL é um caminho local
  static bool isLocalPath(String path) {
    return path.startsWith('/') || path.startsWith('file://');
  }
}
