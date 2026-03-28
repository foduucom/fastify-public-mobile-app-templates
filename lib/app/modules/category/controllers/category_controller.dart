import 'package:flutter/cupertino.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/core/foduuStudio/foduu_studio_layout_mixin.dart';
import '/app/data/basic_provider.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  var categoryList = List<dynamic>.empty().obs;
  late ScrollController scrollController;
  var currentPage = 1.obs;
  var maxPage = 1.obs;

  var pageSlug = 'category';

  @override
  Future<void> onInit() async {
    super.onInit();
    scrollController = ScrollController();

    await fetchLayout(pageSlug);
  }

  Future<void> onPullTorefresh() async {
    currentPage.value = 1;
    maxPage.value = 1;
    categoryList.clear();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    scrollController.dispose();
  }
}
