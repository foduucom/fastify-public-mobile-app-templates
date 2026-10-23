import 'dart:convert';

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

  /// True when the access token's JWT `exp` is in the past (with a small
  /// skew). Unknown/opaque tokens are treated as not expired; the server's
  /// 401 remains the source of truth for those.
  static bool isAccessTokenExpired({Duration skew = const Duration(seconds: 30)}) {
    final token = accessToken;
    if (token == null || token.isEmpty) return true;
    final parts = token.split('.');
    if (parts.length != 3) return false;
    try {
      final payload = json.decode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final exp = payload is Map ? payload['exp'] : null;
      if (exp is num) {
        final expiry = DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
        return DateTime.now().isAfter(expiry.subtract(skew));
      }
    } catch (_) {}
    return false;
  }
}
