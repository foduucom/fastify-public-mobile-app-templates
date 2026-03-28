import 'package:flutter/material.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import 'package:get/get.dart';

class BlogController extends GetxController with BaseController {
  var allnews = [].obs;
  late ScrollController scrollController;
  var isLoading = false.obs;

  var currentPage = 1.obs;
  var maxPage = 1.obs;

  @override
  void onInit() async {
    scrollController = ScrollController();

    super.onInit();
    getAllNews();
    fetchProductOnScroll();
  }

  void onRefresh() {
    currentPage.value = 1;
    maxPage.value = 1;
    allnews.clear();
    getAllNews();
  }

  Future<void> getAllNews() async {
    try {
      isLoading.value = true;
      var response = await BasicProvider("blogs?count=10&page=$currentPage")
          .getRequest()
          .catchError(handleError);
      print('new respoinse $response');
      if (response == null) return;
      isLoading.value = false;

      allnews.addAll(response['data']);
      maxPage(response["last_page"]);
    } catch (e) {
      print('vacancy error $e');
    }
  }

  Future<void> fetchProductOnScroll() async {
    scrollController.addListener(() async {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 50.0) {
        if (!isLoading.value && currentPage.value < maxPage.value) {
          currentPage(currentPage.value + 1);

          getAllNews();
        }
      }
    });
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
