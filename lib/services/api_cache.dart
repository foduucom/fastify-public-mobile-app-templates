import 'dart:convert';

import 'package:get_storage/get_storage.dart';

/// Last-known-good copy of GET responses, used as a fallback while the backend
/// is unreachable (stale-while-revalidate). Lives in its own storage container
/// so it can be wiped without touching the session.
class ApiCache {
  ApiCache._();

  static const containerName = 'api_cache';
  static const _maxEntries = 60;

  /// Endpoints that must never be served from cache.
  static const _deny = [
    'auth',
    'otp',
    'login',
    'register',
    'logout',
    'password',
    'verify',
    'payment',
    'phonepe',
    'razorpay',
    'stripe',
    'checkout',
  ];

  static final GetStorage _box = GetStorage(containerName);

  static Future<void> init() => GetStorage.init(containerName);

  static bool isCacheable(String path) {
    final p = path.toLowerCase();
    return !_deny.any(p.contains);
  }

  /// Authenticated responses are keyed per token so one user never sees
  /// another user's cached data.
  static String keyFor(Uri uri, String? token) =>
      '${token == null ? 'anon' : token.hashCode}|$uri';

  static dynamic read(String key) {
    try {
      final entry = _box.read(key);
      if (entry is Map && entry['d'] is String) {
        return jsonDecode(entry['d'] as String);
      }
    } catch (_) {}
    return null;
  }

  static void write(String key, dynamic data) {
    if (data == null) return;
    try {
      _box.write(key, {
        't': DateTime.now().millisecondsSinceEpoch,
        'd': jsonEncode(data),
      });
      _evictIfNeeded();
    } catch (_) {}
  }

  static void _evictIfNeeded() {
    final keys = _box.getKeys<Iterable>().toList();
    if (keys.length <= _maxEntries) return;
    final stamped = <MapEntry<dynamic, int>>[];
    for (final k in keys) {
      final e = _box.read(k as String);
      stamped.add(MapEntry(k, e is Map ? (e['t'] as int? ?? 0) : 0));
    }
    stamped.sort((a, b) => a.value.compareTo(b.value));
    for (final e in stamped.take(keys.length - _maxEntries)) {
      _box.remove(e.key as String);
    }
  }

  static Future<void> clear() async {
    try {
      await _box.erase();
    } catch (_) {}
  }
}
