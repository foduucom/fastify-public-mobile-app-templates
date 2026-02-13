import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/auth/token_manager.dart';
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
    if (isLogin == true) {
      return true;
    } else {
      return false;
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

  static dynamic getUserDetails() {
    var userDetails = box.read("userData");
    if (userDetails != null) {
      return userDetails;
    }
  }

  dynamic updateUserDetailsFromServer() async {
    if (isUserLogin()) {
      String? userToken = TokenManager.accessToken;
      if (userToken != null) {
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
}
