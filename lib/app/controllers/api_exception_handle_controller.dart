import '/app/modules/auth/auth_details.dart';
import '/app/routes/app_pages.dart';
import '/constants/app_exceptions.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

mixin BaseController {
  var getbox = GetStorage();
  static bool _isHandlingUnauthorized = false;

  Future<void> handleError(error) async {
    if (Get.isDialogOpen ?? false) Get.back();
    if (error is BadRequestException) {
      var message = error.message;
      HelperFunctions().showSnackBarError(message.toString());
    } else if (error is FetchDataException) {
      var message = error.message;
      HelperFunctions().showSnackBarError(message.toString());
    } else if (error is UnAuthorizedException) {
      if (_isHandlingUnauthorized ||
          Get.currentRoute == Routes.LOGIN ||
          Get.currentRoute == Routes.MOBILELOGIN) {
        return;
      }
      _isHandlingUnauthorized = true;
      try {
        AuthDetails.logOut();
        if (isOtpLogin) {
          Get.offAllNamed(Routes.MOBILELOGIN);
        } else {
          Get.offAllNamed(Routes.LOGIN);
        }
        HelperFunctions().showSnackBarError(
            "Your session has expired. Please log in again.");
      } finally {
        Future.delayed(const Duration(seconds: 2), () {
          _isHandlingUnauthorized = false;
        });
      }
    } else if (error is ApiNotRespondingException) {
      // print("------------------");
      // print("------------------");
      // print(error.message);
      // print("------------------");
      // print("------------------");
      // HelperFunctions().showSnackBarError("Oops! It took longer to respond.");
    } else if (error is FetchDataException) {
      var message = error.message;
      HelperFunctions().showSnackBarError(message.toString());
    }
  }
}
