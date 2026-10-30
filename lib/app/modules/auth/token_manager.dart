import 'package:get_storage/get_storage.dart';

/// Centralized token persistence and retrieval helper.
class TokenManager {
  static final _box = GetStorage();
  static const String _kAccessToken = 'token';
  static const String _kRefreshToken = 'refreshToken';

  /// Get the current access token, or null if not logged in.
  static String? get accessToken => _box.read<String>(_kAccessToken);

  /// Get the refresh token, if any.
  static String? get refreshToken => _box.read<String>(_kRefreshToken);

  /// Save or remove the access token.
  static Future<void> setAccessToken(String? token) async {
    if (token != null && token.isNotEmpty) {
      await _box.write(_kAccessToken, token);
    } else {
      await _box.remove(_kAccessToken);
    }
  }

  /// Save or remove the refresh token.
  static Future<void> setRefreshToken(String? token) async {
    if (token != null && token.isNotEmpty) {
      await _box.write(_kRefreshToken, token);
    } else {
      await _box.remove(_kRefreshToken);
    }
  }

  /// Clear all stored auth tokens.
  static Future<void> clearTokens() async {
    await _box.remove(_kAccessToken);
    await _box.remove(_kRefreshToken);
  }
}

