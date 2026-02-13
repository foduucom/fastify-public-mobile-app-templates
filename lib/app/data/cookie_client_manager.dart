import 'package:http_cookie_store/http_cookie_store.dart';
import 'package:http/http.dart' as http;

class CookieClientManager {
  static CookieClient? _client;

  // Get singleton instance of CookieClient
  static CookieClient getClient() {
    _client ??= CookieClient();
    return _client!;
  }

  // Clear all cookies
  static void clearCookies() {
    _client?.close();
    _client = null;
    _client = CookieClient();
    print('All cookies cleared');
  }

  // Close the client
  static void close() {
    _client?.close();
    _client = null;
  }
}
