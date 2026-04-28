import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:get/get.dart';

class AboutusController extends GetxController with BaseController {
  var aboutUsDetials = "".obs;
  @override
  void onInit() async {
    super.onInit();
  }

  Future<void> aboutUsContetn() async {
    var response =
        await BasicProvider("page/about").getRequest().catchError(handleError);
    if (response == null) return;
    if (response != null) {
      aboutUsDetials.value = response["content"];
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
