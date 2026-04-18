import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/components/home_component/home_category.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_view.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';

class CategoryView extends GetView<CategoryController> {
  CategoryView({Key? key}) : super(key: key);

  final categoryController =
      Get.lazyPut<CategoryController>(() => CategoryController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FoduuStudioLayoutView(
          onRefresh: () async {
            await controller.onPullTorefresh();
          },
          widgetList: controller.widgetList,
          isLoading: controller.isLayoutLoading,
          loadingWidget: const CategoryPageShimmer(),
        ),
      ),
    );
  }
}
