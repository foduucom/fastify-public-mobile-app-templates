import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:get/get.dart';

class HelpandsupportController extends GetxController with BaseController {
  var isLoading = false.obs;
  var faqs = [].obs;
  RxInt expandedIndex = RxInt(-1);

  @override
  void onInit() {
    super.onInit();
    getFaqs();
  }

  void toggleExpansion(int index) {
    if (expandedIndex.value == index) {
      expandedIndex.value = -1;
    } else {
      expandedIndex.value = index;
    }
  }

  Future<void> getFaqs() async {
    try {
      isLoading.value = true;
      var response = await BasicProvider("frontend/faq")
          .getRequest()
          .catchError(handleError);
      isLoading.value = false;
      if (response == null) return;
      faqs.clear();
      if (response is List) {
        faqs.addAll(response);
      } else if (response is Map) {
        final data = response['data'] ?? response['faqs'] ?? response['docs'];
        if (data is List) {
          faqs.addAll(data);
        }
      }
    } catch (e) {
      isLoading.value = false;
      print('faq and support error $e');
    }
  }
}
