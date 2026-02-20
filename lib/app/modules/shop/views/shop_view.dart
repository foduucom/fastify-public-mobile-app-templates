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
              Obx(() => Text(
                    controller.collectionName.value.toString() + ' Collection',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'lato',
                      fontSize: 15,
                      color: context.onSurfaceColor, // Theme-aware title
                    ),
                  )),
              Obx(
                () => Text(
                  controller.allProductList.length.toString() + ' items',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'lato',
                    fontSize: 12,
                    color:
                        context.onSurfaceVariantColor, // Theme-aware subtitle
                  ),
                ),
              ),
            ],
          ),
          titleSpacing: 0,
          elevation: 0,
          backgroundColor:
              context.surfaceColor, // Theme-aware app bar background
          actions: [
            Obx(() => Get.find<BottombarController>().cartbadge(
                  child: HeartIcon(() {
                    if (!AuthDetails.isUserLogin()) {
                      // Show login dialog for non-logged in users
                      Get.dialog(
                        AlertDialog(
                          backgroundColor:
                              context.surfaceColor, // Theme-aware dialog
                          title: Text(
                            'Login Required',
                            style: TextStyle(color: context.onSurfaceColor),
                          ),
                          content: Text(
                            'Please login to view your wishlist',
                            style:
                                TextStyle(color: context.onSurfaceVariantColor),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                    color: context.onSurfaceVariantColor),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.back();
                                isOtpLogin
                                    ? Get.toNamed(Routes.MOBILELOGIN)
                                    : Get.toNamed(Routes.LOGIN);
                              },
                              child: Text(
                                'Login',
                                style: TextStyle(color: context.primaryColor),
                              ),
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
          color: context.primaryColor, // Theme-aware refresh indicator
          backgroundColor: context.surfaceColor, // Theme-aware background
          child: CustomScrollView(
            controller: controller.scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: GetBuilder<ShopController>(
                  builder: (controller) {
                    return controller.subCategories.isEmpty
                        ? SizedBox.shrink()
                        : Container(
                            height: 50,
                            margin: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 8),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              // Add +1 to itemCount for the "All" button
                              itemCount: controller.subCategories.length + 1,
                              itemBuilder: (context, index) {
                                // Handle the "All" button (index 0)
                                if (index == 0) {
                                  final isSelected = index ==
                                      controller.selectedSubCategoryIndex;

                                  return GestureDetector(
                                    onTap: () {
                                      print("🔹 Tapped All button");
                                      controller.selectedSubCategoryIndex =
                                          index;
                                      controller.selectedSubCategoryId.value =
                                          '';
                                      controller.allProductList.clear();
                                      controller.currentPage.value = 1;
                                      controller.update();

                                      // Clear deep categories
                                      controller.deepCategories.clear();

                                      // Pass collectionName to get all products
                                      controller.getProductsForCategory(
                                          controller.collectionName.value
                                              .toString());
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(right: 8),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? DefaultThemeColors.mainprimary
                                            : context
                                                .surfaceVariantColor, // Theme-aware
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'All',
                                          style: TextStyle(
                                            color: isSelected
                                                ? context
                                                    .onPrimaryColor // White when selected
                                                : context
                                                    .onSurfaceColor, // Theme-aware
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                // Handle regular subcategories (index-1 to account for All button)
                                final subCat =
                                    controller.subCategories[index - 1];
                                final isSelected = index ==
                                    controller.selectedSubCategoryIndex;

                                return GestureDetector(
                                  onTap: () {
                                    print("🔹 Tapped index: $index");
                                    controller.selectedSubCategoryIndex = index;
                                    controller.selectedSubCategoryId.value =
                                        subCat['slug'] ?? '';
                                    controller.allProductList.clear();
                                    controller.currentPage.value = 1;
                                    controller.update();

                                    // Handle deep categories
                                    if (subCat['children'] != null &&
                                        subCat['children'].isNotEmpty) {
                                      controller.deepCategories.value =
                                          List.from(subCat['children']);
                                      controller
                                          .fetchProductsForCategoryAndSubcategories(
                                              subCat['slug']);
                                    } else {
                                      controller.deepCategories.clear();
                                      controller.getProductsForCategory(
                                          subCat['slug']);
                                    }
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 8),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? DefaultThemeColors.mainprimary
                                          : context
                                              .surfaceVariantColor, // Theme-aware
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Text(
                                        subCat['name'] ?? '',
                                        style: TextStyle(
                                          color: isSelected
                                              ? context
                                                  .onPrimaryColor // White when selected
                                              : context
                                                  .onSurfaceColor, // Theme-aware
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
                          );
                  },
                ),
              ),
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 50,
                floating: true,
                backgroundColor: context.surfaceColor, // Theme-aware
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
                              fillColor:
                                  context.surfaceVariantColor, // Theme-aware
                              prefixIcon: Icon(
                                Icons.search,
                                color: context
                                    .onSurfaceVariantColor, // Theme-aware
                              ),
                              contentPadding: const EdgeInsets.fromLTRB(
                                  30.0, 15.0, 30.0, 10.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1,
                                  color: context.primaryColor, // Theme-aware
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1,
                                  color: context.outlineColor, // Theme-aware
                                ),
                              ),
                              hintText: "Search",
                              hintStyle: txtTheme().titleLarge!.copyWith(
                                    color: context
                                        .onSurfaceVariantColor, // Theme-aware
                                  )),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => FilterPage())),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: DefaultThemeColors
                              .mainprimary, // Brand color background
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          'assets/icon/filter.svg',
                          // color: context.onPrimaryColor, // White icon
                          width: 20,
                          height: 20,
                        ),
                      ),
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
                                        color: wishlistcontroller
                                                .wishlistProductIds
                                                .contains(controller
                                                        .allProductList[index]
                                                    ['_id'])
                                            ? context
                                                .errorColor // Red when liked
                                            : context
                                                .onSurfaceVariantColor, // Gray when not liked
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: context.surfaceColor, // Theme-aware
          title: Text(
            "Filters",
            style: txtTheme().titleLarge!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.onSurfaceColor, // Theme-aware
                ),
          ),
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
                      Text(
                        "Brand: ",
                        style: TextStyle(
                          fontFamily: 'lato',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: context.onSurfaceColor, // Theme-aware
                        ),
                      ),
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
                              final isSelected =
                                  controller.selectBrand.value == index;
                              return GestureDetector(
                                onTap: () {
                                  controller.selectBrand.value = index;
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: isSelected
                                        ? context.primaryColor.withOpacity(0.1)
                                        : context.surfaceVariantColor,
                                    border: Border.all(
                                      color: isSelected
                                          ? context.primaryColor
                                          : context.outlineColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      controller.brads[index]['brandname']
                                          .toString(),
                                      style: TextStyle(
                                        fontFamily: 'lato',
                                        fontSize: 14,
                                        color: isSelected
                                            ? context.primaryColor
                                            : context.onSurfaceColor,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            });
                          }),
                        ),
                      ),
                      Text(
                        "Size:",
                        style: TextStyle(
                          fontFamily: 'lato',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: context.onSurfaceColor, // Theme-aware
                        ),
                      ),
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
                              final isSelected =
                                  controller.selectSize.value == index;
                              return GestureDetector(
                                onTap: () {
                                  controller.selectSize.value = index;
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: isSelected
                                        ? context.primaryColor.withOpacity(0.1)
                                        : context.surfaceVariantColor,
                                    border: Border.all(
                                      color: isSelected
                                          ? context.primaryColor
                                          : context.outlineColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      controller.size[index]['size'].toString(),
                                      style: TextStyle(
                                        fontFamily: 'lato',
                                        fontSize: 14,
                                        color: isSelected
                                            ? context.primaryColor
                                            : context.onSurfaceColor,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            });
                          }),
                        ),
                      ),
                      Text(
                        "Price:",
                        style: TextStyle(
                          fontFamily: 'lato',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: context.onSurfaceColor, // Theme-aware
                        ),
                      ),
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
                          activeColor: context.primaryColor, // Theme-aware
                          inactiveColor: context.outlineColor, // Theme-aware
                        );
                      }),
                      Text(
                        "Colors:",
                        style: TextStyle(
                          fontFamily: 'lato',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: context.onSurfaceColor, // Theme-aware
                        ),
                      ),
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
                              final isSelected =
                                  controller.selectedColor.value == index;
                              return GestureDetector(
                                onTap: () {
                                  controller.selectedColor.value = index;
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: controller.colorList[index]['color'],
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                      color: isSelected
                                          ? context.primaryColor
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check,
                                          color: context.onPrimaryColor,
                                          size: 16,
                                        )
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
