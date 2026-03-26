import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
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
    //print("Get Token: $token");
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
    if (response != null) {
      box.write('userData', response);
      box.write('isLogin', true);

      final data = response['data'];

      print("Save Login Response (data.token): ${data?['token']}");

      if (data != null && data['token'] != null) {
        if (data['token'] is Map) {
          box.write('token', data['token']['value']);
          box.write('tokenExpiry', data['token']['expiry']);
        } else {
          box.write('token', data['token']);
        }
      }
    }
  }

  static dynamic getUserDetails() {
    var userDetails = box.read("userData");
    if (userDetails != null) {
      return userDetails;
    }
  }

  Future<dynamic> updateUserDetailsFromServer() async {
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
