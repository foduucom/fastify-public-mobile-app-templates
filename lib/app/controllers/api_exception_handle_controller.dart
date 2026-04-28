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
      HelperFunctions().showSnackBarError(message.toString());
    } else if (error is FetchDataException) {
      var message = error.message;
      HelperFunctions().showSnackBarError(message.toString());
    } else if (error is UnAuthorizedException) {
      var message = error.message;
      // if (await FirebaseHelpers().unsubscribeFromAllTopics()) {
      getbox.erase();
      isOtpLogin
          ? Get.offAllNamed(Routes.MOBILELOGIN)
          : Get.offAllNamed(Routes.LOGIN);
      // }
      // Get.find<BottomnavController>().logout();
      HelperFunctions()
          .showSnackBarError("$message Your session seems to be expired!");
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
