import 'package:foddu/services/api_cache.dart';
import 'package:foddu/app/controllers/api_exception_handle_controller.dart';
import 'package:foddu/app/data/basic_provider.dart';
import 'package:foddu/app/routes/app_pages.dart';
import 'package:foddu/constants/firebase_notification.dart';
import 'package:foddu/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DeleteAccountController extends GetxController with BaseController {
  var account_delete = false.obs;
  var isLoading = false.obs;
  var box = GetStorage();

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> deleteAccount() async {
    HelperFunctions().showOverlayLoader();

    var form = FormData({});
    isLoading.value = true;
    var response = await BasicProvider("deleteaccount")
        .postRequest(form)
        .catchError(handleError);

    if (response == null) {
      isLoading.value = false;
      return;
    }

    if (await FirebaseHelpers.unsubscribeFromAllTopics()) {
      isLoading.value = false;
      box.erase();
      ApiCache.clear();
      Get.until((route) => !Get.isDialogOpen!);
      HelperFunctions()
          .showSnackBarSuccess("Your account has been permanently deleted!");
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
