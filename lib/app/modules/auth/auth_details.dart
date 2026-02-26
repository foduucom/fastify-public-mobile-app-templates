import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import 'package:get_storage/get_storage.dart';

class AuthDetails with BaseController {
  static final box = GetStorage();

  static bool checkAuthentication() {
    try {
      var userDetails = box.read("userData");
      if (userDetails != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static bool isIntroViewd() {
    try {
      var isIntroViews = box.read('isIntroViewed');
      if (isIntroViews != null && isIntroViews == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Authentication details error $e');
      return false;
    }
  }

  static bool isUserLogin() {
    var isLogin = box.read('isLogin');
    if (isLogin == true || isLogin == 'true') {
      return true;
    } else {
      return false;
    }
  }

  static String? getToken() {
    var token = box.read('token');
    if (token != null) {
      return token;
    } else {
      return null;
    }
  }

  // static String userType() {
  //   var userDetails = box.read("token");
  //   if (userDetails["type"] != null) {
  //     return userDetails["type"];
  //   } else {
  //     return "";
  //   }
  // }

  // static bool isVerified() {
  //   // var userDetails = box.read("token");

  //   if (userDetails != null) {
  //     return userDetails["user"]["is_register"] == 1 ? true : false;
  //   } else {
  //     return false;
  //   }
  // }

  static void saveLoginResponse(dynamic response) {
    print('OTP VERIFICATION RESPONSE: $response');
    if (response != null) {
      // Check if the actual user data is nested inside a 'data' field
      dynamic userData;

      if (response['data'] != null) {
        // If response has a 'data' field, use that as user data
        userData = response['data'];

        // Also save the full response if needed
        box.write('fullResponse', response);
      } else {
        // Otherwise use the response directly
        userData = response;
      }

      // Save the user data
      box.write('userData', userData);
      box.write('isLogin', true);

      // Extract token from the correct location
      String? tokenValue;
      String? tokenExpiry;

      if (userData['token'] != null) {
        if (userData['token'] is Map) {
          tokenValue = userData['token']['value'];
          tokenExpiry = userData['token']['expiry'];
        } else {
          tokenValue = userData['token'];
        }
      }

      // Save token if found
      if (tokenValue != null) {
        box.write('token', tokenValue);
        if (tokenExpiry != null) {
          box.write('tokenExpiry', tokenExpiry);
        }
        print('Token saved successfully: $tokenValue');
      } else {
        print('WARNING: No token found in response');
      }
    }
  }

  static dynamic getUserDetails() {
    var userDetails = box.read("userData");
    if (userDetails != null) {
      return userDetails;
    }
  }

  dynamic updateUserDetailsFromServer() async {
    if (isUserLogin()) {
      var response = await BasicProvider("public/customer/profile")
          .getRequest()
          .catchError(handleError);
      if (response != null) {
        var userDetails = response;

        box.write('userData', userDetails);

        return userDetails;
      }
    }
  }
}
