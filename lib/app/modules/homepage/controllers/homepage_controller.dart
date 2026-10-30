// ignore_for_file: avoid_print

import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../core/foduuStudio/foduu_studio_layout_mixin.dart';

class HomepageController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  var selectcategory = 0.obs;
  var isLoading = true.obs;
  var box = GetStorage();
  final isLogin = false.obs;
  var blogList = [].obs;
  var notificatoinCount = 0.obs;
  var isDrawerNavigationLoading = false.obs;
  var drawernavigationItems = [].obs;
  var dashboardDesign = {}.obs;

  var pageSlug = 'home';

  @override
  Future<void> onInit() async {
    super.onInit();
    getDrawerNavigation();
    await getDashboardDesign(pageSlug);
  }

  Future<dynamic> getDashboardDesign(String slug,
      {dynamic? requestBody}) async {
    try {
      isLoading.value = true;

      var response = await fetchLayout(slug, requestBody: requestBody);

      return response;
    } catch (e) {
      print('home page controller getDashboardDesign error $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<dynamic> getDrawerNavigation() async {
    try {
      isDrawerNavigationLoading(true);

      var response = await BasicProvider("navigation/sidebar")
          .getRequest()
          .catchError(handleError);

      if (response != null) {
        // Handle both 'data' (from BasicProvider) and direct list if applicable
        var list = response is List ? response : (response['value'] ?? response['data'] ?? []);
        drawernavigationItems.assignAll(list is List ? list : []);
      } else {
        print('WARNING: Drawer navigation data is null');
        drawernavigationItems.assignAll([]);
      }

      return response;
    } catch (e) {
      print('home page controller getDrawerNavigation error $e');
    } finally {
      isDrawerNavigationLoading.value = false;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
