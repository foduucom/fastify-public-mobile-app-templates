import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:zouhi/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:get/get.dart';

class HomeBanner extends StatefulWidget {
  var bannerData;
  HomeBanner({super.key, required this.bannerData});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner>
    with AutomaticKeepAliveClientMixin {
  late var homeController;
  int bannerLength = 0;
  String getImage(int index) {
    final featuredImage =
        widget.bannerData['columndata'][index.toString()]['featured_image'];
    if (featuredImage != null) {
      print('url ${url + featuredImage['filepath'].toString()}');
      return url + featuredImage['filepath'].toString();
    }
    return HelperFunctions.getNoImage();
  }

  @override
  void initState() {
    homeController = Get.find<HomepageController>();
    bannerLength = int.parse(widget.bannerData['no_of_columns']);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          bannerLength >= 1
              ? Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      if (widget.bannerData['columndata']['0']['link_type'] ==
                          'product') {
                        Get.toNamed(Routes.PRODUCTDETAILS, arguments: {
                          'productId': widget.bannerData['columndata']['0']
                              ['link']['value']
                        });
                      }
                      if (widget.bannerData['columndata']['0']['link_type'] ==
                          'mobile_app_page') {}
                      if (widget.bannerData['columndata']['0']['link_type'] ==
                          'category') {
                        BottombarController.switchTab(1, arguments: {
                          'source': 'category',
                          'productId': widget.bannerData['columndata']['0']
                              ['link']['value'],
                          'name': widget.bannerData['columndata']['0']['link']
                              ['label']
                        });
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                          fit: BoxFit.cover,

                          // height: 150,
                          memCacheWidth: (MediaQuery.of(context).size.width /
                                  bannerLength *
                                  MediaQuery.of(context).devicePixelRatio)
                              .round(),
                          memCacheHeight:
                              (150 * MediaQuery.of(context).devicePixelRatio)
                                  .round(),
                          imageUrl: getImage(0),
                          progressIndicatorBuilder: (context, url, progress) {
                            return Container(
                              decoration:
                                  BoxDecoration(color: Colors.grey.shade100),
                              child: HelperFunctions().loadingIndicator(),
                            );
                          },
                          errorWidget: ((context, url, error) {
                            return const SizedBox(
                              child: Icon(Icons.error),
                            );
                          })),
                    ),
                  ),
                )
              : Container(),
          bannerLength >= 2
              ? const SizedBox(
                  width: 3,
                )
              : Container(),
          bannerLength >= 2
              ? Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      if (widget.bannerData['columndata']['1']['link_type'] ==
                          'product') {
                        Get.toNamed(Routes.PRODUCTDETAILS, arguments: {
                          'productId': widget.bannerData['columndata']['1']
                              ['link']['value']
                        });
                      }
                      if (widget.bannerData['columndata']['1']['link_type'] ==
                          'mobile_app_page') {}
                      if (widget.bannerData['columndata']['1']['link_type'] ==
                          'category') {
                        BottombarController.switchTab(1, arguments: {
                          'source': 'category',
                          'productId': widget.bannerData['columndata']['1']
                              ['link']['value'],
                          'name': widget.bannerData['columndata']['1']['link']
                              ['label']
                        });
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          // height: 150,
                          memCacheWidth: (MediaQuery.of(context).size.width /
                                  bannerLength *
                                  MediaQuery.of(context).devicePixelRatio)
                              .round(),
                          memCacheHeight:
                              (150 * MediaQuery.of(context).devicePixelRatio)
                                  .round(),
                          imageUrl: getImage(1),
                          errorWidget: ((context, url, error) {
                            return const SizedBox(
                              child: Icon(Icons.error),
                            );
                          })),
                    ),
                  ),
                )
              : Container(),
          bannerLength >= 3
              ? const SizedBox(
                  width: 3,
                )
              : Container(),
          bannerLength >= 3
              ? Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      if (widget.bannerData['columndata']['2']['link_type'] ==
                          'product') {
                        Get.toNamed(Routes.PRODUCTDETAILS, arguments: {
                          'productId': widget.bannerData['columndata']['2']
                              ['link']['value']
                        });
                      }
                      if (widget.bannerData['columndata']['2']['link_type'] ==
                          'mobile_app_page') {}
                      if (widget.bannerData['columndata']['2']['link_type'] ==
                          'category') {
                        BottombarController.switchTab(1, arguments: {
                          'source': 'category',
                          'productId': widget.bannerData['columndata']['2']
                              ['link']['value'],
                          'name': widget.bannerData['columndata']['2']['link']
                              ['name']
                        });
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: getImage(2),
                          memCacheWidth: (MediaQuery.of(context).size.width /
                                  bannerLength *
                                  MediaQuery.of(context).devicePixelRatio)
                              .round(),
                          memCacheHeight:
                              (150 * MediaQuery.of(context).devicePixelRatio)
                                  .round(),
                          // height: 150,
                          errorWidget: ((context, url, error) {
                            return const SizedBox(
                              child: Icon(Icons.error),
                            );
                          })),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
