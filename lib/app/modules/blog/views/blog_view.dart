import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '/app/modules/blog/controller/blog_controller.dart';
import '/app/routes/app_pages.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';

import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class BlogView extends GetView<BlogController> {
  BlogView({Key? key}) : super(key: key);
  var controller = Get.put(BlogController());
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text('News'),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              return controller.onRefresh();
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              controller: controller.scrollController,
              child: Padding(
                padding: pageSurroundingPadding,
                child: Obx(
                  () => controller.allnews.isEmpty
                      ? AlignedGridView.count(
                          // cacheExtent: 9999,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: 6,
                          crossAxisCount: 2,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 14,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return AllNewsShimmer();
                          },
                        )
                      : Column(
                          children: [
                            AlignedGridView.count(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: controller.allnews.length,
                                crossAxisCount: 2,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 14,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  print(controller.allnews[index]
                                      ['featured_image']);
                                  return GestureDetector(
                                    onTap: () {
                                      Get.toNamed(Routes.BLOG_DETAILS,
                                          arguments: {
                                            'id': controller.allnews[index]
                                                ['_id']
                                          });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    topRight:
                                                        Radius.circular(10)),
                                            child: Obx(
                                              () => CachedNetworkImage(
                                                  height: 170,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                color: Theme.of(context).colorScheme.surfaceContainerHighest),
                                                        child: const Center(
                                                          child:
                                                              Icon(Icons.error),
                                                        ),
                                                      ),
                                                  // imageUrl: controller
                                                  //             .allnews[index]
                                                  //         ['featured_image'] ??
                                                  //     ''),
                                                  imageUrl: HelperFunctions()
                                                      .getImage(controller
                                                              .allnews[index]
                                                          ['featured_image'])),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                    horizontal: 10, vertical: 0)
                                                .copyWith(top: 5),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Obx(
                                                  () => Text(
                                                    controller.allnews[index]
                                                            ['name'] ??
                                                        '',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    softWrap: true,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: 'lato'),
                                                  ),
                                                ),
                                                Obx(
                                                  () => Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 5),
                                                    child: HtmlWidget(
                                                      controller
                                                                  .allnews[
                                                                      index][
                                                                      'content']
                                                                  .length >
                                                              40
                                                          ? controller.allnews[
                                                                      index][
                                                                      'content']
                                                                  .substring(
                                                                      0, 45) +
                                                              '...'
                                                          : controller.allnews[
                                                              index]['content'],
                                                      textStyle:
                                                          const TextStyle(
                                                        fontSize: 13.0,
                                                        // color: themeTextColor,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                            const SizedBox(height: 20),
                            Obx(() => controller.isLoading.isTrue &&
                                    controller.allnews.isNotEmpty
                                ? HelperFunctions().loadingIndicator()
                                : Container()),
                            const SizedBox(height: 30)
                          ],
                        ),
                ),
              ),
            ),
          )),
    );
  }
}

class AllNewsShimmer extends StatelessWidget {
  const AllNewsShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade600 : Colors.grey.shade100,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            // border: Border.all(color: Colors.grey, width: 1.0),
            borderRadius: BorderRadius.circular(15.0)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  height: 170,
                  width: 180,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 10),
              Container(
                  height: 10,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  width: 150),
              const SizedBox(height: 5),
              Container(
                  height: 10,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  width: 120),
              const SizedBox(height: 5),
              Container(
                  height: 10,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  width: 90),
            ]),
      ),
    );
  }
}
