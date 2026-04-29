// lib/app/modules/explore/controllers/explore_controller.dart

import 'package:get/get.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';

class ExploreController extends GetxController with BaseController {
  var isLoading = false.obs;
  var searchQuery = ''.obs;
  var nearbyStores = <Map<String, dynamic>>[].obs;
  var otherStores = <Map<String, dynamic>>[].obs;
  var currentBannerIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStores();
  }

  Future<void> fetchStores() async {
    try {
      isLoading(true);
      // var response = await BasicProvider('stores/nearby')
      //     .getRequest()
      //     .catchError(handleError);

      // if (response != null) {
      //   nearbyStores.assignAll(response['nearby'] ?? []);
      //   otherStores.assignAll(response['others'] ?? []);
      // }
    } catch (e) {
      print('ExploreController fetchStores error: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> onRefresh() async => await fetchStores();
}
