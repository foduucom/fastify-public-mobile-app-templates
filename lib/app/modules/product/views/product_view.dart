import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foduu_ecommerce/app/modules/product/controllers/product_controller.dart';
import 'package:foduu_ecommerce/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/ImagePreviewMultipleView.dart';
import 'package:foduu_ecommerce/components/buttons/primary_action_button.dart';
import 'package:foduu_ecommerce/components/commonWidgets/secondary_app_header.dart';
import 'package:foduu_ecommerce/components/commonWidgets/simple_price_text.dart';
import 'package:foduu_ecommerce/components/commonWidgets/variable_price_text.dart';
import 'package:foduu_ecommerce/components/shimmer_effects.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/product_helper.dart';
import 'package:foduu_ecommerce/constants/theme.dart';
import 'package:foduu_ecommerce/core/services/wishlistService.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ProductView extends GetView<ProductController> {
  ProductView({Key? key}) : super(key: key);

  ColorScheme get colorScheme => Theme.of(Get.context!).colorScheme;
  TextTheme get textTheme => Theme.of(Get.context!).textTheme;

  WishlistController wishListController = Get.find<WishlistController>();

  @override
  Widget build(BuildContext context) {
    var width = Get.width;
    var height = Get.height;
    // Removed redundant Get.create which was causing an infinite loop of API calls
    // ProductView is a GetView<ProductController>, so it already has access to 'controller'

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              bottom: 0,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    //SizedBox(height: height * 0.005),
                    Obx(() {
                      final isInWishlist =
                          WishListService.to.isInWishlist(controller.productId);
                      return SecondaryAppHeader(
                        title: "Product Detail",
                        rightIcon: isInWishlist
                            ? Icons.favorite
                            : Icons.favorite_outline,
                        onRightIconTap: () async {
                          String? variantId;
                          if (controller.productDetials['type'] == 'variable') {
                            final variants =
                                controller.productDetials['variants'];
                            if (variants != null &&
                                variants is List &&
                                controller.selectedVariantIndex.value <
                                    variants.length) {
                              variantId = variants[
                                  controller.selectedVariantIndex.value]['_id'];
                            }
                          }

                          await WishListService.to.toggleWishlist(
                            productId: controller.productId,
                            variantSlug:
                                controller.productDetials['variant_slug'] ?? '',
                            variantId: variantId,
                          );
                        },
                      );
                    }),
                    SizedBox(height: height * 0.005),
                    // In your product details screen where you call ProductGallery
                    Obx(
                      () {
                        List gallery = [];

                        if (controller.productDetials['type'] == 'variable') {
                          var variants = controller.productDetials['variants'];
                          int selectedIdx =
                              controller.selectedVariantIndex.value;

                          if (variants != null &&
                              variants is List &&
                              selectedIdx < variants.length) {
                            var variant = variants[selectedIdx];

                            // 1. Add variant's featured image
                            if (variant['featured_image'] != null) {
                              gallery.add(variant['featured_image']);
                            }

                            // 2. Add variant's gallery/images
                            var variantGallery =
                                variant['gallery'] ?? variant['images'];
                            if (variantGallery != null &&
                                variantGallery is List) {
                              gallery.addAll(variantGallery);
                            }
                          }
                        }

                        // If gallery is still empty (simple product or variant has no images), use product-level gallery
                        if (gallery.isEmpty) {
                          if (controller.productDetials['featured_image'] !=
                              null) {
                            gallery.add(
                                controller.productDetials['featured_image']);
                          }
                          gallery.addAll(controller.productGallery);
                        }

                        return ProductGallery(
                          controller: controller,
                          productGallery: gallery,
                        );
                      },
                    ),
                    const SizedBox(height: 8.0),
                    Obx(() {
                      int galleryLength = 0;
                      if (controller.productDetials['type'] == 'variable') {
                        var variants = controller.productDetials['variants'];
                        int selectedIdx = controller.selectedVariantIndex.value;

                        if (variants != null &&
                            variants is List &&
                            selectedIdx < variants.length) {
                          var variant = variants[selectedIdx];
                          var variantGallery =
                              variant['gallery'] ?? variant['images'];
                          if (variantGallery != null &&
                              variantGallery is List) {
                            galleryLength = variantGallery.length +
                                (variant['featured_image'] != null ? 1 : 0);
                          }
                        }
                      }

                      if (galleryLength == 0) {
                        galleryLength = controller.productGallery.length +
                            (controller.productDetials['featured_image'] != null
                                ? 1
                                : 0);
                      }

                      return galleryLength <= 1
                          ? Container()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: List.generate(
                                galleryLength,
                                (index) => Obx(() {
                                  return Container(
                                    width: controller.selectedPageIndex.value ==
                                            index
                                        ? 30
                                        : 9,
                                    height: 9,
                                    margin: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color:
                                          controller.selectedPageIndex.value ==
                                                  index
                                              ? colorScheme.primary
                                              : colorScheme.outline
                                                  .withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  );
                                }),
                              ));
                    }),
                    Column(
                      children: [
                        Padding(
                          padding: pageSurroundingPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              // In your ProductView build method, after the gallery and before color selector:
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Product Name (Left side)
                                  Expanded(
                                    child: Obx(
                                      () => controller.productDetials['name'] ==
                                              null
                                          ? const ShimmerEffect(
                                              height: 20, width: 150)
                                          : Text(
                                              controller.productDetials['name']
                                                  .toString(),
                                              style: txtTheme()
                                                  .displayMedium!
                                                  .copyWith(
                                                    fontSize: height * 0.020,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                    ),
                                  ),

                                  SizedBox(width: 10),

                                  // Price (Right side)
                                  Flexible(
                                    child: Obx(
                                      () {
                                        if (controller.productDetials.isEmpty) {
                                          return const ShimmerEffect(
                                              height: 20, width: 80);
                                        }

                                        final productType =
                                            controller.productDetials['type'] ??
                                                'simple';

                                        if (productType == 'variable') {
                                          final variants = controller
                                                  .productDetials['variants']
                                              as List?;
                                          if (variants != null &&
                                              variants.isNotEmpty) {
                                            final selectedVariant = variants[
                                                controller.selectedVariantIndex
                                                    .value];

                                            String discountRate = '';
                                            final priceStr =
                                                selectedVariant['price']
                                                        ?.toString() ??
                                                    '0';
                                            final saleStr =
                                                selectedVariant['sale_price']
                                                        ?.toString() ??
                                                    '0';
                                            final price =
                                                double.tryParse(priceStr) ?? 0;
                                            final discountedPrice =
                                                double.tryParse(saleStr) ?? 0;

                                            // Both price and sale_price are 0 → free product
                                            if (price == 0 &&
                                                discountedPrice == 0) {
                                              return Text(
                                                'Free',
                                                style: txtTheme()
                                                    .displayMedium!
                                                    .copyWith(
                                                      fontSize: height * 0.020,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.green,
                                                    ),
                                              );
                                            }

                                            // sale_price "0" on a paid product = no discount
                                            final hasDiscount =
                                                discountedPrice > 0 &&
                                                    price > discountedPrice;
                                            if (hasDiscount) {
                                              final discount =
                                                  ((price - discountedPrice) /
                                                          price *
                                                          100)
                                                      .round();
                                              discountRate = '$discount% off';
                                            }

                                            return SimplePriceText(
                                              price: hasDiscount
                                                  ? discountedPrice
                                                  : price,
                                              originalPrice:
                                                  hasDiscount ? price : null,
                                              discountLabel: hasDiscount
                                                  ? discountRate
                                                  : null,
                                              priceStyle: txtTheme()
                                                  .displayMedium!
                                                  .copyWith(
                                                    fontSize: height * 0.020,
                                                    fontWeight: FontWeight.w700,
                                                    color: colorScheme.primary,
                                                  ),
                                            );
                                          }
                                        }

                                        // Fallback
                                        final priceInfo =
                                            ProductHelper.calculatePriceInfo(
                                                Map<String, dynamic>.from(
                                                    controller.productDetials));

                                        if (productType == 'variable') {
                                          return VariablePriceText(
                                            lowestPrice:
                                                priceInfo['lowestPrice'],
                                            highestPrice:
                                                priceInfo['highestPrice'],
                                            style: txtTheme()
                                                .displayMedium!
                                                .copyWith(
                                                  fontSize: height * 0.020,
                                                  fontWeight: FontWeight.w700,
                                                  color: colorScheme.primary,
                                                ),
                                          );
                                        } else {
                                          return SimplePriceText(
                                            price: priceInfo['productPrice'],
                                            originalPrice:
                                                priceInfo['discountPrice'],
                                            discountLabel:
                                                priceInfo['discountRate'],
                                            priceStyle: txtTheme()
                                                .displayMedium!
                                                .copyWith(
                                                  fontSize: height * 0.020,
                                                  fontWeight: FontWeight.w700,
                                                  color: colorScheme.primary,
                                                ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: height * 0.001),
                              Padding(
                                padding: EdgeInsets.zero,
                                //width: width * 0.80,
                                child: Row(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: height * 0.018, // ≈ 16
                                          color: Colors.amber,
                                        ),
                                        Obx(() {
                                          final rating = controller
                                              .productDetials['average_rating'];
                                          final ratingStr = rating != null
                                              ? rating.toString()
                                              : '—';
                                          return Text(ratingStr,
                                              style: txtTheme()
                                                  .titleSmall!
                                                  .copyWith(
                                                    fontSize: height * 0.018,
                                                    height: 1.4,
                                                    fontFamily:
                                                        'Plus Jakarta Sans',
                                                  ));
                                        }),
                                      ],
                                    ),
                                    SizedBox(width: width * 0.012),
                                    Text(
                                      "•",
                                      style: TextStyle(
                                        fontSize: height * 0.02,
                                        color: colorScheme.outline,
                                      ),
                                    ),
                                    SizedBox(width: width * 0.012),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.storefront,
                                          size: height * 0.02, // ≈ 16
                                          color: colorScheme.onSurface,
                                        ),
                                        SizedBox(width: width * 0.015),
                                        Obx(() {
                                          final brand = controller
                                              .productDetials['brand'];
                                          final brandName = (brand is Map)
                                              ? (brand['name']?.toString() ??
                                                  '')
                                              : (brand?.toString() ?? '');
                                          return Text(
                                            brandName.isEmpty
                                                ? 'Unknown Brand'
                                                : brandName,
                                            style: txtTheme()
                                                .titleSmall!
                                                .copyWith(
                                                  fontFamily:
                                                      'Plus Jakarta Sans',
                                                  color: colorScheme.onSurface,
                                                  fontSize: height * 0.018,
                                                  height: 1.4,
                                                ),
                                          );
                                        }),
                                      ],
                                    ),
                                    SizedBox(width: width * 0.012),
                                    Text(
                                      "•",
                                      style: TextStyle(
                                        fontSize: height * 0.02,
                                        color: colorScheme.outline,
                                      ),
                                    ),
                                    SizedBox(width: width * 0.012),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.chat_bubble_outline,
                                          size: height * 0.02, // ≈ 16
                                          color: colorScheme.onSurface,
                                        ),
                                        SizedBox(width: width * 0.015),
                                        Obx(
                                          () {
                                            return Text(
                                              '${controller.productReview.length} Reviews',
                                              style: txtTheme()
                                                  .titleSmall!
                                                  .copyWith(
                                                    fontFamily:
                                                        'Plus Jakarta Sans',
                                                    fontSize: height * 0.018,
                                                    height: 1.4,
                                                  ),
                                            );
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              // HOT / TRENDING / FEATURED badges
                              Obx(() {
                                final badges = <String>[];
                                if (controller.productDetials['hot'] == true)
                                  badges.add('Hot');
                                if (controller.productDetials['trending'] ==
                                    true) badges.add('Trending');
                                if (controller.productDetials['featured'] ==
                                    true) badges.add('Featured');
                                if (badges.isEmpty) return SizedBox.shrink();
                                return Padding(
                                  padding: EdgeInsets.only(top: height * 0.008),
                                  child: Wrap(
                                    spacing: 6,
                                    children: badges.map((b) {
                                      final bg = b == 'Hot'
                                          ? Colors.orange.shade100
                                          : b == 'Trending'
                                              ? Colors.blue.shade100
                                              : Colors.purple.shade100;
                                      final fg = b == 'Hot'
                                          ? Colors.orange.shade800
                                          : b == 'Trending'
                                              ? Colors.blue.shade800
                                              : Colors.purple.shade800;
                                      return Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: bg,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(b,
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: fg)),
                                      );
                                    }).toList(),
                                  ),
                                );
                              }),

                              // STOCK STATUS badge
                              Obx(() {
                                final variants = controller
                                    .productDetials['variants'] as List?;
                                final v =
                                    (variants != null && variants.isNotEmpty)
                                        ? variants[controller
                                            .selectedVariantIndex.value] as Map?
                                        : null;
                                final qty = v?['quantity'];
                                final inStock = qty == null ||
                                    (qty != 0 &&
                                        qty != false &&
                                        qty.toString() != '0');
                                return Padding(
                                  padding: EdgeInsets.only(top: height * 0.008),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: inStock
                                              ? Colors.green.shade50
                                              : Colors.red.shade50,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                              color: inStock
                                                  ? Colors.green
                                                  : Colors.red),
                                        ),
                                        child: Text(
                                          inStock ? 'In Stock' : 'Out of Stock',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: inStock
                                                ? Colors.green.shade700
                                                : Colors.red.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),

                              // SKU + BARCODE row
                              Obx(() {
                                final variants = controller
                                    .productDetials['variants'] as List?;
                                final v =
                                    (variants != null && variants.isNotEmpty)
                                        ? variants[controller
                                            .selectedVariantIndex.value] as Map?
                                        : null;
                                final sku = v?['sku']?.toString() ?? '';
                                final barcode = v?['barcode']?.toString() ?? '';
                                if (sku.isEmpty && barcode.isEmpty)
                                  return SizedBox.shrink();
                                return Padding(
                                  padding: EdgeInsets.only(top: height * 0.006),
                                  child: Row(
                                    children: [
                                      if (sku.isNotEmpty)
                                        Text('SKU: $sku',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade600)),
                                      if (sku.isNotEmpty && barcode.isNotEmpty)
                                        SizedBox(width: 16),
                                      if (barcode.isNotEmpty)
                                        Text('Barcode: $barcode',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade600)),
                                    ],
                                  ),
                                );
                              }),

                              // COLOR SELECTOR - Make it reactive
                              Obx(
                                () => (controller.colors.isEmpty ||
                                        controller.productDetials['type'] !=
                                            'variable')
                                    ? SizedBox
                                        .shrink() // Hide if no colors or not variable
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: height * 0.01),
                                          Text(
                                            'Color',
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: height * 0.018,
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          SizedBox(height: height * 0.01),
                                          Container(
                                            width: width * 0.90,
                                            height: height * 0.045,
                                            child: Row(
                                              children: List.generate(
                                                  controller.colors.length,
                                                  (index) {
                                                final bool isActive = index ==
                                                    controller
                                                        .selectedColorIndex
                                                        .value;
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                    right: index !=
                                                            controller.colors
                                                                    .length -
                                                                1
                                                        ? width * 0.02
                                                        : 0,
                                                  ),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      controller
                                                          .selectedColorIndex
                                                          .value = index;
                                                      controller
                                                          .updateSelectedVariant();
                                                    },
                                                    child: Container(
                                                      width: width * 0.162,
                                                      height: height * 0.045,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal:
                                                            width * 0.032,
                                                        vertical:
                                                            height * 0.0075,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: isActive
                                                            ? colorScheme
                                                                .primary
                                                            : colorScheme
                                                                .surface,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    height * 2),
                                                        border: Border.all(
                                                          color: isActive
                                                              ? colorScheme
                                                                  .primary
                                                              : colorScheme
                                                                  .outline,
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          controller
                                                              .colors[index],
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Plus Jakarta Sans',
                                                            fontSize:
                                                                height * 0.015,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: isActive
                                                                ? colorScheme
                                                                    .onPrimary
                                                                : colorScheme
                                                                    .onSurface,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),

                              // SIZE SELECTOR - Make it reactive
                              Obx(
                                () => (controller.sizes.isEmpty ||
                                        controller.productDetials['type'] !=
                                            'variable')
                                    ? SizedBox
                                        .shrink() // Hide if no sizes or not variable
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: height * 0.01),
                                          Text(
                                            'Size',
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: height * 0.018,
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          SizedBox(height: height * 0.01),
                                          Container(
                                            width: width * 0.90,
                                            height: height * 0.045,
                                            child: Row(
                                              children: List.generate(
                                                  controller.sizes.length,
                                                  (index) {
                                                final bool isActive = index ==
                                                    controller.selectedSizeIndex
                                                        .value;
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                    right: index !=
                                                            controller.sizes
                                                                    .length -
                                                                1
                                                        ? width * 0.02
                                                        : 0,
                                                  ),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      controller
                                                          .selectedSizeIndex
                                                          .value = index;
                                                      controller
                                                          .updateSelectedVariant();
                                                    },
                                                    child: Container(
                                                      width: width * 0.162,
                                                      height: height * 0.045,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal:
                                                            width * 0.032,
                                                        vertical:
                                                            height * 0.0075,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: isActive
                                                            ? colorScheme
                                                                .primary
                                                            : colorScheme
                                                                .surface,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    height * 2),
                                                        border: Border.all(
                                                          color: isActive
                                                              ? colorScheme
                                                                  .primary
                                                              : colorScheme
                                                                  .outline,
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          controller
                                                              .sizes[index],
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Plus Jakarta Sans',
                                                            fontSize:
                                                                height * 0.015,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: isActive
                                                                ? colorScheme
                                                                    .onPrimary
                                                                : colorScheme
                                                                    .onSurface,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),

                              SizedBox(height: height * 0.01),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: width * 0.535, // ≈ 200.15
                                    child: Text(
                                      "Description",
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 14, // ≈ 16
                                        fontWeight: FontWeight.w700, // Bold
                                        height: 1.75, // ≈ 28
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Color.fromARGB(
                                                255, 216, 216, 216)),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        elevation: 0,
                                        backgroundColor: Colors.transparent,
                                      ),
                                      onPressed: () {
                                        reviewModal(controller);
                                      },
                                      child: Text('Add Review',
                                          style: textTheme.titleMedium!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      colorScheme.onSurface))),
                                ],
                              ),

                              SizedBox(height: height * 0.004), // ≈ gap 10.46

                              // Remove the Expanded widget
                              Container(
                                width: width * 0.92,
                                child: Obx(() {
                                  final description = controller
                                          .productDetials['long_content'] ??
                                      controller.productDetials['content'] ??
                                      "";
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min, // Add this
                                    children: [
                                      Html(
                                        data: description,
                                        style: {
                                          "body": Style(
                                            fontSize: FontSize(12),
                                            fontWeight: FontWeight.w700,
                                            color: colorScheme.onSurfaceVariant,
                                            maxLines: controller
                                                    .isDescriptionExpanded.value
                                                ? 100
                                                : 2,
                                            textOverflow: TextOverflow.ellipsis,
                                          ),
                                          "span": Style(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                          "font": Style(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        },
                                      ),
                                      if (description.length > 150)
                                        GestureDetector(
                                          onTap: () =>
                                              controller.toggleDescription(),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                top: height * 0.01),
                                            child: Text(
                                              controller.isDescriptionExpanded
                                                      .value
                                                  ? 'Read less'
                                                  : 'Read more',
                                              style: TextStyle(
                                                fontSize: height * 0.016,
                                                fontWeight: FontWeight.w700,
                                                color: colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                }),
                              ),
                              // TAGS section
                              Obx(() {
                                final tags =
                                    controller.productDetials['tags'] as List?;
                                if (tags == null || tags.isEmpty) {
                                  return SizedBox.shrink();
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: height * 0.015),
                                    Text(
                                      'Tags',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: height * 0.008),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: tags.map((tag) {
                                        final name = (tag is Map)
                                            ? tag['name']?.toString() ?? ''
                                            : tag.toString();
                                        if (name.isEmpty) {
                                          return SizedBox.shrink();
                                        }
                                        return Chip(
                                          label: Text(
                                            name,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          backgroundColor: Colors.grey.shade100,
                                          side: BorderSide(
                                              color: Colors.grey.shade300),
                                          padding: EdgeInsets.zero,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                );
                              }),

                              const SizedBox(height: 50),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _addToCartFooter(width: width, height: height),
      ),
    );
  }

  Widget _addToCartFooter({
    required final width,
    required final height,
  }) {
    return Container(
      width: width, // ≈ 393
      height: height * 0.10, // ≈ 80
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.06, // ≈ 24
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: width * 0.30, // ≈ 118
            height: height * 0.06, // ≈ 48
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: height * 0.05, // ≈ 40
                  height: height * 0.05, // ≈ 40
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(Get.context!).colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.remove,
                      size: height * 0.025, // ≈ 20
                    ),
                    onPressed: () {
                      controller.decrement();
                    },
                  ),
                ),
                SizedBox(
                  width: width * 0.075, // ≈ 30
                  height: height * 0.06, // ≈ 48
                  child: Center(
                    child: Obx(() {
                      return Text(
                        controller.count.toString(),
                        style: txtTheme().displayMedium!.copyWith(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: height * 0.02, // ≈ 16
                              height: 1.75,
                            ),
                      );
                    }),
                  ),
                ),
                Container(
                  width: height * 0.05, // ≈ 40
                  height: height * 0.05, // ≈ 40
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(Get.context!).colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      controller.increment();
                    },
                    icon: Icon(
                      Icons.add,
                      size: height * 0.025, // ≈ 20
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: height * 0.06, // ≈ 48
            width: width * 0.45,
            child: Obx(() => PrimaryActionButton(
                  text: "Add Cart",
                  isLoading: controller.isLoading.value,
                  onPressed: () async {
                    HelperFunctions().showOverlayLoader();

                    await controller.addToCart().then((value) {
                      Get.until((route) => !Get.isDialogOpen!);
                      return Get.toNamed(Routes.CART);
                    });
                  },
                )),
          ),
        ],
      ),
    );
  }
}

reviewModal(ProductController controller) {
  TextEditingController reviewController = TextEditingController();
  int rating = 3;
  final colorScheme = Theme.of(Get.context!).colorScheme;
  return Get.dialog(AlertDialog(
      backgroundColor: colorScheme.surface,
      content: SizedBox(
        // width: MediaQuery.of(context).size.width * 80,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Write Review',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                RatingBar.builder(
                  initialRating: 3,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: EdgeInsets.zero,
                  itemBuilder: (context, _) => Transform.scale(
                    scale: 0.6,
                    child: const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                  ),
                  onRatingUpdate: (value) {
                    rating = value.toInt();
                  },
                ),
                const SizedBox(height: 10),
                Text("Review:",
                    style: TextStyle(
                        fontSize: 14, color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: reviewController,
                  maxLength: 300,
                  scrollPhysics: const AlwaysScrollableScrollPhysics(),
                  onChanged: (value) {
                    // .text = value;
                  },
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(Get.context!).colorScheme.primary,
                            width: 1)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(Get.context!).colorScheme.outline,
                            width: 1)),
                  ),
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  maxLines: 6,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  Get.back();
                },
                child: SizedBox(
                    height: 45,
                    child: Center(
                      child: Text('Back'.toUpperCase(),
                          style: Theme.of(Get.context!)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                color: Theme.of(Get.context!)
                                    .colorScheme
                                    .onSurface,
                              )),
                    )),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    if (reviewController.text.isNotEmpty) {
                      // print('23234554');
                      controller.postReview(
                          summary: reviewController.text, rating: rating);
                      Get.back();
                    } else {
                      // Get.showSnackbar(const GetSnackBar(
                      //   message: 'Enter review',
                      // ));
                      HelperFunctions().showSnackBarError('Enter review');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(Get.context!).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Submit'.toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(Get.context!).colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
            ),
          ],
        ),
      ]));
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.wishListTap,
    required this.addToCartTap,
    required this.controller,
    required this.btntext,
  }) : super(key: key);

  final VoidCallback wishListTap;
  final String btntext;
  final Function() addToCartTap;
  final ProductController controller;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color:
                    Theme.of(Get.context!).colorScheme.outline.withOpacity(0.3),
                spreadRadius: 0,
                blurRadius: 2),
          ],
        ),
        width: Get.width,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  widget.wishListTap();
                  _controller
                      .forward(
                        from: 0.0,
                      )
                      .then((value) => _controller.reverse());
                },
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Obx(
                            () {
                              final wishlistService =
                                  Get.find<WishListService>();
                              return wishlistService
                                      .isInWishlist(widget.controller.productId)
                                  ? SvgPicture.asset('assets/icon/like.svg')
                                  : SvgPicture.asset('assets/icon/unlike.svg');
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text("WISHLIST",
                            style: Theme.of(Get.context!)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  fontSize: 16,
                                  color: Theme.of(Get.context!)
                                      .colorScheme
                                      .onSurface,
                                ))
                      ],
                    );
                  },
                ),
              ),
            ),
            const VerticalDivider(
              width: 20,
              thickness: 1.5,
              indent: 10,
              endIndent: 10,
            ),
            Expanded(
              child: GestureDetector(
                onTap: widget.addToCartTap,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icon/addtobag.svg',
                      width: 16,
                    ),
                    const SizedBox(width: 10),
                    Text(widget.btntext,
                        style: Theme.of(Get.context!)
                            .textTheme
                            .headlineSmall!
                            .copyWith(
                              fontSize: 16,
                              color:
                                  Theme.of(Get.context!).colorScheme.onSurface,
                            )),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

class ProductGallery extends StatelessWidget {
  final ProductController controller;
  final List productGallery;

  ColorScheme get colorScheme => Theme.of(Get.context!).colorScheme;

  const ProductGallery({
    super.key,
    required this.controller,
    required this.productGallery,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Obx(() {
      // Touch an observable to satisfy GetX requirement that at least one observable is used,
      // even if productGallery is initially empty.
      controller.selectedImageIndex.value;

      print("Gallery rebuilding with ${productGallery.length} images");

      if (productGallery.isEmpty) {
        return _buildShimmerLoading(height, width);
      } else {
        return _buildGalleryWithThumbnails(context, height, width);
      }
    });
  }

  Widget _buildShimmerLoading(double height, double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Shimmer.fromColors(
        enabled: true,
        direction: ShimmerDirection.ltr,
        loop: 0,
        period: const Duration(seconds: 1),
        baseColor: colorScheme.surfaceVariant,
        highlightColor: colorScheme.onSurfaceVariant.withOpacity(0.1),
        child: SizedBox(
          height: height * 0.47,
          width: width * 0.92,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height * 0.028),
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryWithThumbnails(
      BuildContext context, double height, double width) {
    // Extract image paths safely with null checks
    List<String> imagePaths = [];

    try {
      imagePaths = productGallery.map<String>((item) {
        String imagePath = '';

        // Handle different image structures
        if (item is String) {
          // If it's directly a string URL
          imagePath = item;
        } else if (item is Map) {
          // If it's a map with filepath or filename
          imagePath = item['filepath'] ??
              item['filename'] ??
              item['image'] ??
              item['url'] ??
              '';
        }

        // Add base URL if needed and not already a full URL
        if (imagePath.isNotEmpty && !imagePath.startsWith('http')) {
          return assetURL + imagePath;
        }

        return imagePath;
      }).toList();
    } catch (e) {
      print("Error parsing gallery images: $e");
      return SizedBox.shrink();
    }

    // Ensure selectedImageIndex is valid
    if (controller.selectedImageIndex.value >= imagePaths.length) {
      controller.selectedImageIndex.value = 0;
    }

    return Container(
      width: width * 0.92,
      height: height * 0.47,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height * 0.028),
        image: imagePaths.isNotEmpty
            ? DecorationImage(
                image: CachedNetworkImageProvider(
                  imagePaths[controller.selectedImageIndex.value],
                ),
                fit: BoxFit.cover,
              )
            : null,
        color: Colors.grey.shade200, // Fallback color
      ),
      child: imagePaths.isEmpty
          ? Center(child: Text('No images available'))
          : Stack(
              children: [
                // Full screen tap (Move this BEFORE thumbnails so thumbnails are clickable)
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Get.to(
                          () => ImageSlider(),
                          arguments: {"images": productGallery},
                        );
                      },
                      borderRadius: BorderRadius.circular(height * 0.028),
                    ),
                  ),
                ),

                // Thumbnails
                Positioned(
                  left: width * 0.037,
                  bottom: height * 0.02,
                  child: Container(
                    width: width * 0.845,
                    height: height * 0.085,
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.02,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(height * 0.02),
                    ),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: imagePaths.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(width: width * 0.02),
                      itemBuilder: (context, index) {
                        final isActive =
                            controller.selectedImageIndex.value == index;

                        return GestureDetector(
                          onTap: () {
                            controller.selectedImageIndex.value = index;
                          },
                          child: Container(
                            width: height * 0.085,
                            height: height * 0.085,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(height * 0.02),
                              border: isActive
                                  ? Border.all(
                                      color: colorScheme.primary,
                                      width: 2,
                                    )
                                  : null,
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                  imagePaths[index],
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class dileveryOption extends StatelessWidget {
  dileveryOption({Key? key, required this.icon, required this.services})
      : super(key: key);
  String icon;
  String services;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(icon),
        const SizedBox(width: 10),
        Text(services,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(Get.context!).colorScheme.onSurface,
            ))
      ],
    );
  }
}
