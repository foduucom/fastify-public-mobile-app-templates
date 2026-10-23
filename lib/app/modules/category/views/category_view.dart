import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/categoryshimmer.dart';
import 'package:zouhi/components/commonWidgets/appbarIcons.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/theme_ext.dart';

import '../controllers/category_controller.dart';

class CategoryView extends GetView<CategoryController> {
  CategoryView({Key? key}) : super(key: key);

  final categoryController =
      Get.lazyPut<CategoryController>(() => CategoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Category",
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
        centerTitle: true,
        titleSpacing: 0,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.onPullTorefresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: controller.scrollController,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                10, 20, 10, 10), // Added top padding for better spacing
            child: Obx(() {
              if (controller.categoryList.isEmpty) {
                return GridView.builder(
                  // Changed to GridView
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Changed to 3 items per row
                    crossAxisSpacing: 12, // Reduced spacing horizontally
                    mainAxisSpacing: 20, // Spacing between items vertically
                    childAspectRatio: 0.71,   // From 75
                  ),
                  itemBuilder: (context, index) =>
                      CategoryShimmer(index: index),
                  itemCount: 6, // Show 6 shimmer items (3 rows of 2)
                );
              } else {
                return GridView.builder(
                  // Changed to GridView
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Changed to 3 items per row
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.71,   // From 75
                  ),
                  itemCount: controller.categoryList.length,
                  itemBuilder: ((context, index) {
                    // This is just a placeholder to demonstrate the new UI structure.
                    // You'll need to adapt the actual data and routing logic here.
                    String categoryName =
                        controller.categoryList[index]['name'];
                    String imageUrl = controller.getImage(index);

                    return GestureDetector(
                      onTap: () {
                        final catItem = controller.categoryList[index];
                        final catName = catItem['name']?.toString() ?? 'Category';
                        final slug = (catItem['slug'] ?? '').toString().toLowerCase();
                        if (slug == 'cable-assemblies' ||
                            catName.toLowerCase().contains('cable assembl')) {
                          Get.toNamed(Routes.CABLE_ASSEMBLIES);
                          return;
                        }
                        if (slug == 'mtp-solution' ||
                            slug.contains('mtp') ||
                            catName.toLowerCase().contains('mtp')) {
                          Get.toNamed(Routes.MTP_SOLUTION);
                          return;
                        }
                        Get.toNamed(Routes.CATEGORYPRODUCTS, arguments: {
                          'categoryId': catItem['_id'],
                          'name': catName,
                          'children': catItem['children'],
                        });
                      },
                      child: Column(
                        children: [
                          Container(
                            width:
                                Get.width * 0.28, // Adjusted width for 3 items
                            height: Get.width * 0.28, // Making it a square
                            decoration: BoxDecoration(
                              shape: BoxShape
                                  .circle, // Circular shape for the image
                              border: Border.all(
                                  color: themePrimaryColor,
                                  width: 2), // Golden border
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    const Center(
                                  child: Icon(Icons.error),
                                ),
                                progressIndicatorBuilder:
                                    (context, url, progress) => Center(
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: HelperFunctions().loadingIndicator(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                              height: 10), // Spacing between image and text
                          Expanded(
                            child: Text(
                              categoryName.toUpperCase(),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: context.themeTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                );
              }
            }),
          ),
        ),
      ),
    );
  }
}
