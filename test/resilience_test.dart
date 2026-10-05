import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/constants/app_exceptions.dart';
import 'package:foduu_ecommerce/services/api_cache.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _nginx502 = '<html><body><h1>502 Bad Gateway</h1></body></html>';

Future<T> _withServer<T>(
    http.Response Function(int call) respond, Future<T> Function() body) {
  var calls = 0;
  final client = MockClient((_) async => respond(calls++));
  return http.runWithClient(body, () => client);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final dir = Directory.systemTemp.createTempSync('resilience_test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (call) async => dir.path);
    await GetStorage.init();
    await ApiCache.init();
  });

  setUp(() => ApiCache.clear());

  test('502 with HTML body is classified as ServiceUnavailable', () async {
    await _withServer((_) => http.Response(_nginx502, 502), () async {
      expect(
        () => BasicProvider('products').getRequest(retry: false),
        throwsA(isA<ServiceUnavailableException>()),
      );
    });
  });

  test('retries 502 then succeeds', () async {
    var calls = 0;
    await _withServer((n) {
      calls = n + 1;
      return n < 1
          ? http.Response(_nginx502, 502)
          : http.Response('{"data": {"ok": true}}', 200);
    }, () async {
      final result = await BasicProvider('retry-ok').getRequest();
      expect(result, {'ok': true});
    });
    expect(calls, 2);
  });

  test('does not retry 4xx', () async {
    var calls = 0;
    await _withServer((n) {
      calls = n + 1;
      return http.Response('{"message": "nope"}', 400);
    }, () async {
      await expectLater(BasicProvider('missing').getRequest(),
          throwsA(isA<BadRequestException>()));
    });
    expect(calls, 1);
  });

  test('serves cached copy when backend returns 502', () async {
    await _withServer(
        (_) => http.Response('{"data": {"v": 1}}', 200),
        () => BasicProvider('mobile-app/home').getRequest());

    await _withServer((_) => http.Response(_nginx502, 502), () async {
      final provider = BasicProvider('mobile-app/home');
      final result = await provider.getRequest(retry: false);
      expect(result, {'v': 1});
      expect(provider.servedFromCache, isTrue);
    });
  });

  test('auth endpoints are never cached', () {
    expect(ApiCache.isCacheable('auth/login'), isFalse);
    expect(ApiCache.isCacheable('payment/create'), isFalse);
    expect(ApiCache.isCacheable('mobile-app/home'), isTrue);
  });
}
