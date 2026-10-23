import 'package:flutter/cupertino.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
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
    await initFetchCategories();
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

  String getImage(int index) {
    if (index >= categoryList.length) return HelperFunctions.getNoImage();
    final category = categoryList[index];
    if (category is! Map) return HelperFunctions.getNoImage();
    var featuredImage = category['featured_image'] ??
        category['featured_image_url'] ??
        category['featured_image_icon'];

    if (featuredImage != null) {
      final img = HelperFunctions().getImage(
        featuredImage,
      );
      if (img.isNotEmpty) {
        return img;
      }
    }

    return HelperFunctions.getNoImage();
  }

  Future<void> initFetchCategories() async {
    isLoading.value = true;
    //categories/featureCategory
    var response = await BasicProvider("category/featured")
        .getRequest()
        .catchError(handleError);

    // print('response response category')

    if (response != null) {
      if (response is List) {
        categoryList.addAll(response);
      } else if (response is Map && response['data'] is List) {
        categoryList.addAll(response['data']);
        if (response['current_page'] != null) {
          currentPage.value = response['current_page'];
        }
        if (response['last_page'] != null) {
          maxPage.value = response['last_page'];
        }
      }
    }

    isLoading.value = false;
  }

  // Future<void> fetchMorePostOnScroll() async {
  //   scrollController.addListener(() async {
  //     if (scrollController.position.pixels >=
  //         scrollController.position.maxScrollExtent - 50.0) {
  //       if (!isLoading.value && currentPage.value < maxPage.value) {
  //         currentPage(currentPage.value + 1);
  //         await initFetchCategories();
  //       }
  //     }
  //   });
  // }

  @override
  void onClose() {
    scrollController.dispose();
  }
}
