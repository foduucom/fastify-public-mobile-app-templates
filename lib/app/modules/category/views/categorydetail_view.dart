// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/commonWidgets/appbarIcons.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:get/get.dart';
import '../../../../../constants/constants.dart';
import 'package:zouhi/components/product_image_placeholder.dart';
import '../controllers/categorydetial_controller.dart';

class CategeorydetailView extends GetView<CategeorydetaiController> {
  CategeorydetailView({super.key});

  // var categorydetial = Get.arguments;
  // var index = 0;

  var controller = Get.put(CategeorydetaiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Categories',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: context.themeTextColor,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 5),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: context.themeSecondrytext,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                controller.banner['name'].toString(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: context.themeSecondrytext,
                    fontWeight: FontWeight.w600),
              ),
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
              icon: Icon(Icons.arrow_back, color: context.colors.onSurface)),
        ),
        // backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Obx(() => Get.find<BottombarController>().cartbadge(
              onTap: () {
                BottombarController.switchTab(3);
              },
              child: HeartIcon(() {
                BottombarController.switchTab(3);
              }),
              badgeNumber: Get.find<WishlistController>().wishList.length)),
          SizedBox(width: 14),
          // Padding(
          //   padding: const EdgeInsets.only(right: 12.0),
          //   child: InkWell(
          //     onTap: () {},
          //     child: SvgPicture.asset('assets/icon/appbarshop.svg'),
          //   ),
          // ),
        ],
      ),
      body: SingleChildScrollView(
        controller: controller.scrollController,
        physics: AlwaysScrollableScrollPhysics(),
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
                      decoration: BoxDecoration(
                          color: context.themegreyColor,
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20, left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Obx(
                            // () =>
                            Text(
                              controller.banner['name'].toString(),
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: context.themeTextColor,
                                  fontWeight: FontWeight.w600),
                            ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 25,
                    child: controller.banner['image'] != null
                        ? Container(
                            height: 95,
                            width: 80,
                            color: Colors.blue,
                            child: Image.network(
                              controller.banner['image'],
                              height: 35,
                              width: 20,
                              fit: BoxFit.contain,
                            ),
                          )
                        : const SizedBox(
                            height: 95,
                            width: 80,
                            child: ProductImagePlaceholder(radius: 8),
                          ),
                    // ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 0-------------------------------------------------------

              GetBuilder<CategeorydetaiController>(
                builder: (controller) {
                  return Obx(
                    () => controller.isParentLoading.value
                        ? SizedBox(
                            height: Get.height / 2,
                            child: HelperFunctions().loadingIndicator())
                        : ListView.builder(
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
                                    headerBuilder: (BuildContext context,
                                        bool isExpanded) {
                                      return ListTile(
                                        title: Text(
                                          controller.parentCategor[index]
                                              ['name'],
                                          // index.toString(),
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        onTap: () {},
                                      );
                                    },
                                    body: Column(
                                      children: [
                                        Divider(
                                          height: 2,
                                        ),
                                        Obx(
                                          () => Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              if (controller.subcategory.isEmpty)
                                                Container()
                                              else if (controller.subcategory.length == 1 &&
                                                  controller.subcategory[0]['name'] ==
                                                      'no further category')
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                      vertical: 20),
                                                  child: Center(
                                                    child: Text(
                                                      'No subcategories available',
                                                      style: TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontSize: 14,
                                                          color: context
                                                              .themeSecondrytext),
                                                    ),
                                                  ),
                                                )
                                              else
                                                SizedBox(
                                                  height: 140,
                                                  child: ListView.separated(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            vertical: 5,
                                                            horizontal: 12),
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount: controller
                                                        .subcategory.length,
                                                    separatorBuilder:
                                                        (context, index) =>
                                                            const SizedBox(
                                                                width: 23),
                                                    itemBuilder: (context, subindex) {
                                                      var subCat = controller
                                                          .subcategory[subindex];
                                                      String imageUrl =
                                                          HelperFunctions()
                                                              .getImage(
                                                                  subCat[
                                                                      'featured_image'],
                                                                  moduleName:
                                                                      'categories');

                                                      return GestureDetector(
                                                        onTap: () {
                                                          if (subCat['name'] !=
                                                              'no further category') {
                                                            Get.toNamed(
                                                                Routes
                                                                    .SHOPPRODUCTLISTVIEW,
                                                                arguments: {
                                                                  'productId':
                                                                      subCat[
                                                                          '_id'],
                                                                  'categorySlug':
                                                                      subCat[
                                                                          'slug'],
                                                                  'name':
                                                                      subCat[
                                                                          'name'],
                                                                  'source':
                                                                      'category'
                                                                });
                                                          }
                                                        },
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              width: 76,
                                                              height: 76,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                border: Border.all(
                                                                  color: const Color
                                                                      .fromRGBO(
                                                                      255,
                                                                      128,
                                                                      0,
                                                                      1),
                                                                  width: 2.0,
                                                                ),
                                                              ),
                                                              child: ClipOval(
                                                                child: Container(
                                                                  width: 70,
                                                                  height: 70,
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            203,
                                                                            212,
                                                                            233),
                                                                  ),
                                                                  child: ClipOval(
                                                                    child:
                                                                        CachedNetworkImage(
                                                                      width: 70,
                                                                      height: 70,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      imageUrl:
                                                                          imageUrl,
                                                                      errorWidget:
                                                                          ((context,
                                                                              url,
                                                                              error) {
                                                                        return const Center(
                                                                          child:
                                                                              Icon(
                                                                            Icons
                                                                                .error,
                                                                            color:
                                                                                Colors.grey,
                                                                          ),
                                                                        );
                                                                      }),
                                                                      progressIndicatorBuilder:
                                                                          ((context,
                                                                              url,
                                                                              progress) {
                                                                        return Center(
                                                                          child:
                                                                              SizedBox(
                                                                            width:
                                                                                20,
                                                                            height:
                                                                                20,
                                                                            child:
                                                                                HelperFunctions().loadingIndicator(),
                                                                          ),
                                                                        );
                                                                      }),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 5),
                                                            SizedBox(
                                                              width: 76,
                                                              child: Text(
                                                                subCat['name']
                                                                    .toString(),
                                                                style: txtTheme()
                                                                    .bodyMedium,
                                                                textAlign: TextAlign
                                                                    .center,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              Obx(() =>
                                                  controller.isLoading.isTrue
                                                      ? SizedBox(
                                                          height: 50,
                                                          child: HelperFunctions()
                                                              .loadingIndicator(),
                                                        )
                                                      : Container()),
                                            ],
                                          ),
                                        ),
                                        Divider(
                                          height: 2,
                                        ),
                                      ],
                                    ),
                                    isExpanded:
                                        controller.expandedindex.value == index,
                                  ),
                                ],
                                expansionCallback:
                                    (int panelIndex, bool isExpanded) async {
                                  printInfo(
                                      info: 'boos is expanded ${isExpanded}');
                                  controller.toggleExpansion(index);

                                  controller.subcategory.clear();
                                  controller.currentPage.value = 1;
                                  controller.maxPage.value = 1;
                                  if (isExpanded) {
                                    controller.subId =
                                        controller.parentCategor[index]['_id'];

                                    var data =
                                        await controller.getSubCategory();

                                    if (controller.subcategory.isEmpty) {
                                      controller.subcategory
                                          .add({'name': 'no further category'});
                                    }
                                  }
                                },
                              );
                            }),
                          ),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
