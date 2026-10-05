import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/app_exceptions.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:foduu_ecommerce/services/api_cache.dart';

mixin BaseController {
  var getbox = GetStorage();
  Future<void> handleError(error) async {
    // print error details for debugging
    if (error is AppException) {
      print('❌ Error Caught in BaseController: ${error.message}');
      print('🔗 Error URL: ${error.url}');
      print('🏷️ Prefix: ${error.prefix}');
    }

    HelperFunctions().hideOverlayLoader();
    const friendly = "We are facing some issue, please wait a minute.";
    bool unusable(Object? m) =>
        m == null ||
        m.toString().isEmpty ||
        m.toString().contains('<html>') ||
        m.toString() == "null";

    if (error is BadRequestException) {
      var message = error.message;
      if (unusable(message)) message = friendly;
      HelperFunctions().showSnackBarError(message.toString());
    } else if (error is FetchDataException) {
      var message = error.message;
      if (unusable(message)) message = friendly;
      HelperFunctions().showSnackBarError(message.toString());
    } else if (error is UnAuthorizedException) {
      var message = error.message;
      getbox.erase();
      ApiCache.clear();
      isOtpLogin
          ? Get.offAllNamed(Routes.MOBILELOGIN)
          : Get.offAllNamed(Routes.LOGIN);
      HelperFunctions()
          .showSnackBarError("$message Your session seems to be expired!");
    } else if (error is ServiceUnavailableException) {
      // The reconnecting banner / friendly state already informs the user.
    } else if (error is ApiNotRespondingException) {
      // HelperFunctions().showSnackBarError("Oops! It took longer to respond.");
    } else if (error is FetchDataException) {
      var message = error.message;
      HelperFunctions().showSnackBarError(message.toString());
    }
  }
}
