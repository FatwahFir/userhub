import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureStorage {
  Future<void> writeToken(String token);
  Future<String?> readToken();

  Future<void> writeUser(Map<String, dynamic> userJson);
  Future<Map<String, dynamic>?> readUser();

  Future<void> clear();
}

class SecureStorageImpl implements SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _kToken = 'auth_token';
  static const _kUser = 'auth_user';

  @override
  Future<void> writeToken(String token) =>
      _storage.write(key: _kToken, value: token);

  @override
  Future<String?> readToken() => _storage.read(key: _kToken);

  @override
  Future<void> writeUser(Map<String, dynamic> userJson) =>
      _storage.write(key: _kUser, value: jsonEncode(userJson));

  @override
  Future<Map<String, dynamic>?> readUser() async {
    final raw = await _storage.read(key: _kUser);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _kToken);
    await _storage.delete(key: _kUser);
  }
}
