import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthDetails with BaseController {
  static final AuthDetails _instance = AuthDetails._internal();

  factory AuthDetails() {
    return _instance;
  }

  AuthDetails._internal();

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

  /// Reactive mirror of the persisted `isLogin` flag so UI (Profile, etc.)
  /// flips to the signed-out state the moment a session is torn down.
  static final RxBool loggedIn = _createLoggedIn();

  static RxBool _createLoggedIn() {
    bool isTrue(dynamic v) => v == true || v == 'true';
    final rx = RxBool(isTrue(box.read('isLogin')));
    box.listenKey('isLogin', (value) => rx.value = isTrue(value));
    return rx;
  }

  static bool isUserLogin() {
    var isLogin = box.read('isLogin');
    var token = box.read('token');
    if ((isLogin == true || isLogin == 'true') &&
        token != null &&
        token.toString().isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  static String? getToken() {
    if (!isUserLogin()) return null;
    var token = box.read('token');
    //print("Get Token: $token");
    if (token != null) {
      return token.toString();
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
    if (response != null) {
      final userMap = (response is Map && response['data'] is Map && response['data']['id'] != null)
          ? response['data']
          : response;
      box.write('userData', userMap);
      box.write('isLogin', true);

      // Support both unwrapped response (direct map) and wrapped { data: { token: ... } }
      dynamic tokenData;
      if (response is Map) {
        tokenData = response['token'] ??
            (response['data'] is Map ? response['data']['token'] : null) ??
            response['access_token'] ??
            (response['data'] is Map ? response['data']['access_token'] : null);
      }

      print("Save Login Response (tokenData): $tokenData");

      if (tokenData != null) {
        if (tokenData is Map) {
          final tokenVal = tokenData['value'] ?? tokenData['token'];
          final expiry = tokenData['expiry'];
          if (tokenVal != null) {
            box.write('token', tokenVal.toString());
          }
          if (expiry != null) {
            box.write('tokenExpiry', expiry.toString());
          }
        } else {
          box.write('token', tokenData.toString());
        }
        print("Save Login Response - Successfully stored token: ${box.read('token')}");
      } else {
        print("WARNING: Could not extract token from response: $response");
      }
    }
  }

  static void logOut() {
    box.remove('token');
    box.remove('tokenExpiry');
    box.remove('userData');
    box.write('isLogin', false);
  }

  static dynamic getUserDetails() {
    var userDetails = box.read("userData");
    if (userDetails != null) {
      return userDetails;
    }
  }

  static String? getCurrentUserName() {
    if (!isUserLogin()) return null;
    final userData = getUserDetails();
    if (userData == null) return null;
    final name = userData['name']?.toString().trim();
    if (name != null && name.isNotEmpty) return name;
    return userData['email']?.toString();
  }

  Future<dynamic> updateUserDetailsFromServer() async {
    if (isUserLogin()) {
      var response = await BasicProvider("auth/customer/profile")
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
