import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/app/modules/auth/auth_details.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/app/data/services/notification_service.dart';
import 'package:zouhi/constants/helper_functions.dart';
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

    isLoading.value = true;
    var response = await BasicProvider("auth/customer/profile-delete")
        .getRequest()
        .catchError(handleError);

    print('delete resp9onse ${response}');
    isLoading.value = false;

    if (response != null) {
      await NotificationService.unsubscribeFromAllTopics();
      isLoading.value = false;
      box.erase();
      Get.until((route) => !Get.isDialogOpen!);
      HelperFunctions()
          .showSnackBarSuccess("Your account has been permanently deleted!");
      Get.offAllNamed(Routes.LOGIN);
      return;
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
