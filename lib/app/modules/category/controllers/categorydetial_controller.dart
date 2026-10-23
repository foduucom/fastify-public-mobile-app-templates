import 'package:flutter/material.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get_storage/get_storage.dart';

class CategeorydetaiController extends GetxController with BaseController {
  // var productCategoryList = List<dynamic>.empty().obs;
  var isLoading = true.obs;
  var box = GetStorage();
  var arguments = {}.obs;
  var subcategory = [].obs;
  var parentCategor = [].obs;
  var banner = {}.obs;
  late ScrollController scrollController;
  var subId = null;
  var maxPage = 1.obs;
  var currentPage = 1.obs;
  var isParentLoading = false.obs;

  RxInt expandedindex = RxInt(-1);

  void toggleExpansion(int index) {
    if (expandedindex.value == index) {
      expandedindex.value = -1;
    } else {
      expandedindex.value = index;
    }
    update();
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    scrollController = ScrollController();
    arguments.addAll(Get.arguments);

    banner.addAll(arguments['bannerData']);
    getCategoryParent(arguments['id']);
    await fetchCategoryOnScroll();
  }

  Future<void> getCategoryParent(String id) async {
    try {
      isParentLoading.value = true;
      print('parent category id : $id');
      var response = await BasicProvider('category').getRequest(
          queryParams: {'childrenOfParent': id}).catchError(handleError);
      isParentLoading.value = false;
      if (response == null) return;
      print('repsonse of parent category m$response');
      if (response is List) {
        parentCategor.addAll(response);
      } else if (response is Map && response.containsKey('data')) {
        parentCategor.addAll(response['data']);
      }
    } catch (e) {
      isParentLoading.value = false;
      print('error on getting parent categoyr ${e}');
    }
  }

  Future<void> getSubCategory() async {
    try {
      isLoading(true);
      //categories/get-children/$subId?page=${currentPage.value}&count=50
      var response = await BasicProvider(
              'category?childrenOfParent=$subId')
          .getRequest()
          .catchError(handleError);
      if (response is List) {
        subcategory.addAll(response);
      } else if (response is Map && response.containsKey('data')) {
        subcategory.addAll(response['data']);
        maxPage.value = response['last_page'] ?? 1;
      }
      isLoading(false);
    } catch (e) {
      printError(info: 'error in get sub category $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCategoryOnScroll() async {
    print('scroloing  listender');
    scrollController.addListener(() async {
      print(
          'scroll on ${scrollController.position.pixels >= scrollController.position.maxScrollExtent - 50.0}');
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 50.0) {
        if (!isLoading.value && currentPage.value < maxPage.value) {
          currentPage(currentPage.value + 1);

          await getSubCategory();
        }
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}
}
