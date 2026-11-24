import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foddu/services/api_cache.dart';
import 'package:get_storage/get_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory storageDirectory;
  late GetStorage cache;

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') return '.';
      return null;
    });
  });

  setUp(() async {
    storageDirectory = await Directory.systemTemp.createTemp('api-cache-test');
    // Register the container with an isolated path before ApiCache initializes
    // its singleton storage handle.
    cache = GetStorage(ApiCache.containerName, storageDirectory.path);
    await cache.initStorage;
    await cache.erase();
  });

  tearDown(() async {
    await storageDirectory.delete(recursive: true);
  });

  test('purges several disallowed keys without mutating a live iteration',
      () async {
    const allowedKey = 'anon|https://store.example/products';
    const authKey = 'anon|https://store.example/auth/login';
    const paymentKey = 'anon|https://store.example/payment/checkout';
    const malformedKey = 'not-a-cache-key';

    await cache.write(allowedKey, {'d': '{}', 't': 1});
    await cache.write(authKey, {'d': '{}', 't': 1});
    await cache.write(paymentKey, {'d': '{}', 't': 1});
    await cache.write(malformedKey, {'d': '{}', 't': 1});

    await ApiCache.init();

    expect(cache.read(allowedKey), isNotNull);
    expect(cache.read(authKey), isNull);
    expect(cache.read(paymentKey), isNull);
    expect(cache.read(malformedKey), isNull);
  });
}
