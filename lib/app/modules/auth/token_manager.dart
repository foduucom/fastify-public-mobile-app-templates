import 'package:get_storage/get_storage.dart';

class TokenManager {
  static final GetStorage _storage = GetStorage();

  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';

  static String? get accessToken => _storage.read(_accessTokenKey);
  static String? get refreshToken => _storage.read(_refreshTokenKey);

  static Future<void> setAccessToken(String token) async {
    await _storage.write(_accessTokenKey, token);
  }

  static Future<void> setRefreshToken(String token) async {
    await _storage.write(_refreshTokenKey, token);
  }

  static Future<void> clearTokens() async {
    await _storage.remove(_accessTokenKey);
    await _storage.remove(_refreshTokenKey);
  }
}
