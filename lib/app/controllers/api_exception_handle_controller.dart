import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/app_exceptions.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

mixin BaseController {
  var getbox = GetStorage();
  Future<void> handleError(error) async {
    HelperFunctions().hideOverlayLoader();
    if (error is BadRequestException) {
      var message = error.message;
      if (message == null || message.toString().isEmpty || message.toString().contains('<html>') || message.toString() == "null") {
        message = "We are facing some issue, please wait a minute.";
      }
      HelperFunctions().showSnackBarError(message.toString());
    } else if (error is FetchDataException) {
      var message = error.message;
      if (message == null || message.toString().isEmpty || message.toString().contains('<html>') || message.toString() == "null") {
        message = "We are facing some issue, please wait a minute.";
      }
      HelperFunctions().showSnackBarError(message.toString());
    } else if (error is UnAuthorizedException) {
      var message = error.message;
      getbox.erase();
      isOtpLogin
          ? Get.offAllNamed(Routes.MOBILELOGIN)
          : Get.offAllNamed(Routes.LOGIN);
      HelperFunctions()
          .showSnackBarError("$message Your session seems to be expired!");
    } else if (error is ApiNotRespondingException) {
      HelperFunctions().showSnackBarError("We are facing some issue, please wait a minute.");
    } else {
      final errorStr = error.toString();
      if (errorStr.contains('FormatException') || errorStr.contains('<html>') || errorStr.contains('502') || errorStr.contains('500') || errorStr.contains('Connection refused')) {
        HelperFunctions().showSnackBarError("We are facing some issue, please wait a minute.");
      } else {
        HelperFunctions().showSnackBarError(errorStr);
      }
    }
  }
}
