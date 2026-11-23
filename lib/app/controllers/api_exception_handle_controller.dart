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

  static const _friendlyApiError =
      'We are facing some issue. Please try again in a moment.';

  String _userFacingMessage(
    String? message, {
    String fallback = _friendlyApiError,
  }) {
    final value = message?.trim() ?? '';
    if (value.isEmpty ||
        value.toLowerCase() == 'null' ||
        RegExp(r'<[^>]+>').hasMatch(value)) {
      return fallback;
    }
    return value;
  }

  Future<void> handleError(error) async {
    if (error is BadRequestException) {
      HelperFunctions().showSnackBarError(_userFacingMessage(error.message));
    } else if (error is FetchDataException) {
      HelperFunctions().showSnackBarError(_userFacingMessage(error.message));
    } else if (error is UnAuthorizedException) {
      if (AuthDetails.isUserLogin()) {
        // A 401 only expires an active authenticated session. SessionService
        // owns cleanup and navigation so simultaneous requests cannot race.
        await SessionService.expire(message: error.message);
      } else {
        HelperFunctions().showSnackBarError(_userFacingMessage(
          error.message,
          fallback: 'You are not authorized',
        ));
      }
    } else if (error is ServiceUnavailableException) {
      // ApiHealthService and the reconnecting UI already report this state.
    } else if (error is ApiNotRespondingException) {
      HelperFunctions().showSnackBarError(_userFacingMessage(error.message));
    }
  }
}
