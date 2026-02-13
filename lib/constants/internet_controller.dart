import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:get/get.dart';

class InternetController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final isInternet = true.obs;

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      print('Error checking connection: $e');
      isInternet.value = false;
      _showNoInternetSnackbar();
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final hasInternet = !results.contains(ConnectivityResult.none);

    if (hasInternet != isInternet.value) {
      isInternet.value = hasInternet;

      // Show/hide snackbar based on connection
      if (!hasInternet) {
        _showNoInternetSnackbar();
      } else {
        if (Get.isSnackbarOpen) {
          Get.closeCurrentSnackbar();
          // Show connected message briefly
          Get.snackbar(
            'Connected',
            'Internet connection restored',
            backgroundColor: DefaultThemeColors.alertSuccessLight,
            colorText: DefaultThemeColors.lightOnPrimary,
            duration: Duration(seconds: 2),
            snackPosition: SnackPosition.TOP,
          );
        }
      }
    }
  }

  void _showNoInternetSnackbar() {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      'No Internet Connection',
      'Please check your internet connection',
      backgroundColor: DefaultThemeColors.alertErrorLighter,
      colorText: DefaultThemeColors.lightOnPrimary,
      icon: Icon(Icons.wifi_off, color: DefaultThemeColors.lightOnPrimary),
      duration: Duration(days: 1), // Show until connection is restored
      isDismissible: false,
      mainButton: TextButton(
        onPressed: () async {
          await _checkInitialConnection();
        },
        child: Text('RETRY',
            style: TextStyle(color: DefaultThemeColors.lightOnPrimary)),
      ),
      snackPosition: SnackPosition.TOP,
      snackStyle: SnackStyle.FLOATING,
      margin: EdgeInsets.all(10),
      borderRadius: 8,
    );
  }
}
