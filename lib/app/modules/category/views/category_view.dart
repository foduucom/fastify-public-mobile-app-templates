import 'package:flutter/material.dart';
import '/core/foduuStudio/foduu_studio_layout_view.dart';
import '/core/services/wishlistService.dart';
import '/app/modules/bottomar/controllers/bottombar_controller.dart';
import '/app/modules/wishlist/controllers/wishlist_controller.dart';
import '/components/commonWidgets/appbarIcons.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';

class CategoryView extends GetView<CategoryController> {
  CategoryView({Key? key}) : super(key: key);

  final categoryController =
      Get.lazyPut<CategoryController>(() => CategoryController());

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Categories",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'lato',
              ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          Obx(() => Get.find<BottombarController>().cartbadge(
              child: HeartIcon(() {
                Get.find<BottombarController>().currentPageIndex.value = 3;
                Get.find<BottombarController>().pageController.jumpToPage(3);
              }),
              badgeNumber: WishListService.to.wishListItemCount)),
          const SizedBox(width: 14),
        ],
      ),
      body: FoduuStudioLayoutView(
        onRefresh: () async {
          await controller.onPullTorefresh();
        },
        widgetList: controller.widgetList,
        isLoading: controller.isLayoutLoading,
      ),
    );
  }
}
