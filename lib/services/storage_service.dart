import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nicotinaai_flutter/core/constants/app_constants.dart';

/// Serviço para gerenciar o armazenamento seguro de dados na aplicação
/// Nota: A sessão de autenticação é gerenciada automaticamente pelo Supabase
class StorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  /// Salva dados sensíveis de forma segura
  Future<void> saveSecureData(String key, String value) async {
    if (value.isNotEmpty) {
      await _secureStorage.write(
        key: key,
        value: value,
      );
    }
  }
  
  /// Recupera dados sensíveis
  Future<String?> getSecureData(String key) async {
    return await _secureStorage.read(key: key);
  }
  
  /// Remove dados sensíveis
  Future<void> deleteSecureData(String key) async {
    await _secureStorage.delete(key: key);
  }
  
  /// Limpa todos os dados armazenados
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
  
  /// Verifica se existe um dado armazenado pela chave
  Future<bool> hasSecureData(String key) async {
    final data = await getSecureData(key);
    return data != null && data.isNotEmpty;
  }
}