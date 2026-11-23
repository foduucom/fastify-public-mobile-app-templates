import 'package:foddu/app/controllers/api_exception_handle_controller.dart';
import 'package:foddu/app/data/basic_provider.dart';
import 'package:foddu/app/data/services/session_service.dart';
import 'package:foddu/app/routes/app_pages.dart';
import 'package:foddu/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DeleteAccountController extends GetxController with BaseController {
  var account_delete = false.obs;
  var isLoading = false.obs;

  Future<void> deleteAccount() async {
    HelperFunctions().showOverlayLoader();
    isLoading.value = true;
    try {
      final response = await BasicProvider("deleteaccount")
          .postRequest(FormData({}))
          .catchError(handleError);
      if (response == null) return;

      final user = GetStorage().read('userData');
      final userId =
          user is Map ? (user['_id'] ?? user['id'])?.toString() : null;
      await SessionService.clearLocalSession();
      SessionService.unsubscribeFromPushInBackground(userId);
      HelperFunctions()
          .showSnackBarSuccess("Your account has been permanently deleted!");
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      HelperFunctions()
          .showSnackBarError('Account deletion failed. Please try again.');
    } finally {
      HelperFunctions().hideOverlayLoader();
      isLoading.value = false;
    }
  }
}
