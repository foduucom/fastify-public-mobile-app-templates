import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import 'package:get/get.dart';

class AboutusController extends GetxController with BaseController {
  var aboutUsDetials = "".obs;

  Future<void> aboutUsContetn() async {
    var response =
        await BasicProvider("page/about").getRequest().catchError(handleError);
    if (response == null) return;
    if (response != null) {
      aboutUsDetials.value = response["content"];
    }
  }
}
