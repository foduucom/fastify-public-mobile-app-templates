import 'dart:convert';
import 'package:foddu/app/data/basic_provider.dart';

class OtpProvider extends BasicProvider {
  OtpProvider() : super('/verify-otp');

  /// Verifies OTP code sent to email or mobile number.
  Future<Map<String, dynamic>?> verifyOtp({
    String? email,
    String? mobile,
    String? countryCode,
    required String otp,
  }) async {
    final Map<String, dynamic> body = {
      'otp': otp,
      if (email != null && email.isNotEmpty) 'email': email,
      if (mobile != null && mobile.isNotEmpty) 'mobile': mobile,
      if (countryCode != null && countryCode.isNotEmpty) 'country_code': countryCode,
    };

    try {
      final response = await postRequest('/verify-otp', body);
      if (response != null) {
        if (response is Map<String, dynamic>) {
          return response;
        } else if (response is String) {
          return jsonDecode(response) as Map<String, dynamic>;
        }
      }
      return {'statusCode': 200, 'message': 'Verified'};
    } catch (e) {
      // Return structured response on failure
      return {'statusCode': 400, 'message': e.toString()};
    }
  }

  /// Requests a fresh OTP for email or mobile.
  Future<Map<String, dynamic>?> resendOtp({
    String? email,
    String? mobile,
    String? countryCode,
  }) async {
    final Map<String, dynamic> body = {
      if (email != null && email.isNotEmpty) 'email': email,
      if (mobile != null && mobile.isNotEmpty) 'mobile': mobile,
      if (countryCode != null && countryCode.isNotEmpty) 'country_code': countryCode,
    };

    try {
      final response = await postRequest('/resend-otp', body);
      if (response != null) {
        if (response is Map<String, dynamic>) {
          return response;
        } else if (response is String) {
          return jsonDecode(response) as Map<String, dynamic>;
        }
      }
      return {'statusCode': 200, 'message': 'OTP resent'};
    } catch (e) {
      return {'statusCode': 400, 'message': e.toString()};
    }
  }
}

