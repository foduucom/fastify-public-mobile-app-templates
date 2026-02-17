// ignore_for_file: sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_if_null_operators, prefer_interpolation_to_compose_strings
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:foduu_ecommerce/app/modules/shop/controllers/shop_controller.dart';
import 'package:foduu_ecommerce/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/filterbutton.dart';
import 'package:foduu_ecommerce/components/commonWidgets/appbarIcons.dart';
import 'package:foduu_ecommerce/components/gridviewproductcard.dart';
import 'package:foduu_ecommerce/components/shopShimmer.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/theme.dart';
import 'package:get/get.dart';

class ShopView extends GetView<ShopController> {
  final shopController = Get.lazyPut<ShopController>(() => ShopController());
  final wishlistController = Get.find<WishlistController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.collectionName.toString() + ' Collection',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'lato',
                    fontSize: 15),
              ),
              Obx(
                () => Text(
                  controller.allProductList.length.toString() + ' items',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'lato',
                      fontSize: 12,
                      color: Color.fromRGBO(119, 119, 119, 1)),
                ),
              ),
            ],
          ),
          titleSpacing: 0,
          elevation: 0,
          actions: [
            // Obx(() => Get.find<BottombarController>().cartbadge(
            //     child: HeartIcon(() {
            //       Get.toNamed(Routes.WISHLIST);
            //     }),
            //     badgeNumber: Get.find<WishlistController>().wishList.length)),
            // In your shop_view.dart where you have the HeartIcon
            Obx(() => Get.find<BottombarController>().cartbadge(
                  child: HeartIcon(() {
                    if (!AuthDetails.isUserLogin()) {
                      // Show login dialog for non-logged in users
                      Get.dialog(
                        AlertDialog(
                          title: Text('Login Required'),
                          content: Text('Please login to view your wishlist'),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.back();
                                isOtpLogin
                                    ? Get.toNamed(Routes.MOBILELOGIN)
                                    : Get.toNamed(Routes.LOGIN);
                              },
                              child: Text('Login'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Navigate to BottomBar's WishlistView (index 2)
                      final bottomBarController =
                          Get.find<BottombarController>();
                      bottomBarController.pageController.jumpToPage(2);
                      bottomBarController.currentPageIndex.value = 2;
                    }
                  }),
                  badgeNumber: Get.find<WishlistController>().wishList.length,
                )),
            SizedBox(width: 14),
            Obx(
              () => Get.find<BottombarController>().cartbadge(
                  child: CartIcon(() {
                    Get.toNamed(Routes.CART);
                  }),
                  badgeNumber:
                      Get.find<CartController>().productDetails.length),
            ),
            SizedBox(width: 15)
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            controller.onPullTorefresh();
          },
          child: CustomScrollView(
            controller: controller.scrollController,
            slivers: [
              // Category Tabs Section (NEW)
              SliverToBoxAdapter(
                child: Obx(
                  () => controller.subCategories.isEmpty
                      ? SizedBox.shrink()
                      : Container(
                          height: 50,
                          margin:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.subCategories.length,
                            itemBuilder: (context, index) {
                              final subCat = controller.subCategories[index];
                              final isSelected = index ==
                                  controller.selectedSubCategoryIndex.value;

                              return GestureDetector(
                                onTap: () async {
                                  controller.selectedSubCategoryIndex.value =
                                      index;
                                  controller.selectedSubCategoryId.value =
                                      subCat['_id'] ?? '';
                                  controller.allProductList.clear();
                                  controller.currentPage.value = 1;

                                  // Check if this subcategory has children (like Footwear has Nike/Adidas)
                                  if (subCat['children'] != null &&
                                      subCat['children'].isNotEmpty) {
                                    // Show deep category tabs
                                    controller.deepCategories.value =
                                        List.from(subCat['children']);
                                    print(
                                        "Print Sub Categories From If: ${controller.deepCategories.value}");
                                    // Fetch products from all children
                                    await controller
                                        .fetchProductsForCategoryAndSubcategories(
                                            subCat['_id']);
                                  } else {
                                    // ✅ FIXED: Use subCat['_id'] here, NOT deepCat
                                    controller.deepCategories.clear();
                                    await controller
                                        .getProductsForCategory(subCat['_id']);
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: 8),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? DefaultThemeColors.mainprimary
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      subCat['name'] ?? '',
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ),

              // Deep Category Tabs (for Nike/Adidas under Footwear)
              // SliverToBoxAdapter(
              //   child: Obx(
              //     () => controller.deepCategories.isEmpty
              //         ? SizedBox.shrink()
              //         : Container(
              //             height: 40,
              //             margin:
              //                 EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              //             child: ListView.builder(
              //               scrollDirection: Axis.horizontal,
              //               itemCount: controller.deepCategories.length,
              //               itemBuilder: (context, index) {
              //                 final deepCat = controller.deepCategories[index];
              //                 final isSelected = index ==
              //                     controller.selectedDeepCategoryIndex.value;

              //                 return GestureDetector(
              //                   onTap: () {
              //                     controller.selectedDeepCategoryIndex.value =
              //                         index;
              //                     controller.allProductList.clear();
              //                     controller.currentPage.value = 1;
              //                     // ✅ FIX: Change this line from getCategoryWiseProduct to getProductsForCategory
              //                     controller
              //                         .getProductsForCategory(deepCat['_id']);
              //                   },
              //                   child: Container(
              //                     margin: EdgeInsets.only(right: 6),
              //                     padding: EdgeInsets.symmetric(
              //                         horizontal: 12, vertical: 6),
              //                     decoration: BoxDecoration(
              //                       color: isSelected
              //                           ? Colors.blue.shade100
              //                           : Colors.grey.shade100,
              //                       borderRadius: BorderRadius.circular(16),
              //                       border: Border.all(
              //                         color: isSelected
              //                             ? Colors.blue
              //                             : Colors.transparent,
              //                         width: 1,
              //                       ),
              //                     ),
              //                     child: Text(
              //                       deepCat['name'] ?? '',
              //                       style: TextStyle(
              //                         fontWeight: isSelected
              //                             ? FontWeight.w600
              //                             : FontWeight.normal,
              //                         fontSize: 13,
              //                         color: isSelected
              //                             ? Colors.blue.shade800
              //                             : Colors.black87,
              //                       ),
              //                     ),
              //                   ),
              //                 );
              //               },
              //             ),
              //           ),
              //   ),
              // ),

              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 50,
                floating: true,
                title: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: Get.height * 0.05,
                        child: TextFormField(
                          onTap: () {
                            Get.toNamed(Routes.SEARCH);
                          },
                          readOnly: true,
                          decoration: InputDecoration(
                              filled: true,
                              prefixIcon: Icon(
                                Icons.search,
                                size: 20,
                              ),
                              contentPadding: const EdgeInsets.fromLTRB(
                                  30.0, 15.0, 30.0, 10.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 1),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(width: 1)),
                              hintText: "Search",
                              hintStyle: txtTheme().titleLarge!.copyWith()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => FilterPage())),
                      child: SvgPicture.asset('assets/icon/filter.svg'),
                    )
                  ],
                ),
              ),

              SliverList(
                  delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Obx(() {
                    return controller.isLoading.value &&
                            controller.allProductList.isEmpty
                        ? AlignedGridView.count(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: 6,
                            crossAxisCount: 2,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 14,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return ShopShimmer();
                            },
                          )
                        : AlignedGridView.count(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: controller.allProductList.length,
                            crossAxisCount: 2,
                            mainAxisSpacing: 20,
                            cacheExtent: 9999,
                            crossAxisSpacing: 14,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final product = controller.allProductList[index];

                              return Obx(() {
                                if (controller.allProductList.isEmpty) {
                                  return HelperFunctions().loadingIndicator();
                                }

                                // Handle different product types
                                String productType =
                                    product['type'] ?? 'simple';
                                String lowestPrice = '0';
                                String highestPrice = '0';
                                String displayPrice = '0';
                                String originalPrice = '';
                                String discountRate = '';

                                if (productType == 'variable') {
                                  // Check if variants exist AND have data
                                  final hasValidVariants =
                                      product['variants'] != null &&
                                          product['variants'] is List &&
                                          (product['variants'] as List)
                                              .isNotEmpty;

                                  if (hasValidVariants) {
                                    final variants =
                                        product['variants'] as List;
                                    final firstVariant = variants.first;

                                    // Get prices from first variant
                                    final price = firstVariant['price'] ?? 0;
                                    final discountedPrice =
                                        firstVariant['discounted_price'] ?? 0;

                                    displayPrice = (discountedPrice > 0
                                            ? discountedPrice
                                            : price)
                                        .toString();

                                    if (discountedPrice > 0 &&
                                        price > discountedPrice) {
                                      originalPrice = price.toString();
                                      final discount =
                                          ((price - discountedPrice) /
                                                  price *
                                                  100)
                                              .round();
                                      discountRate = '$discount% off';
                                    }

                                    // For price range - check if we have multiple variants
                                    if (variants.length >= 2) {
                                      // Use HelperFunctions only when we have at least 2 variants
                                      try {
                                        lowestPrice =
                                            HelperFunctions.lowestPrice(
                                                    variants)
                                                .toString();
                                        highestPrice =
                                            HelperFunctions.highestPrice(
                                                    variants)
                                                .toString();
                                      } catch (e) {
                                        // Fallback if HelperFunctions fails
                                        lowestPrice = displayPrice;
                                        highestPrice = displayPrice;
                                        print(
                                            '⚠️ Error calculating price range: $e');
                                      }
                                    } else {
                                      // Only one variant - use same price for both
                                      lowestPrice = displayPrice;
                                      highestPrice = displayPrice;
                                    }
                                  } else {
                                    // NO VARIANTS - treat as simple product
                                    print(
                                        '⚠️ Product ${product['_id']} is type "variable" but has no variants');

                                    final salePrice =
                                        product['sale_price'] ?? 0;
                                    final regularPrice = product['price'] ?? 0;

                                    displayPrice = (salePrice > 0
                                            ? salePrice
                                            : regularPrice)
                                        .toString();

                                    if (salePrice > 0 &&
                                        regularPrice > salePrice) {
                                      originalPrice = regularPrice.toString();
                                      final discount =
                                          (100 - salePrice * 100 / regularPrice)
                                              .round();
                                      discountRate = '$discount% off';
                                    }

                                    lowestPrice = displayPrice;
                                    highestPrice = displayPrice;
                                  }
                                } else {
                                  // Simple product
                                  final salePrice = product['sale_price'] ?? 0;
                                  final regularPrice = product['price'] ?? 0;

                                  displayPrice =
                                      (salePrice > 0 ? salePrice : regularPrice)
                                          .toString();

                                  if (salePrice > 0 &&
                                      regularPrice > salePrice) {
                                    originalPrice = regularPrice.toString();
                                    final discount =
                                        (100 - salePrice * 100 / regularPrice)
                                            .round();
                                    discountRate = '$discount% off';
                                  }

                                  lowestPrice = displayPrice;
                                  highestPrice = displayPrice;
                                }

                                // Get product image with detailed debugging
                                String imageUrl = HelperFunctions.getNoImage();
                                print(
                                    '🔍 Processing image for product: ${product['name']} (${product['_id']})');

// Check featured_image
                                if (product['featured_image'] != null) {
                                  print(
                                      '  - featured_image exists: ${product['featured_image'].runtimeType}');

                                  if (product['featured_image'] is Map) {
                                    print(
                                        '  - featured_image is Map with keys: ${(product['featured_image'] as Map).keys}');

                                    if (product['featured_image']['filepath'] !=
                                        null) {
                                      imageUrl = url +
                                          'images/' +
                                          product['featured_image']['filepath'];
                                      print(
                                          '  ✅ Using featured_image.filepath: $imageUrl');
                                    } else if (product['featured_image']
                                            ['_id'] !=
                                        null) {
                                      // Sometimes the image ID is stored, need to fetch or construct URL
                                      print(
                                          '  ⚠️ featured_image has ID but no filepath: ${product['featured_image']['_id']}');
                                      // Try alternative: maybe it's just an ID reference
                                      imageUrl = url +
                                          'images/' +
                                          product['featured_image']['_id'];
                                      print(
                                          '  🔄 Trying constructed URL: $imageUrl');
                                    }
                                  } else if (product['featured_image']
                                      is String) {
                                    print(
                                        '  - featured_image is String: ${product['featured_image']}');
                                    imageUrl = url +
                                        'images/' +
                                        product['featured_image'];
                                    print(
                                        '  ✅ Using string featured_image: $imageUrl');
                                  }
                                }
// Check variants for images
                                else if (productType == 'variable' &&
                                    product['variants'] != null &&
                                    product['variants'].isNotEmpty) {
                                  print('  - Checking variants for images');
                                  final variants = product['variants'] as List;

                                  for (int i = 0; i < variants.length; i++) {
                                    if (variants[i]['images'] != null &&
                                        variants[i]['images'].isNotEmpty) {
                                      print(
                                          '  - Variant $i has ${variants[i]['images'].length} images');
                                      final firstImage =
                                          variants[i]['images'].first;

                                      if (firstImage is Map &&
                                          firstImage['filepath'] != null) {
                                        imageUrl = url + firstImage['filepath'];
                                        print(
                                            '  ✅ Using variant image: $imageUrl');
                                        break;
                                      } else if (firstImage is String) {
                                        imageUrl = url + 'images/' + firstImage;
                                        print(
                                            '  ✅ Using variant string image: $imageUrl');
                                        break;
                                      }
                                    }
                                  }
                                }

                                print('  📸 Final imageUrl: $imageUrl');

                                print(
                                    '📦 Product data for ID ${product['_id']}:');
                                print('  - price: ${product['price']}');
                                print(
                                    '  - sale_price: ${product['sale_price']}');
                                print(
                                    '  - variants exists? ${product.containsKey('variants')}');
                                if (product.containsKey('variants')) {
                                  print(
                                      '  - variants is List? ${product['variants'] is List}');
                                  print(
                                      '  - variants length: ${product['variants']?.length}');
                                }

                                return gridProductCart(
                                  animationController: controller.controller,
                                  scaoleAnimation: controller.scaleAnimation,
                                  highestPrice: highestPrice,
                                  lowestPrice: lowestPrice,
                                  productType: productType,
                                  liked: GetBuilder<WishlistController>(
                                    id: controller.allProductList[index][
                                        '_id'], // Use product ID as unique identifier
                                    builder: (wishlistcontroller) {
                                      return SvgPicture.asset(
                                        wishlistcontroller.wishlistProductIds
                                                .contains(controller
                                                        .allProductList[index]
                                                    ['_id'])
                                            ? 'assets/icon/like.svg'
                                            : 'assets/icon/unlike.svg',
                                        width: 20,
                                        height: 20,
                                      );
                                    },
                                  ),
                                  onLiked: () async {
                                    final productId =
                                        controller.allProductList[index]['_id'];
                                    final wishlistController =
                                        Get.find<WishlistController>();

                                    // Toggle wishlist status
                                    await wishlistController
                                        .toggleWishlist(productId);

                                    // No need to call getwishlist() here as toggleWishlist already handles it
                                    // and updates the specific button using the ID
                                  },
                                  rating: double.parse(
                                    product['average_rating']?.toString() ??
                                        '0',
                                  ),
                                  quantity:
                                      "In Stock", // You might want to calculate this from variants
                                  // keypressEvent: () {
                                  //   Get.toNamed(Routes.PRODUCTDETAILS,
                                  //       arguments: {
                                  //         'productId': product['_id'],
                                  //       });
                                  // },
                                  // In your gridProductCart call
                                  keypressEvent: () {
                                    Get.toNamed(Routes.PRODUCTDETAILS,
                                        arguments: {
                                          'productId': controller
                                              .allProductList[index]['_id'],
                                        });
                                  },
                                  assetimage: imageUrl,
                                  productname:
                                      product['name']?.toString() ?? '',
                                  discountprice: originalPrice,
                                  productprice: displayPrice,
                                  discountrate: discountRate,
                                  height: Get.height * 0.3,
                                  width: Get.width,
                                );
                              });
                            },
                          );
                  }),
                ),
                const SizedBox(height: 20),
                Obx(() => controller.isLoading.isTrue &&
                        controller.allProductList.isNotEmpty
                    ? HelperFunctions().loadingIndicator()
                    : Container()),
                const SizedBox(height: 30)
              ]))
            ],
          ),
        ),
      ),
    );
  }
}

class FilterPage extends StatelessWidget {
  final controller = Get.find<ShopController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text("Filters",
              style: txtTheme()
                  .titleLarge!
                  .copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              left: 0,
              child: SingleChildScrollView(
                child: Padding(
                  padding: pageSurroundingPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Brand: ",
                          style: TextStyle(
                              fontFamily: 'lato',
                              fontSize: 16,
                              fontWeight: FontWeight.w400)),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.25,
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: 2 / 0.5,
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 15),
                          itemCount: controller.brads.length,
                          itemBuilder: ((context, index) {
                            return Obx(() {
                              return GestureDetector(
                                onTap: () {
                                  controller.selectBrand.value = index;
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Center(
                                      child: Text(
                                          controller.brads[index]['brandname']
                                              .toString(),
                                          style: TextStyle(
                                            fontFamily: 'lato',
                                            fontSize: 14,
                                          ))),
                                ),
                              );
                            });
                          }),
                        ),
                      ),
                      const Text("Size:",
                          style: TextStyle(
                              fontFamily: 'lato',
                              fontSize: 16,
                              fontWeight: FontWeight.w400)),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15,
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: 2 / 0.7,
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 15),
                          itemCount: controller.size.length,
                          itemBuilder: ((context, index) {
                            return Obx(() {
                              return GestureDetector(
                                onTap: () {
                                  controller.selectSize.value = index;
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Center(
                                      child: Text(
                                          controller.size[index]['size']
                                              .toString(),
                                          style: TextStyle(
                                            fontFamily: 'lato',
                                            fontSize: 14,
                                          ))),
                                ),
                              );
                            });
                          }),
                        ),
                      ),
                      const Text("Price:",
                          style: TextStyle(
                              fontFamily: 'lato',
                              fontSize: 16,
                              fontWeight: FontWeight.w400)),
                      Obx(() {
                        return RangeSlider(
                          values: controller.currentRangeValues.value,
                          max: double.parse(
                              controller.filterMaxPrice.toString()),
                          divisions: 5,
                          labels: RangeLabels(
                            controller.currentRangeValues.value.start
                                .round()
                                .toString(),
                            controller.currentRangeValues.value.end
                                .round()
                                .toString(),
                          ),
                          onChanged: (RangeValues values) {
                            controller.updateSlider(values);
                          },
                        );
                      }),
                      const Text("Colors:",
                          style: TextStyle(
                              fontFamily: 'lato',
                              fontSize: 16,
                              fontWeight: FontWeight.w400)),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15,
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: 1 / 1,
                                  crossAxisCount: 7,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 15),
                          itemCount: controller.colorList.length,
                          itemBuilder: ((context, index) {
                            return Obx(() {
                              return GestureDetector(
                                onTap: () {
                                  controller.selectedColor.value = index;
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: controller.colorList[index]
                                          ['color'],
                                      borderRadius: BorderRadius.circular(50)),
                                  child: controller.selectedColor.value == index
                                      ? Icon(Icons.check)
                                      : SizedBox(),
                                ),
                              );
                            });
                          }),
                        ),
                      ),
                      SizedBox(height: 60)
                    ],
                  ),
                ),
              ),
            ),
            filterButton(
              reset: 'reset',
              filter: 'apply filter',
              pressEvnetFilter: () {
                print(controller.currentRangeValues.value.start);
                controller.allProductList.clear();
                controller.currentPage.value = 0;
                controller.maxPage.value = 0;
                controller.filterProducts();
                Get.back();
              },
              pressEvnetReset: () {
                controller.isFilter.value = false;
                Get.back();
                controller.onPullTorefresh();
              },
            )
          ],
        ),
      ),
    );
  }
}
