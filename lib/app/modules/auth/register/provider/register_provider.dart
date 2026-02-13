import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get_connect/connect.dart';

// class RegisterProvider extends GetConnect {
//   String fetchUrl(String _path) {
//     return apiURL + _path;
//   }

//   Future<dynamic> sendRegisterCustomerRequest(form) async {
//     try {
//       print('form:dffff ${form.toString()}');

//       final response = await post(
//         fetchUrl("auth/register"),
//         form,
//         contentType: "application/json",
//         headers: {
//           "Accept": "application/json",
//           "Content-Type": "application/json",
//           "access_key": ACCESS_KEY,
//         },
//       );

//       print("===================");
//       print(response.body);
//       print("===================");

//       if (response.status.hasError) {
//         return Future.error(response.body);
//       } else {
//         return response.body;
//       }
//     } catch (e) {
//       print('register provider error: ${e.toString()}');
//       return Future.error(e.toString());
//     }
//   }
// }
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterProvider extends GetConnect {
  String fetchUrl(String path) {
    return apiURL + path;
  }

  // Send OTP to the user's email for OTP-based registration
  Future<dynamic> sendOtp(String email) async {
    try {
      final form = jsonEncode({"email": email});
      final response = await post(
        fetchUrl("auth/send-otp"),
        form,
        contentType: "application/json",
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "access_key": ACCESS_KEY,
        },
      );
      if (response.status.hasError) {
        throw Exception(response.body['message']);
      }
      return response.body; // Send the OTP details or success response
    } catch (e) {
      throw Exception("Failed to send OTP: $e");
    }
  }

  // Register the user via OTP-based method
  Future<dynamic> otpRegister(String email, String otp) async {
    try {
      final form = jsonEncode({"email": email, "otp": otp});
      final response = await post(
        fetchUrl("auth/register"),
        form,
        contentType: "application/json",
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "access_key": ACCESS_KEY,
        },
      );
      if (response.status.hasError) {
        throw Exception(response.body['message']);
      }
      return response
          .body; // Return the registration response (user details, token, etc.)
    } catch (e) {
      throw Exception("Failed to register with OTP: $e");
    }
  }

  // Register the user via password-based method
  Future<dynamic> passwordRegister(
      String name, String mobile, String email, String password) async {
    try {
      final form = {
        'name': name,
        'mobile': mobile,
        'email': email,
        'password': password,
      };
      print('Registration Request: $form');
      final response = await post(
        fetchUrl("auth/register"),
        jsonEncode(form),
        contentType: "application/json",
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "access_key": ACCESS_KEY,
        },
      );
      // Handle response - check if body is already a Map or needs decoding
      dynamic responseBody;

      if (response.body is String && (response.body as String).isNotEmpty) {
        try {
          responseBody = jsonDecode(response.body);
          print('Successfully decoded JSON response');
        } catch (e) {
          print('JSON decode error: $e');
          // If decode fails, use the raw string
          responseBody = response.body;
        }
      } else if (response.body is Map) {
        // Response is already a Map
        responseBody = response.body;
        print('Response is already a Map');
      } else {
        responseBody = {'message': 'Empty response from server'};
      }

      print('Processed Response Body: $responseBody');
      print('Response Body Type: ${responseBody.runtimeType}');

      // Check for API errors
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Return structured response
        return {
          'body': responseBody,
          'headers': response.headers,
          'statusCode': response.statusCode,
          'success': true,
        };
      } else {
        // Handle error responses
        String errorMessage = 'Registration failed';

        if (responseBody is Map) {
          errorMessage = responseBody['message'] ??
              responseBody['data'] ??
              responseBody['error'] ??
              'Registration failed with status ${response.statusCode}';
        } else if (responseBody is String) {
          errorMessage = responseBody;
        }

        print('Registration failed: $errorMessage');
        HelperFunctions().showSnackBarError(errorMessage);

        return {
          'body': responseBody,
          'headers': response.headers,
          'statusCode': response.statusCode,
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e, stackTrace) {
      print('Registration provider error: $e');
      print('Stack trace: $stackTrace');
      HelperFunctions().showSnackBarError('Registration failed: $e');
      rethrow;
    }
  }
}
