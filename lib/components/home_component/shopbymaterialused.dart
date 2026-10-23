import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/components/shimmer_effects.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zouhi/constants/theme_ext.dart';

class ShopbyMaterialUsed extends StatefulWidget {
  var productCategoryList;
  var isLoading;
  ShopbyMaterialUsed({
    super.key,
    this.productCategoryList,
    this.isLoading,
  });

  @override
  State<ShopbyMaterialUsed> createState() => _TopCategoryHomeState();
}

class _TopCategoryHomeState extends State<ShopbyMaterialUsed>
    with AutomaticKeepAliveClientMixin, BaseController {
  String getImage(int index) {
    var featuredImage = widget.productCategoryList[index]['featured_image'];
    return HelperFunctions().getImage(featuredImage);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: pageSurroundingPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shop by Material Used',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.themeTextColor),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 100, // Increased height to accommodate wrapped text
            child: widget.isLoading
                ? const CategoryHomeShimmer()
                : ListView.separated(
                    shrinkWrap: false,
                    cacheExtent: 9999,
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.productCategoryList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          BottombarController.switchTab(1, arguments: {
                            'productId': widget.productCategoryList[index]
                                ['_id'],
                            'categorySlug': widget.productCategoryList[index]
                                ['slug'],
                            'name': widget.productCategoryList[index]['name'],
                            'source': 'category'
                          });
                        },
                        child: Column(
                          children: [
                            // Fixed circular container
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color.fromRGBO(
                                      255, 128, 0, 1), // Golden color
                                  width: 2.0, // Border width
                                ),
                              ),
                              child: ClipOval(
                                // ClipOval for circular clipping
                                child: CachedNetworkImage(
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  memCacheWidth:
                                      (70 * MediaQuery.of(context).devicePixelRatio)
                                          .round(),
                                  memCacheHeight:
                                      (70 * MediaQuery.of(context).devicePixelRatio)
                                          .round(),
                                  imageUrl: getImage(index),
                                  errorWidget: ((context, url, error) {
                                    return Container(
                                      color: context.themegreyColor,
                                      child: Icon(
                                        Icons.error,
                                        color: context.themeSecondrytext,
                                      ),
                                    );
                                  }),
                                  progressIndicatorBuilder:
                                      ((context, url, progress) {
                                    return Container(
                                      color: context.themegreyColor,
                                      child: Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: HelperFunctions()
                                              .loadingIndicator(),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              child: Text(
                                widget.productCategoryList[index]['name']
                                    .toString(),
                                style: txtTheme().bodyMedium!.copyWith(color: context.themeTextColor),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(width: 23);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class CategoryHomeShimmer extends StatelessWidget {
  const CategoryHomeShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        enabled: true,
        direction: ShimmerDirection.ltr,
        loop: 0,
        period: const Duration(seconds: 1),
        baseColor: context.isDark ? Colors.grey[800]! : Colors.grey.shade200,
        highlightColor: context.isDark ? Colors.grey[700]! : const Color.fromARGB(255, 197, 197, 197),
        child: ListView.separated(
          itemCount: 10,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (context, index) {
            return const SizedBox(
              width: 10,
            );
          },
          itemBuilder: (context, index) {
            return Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: context.themeWhiteColor,
                    shape: BoxShape.circle,
                  ),
                  width: 70,
                  height: 70,
                ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: context.themeWhiteColor,
                      borderRadius: BorderRadius.circular(4)),
                  width: 40,
                  height: 10,
                ),
              ],
            );
          },
        ));
  }
}

