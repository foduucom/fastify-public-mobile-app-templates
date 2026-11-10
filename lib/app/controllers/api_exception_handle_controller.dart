import '/app/data/services/session_service.dart';
import '/app/modules/auth/auth_details.dart';
import '/constants/app_exceptions.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

mixin BaseController {
  var getbox = GetStorage();
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> handleError(error) async {
    // hideLoading();
    if (error is BadRequestException) {
      var message = error.message;
      HelperFunctions().showSnackBarError(message.toString());
    } else if (error is FetchDataException) {
      var message = error.message;
      HelperFunctions().showSnackBarError(message.toString());
    } else if (error is UnAuthorizedException) {
      if (AuthDetails.isUserLogin()) {
        // A 401 only expires an active authenticated session. SessionService
        // owns cleanup and navigation so simultaneous requests cannot race.
        await SessionService.expire(message: error.message);
      } else {
        HelperFunctions().showSnackBarError(
            (error.message != null && error.message!.isNotEmpty)
                ? error.message!
                : "You are not authorized");
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
