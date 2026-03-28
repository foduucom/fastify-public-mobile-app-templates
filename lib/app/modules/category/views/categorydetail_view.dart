// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '/core/services/wishlistService.dart';
import '/app/modules/bottomar/controllers/bottombar_controller.dart';
import '/app/routes/app_pages.dart';
import '/components/commonWidgets/appbarIcons.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';
import '../../../../../constants/constants.dart';
import '../controllers/categorydetial_controller.dart';

class CategeorydetailView extends GetView<CategeorydetaiController> {
  CategeorydetailView({super.key});

  var controller = Get.put(CategeorydetaiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Categories',
              style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  // color: themeTextColor,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.arrow_forward_ios,
              size: 12,
            ),
            const SizedBox(width: 5),
            Text(
              controller.banner['name'].toString(),
              style: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
        titleSpacing: 0.0,
        leading: Transform.translate(
          offset: const Offset(0, 0),
          child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
              )),
        ),
        // backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Obx(() => Get.find<BottombarController>().cartbadge(
              onTap: () {
                Get.find<BottombarController>().currentPageIndex.value = 3;
                Get.find<BottombarController>().pageController.jumpToPage(3);
              },
              child: HeartIcon(() {
                Get.toNamed(Routes.WISHLIST);
              }),
              badgeNumber: WishListService.to.wishListItemCount)),
          SizedBox(width: 14),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: pageSurroundingPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 15,
                    ),
                    child: Container(
                      height: 81,
                      width: MediaQuery.of(context).size.width,
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20, left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              controller.banner['name'].toString(),
                              style: const TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 25,
                    child: Image.network(
                      HelperFunctions().getImage(controller.banner['image']),
                      height: 95,
                      fit: BoxFit.contain,
                    ),
                    // ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 0-------------------------------------------------------

              Obx(() {
                if (controller.isLoading.value &&
                    controller.parentCategor.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return GetBuilder<CategeorydetaiController>(
                  builder: (controller) {
                    if (controller.parentCategor.isEmpty) {
                      return const Center(
                          child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text("No categories found."),
                      ));
                    }
                    return ListView.builder(
                      padding: EdgeInsets.all(0),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.parentCategor.length,
                      itemBuilder: ((context, index) {
                        return ExpansionPanelList(
                          animationDuration: Duration(milliseconds: 500),
                          elevation: 0,
                          expandedHeaderPadding: EdgeInsets.zero,
                          children: [
                            ExpansionPanel(
                              headerBuilder:
                                  (BuildContext context, bool isExpanded) {
                                return ListTile(
                                  title: Text(
                                    controller.parentCategor[index]['name'],
                                    // 'df',
                                    style: TextStyle(
                                        fontFamily: 'lato',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  onTap: () {
                                    controller.fetchSubcategoriesAndToggle(
                                        index,
                                        controller.parentCategor[index]
                                                ['_id'] ??
                                            '',
                                        controller.parentCategor[index]
                                                ['name'] ??
                                            '');
                                  },
                                );
                              },
                              body: Obx(
                                () => controller.isSubcategoryLoading.value
                                    ? const Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: Center(
                                            child: CircularProgressIndicator()),
                                      )
                                    : Column(
                                        children: [
                                          Divider(
                                            height: 2,
                                          ),
                                          ListView.builder(
                                            shrinkWrap: true,
                                            itemCount:
                                                controller.subcategory.length,
                                            itemBuilder: (context, subindex) {
                                              return GestureDetector(
                                                onTap: () {
                                                  print(controller
                                                      .subcategory[subindex]);
                                                  print(controller
                                                      .subcategory[subindex]);
                                                  if (controller.subcategory[
                                                          subindex]['name'] !=
                                                      'no further category') {
                                                    Get.toNamed(
                                                        Routes
                                                            .SHOPPRODUCTLISTVIEW,
                                                        arguments: {
                                                          'productId': controller
                                                                  .subcategory[
                                                              subindex]['_id'],
                                                          'categorySlug':
                                                              controller.subcategory[
                                                                          subindex]
                                                                      [
                                                                      'slug'] ??
                                                                  '',
                                                          'name': controller
                                                                  .subcategory[
                                                              subindex]['name'],
                                                          'source': 'category'
                                                        });
                                                  }
                                                },
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              40.0,
                                                              10.0,
                                                              10.0,
                                                              10.0),
                                                      child: Text(
                                                        controller.subcategory[
                                                                    subindex]
                                                                ['name'] ??
                                                            '',
                                                        style: TextStyle(
                                                            fontFamily: "Lato"),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          Divider(
                                            height: 2,
                                          ),
                                        ],
                                      ),
                              ),
                              isExpanded:
                                  controller.expandedindex.value == index,
                            ),
                          ],
                          expansionCallback: (int panelIndex, bool isExpanded) {
                            controller.fetchSubcategoriesAndToggle(
                                index,
                                controller.parentCategor[index]['_id'] ?? '',
                                controller.parentCategor[index]['name'] ?? '');
                          },
                        );
                      }),
                    );
                  },
                );
              }),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
