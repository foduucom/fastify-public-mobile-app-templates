import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/app_exceptions.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

mixin BaseController {
  var getbox = GetStorage();
  Future<void> handleError(error) async {
    // print error details for debugging
    if (error is AppException) {
      print('❌ Error Caught in BaseController: ${error.message}');
      print('🔗 Error URL: ${error.url}');
      print('🏷️ Prefix: ${error.prefix}');
    }

    if (error is BadRequestException) {
      var message = error.message;
      HelperFunctions().showSnackBarError(message.toString());
    } else if (error is FetchDataException) {
      var message = error.message;
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
      // HelperFunctions().showSnackBarError("Oops! It took longer to respond.");
    } else if (error is FetchDataException) {
      var message = error.message;
      HelperFunctions().showSnackBarError(message.toString());
    }
  }
}
