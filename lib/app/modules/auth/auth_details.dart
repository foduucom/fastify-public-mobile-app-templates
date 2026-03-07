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
      //print('token $token');
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
    if (response != null && response is Map) {
      print('Processing Login Response: $response');

      // Mark as logged in
      box.write('isLogin', true);
      box.write('fullResponse', response);

      // Extract user data
      dynamic userData;
      if (response['data'] != null) {
        userData = response['data'];
      } else if (response['user'] != null) {
        userData = response['user'];
      } else {
        userData = response;
      }

      // Only process as userData Map if it actually is one
      if (userData != null && userData is Map) {
        box.write('userData', userData);

        // Extract token from various possible locations
        String? tokenValue;
        String? tokenExpiry;

        // Check in userData
        if (userData['token'] != null) {
          if (userData['token'] is Map) {
            tokenValue = userData['token']['value']?.toString();
            tokenExpiry = userData['token']['expiry']?.toString();
          } else {
            tokenValue = userData['token'].toString();
          }
        }

        // Check in response root if not found in userData
        if (tokenValue == null && response['token'] != null) {
          tokenValue = response['token'].toString();
        }

        if (tokenValue == null && response['access_token'] != null) {
          tokenValue = response['access_token'].toString();
        }

        // Save token if found
        if (tokenValue != null) {
          box.write('token', tokenValue);
          if (tokenExpiry != null) {
            box.write('tokenExpiry', tokenExpiry);
          }
          print('Token saved successfully');
        } else {
          print(
              'INFO: No token found in response body (might be using cookies)');
        }
      } else {
        print(
            'INFO: response data is not a Map (likely a success message): $userData');
        // If it's a string, we still consider it a success since we set isLogin=true above
      }
    }
  }

  static dynamic getUserDetails() {
    var userDetails = box.read("userData");
    if (userDetails != null) {
      return userDetails;
    }
  }

  static Future<dynamic> updateUserDetailsFromServer() async {
    if (isUserLogin()) {
      try {
        var response = await BasicProvider("profile").getRequest();
        if (response != null) {
          box.write('userData', response);
          print('Successfully updated user details from server');
          return response;
        }
      } catch (e) {
        print('Error updating user details from server: $e');
      }
    }
    return null;
  }
}
