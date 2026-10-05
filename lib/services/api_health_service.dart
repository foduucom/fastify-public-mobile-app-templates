import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:get/get.dart';

enum ApiHealth { healthy, reconnecting, down }

/// Tracks whether the backend is reachable, so the UI can show a calm
/// "reconnecting" state instead of errors, and screens can silently reload as
/// soon as the server is back (e.g. after a deploy).
class ApiHealthService extends GetxService {
  static ApiHealthService? get maybe =>
      Get.isRegistered<ApiHealthService>() ? Get.find<ApiHealthService>() : null;

  /// After this many seconds without a response we move from "reconnecting"
  /// to the friendlier full-screen "taking longer" state.
  static const downAfterSeconds = 8;
  static const probeIntervalSeconds = 5;

  final status = ApiHealth.healthy.obs;
  final isOffline = false.obs;

  /// True while the data on screen came from the cache.
  final servingStale = false.obs;

  /// Shows the "back online" confirmation for a couple of seconds.
  final showRecovered = false.obs;

  /// Incremented every time the backend comes back. Screens listen and reload.
  final recoveryTick = 0.obs;

  final outageSeconds = 0.obs;
  final secondsToRetry = 0.obs;

  Timer? _ticker;
  Timer? _recoveredTimer;
  DateTime? _outageStart;
  bool _probing = false;

  bool get isUnhealthy => status.value != ApiHealth.healthy;

  void reportTransientFailure() {
    if (_outageStart == null) {
      _outageStart = DateTime.now();
      outageSeconds.value = 0;
      secondsToRetry.value = probeIntervalSeconds;
      _recoveredTimer?.cancel();
      showRecovered.value = false;
      status.value = ApiHealth.reconnecting;
      _refreshOffline();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  void reportStale() => servingStale.value = true;

  void reportSuccess() {
    if (_outageStart == null) {
      servingStale.value = false;
      return;
    }
    _ticker?.cancel();
    _ticker = null;
    _outageStart = null;
    status.value = ApiHealth.healthy;
    isOffline.value = false;
    secondsToRetry.value = 0;
    outageSeconds.value = 0;
    servingStale.value = false;
    showRecovered.value = true;
    recoveryTick.value++;
    _recoveredTimer?.cancel();
    _recoveredTimer =
        Timer(const Duration(seconds: 2), () => showRecovered.value = false);
  }

  /// "Try now" button.
  Future<void> retryNow() => _probe();

  void _tick() {
    final start = _outageStart;
    if (start == null) return;
    outageSeconds.value = DateTime.now().difference(start).inSeconds;
    if (outageSeconds.value >= downAfterSeconds &&
        status.value == ApiHealth.reconnecting) {
      status.value = ApiHealth.down;
    }
    if (secondsToRetry.value > 0) secondsToRetry.value--;
    if (secondsToRetry.value <= 0) {
      secondsToRetry.value = probeIntervalSeconds;
      _probe();
    }
  }

  /// Cheap request to find out when the backend is back, even if no screen is
  /// currently loading. Success is reported by BasicProvider itself.
  Future<void> _probe() async {
    if (_probing || _outageStart == null) return;
    _probing = true;
    try {
      await BasicProvider('public-settings')
          .getRequest(useCache: false, retry: false);
    } catch (_) {
      _refreshOffline();
    } finally {
      _probing = false;
    }
  }

  Future<void> _refreshOffline() async {
    try {
      // connectivity_plus returns a single result (<6) or a list (>=6).
      final dynamic r = await Connectivity().checkConnectivity();
      isOffline.value = r is List
          ? r.isEmpty || r.every((e) => e == ConnectivityResult.none)
          : r == ConnectivityResult.none;
    } catch (_) {}
  }

  @override
  void onClose() {
    _ticker?.cancel();
    _recoveredTimer?.cancel();
    super.onClose();
  }
}
