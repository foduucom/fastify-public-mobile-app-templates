import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foddu/app/controllers/api_exception_handle_controller.dart';
import 'package:foddu/app/modules/auth/auth_details.dart';
import 'package:foddu/app/modules/auth/otp/provider/otp_provider.dart';
import 'package:foddu/app/modules/auth/register/provider/register_provider.dart';
import 'package:foddu/app/routes/app_pages.dart';
import 'package:foddu/constants/firebase_notification.dart';
import 'package:foddu/constants/helper_functions.dart';
import 'package:foddu/core/services/cartServcie.dart';
import 'package:foddu/core/services/wishlistService.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class OtpController extends GetxController with BaseController {
  final isLoading = false.obs;
  final isResending = false.obs;
  final otpCode = ''.obs;
  final box = GetStorage();
  final OtpProvider otpProvider = OtpProvider();

  late String email;
  late String name;
  late String context;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    email = args is Map ? (args['email'] ?? '').toString() : '';
    name = args is Map ? (args['name'] ?? '').toString() : '';
    context = args is Map ? (args['context'] ?? 'login').toString() : 'login';
  }

  void onOtpChanged(String value) => otpCode.value = value.trim();

  Future<void> verifyOtp() async {
    final otp = otpCode.value.trim();
    if (otp.length != 6) {
      HelperFunctions()
          .showSnackBarError('Please enter the complete 6-digit code.');
      return;
    }
    if (email.trim().isEmpty) {
      HelperFunctions()
          .showSnackBarError('Email address is missing. Please try again.');
      return;
    }

    isLoading.value = true;
    try {
      dynamic response;
      if (context == 'register') {
        response = await RegisterProvider().otpRegister(email.trim(), otp);
      } else {
        response = await otpProvider.verifyOtp(email: email.trim(), otp: otp);
      }

      if (response == null || response is! Map) {
        throw StateError('The verification response was empty or invalid.');
      }
      final statusCode = int.tryParse(response['statusCode']?.toString() ?? '');
      if (statusCode != null && statusCode >= 400) {
        throw StateError(
          (response['message'] ?? response['error'] ?? 'The code is invalid.')
              .toString(),
        );
      }

      final payload = response['body'] is Map
          ? response['body']
          : response['data'] is Map
              ? response['data']
              : response;
      if (payload is! Map) {
        throw StateError(
            'The verification response did not include account data.');
      }

      final user = payload['user'] ?? payload['customer'] ?? payload['data'];
      final loginData = <String, dynamic>{
        ...Map<String, dynamic>.from(payload),
        if (user is Map) ...Map<String, dynamic>.from(user),
      };
      final tokenValue = loginData['access_token'] ?? loginData['token'];
      final token = tokenValue is Map
          ? (tokenValue['value'] ?? tokenValue['access_token'] ?? '').toString()
          : (tokenValue ?? '').toString();
      if (token.isEmpty) {
        throw StateError(
            'Verification succeeded but no sign-in token was returned.');
      }

      AuthDetails.saveLoginResponse(loginData);
      if (!AuthDetails.isUserLogin()) {
        throw StateError(
            'Could not save the signed-in session. Please try again.');
      }

      // Login is valid even if a secondary cart or wishlist refresh is offline.
      if (Get.isRegistered<CartService>()) {
        try {
          await CartService.to.syncLocalCartToServer();
          await CartService.to.fetchCart(useCache: false);
        } catch (e) {
          debugPrint('Post-login cart refresh failed: $e');
        }
      }
      if (Get.isRegistered<WishListService>()) {
        await WishListService.to.fetchWishList();
      }
      unawaited(FirebaseHelpers.afterLoginSubscribe());

      HelperFunctions().showSnackBarSuccess(
        context == 'register' ? 'Your account is ready.' : 'You are signed in.',
      );
      Get.offAllNamed(Routes.BOTTOMBAR);
    } catch (e) {
      debugPrint('OTP verification failed: $e');
      HelperFunctions().showSnackBarError(
        e
            .toString()
            .replaceFirst('Bad state:', '')
            .replaceFirst('Exception:', '')
            .trim(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    isResending.value = true;
    try {
      final response = context == 'register'
          ? await RegisterProvider().sendOtp(email.trim(), name.trim())
          : await otpProvider.resendOtp(email: email.trim());
      if (response == null) {
        throw StateError('The code could not be resent. Please try again.');
      }
      HelperFunctions().showSnackBarSuccess('A new code was sent to $email.');
    } catch (e) {
      HelperFunctions().showSnackBarError(
        e.toString().replaceFirst('Exception:', '').trim(),
      );
    } finally {
      isResending.value = false;
    }
  }
}
