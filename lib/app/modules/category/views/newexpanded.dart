// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:get/get.dart';
import '../../../../../constants/constants.dart';
import '../controllers/categorydetial_controller.dart';

class CategeorydetailView2 extends GetView<CategeorydetaiController> {
  CategeorydetailView2({super.key});

  // var categorydetial = Get.arguments;
  // var index = 0;

  var controller = Get.put(CategeorydetaiController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                // color: themeSecondrytext,
              ),
              const SizedBox(width: 5),
              Text(
                controller.banner['name'].toString(),
                style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16,
                    // color: themeSecondrytext,
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
                icon: const Icon(Icons.arrow_back, color: Colors.black)),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: InkWell(
                onTap: () {},
                child: SvgPicture.asset('assets/icon/appbarlike.svg'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: InkWell(
                onTap: () {},
                child: SvgPicture.asset('assets/icon/appbarshop.svg'),
              ),
            ),
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
                        decoration: BoxDecoration(
                            // color: themegreyColor,
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
                                style: const TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 16,
                                    // color: themeTextColor,
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
                      child:
                          //  Obx(
                          // () =>
                          Image.network(
                        controller.banner['image'],
                        // 'http://192.168.1.117:3016/images/2024/3/1710241474039-jeans_img.jpeg',
                        height: 95,
                        fit: BoxFit.contain,
                      ),
                      // ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 0-------------------------------------------------------

                GetBuilder<CategeorydetaiController>(
                  builder: (controller) {
                    print('rebuild');
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
                                    style: TextStyle(
                                        fontFamily: 'lato',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  onTap: () {
                                    controller.toggleExpansion(index);
                                    controller.subcategory.clear();

                                    controller.subcategory.addAll(controller
                                        .parentCategor[index]['children']);

                                    if (controller.subcategory.isEmpty) {
                                      controller.subcategory
                                          .add({'name': 'no further category'});
                                    }
                                  },
                                );
                              },
                              body: Column(
                                children: [
                                  Divider(
                                    height: 2,
                                  ),
                                  Obx(
                                    () => ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: controller.subcategory.length,
                                      itemBuilder: (context, subindex) {
                                        return GestureDetector(
                                          onTap: () {
                                            Get.toNamed(
                                                Routes.SHOPPRODUCTLISTVIEW,
                                                arguments: {
                                                  'productId': controller
                                                          .subcategory[index]
                                                      ['_id'],
                                                  'name': controller
                                                          .subcategory[index]
                                                      ['name']
                                                });
                                          },
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    40.0, 10.0, 10.0, 10.0),
                                                child: Text(
                                                  controller
                                                          .subcategory[subindex]
                                                      ['name'],
                                                  style: TextStyle(
                                                      fontFamily: "Lato"),
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      },
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
                          expansionCallback: (int panelIndex, bool isExpanded) {
                            controller.toggleExpansion(index);

                            controller.subcategory.clear();

                            controller.subcategory.addAll(
                                controller.parentCategor[index]['children']);

                            if (controller.subcategory.isEmpty) {
                              controller.subcategory
                                  .add({'name': 'no further category'});
                            }
                          },
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
