import 'dart:convert';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:get/get.dart';

class LoginProvider extends GetConnect {
  String fetchUrl(String path) {
    return apiURL + path;
  }

  /// Send login request (supports both OTP and Password based on form data)
  Future<Map<String, dynamic>> sendLoginRequest(
      Map<String, dynamic> form) async {
    try {
      final response = await post(
        fetchUrl("auth/login"),
        jsonEncode(form),
        contentType: "application/json",
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "access-key": ACCESS_KEY,
        },
      ).timeout(const Duration(seconds: 30));

      print('Login request completed with status ${response.statusCode}.');

      // Return a structured map similar to OtpProvider
      return {
        'body': response.body,
        'headers': response.headers,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      print('Login request failed.');
      return {
        'body': {'status': 'error', 'message': e.toString()},
        'statusCode': 500,
      };
    }
  }
}
