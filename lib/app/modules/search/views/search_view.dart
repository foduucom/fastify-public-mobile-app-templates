import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/search_bar_rounded.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/theme.dart';
import 'package:get/get.dart';

import '../controllers/search_controller.dart';

class SearchView extends GetView<SearchsController> {
  const SearchView({Key? key}) : super(key: key);

  // In SearchView.dart, update the getImage method to use controller
  String getImage(int index) {
    try {
      if (index < 0 || index >= controller.trendingCategoryProduct.length) {
        return HelperFunctions.getNoImage();
      }

      final product = controller.trendingCategoryProduct[index];
      return controller.getProductImage(product);
    } catch (e) {
      print('Error in getImage: $e');
      return HelperFunctions.getNoImage();
    }
  }

// Also update the _buildImageUrl method
  String _buildImageUrl(dynamic item) {
    return controller.getProductImage(item);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HelperFunctions().closeKeyboard(context),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            titleSpacing: 15,
            title: SizedBox(
              height: Get.height * 0.05,
              child: SearchBarRounded(
                icon: Icons.arrow_back_ios,
                searchHintText: "Search...",
                SearchsController: controller.searchTextController,
                onChanged: (value) {
                  controller.serachData.clear();
                  controller.searchBlog.clear();
                  controller.searchCategory.clear();
                  controller.searchProduct.clear();
                  if (value.isNotEmpty && value.length > 2) {
                    controller.getSearchSuggestion(text: value);
                  }
                },
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: pageSurroundingPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () {
                      return controller.searchProduct.isNotEmpty ||
                              controller.searchCategory.isNotEmpty ||
                              controller.searchBlog.isNotEmpty
                          ? Container()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                controller.recentSearchList.isNotEmpty
                                    ? Text(
                                        "Recent Search",
                                        style: txtTheme()
                                            .headlineSmall!
                                            .copyWith(
                                                fontWeight: FontWeight.bold),
                                      )
                                    : Container(),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount:
                                      controller.recentSearchList.length >= 4
                                          ? 4
                                          : controller.recentSearchList.length,
                                  itemBuilder: (context, index) => Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            if (controller
                                                        .recentSearchList[index]
                                                    ['type'] ==
                                                'product') {
                                              Get.toNamed(Routes.PRODUCTDETAILS,
                                                  arguments: {
                                                    'productId': controller
                                                            .recentSearchList[
                                                        index]['productId'],
                                                  });
                                            } else if (controller
                                                        .recentSearchList[index]
                                                    ['type'] ==
                                                'category') {
                                              print('ont tap');
                                              print(
                                                  'recent ${controller.recentSearchList}');
                                              Get.toNamed(
                                                  Routes.SHOPPRODUCTLISTVIEW,
                                                  arguments: {
                                                    'productId': controller
                                                            .recentSearchList[
                                                        index]['productId'],
                                                    'source': 'category',
                                                    'name': controller
                                                            .recentSearchList[
                                                        index]['name']
                                                  });
                                            } else if (controller
                                                        .recentSearchList[index]
                                                    ['type'] ==
                                                'blog') {
                                              Get.toNamed(Routes.BLOG,
                                                  arguments: controller
                                                          .recentSearchList[
                                                      index]['productId']);
                                            }
                                          },
                                          child: Row(
                                            children: [
                                              Icon(Icons.access_time, size: 20),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                    controller.recentSearchList[
                                                            index]['name'] ??
                                                        '',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: txtTheme()
                                                        .titleLarge!
                                                        .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor)),
                                              ),
                                              const Spacer(),
                                              GestureDetector(
                                                onTap: () {
                                                  controller.recentSearchList
                                                      .removeAt(index);
                                                  controller.box.write(
                                                      'recentSearch',
                                                      controller
                                                          .recentSearchList);
                                                },
                                                child: const Icon(
                                                  Icons
                                                      .highlight_remove_outlined,
                                                  size: 24,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                    },
                  ),
                  Obx(
                    () {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          controller.searchProduct.isNotEmpty
                              ? Text(
                                  "Products",
                                  style: txtTheme()
                                      .headlineSmall!
                                      .copyWith(fontWeight: FontWeight.bold),
                                )
                              : Container(),
                          ListView.separated(
                            shrinkWrap: true,
                            itemCount: controller.searchProduct.length > 3
                                ? 3
                                : controller.searchProduct.length,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return ListTile(
                                onTap: () {
                                  controller.recentSearchList.add({
                                    'productId': controller.searchProduct[index]
                                        ['_id'],
                                    'name': controller.searchProduct[index]
                                        ['name'],
                                    'type': 'product'
                                  });
                                  controller.box.write(
                                      'recentSearch',
                                      controller.recentSearchList
                                          .toSet()
                                          .toList());
                                  Get.toNamed(Routes.PRODUCTDETAILS,
                                      arguments: {
                                        'productId': controller
                                            .searchProduct[index]['_id']
                                      });
                                },
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    progressIndicatorBuilder: (context, url,
                                            progress) =>
                                        HelperFunctions().loadingIndicator(),
                                    width: 45,
                                    height: 45,
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.low,
                                    errorWidget: ((context, url, error) {
                                      return const SizedBox(
                                        child: Icon(Icons.error),
                                      );
                                    }),
                                    imageUrl: _buildImageUrl(
                                        controller.searchProduct[index]),
                                  ),
                                ),
                                title: Text(
                                  controller.searchProduct[index]['name'],
                                  style: txtTheme().titleLarge!.copyWith(),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox(
                                height: 10,
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  Obx(
                    () {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          controller.searchCategory.isNotEmpty
                              ? Text(
                                  "Category",
                                  style: txtTheme()
                                      .headlineSmall!
                                      .copyWith(fontWeight: FontWeight.bold),
                                )
                              : Container(),
                          ListView.separated(
                            shrinkWrap: true,
                            itemCount: controller.searchCategory.length > 3
                                ? 3
                                : controller.searchCategory.length,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return ListTile(
                                onTap: () {
                                  controller.recentSearchList.add({
                                    'productId':
                                        controller.searchCategory[index]['_id'],
                                    'name': controller.searchCategory[index]
                                        ['name'],
                                    'type': 'category'
                                  });
                                  controller.box.write(
                                      'recentSearch',
                                      controller.recentSearchList
                                          .toSet()
                                          .toList());

                                  Get.toNamed(Routes.SHOPPRODUCTLISTVIEW,
                                      arguments: {
                                        'productId': controller
                                            .searchCategory[index]['_id'],
                                        'name': controller.searchCategory[index]
                                            ['name'],
                                        'source': 'category',
                                      });
                                },
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    progressIndicatorBuilder: (context, url,
                                            progress) =>
                                        HelperFunctions().loadingIndicator(),
                                    width: 45,
                                    height: 45,
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.low,
                                    errorWidget: ((context, url, error) {
                                      return const SizedBox(
                                        child: Icon(Icons.error),
                                      );
                                    }),
                                    imageUrl: _buildImageUrl(
                                        controller.searchCategory[index]),
                                  ),
                                ),
                                title: Text(
                                  controller.searchCategory[index]['name'],
                                  style: txtTheme().titleLarge!.copyWith(),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox(
                                height: 10,
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  Obx(
                    () {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          controller.searchBlog.isNotEmpty
                              ? Text(
                                  "Blogs",
                                  style: txtTheme()
                                      .headlineSmall!
                                      .copyWith(fontWeight: FontWeight.bold),
                                )
                              : Container(),
                          ListView.separated(
                            shrinkWrap: true,
                            itemCount: controller.searchBlog.length > 3
                                ? 3
                                : controller.searchBlog.length,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return ListTile(
                                onTap: () {
                                  controller.recentSearchList.add({
                                    'productId': controller.searchBlog[index]
                                        ['_id'],
                                    'name': controller.searchBlog[index]
                                        ['name'],
                                    'type': 'blog'
                                  });
                                  controller.box.write(
                                      'recentSearch',
                                      controller.recentSearchList
                                          .toSet()
                                          .toList());
                                  Get.toNamed(Routes.BLOG,
                                      arguments: controller.searchBlog[index]
                                          ['_id']);
                                },
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    progressIndicatorBuilder: (context, url,
                                            progress) =>
                                        HelperFunctions().loadingIndicator(),
                                    width: 45,
                                    height: 45,
                                    fit: BoxFit.cover,
                                    errorWidget: ((context, url, error) {
                                      return const SizedBox(
                                        child: Icon(Icons.error),
                                      );
                                    }),
                                    filterQuality: FilterQuality.low,
                                    imageUrl: _buildImageUrl(
                                        controller.searchBlog[index]),
                                  ),
                                ),
                                title: Text(
                                  controller.searchBlog[index]['name'],
                                  style: txtTheme().titleLarge!.copyWith(),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox(
                                height: 10,
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  // Uncomment and fix the Trending Category section
                  const SizedBox(height: 15),
                  Obx(
                    () => controller.trendingCategoryProduct.isEmpty
                        ? Container()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Trending Category",
                                style: txtTheme()
                                    .headlineSmall!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 15),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 1.5 / 2,
                                ),
                                itemCount: controller
                                            .trendingCategoryProduct.length >=
                                        3
                                    ? 3
                                    : controller.trendingCategoryProduct.length,
                                itemBuilder: ((context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Get.toNamed(Routes.SHOPPRODUCTLISTVIEW,
                                          arguments: {
                                            'productId': controller
                                                    .trendingCategoryProduct[
                                                index]['_id'],
                                            'name': controller
                                                    .trendingCategoryProduct[
                                                index]['name']
                                          });
                                    },
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: CachedNetworkImage(
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.shade300),
                                              child: const Center(
                                                child: Icon(Icons.error),
                                              ),
                                            ),
                                            height: 110,
                                            width: 90,
                                            fit: BoxFit.cover,
                                            imageUrl: getImage(index),
                                          ),
                                        ),
                                        const SizedBox(height: 4.0),
                                        Text(
                                          controller.trendingCategoryProduct[
                                                  index]['name'] ??
                                              '',
                                          style: txtTheme().titleLarge,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        )
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

//   String _buildImageUrl(dynamic item) {
//     try {
//       if (item['featured_image'] != null &&
//           item['featured_image'] is Map &&
//           item['featured_image']['filepath'] != null) {
//         String filepath = item['featured_image']['filepath'];
//         if (filepath.startsWith('http')) {
//           return filepath;
//         } else {
//           return url + filepath;
//         }
//       }
//     } catch (e) {
//       print('Error building image URL: $e');
//     }
//     return HelperFunctions.getNoImage();
//   }
}
                  // const SizedBox(height: 10),
                  // Text(
                  //   "Recommended for you",
                  //   style: txtTheme()
                  //       .headlineSmall!
                  //       .copyWith(fontWeight: FontWeight.bold),
                  // ),
                  // const SizedBox(height: 15),
                  // GridView.builder(
                  //   shrinkWrap: true,
                  //   physics: const NeverScrollableScrollPhysics(),
                  //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  //       childAspectRatio: 2 / 0.7,
                  //       crossAxisCount: 3,
                  //       crossAxisSpacing: 20,
                  //       mainAxisSpacing: 15),
                  //   itemCount: 5,
                  //   itemBuilder: ((context, index) {
                  //     return GestureDetector(
                  //       onTap: () {},
                  //       child: Container(
                  //         decoration: BoxDecoration(
                  //             color: themegreyColor,
                  //             borderRadius: BorderRadius.circular(5)),
                  //         child: Center(
                  //             child: Text('Denim', style: txtTheme().titleLarge)),
                  //       ),
                  //     );
                  //   }),
                  // ),
                  // const SizedBox(height: 15),
                  // Obx(
                  //   () => controller.trendingCategoryProduct.isEmpty
                  //       ? Container()
                  //       : Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             Text(
                  //               "Trending Category",
                  //               style: txtTheme()
                  //                   .headlineSmall!
                  //                   .copyWith(fontWeight: FontWeight.bold),
                  //             ),
                  //             const SizedBox(height: 15),
                  //             GridView.builder(
                  //               shrinkWrap: true,
                  //               physics: const NeverScrollableScrollPhysics(),
                  //               gridDelegate:
                  //                   const SliverGridDelegateWithFixedCrossAxisCount(
                  //                 crossAxisCount: 3,
                  //                 crossAxisSpacing: 10,
                  //                 childAspectRatio: 1.5 / 2,
                  //               ),
                  //               itemCount:
                  //                   controller.trendingCategoryProduct.length >= 3
                  //                       ? 3
                  //                       : controller
                  //                           .trendingCategoryProduct.length,
                  //               itemBuilder: ((context, index) {
                  //                 return GestureDetector(
                  //                   onTap: () {
                  //                     Get.toNamed(Routes.SHOPPRODUCTLISTVIEW,
                  //                         arguments: {
                  //                           'productId': controller
                  //                                   .trendingCategoryProduct[
                  //                               index]['_id'],
                  //                           'name': controller
                  //                                   .trendingCategoryProduct[
                  //                               index]['name']
                  //                         });
                  //                   },
                  //                   child: Column(
                  //                     children: [
                  //                       ClipRRect(
                  //                         borderRadius: BorderRadius.circular(5),
                  //                         child: CachedNetworkImage(
                  //                           errorWidget: (context, url, error) =>
                  //                               Container(
                  //                             decoration: BoxDecoration(
                  //                                 color: Colors.grey.shade300),
                  //                             child: const Center(
                  //                               child: Icon(Icons.error),
                  //                             ),
                  //                           ),
                  //                           height: 110,
                  //                           width: 90,
                  //                           fit: BoxFit.cover,
                  //                           imageUrl: getImage(index),
                  //                         ),
                  //                       ),
                  //                       const SizedBox(height: 4.0),
                  //                       Text(
                  //                         controller.trendingCategoryProduct[
                  //                                 index]['name'] ??
                  //                             '',
                  //                         style: txtTheme().titleLarge,
                  //                       )
                  //                     ],
                  //                   ),
                  //                 );
                  //               }),
                  //             ),
                  //           ],
                  //         ),
                  // ),
                  // const SizedBox(height: 10),
                  // Text(
                  //   "Top Brands On Foduukart",
                  //   style: txtTheme()
                  //       .headlineSmall!
                  //       .copyWith(fontWeight: FontWeight.bold),
                  // ),
                  // GridView.builder(
                  //   shrinkWrap: true,
                  //   physics: const NeverScrollableScrollPhysics(),
                  //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  //       childAspectRatio: 2 / 1.1,
                  //       crossAxisCount: 3,
                  //       crossAxisSpacing: 10,
                  //       mainAxisSpacing: 0),
                  //   itemCount: 6,
                  //   itemBuilder: ((context, index) {
                  //     return GestureDetector(
                  //         onTap: () {},
                  //         child: const brandCategory(
                  //           assetImage: 'assets/images/asgardia1.png',
                  //         ));
                  //   }),
                  // ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
                                      // onTap: () {
                                      //   // controller.recentSearchList.add({
                                      //   //   'productId': controller
                                      //   //       .searchProduct[index]['_id'],
                                      //   //   'name': controller
                                      //   //       .searchProduct[index]['name']
                                      //   // });
                                      //   if (controller.recentSearchList[index]
                                      //           ['type'] ==
                                      //       'product') {
                                      //   } else if (controller
                                      //               .recentSearchList[index]
                                      //           ['type'] ==
                                      //       'category') {
                                      //     print(
                                      //         'recent ${controller.recentSearchList[0]['name']}');
                                      //     Get.toNamed(
                                      //         Routes.SHOPPRODUCTLISTVIEW,
                                      //         arguments: {
                                      //           'productId': controller
                                      //                   .searchCategory[index]
                                      //               ['_id'],
                                      //           'name': controller
                                      //                   .searchCategory[index]
                                      //               ['name']
                                      //         });
                                      //   } else if (controller
                                      //               .recentSearchList[index]
                                      //           ['type'] ==
                                      //       'blog') {
                                      //     Get.toNamed(Routes.BLOG,
                                      //         arguments: controller
                                      //                 .recentSearchList[index]
                                      //             ['productId']);
                                      //   }
                                      //   print(
                                      //       'recent search ${controller.recentSearchList}');
                                      // },