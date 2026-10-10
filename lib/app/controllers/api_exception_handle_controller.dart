import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/app_exceptions.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/app/data/services/session_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:foduu_ecommerce/services/api_cache.dart';

mixin BaseController {
  var getbox = GetStorage();
  Future<void> handleError(error) async {
    print('🚨 BaseController.handleError: $error');
    if (error is Error) {
      print('🚨 STACKTRACE:\n${error.stackTrace}');
    } else {
      print('🚨 STACKTRACE:\n${StackTrace.current}');
    }
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
      // One idempotent teardown + single navigation, however many requests
      // fail with 401 at the same time.
      await SessionService.expire(message: error.message);
    } else if (error is ServiceUnavailableException) {
      // The reconnecting banner / friendly state already informs the user.
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
