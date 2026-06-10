import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InternetconnectionController extends GetxController {
  var connectionStatus = true.obs;
  late StreamSubscription<List<ConnectivityResult>> _listener;
  var shouldNotificationVisible = false.obs;
  var isCheckingConnection = false.obs;
  var isOnNoInternetScreen = false.obs;

  // Store the exact route we came from
  String previousRoute = '';

  @override
  void onInit() {
    super.onInit();

    _listener = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> resultList) {
      final result =
          resultList.isNotEmpty ? resultList.first : ConnectivityResult.none;
      _updateConnectionStatus(result);
    });
    // Auto-show dialog when internet is lost
    ever(connectionStatus, (status) {
      if (!status) {
        showInternetErrorDialog();
      } else {
        if (isOnNoInternetScreen.value) {
          Future.delayed(Duration(milliseconds: 300), () {
            returnFromNoInternetScreen();
          });
        }
      }
    });
  }

  Future<void> checkInitialConnection() async {
    await checkConnection();
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      connectionStatus.value = false;
      shouldNotificationVisible.value = true;
    } else {
      hideNotificationOnInternet();
    }
  }

  void hideNotificationOnInternet() {
    connectionStatus.value = true;
    Future.delayed(const Duration(milliseconds: 3000), () {
      shouldNotificationVisible.value = false;
    });
  }

  // **Manually check connection when Try Again is pressed**
  // Future<void> checkConnection() async {
  //   isCheckingConnection.value = true;
  //   var connectivityResult = await Connectivity().checkConnectivity();
  //   _updateConnectionStatus(connectivityResult);
  //   await Future.delayed(Duration(seconds: 1));
  //   isCheckingConnection.value = false;
  // }
  Future<void> checkConnection() async {
    isCheckingConnection.value = true;

    try {
      List<ConnectivityResult> resultList =
          await Connectivity().checkConnectivity();
      final result =
          resultList.isNotEmpty ? resultList.first : ConnectivityResult.none;

      _updateConnectionStatus(result);

      // Check if we should navigate back
      if (connectionStatus.value == true &&
          isOnNoInternetScreen.value == true) {
        await Future.delayed(Duration(milliseconds: 500));
        returnFromNoInternetScreen();
      } else if (connectionStatus.value == false) {
        print('=== Still no connection ===');
      }
    } catch (e) {
      print('=== Error checking connectivity: $e ===');
    } finally {
      isCheckingConnection.value = false;
    }
  }

  // **Show dialog if internet is lost**
  void showInternetErrorDialog() {
    print('=== showInternetErrorDialog called ===');
    navigateToNoInternetScreen();
  }

  void navigateToNoInternetScreen() {
    if (!isOnNoInternetScreen.value && Get.currentRoute != '/no-internet') {
      // Save the current route BEFORE navigating
      previousRoute = Get.currentRoute;
      isOnNoInternetScreen.value = true;
      Get.toNamed('/no-internet'); // Use toNamed instead of offNamed
    } else {
      print('=== Already on no internet screen or navigating ===');
    }
  }

  void returnFromNoInternetScreen() {
    if (isOnNoInternetScreen.value && connectionStatus.value) {
      print('=== Conditions met, navigating back ===');
      isOnNoInternetScreen.value = false;

      // Navigate to the saved route
      if (previousRoute.isNotEmpty && previousRoute != '/no-internet') {
        print('=== Going back to: $previousRoute ===');
        Get.offAllNamed(previousRoute);
      } else {
        print('=== No valid previous route, going to default ===');
        Get.offAllNamed('/candidate/bottom-navigation-bar');
      }

      print('=== After navigation, current route: ${Get.currentRoute} ===');
    } else {
      print('=== Conditions not met for return ===');
    }
  }

  @override
  void onClose() {
    _listener.cancel();
    super.onClose();
  }
}
