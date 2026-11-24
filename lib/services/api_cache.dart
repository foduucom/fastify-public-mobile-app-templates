import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

/// Last-known-good copy of GET responses, used as a fallback while the backend
/// is unreachable (stale-while-revalidate). Lives in its own storage container
/// so it can be wiped without touching the session.
class ApiCache {
  ApiCache._();

  static const containerName = 'api_cache';
  static const _maxEntries = 60;
  static const maxStaleAge = Duration(hours: 24);

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

  /// User-owned or transaction-sensitive endpoints are never persisted for
  /// stale fallback. This keeps offline resilience focused on public catalog
  /// and CMS data instead of showing old account or purchase state.
  static const _privateEndpointSegments = {
    'cart',
    'wishlist',
    'order',
    'orders',
    'customer',
    'address',
    'addresses',
    'review',
    'reviews',
    'notification',
    'notifications',
    'coupon',
    'coupons',
    'support-ticket',
    'support-tickets',
  };

  static final GetStorage _box = GetStorage(containerName);

  static Future<void> init() async {
    try {
      await GetStorage.init(containerName);
      await _purgeDisallowedEntries();
    } catch (error, stackTrace) {
      // This cache is optional. Initialization or cleanup failures must not
      // prevent the application from reaching its first frame.
      debugPrint('API cache cleanup skipped: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  static Future<void> _purgeDisallowedEntries() async {
    // GetStorage exposes a live key collection. Removing entries while walking
    // it can throw Concurrent modification during startup.
    final keys = _box.getKeys<Iterable>().toList(growable: false);
    for (final key in keys) {
      if (key is! String) continue;
      final separator = key.indexOf('|');
      final uri =
          separator < 0 ? null : Uri.tryParse(key.substring(separator + 1));
      if (uri == null || !isCacheable(uri.path)) {
        await _box.remove(key);
      }
    }
  }

  static bool isCacheable(String path) {
    final normalizedPath = path.toLowerCase().split('?').first;
    if (_deny.any(normalizedPath.contains)) return false;

    final segments = normalizedPath
        .split('/')
        .where((segment) => segment.isNotEmpty)
        .toSet();
    return !segments.any(_privateEndpointSegments.contains);
  }

  /// Authenticated responses are keyed per token so one user never sees
  /// another user's cached data.
  static String keyFor(Uri uri, String? token) =>
      '${token == null ? 'anon' : token.hashCode}|$uri';

  static dynamic read(String key) {
    try {
      final entry = _box.read(key);
      if (entry is Map && entry['d'] is String) {
        final timestamp = entry['t'];
        if (timestamp is! int) {
          _box.remove(key);
          return null;
        }
        final age = DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(timestamp),
        );
        if (age.isNegative || age > maxStaleAge) {
          _box.remove(key);
          return null;
        }
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
