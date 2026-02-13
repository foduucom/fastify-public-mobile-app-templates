import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:get/get.dart';

class OrdersController extends GetxController with BaseController {
  var isLoading = false.obs;
  var orderList = List<dynamic>.empty().obs;
  var currentPage = 1.obs;
  var maxPage = 1.obs;
  late ScrollController scrollController;

  @override
  Future<void> onInit() async {
    super.onInit();
    scrollController = ScrollController();
    // fetchMoreCategoriesOnScroll();
    await Orders();
  }

  Future<void> Orders() async {
    isLoading.value = true;
    var response = await BasicProvider("public/orders/get/all")
        .getRequest()
        .catchError(handleError);
    if (response == null) return;
    orderList.addAll(response["data"]);
    // maxPage(response["last_page"]);
    isLoading.value = false;
    // print('response===$response');
    // print('orderList===$orderList');
  }

  // Future<void> fetchMoreCategoriesOnScroll() async {
  //   scrollController.addListener(() async {
  //     if (scrollController.position.pixels >=
  //         scrollController.position.maxScrollExtent - 50.0) {
  //       if (!isLoading.value && currentPage.value < maxPage.value) {
  //         currentPage(currentPage.value + 1);
  //         await Orders();
  //       }
  //     }
  //   });
  // }

  void onRefresh() async {
    currentPage.value = 1;
    maxPage.value = 1;
    orderList.clear();
    await Orders();
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
