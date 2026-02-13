import 'dart:convert';

import 'package:foduu_ecommerce/app/data/cookie_client_manager.dart';
import 'package:foduu_ecommerce/constants/app_exceptions.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get_connect/connect.dart';
import 'package:http_cookie_store/http_cookie_store.dart';

class AuthProvider extends GetConnect {
  // Fetch the URL for the login API
  Uri fetchUrl(String path) {
    print('url .>>> ${apiURL + path}');
    return Uri.parse(apiURL + path);
  }

  Future<dynamic> sendLoginRequest(Map<String, dynamic> form) async {
    try {
      print('url .>>> send login request');
      final client = CookieClientManager.getClient();
      final response = await client.post(
        fetchUrl("auth/login"),
        body: jsonEncode(form),
        headers: {
          "accept": "application/json",
          "Content-Type": "application/json",
          "access_key": ACCESS_KEY,
        },
      );

      print("Login Form Data: $form");
      print("Login API Response: ${response.body}");

      if (response.statusCode != 200) {
        throw UnAuthorizedException(jsonDecode(response.body)['data']);
      } else {
        return jsonDecode(response.body);
      }
    } on UnAuthorizedException catch (exception) {
      HelperFunctions().showSnackBarError(exception.message.toString());
      rethrow;
    } catch (exception) {
      HelperFunctions().showSnackBarError("There is some issue with login!");
      print("Login Exception: $exception");
      rethrow;
    }
  }

  /// Send OTP to email for OTP-based login
  Future<dynamic> sendOtp(String email) async {
    try {
      print('url .>>> swapnil} sendotp');
      final client = CookieClientManager.getClient();
      final response = await client.post(
        fetchUrl("auth/send-otp"),
        body: {'email': email},
        headers: {
          "accept": "application/json",
          "Content-Type": "application/json",
          "access_key": ACCESS_KEY,
        },
      );

      print("Send OTP Response: ${response.body}");

      if (response.statusCode != 200) {
        throw UnAuthorizedException(
            jsonDecode(response.body)['message'] ?? 'Failed to send OTP');
      } else {
        return jsonDecode(response.body);
      }
    } on UnAuthorizedException catch (exception) {
      HelperFunctions().showSnackBarError(exception.message.toString());
      rethrow;
    } catch (exception) {
      HelperFunctions().showSnackBarError("Failed to send OTP!");
      print("Send OTP Exception: $exception");
      rethrow;
    }
  }

  /// Resend OTP
  Future<dynamic> resendOtp(String email) async {
    try {
      final client = CookieClientManager.getClient();
      final response = await client.post(
        fetchUrl("auth/resend-otp"),
        body: jsonEncode({'email': email}),
        headers: {
          "accept": "application/json",
          "Content-Type": "application/json",
          "access_key": ACCESS_KEY,
        },
      );

      print("Resend OTP Response: ${response.body}");

      if (response.statusCode != 200) {
        throw UnAuthorizedException(
            jsonDecode(response.body)['message'] ?? 'Failed to resend OTP');
      } else {
        return jsonDecode(response.body);
      }
    } on UnAuthorizedException catch (exception) {
      HelperFunctions().showSnackBarError(exception.message.toString());
      rethrow;
    } catch (exception) {
      HelperFunctions().showSnackBarError("Failed to resend OTP!");
      print("Resend OTP Exception: $exception");
      rethrow;
    }
  }
}
