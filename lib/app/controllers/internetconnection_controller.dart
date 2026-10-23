import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InternetconnectionController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  final connectionStatus = true.obs;
  final showBackOnline = false.obs;
  bool _isInitialCheck = true;

  @override
  void onInit() {
    super.onInit();
    _initConnectivityListener();
  }

  Future<void> _initConnectivityListener() async {
    // Wait until the Get navigator is fully active and ready to render overlays
    while (Get.key.currentState == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    await Future.delayed(const Duration(milliseconds: 500)); // safe buffer

    // Check initial status
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      Get.log("Failed to check initial connectivity: $e");
    } finally {
      _isInitialCheck = false;
    }

    // Start listening to live changes
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      connectionStatus.value = false;
      showBackOnline.value = false;

      // Get.rawSnackbar(
      //   titleText: const Text(
      //     "Connection Status",
      //     style: TextStyle(
      //         color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      //   ),
      //   messageText: const Text(
      //     "We are Offline",
      //     style: TextStyle(color: Colors.white, fontSize: 14),
      //   ),
      //   backgroundColor: Colors.red[700]!,
      //   snackPosition: SnackPosition.TOP,
      //   duration: const Duration(seconds: 4),
      //   margin: const EdgeInsets.all(15),
      //   borderRadius: 8,
      //   icon: const Icon(Icons.wifi_off, color: Colors.white),
      // );
    } else {
      if (!connectionStatus.value && !_isInitialCheck) {
        showBackOnline.value = true;
        Future.delayed(const Duration(seconds: 3), () {
          showBackOnline.value = false;
        });

        Get.rawSnackbar(
          titleText: const Text(
            "Connection Status",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          messageText: const Text(
            "We are back Online",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          backgroundColor: Colors.green[700]!,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(15),
          borderRadius: 8,
          icon: const Icon(Icons.wifi, color: Colors.white),
        );
      }
      connectionStatus.value = true;
    }
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }
}
