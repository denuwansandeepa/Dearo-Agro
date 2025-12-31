import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'authToken';
  static const _userIdKey = 'userId';
  static const _userTypeKey = 'userType';

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  static Future<String?> getUserType() async {
    return await _storage.read(key: _userTypeKey);
  }

  static Future<void> saveAuthData(String token, String userId, String userType) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _userTypeKey, value: userType);
  }

  static Future<void> clearAuthData() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userTypeKey);
  }

  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }
}