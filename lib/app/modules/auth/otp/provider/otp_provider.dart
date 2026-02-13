import 'dart:convert';
import 'package:foduu_ecommerce/app/data/cookie_client_manager.dart';
import 'package:foduu_ecommerce/constants/app_exceptions.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get_connect/connect.dart';
import 'package:http/http.dart' as http;

class OtpProvider extends GetConnect {
  String fetchUrl(String path) {
    return apiURL + path;
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final form = {"email": email, "otp": otp};
      final client = CookieClientManager.getClient();
      final response = await client.post(
        Uri.parse(fetchUrl("auth/verify-otp")),
        body: jsonEncode(form),
        headers: {
          "accept": "application/json",
          "access_key": ACCESS_KEY,
          "Content-Type": "application/json",
        },
      );

      final responseBody = jsonDecode(response.body);

      // Print response headers to debug cookies
      print('Response Headers: ${response.headers}');
      print('Response Status: ${response.statusCode}');
      print('Response Body: $responseBody');

      if (response.statusCode == 200) {
        // Return both response body and headers (for cookies)
        return {
          'body': responseBody,
          'headers': response.headers,
          'statusCode': response.statusCode,
        };
      } else if (response.statusCode == 422) {
        final errorMessage = responseBody['message']?.toString() ??
            'Invalid OTP'; // Add ?.toString()
        throw FormatException(errorMessage);
      } else if (response.statusCode == 401) {
        final errorMessage = responseBody['message']?.toString() ??
            'Invalid credentials'; // Add ?.toString()
        throw UnAuthorizedException(errorMessage); // Pass string directly
      } else {
        // FIX HERE: Convert null to string properly
        final errorMessage =
            responseBody['message']?.toString() ?? 'OTP verification failed';
        throw Exception(errorMessage);
      }
    } on FormatException catch (e) {
      HelperFunctions().showSnackBarError(
          e.message ?? 'Invalid OTP format'); // Handle null message
      rethrow;
    } on UnAuthorizedException catch (e) {
      HelperFunctions().showSnackBarError(e.toString());
      rethrow;
    } catch (e) {
      HelperFunctions().showSnackBarError("OTP verification failed!");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> resendOtp(String email) async {
    try {
      final form = {"email": email};
      final client = CookieClientManager.getClient();
      final response = await client.post(
        Uri.parse(fetchUrl("auth/resend-otp")),
        body: jsonEncode(form),
        headers: {
          "accept": "application/json",
          "access_key": ACCESS_KEY,
          "Content-Type": "application/json",
        },
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'body': responseBody,
          'headers': response.headers,
          'statusCode': response.statusCode,
        };
      } else {
        // FIX HERE TOO
        final errorMessage =
            responseBody['message']?.toString() ?? 'Failed to resend OTP';
        throw Exception(errorMessage);
      }
    } catch (e) {
      HelperFunctions().showSnackBarError("Failed to resend OTP!");
      rethrow;
    }
  }
}
