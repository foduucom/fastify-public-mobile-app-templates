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

  Future<Map<String, dynamic>> verifyOtp(
      {String? email,
      String? mobile,
      String? countryCode,
      required String otp,
      bool persistAuthSession = true}) async {
    try {
      final Map<String, dynamic> form = {"otp": otp};
      if (email != null && email.isNotEmpty) {
        form["email"] = email;
      } else if (mobile != null && mobile.isNotEmpty) {
        form["mobile"] = mobile;
        if (countryCode != null) form["country_code"] = countryCode;
      }
      final http.Client client =
          persistAuthSession ? CookieClientManager.getClient() : http.Client();
      late final http.Response response;
      try {
        response = await client.post(
          Uri.parse(fetchUrl("auth/verify-otp")),
          body: jsonEncode(form),
          headers: {
            "accept": "application/json",
            "access-key": ACCESS_KEY,
            "Content-Type": "application/json",
          },
        );
      } finally {
        if (!persistAuthSession) client.close();
      }

      // Guard against empty or non-JSON response body
      dynamic responseBody;
      if (response.body.isEmpty) {
        responseBody = {'message': 'Empty response from server'};
      } else {
        try {
          responseBody = jsonDecode(response.body);
        } catch (_) {
          responseBody = {
            'message': 'Invalid response from server: ${response.body}'
          };
        }
      }

      if (response.statusCode == 200) {
        // Return both response body and headers (for cookies)
        return {
          'body': responseBody,
          'headers': response.headers,
          'statusCode': response.statusCode,
        };
      } else if (response.statusCode == 422) {
        final errorMessage = responseBody is Map
            ? responseBody['message']?.toString() ?? 'Invalid OTP'
            : 'Invalid OTP';
        throw FormatException(errorMessage);
      } else if (response.statusCode == 401) {
        final errorMessage = responseBody is Map
            ? responseBody['message']?.toString() ?? 'Invalid credentials'
            : 'Invalid credentials';
        throw UnAuthorizedException(errorMessage);
      } else {
        final errorMessage = responseBody is Map
            ? responseBody['message']?.toString() ?? 'OTP verification failed'
            : 'OTP verification failed';
        throw Exception(errorMessage);
      }
    } on FormatException catch (e) {
      HelperFunctions().showSnackBarError(e.message);
      rethrow;
    } on UnAuthorizedException catch (e) {
      HelperFunctions().showSnackBarError(e.toString());
      rethrow;
    } catch (e) {
      HelperFunctions().showSnackBarError("OTP verification failed!");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> resendOtp(
      {String? email, String? mobile, String? countryCode}) async {
    try {
      final Map<String, dynamic> form = {};
      if (email != null && email.isNotEmpty) {
        form["email"] = email;
      } else if (mobile != null && mobile.isNotEmpty) {
        form["mobile"] = mobile;
        if (countryCode != null) form["country_code"] = countryCode;
      }
      final client = CookieClientManager.getClient();
      final response = await client.post(
        Uri.parse(fetchUrl("auth/resend-otp")),
        body: jsonEncode(form),
        headers: {
          "accept": "application/json",
          "access-key": ACCESS_KEY,
          "Content-Type": "application/json",
        },
      );

      // Guard against empty or non-JSON response body
      dynamic responseBody;
      if (response.body.isEmpty) {
        responseBody = {'message': 'Empty response from server'};
      } else {
        try {
          responseBody = jsonDecode(response.body);
        } catch (_) {
          responseBody = {
            'message': 'Invalid response from server: ${response.body}'
          };
        }
      }

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
