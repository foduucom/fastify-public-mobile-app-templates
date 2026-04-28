import 'package:foduu_ecommerce/constants/app_exceptions.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get_connect/connect.dart';
import 'dart:convert'; // Add this import

class OTPLoginProvider extends GetConnect {
  String fetchUrl(String path) {
    return apiURL + path;
  }

  // Send OTP
  Future<dynamic> sendOtp(String email) async {
    try {
      final form = jsonEncode({"email": email});
      final response = await post(
        fetchUrl("auth/resend-otp"),
        form,
        contentType: "application/json",
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "access_key": ACCESS_KEY,
        },
      );
      print("OTP send Sucesss msg=====${response.body}");
      if (response.status.hasError) {
        throw UnAuthorizedException(response.body['message']);
      } else {
        return response.body; // send entire body to check messages
      }
    } catch (e) {
      HelperFunctions().showSnackBarError("Failed to send OTP!");
      rethrow;
    }
  }

  // Verify OTP
  Future<dynamic> verifyOtp(String email, String otp) async {
    try {
      final form = {"email": email, "otp": otp};
      print("form===${form}");
      final response = await post(
        fetchUrl("auth/verify-otp"),
        form,
        contentType: "application/json",
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "access_key": ACCESS_KEY,
        },
      );

      print("otp verify response ${response.body}");
      if (response.status.hasError) {
        throw UnAuthorizedException(response.body['message']);
      } else {
        return response.body; // contains access_token etc
      }
    } catch (e) {
      HelperFunctions().showSnackBarError("OTP verification failed!");
      rethrow;
    }
  }
}
