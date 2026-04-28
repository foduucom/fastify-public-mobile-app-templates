import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:get/get.dart';

class HelpandsupportController extends GetxController with BaseController {
  var faqs = [].obs;
  var subfaqs = [].obs;
  @override
  Future<void> onInit() async {
    super.onInit();
    getFaqs();
  }

  RxInt expandedindex = RxInt(-1);

  void toggleExpansion(int index) {
    if (expandedindex.value == index) {
      expandedindex.value = -1;
    } else {
      expandedindex.value = index;
    }
    update();
  }

  getSubFaq(var subfaq) {
    subfaqs.value = subfaq;
  }

  getFaqs() async {
    try {
      var response = await BasicProvider("frontend/faq")
          .getRequest()
          .catchError(handleError);
      if (response == null) return;
      faqs.clear();
      faqs.addAll(response['data']);
      update();
    } catch (e) {
      print('faq and support error $e');
    }
  }
}
