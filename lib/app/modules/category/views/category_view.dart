import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foduu_ecommerce/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/categoryshimmer.dart';
import 'package:foduu_ecommerce/components/commonWidgets/appbarIcons.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';

class CategoryView extends GetView<CategoryController> {
  CategoryView({Key? key}) : super(key: key);

  final categoryController =
      Get.lazyPut<CategoryController>(() => CategoryController());

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    var height = Get.height;
    var width = Get.width;

    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            controller.initFetchCategories();
          },
          child: Icon(Icons.add),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            controller.onPullTorefresh();
          },
          color: colorScheme.primary,
          child: SingleChildScrollView(
            controller: controller.scrollController,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.02,
              ),
              child: Obx(() {
                if (controller.categoryList.isEmpty) {
                  return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: CategoryShimmer(
                            index: index,
                          )),
                      itemCount: 5);
                } else {
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) =>
                        SizedBox(height: height * 0.03),
                    itemCount: controller.categoryList.length,
                    itemBuilder: ((context, index) {
                      final category = controller.categoryList[index];
                      final hasChildren =
                          (category['children'] as List).isNotEmpty;

                      return Center(
                        child: Material(
                          borderRadius: BorderRadius.circular(height * 0.015),
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => hasChildren
                                ? _showCategoryDialog(category)
                                : Get.toNamed(Routes.SHOPPRODUCTLISTVIEW,
                                    arguments: {
                                        'productId': category['_id'],
                                        'name': category['name'],
                                        'source': 'category'
                                      }),
                            borderRadius: BorderRadius.circular(height * 0.015),
                            splashColor: Colors.white.withOpacity(0.3),
                            highlightColor: Colors.white.withOpacity(0.1),
                            child: Container(
                              width: width * 0.92,
                              height: height * 0.12,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(height * 0.015),
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    HelperFunctions()
                                        .getImage(category['featured_image']),
                                  ),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(0.3),
                                    BlendMode.darken,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.04),
                                  child: Text(
                                    category['name'].toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: height * 0.025,
                                      fontWeight: FontWeight.w600,
                                      height: 1.6,
                                      color: DefaultThemeColors.lightOnPrimary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }
              }),
            ),
          ),
        ),
      ),
    );
  }

  void _showCategoryDialog(Map<String, dynamic> category) {
    final width = Get.width;
    final height = Get.height;
    final children = category['children'] as List;

    // If no children, don't show dialog, navigate directly
    if (children.isEmpty) {
      Get.toNamed(Routes.SHOPPRODUCTLISTVIEW, arguments: {
        'productId': category['_id'],
        'name': category['name'],
        'source': 'category'
      });
      return;
    }

    // Use Get.dialog instead of Get.defaultDialog to have more control
    Get.dialog(
      Dialog(
        backgroundColor: DefaultThemeColors.lightOnPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(height * 0.015),
        ),
        child: Container(
          width: width * 0.92,
          constraints: BoxConstraints(
            maxHeight: height * 0.7,
          ),
          padding: EdgeInsets.all(width * 0.053),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      category['name'].toString(),
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: height * 0.02,
                        fontWeight: FontWeight.w600,
                        height: 1.75,
                        color: DefaultThemeColors.lightOnSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.close,
                      size: height * 0.027,
                      color: DefaultThemeColors.lightOnSecondary,
                    ),
                  ),
                ],
              ),

              SizedBox(height: height * 0.02),

              // Category image
              Container(
                width: double.infinity,
                height: height * 0.12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(height * 0.015),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      HelperFunctions().getImage(category['featured_image']),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SizedBox(height: height * 0.02),

              // Subcategories list
              Text(
                'Subcategories',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: height * 0.018,
                  fontWeight: FontWeight.w600,
                  color: DefaultThemeColors.lightOnSecondary,
                ),
              ),

              SizedBox(height: height * 0.001),

              Flexible(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: children.length,
                  shrinkWrap: true,
                  separatorBuilder: (_, __) => SizedBox(height: height * 0.005),
                  itemBuilder: (context, index) {
                    final childCategory = children[index];
                    return InkWell(
                      onTap: () {
                        Get.back();
                        Get.toNamed(Routes.SHOPPRODUCTLISTVIEW, arguments: {
                          'productId': childCategory['_id'],
                          'name': childCategory['name'],
                          'source': 'category'
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: height * 0.005,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                childCategory['name'].toString(),
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: height * 0.016,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                  color: DefaultThemeColors.darkmain,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              size: height * 0.022,
                              color: DefaultThemeColors.darkmain,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
