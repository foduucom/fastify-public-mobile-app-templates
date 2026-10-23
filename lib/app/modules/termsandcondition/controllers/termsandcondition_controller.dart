import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:get/get.dart';

class TermsandconditionController extends GetxController with BaseController {
  var termsAndConditinDetails = "".obs;
  @override
  Future<void> onInit() async {
    super.onInit();
    await termsAndCondition();
  }

  Future<void> termsAndCondition() async {
    var response = await BasicProvider("page/terms-and-condition")
        .getRequest()
        .catchError(handleError);
    if (response == null) return;
    if (response != null) {
      termsAndConditinDetails.value = response['content'];
      print(termsAndConditinDetails);
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
