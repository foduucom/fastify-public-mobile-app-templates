import 'package:flutter/cupertino.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController with BaseController {
  var categoryList = List<dynamic>.empty().obs;
  late ScrollController scrollController;
  var isLoading = true.obs;
  var currentPage = 1.obs;
  var maxPage = 1.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    scrollController = ScrollController();
    Future.microtask(() {
      initFetchCategories();
    });
    // await fetchMorePostOnScroll();
  }

  Future<void> onPullTorefresh() async {
    currentPage.value = 1;
    maxPage.value = 1;
    categoryList.clear();
    await initFetchCategories();
  }

  @override
  void onReady() {
    super.onReady();
  }

  Future<void> initFetchCategories() async {
    isLoading.value = true;
    categoryList.clear();
    var response = await BasicProvider(
            "category/get-first-parent/products?pagination=false")
        .getRequest()
        .catchError(handleError);
    if (response == null) return;
    categoryList.addAll(response['data']);

    isLoading.value = false;
  }

  @override
  void onClose() {
    scrollController.dispose();
  }
}
