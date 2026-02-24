import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/helpers/socket_helper.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_mixin.dart';

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
  final _socketHelper = SocketHelper();
  var dashboardDesign = {}.obs;
  var pageSlug = 'home';

  // Created By
  RxInt currentIndex = 0.obs;
  // Created By
  void changeTab(int index) {
    currentIndex.value = index;
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    getDrawerNavigation();
    await getDashboardDesign(pageSlug);
    if (kIsWeb) {
      _socketHelper.connect();
    }
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
        var list = response['value'];
        drawernavigationItems.assignAll(list);
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
    if (kIsWeb) {
      _socketHelper.off('dashboard-update-69708c1b6968f244e799ea6a');
    }
    super.onClose();
  }
}
