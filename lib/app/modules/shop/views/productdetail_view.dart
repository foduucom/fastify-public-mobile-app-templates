import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:zouhi/app/modules/auth/auth_details.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/modules/cart/controllers/cart_controller.dart';
import 'package:zouhi/app/modules/shop/controllers/productdetial_controller.dart';
import 'package:zouhi/app/modules/shop/views/all_review_screen.dart';
import 'package:zouhi/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/ImagePreviewMultipleView.dart';
import 'package:zouhi/components/buttons/appbutton.dart';
import 'package:zouhi/components/commonWidgets/appbarIcons.dart';
import 'package:zouhi/components/gridviewproductcard.dart';
import 'package:zouhi/components/review.dart';
import 'package:zouhi/components/shimmer_effects.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:zouhi/components/product_image_placeholder.dart';
import 'package:get/get.dart';
import 'package:zouhi/components/cart_auth_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zouhi/app/modules/shop/views/quote_request_dialog.dart';
import 'package:zouhi/components/loginShowDialog.dart'; // Import the helper file
import 'package:zouhi/app/controllers/internetconnection_controller.dart';
import 'package:zouhi/components/offline_ribbon.dart';
import 'package:zouhi/components/check_internet_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:zouhi/components/support_call_sheet.dart';
import 'package:zouhi/components/catalog_mode_bottom_sheet.dart';

class ProductdetailView extends GetView<ProductdetialController> {
  ProductdetailView({Key? key}) : super(key: key);

  // ProductdetialController controller =
  //     Get.put(ProductdetialController(), permanent: false);
  // ShopController shopController = Get.find<ShopController>();

  WishlistController wishListController = Get.find<WishlistController>();

  bool _shouldShowToggle(String? htmlContent, {int threshold = 150}) {
    if (htmlContent == null || htmlContent.isEmpty) return false;
    final plainText =
        htmlContent.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ').trim();
    return plainText.length > threshold;
  }

  @override
  Widget build(BuildContext context) {
    Get.create(() => ProductdetialController(), permanent: false);
    final controller = Get.find<ProductdetialController>();

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Obx(() {
          if (controller.productDetials['name'] == null) {
            return const ShimmerEffect(height: 10, width: 100);
          } else {
            return Text(
              controller.productDetials['name'].toString(),
              style: TextStyle(
                  fontFamily: 'Poppins',
                  color: context.themeTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            );
          }
        }),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Builder(
                builder: (btnContext) => IconButton(
                    tooltip: 'Share',
                    onPressed: () => controller.shareContent(btnContext),
                    icon: SvgPicture.asset(
                      'assets/icon/appbarshare.svg',
                      colorFilter: ColorFilter.mode(
                          context.themeTextColor, BlendMode.srcIn),
                    )),
              ),
              // IconButton(
              //     onPressed: () {},
              //     icon: SvgPicture.asset('assets/icon/appbarlike.svg')),
              Obx(
                () => Get.find<BottombarController>().cartbadge(
                    child: CartIcon(() {
                      BottombarController.switchTab(2);
                    }),
                    badgeNumber: Get.find<CartController>().cartItemCount),
              ),
              const SizedBox(
                width: 14,
              )
            ],
          )
          // InkWell(
          //   onTap: () {},
          //   child: SvgPicture.asset('assets/icon/appbarshare.svg'),
          // ),
          // const SizedBox(width: 10),
          // InkWell(
          //   onTap: () {},
          //   child: SvgPicture.asset('assets/icon/appbarlike.svg'),
          // ),
          // const SizedBox(width: 10),
          // InkWell(
          //   onTap: () {
          //     Get.find<BottombarController>().goToCart();
          //   },
          //   child: Obx(() {
          //     return Badge(
          //       showBadge: Get.find<BottombarController>().cart.isNotEmpty
          //           ? true
          //           : false,
          //       position: const BadgePosition(top: 0, start: 15),
          //       badgeContent: Text(
          //         Get.find<BottombarController>().cart.length.toString(),
          //         style: txtTheme()
          //             .headlineSmall!
          //             .copyWith(color: context.themeWhiteColor),
          //       ),
          //       child: SvgPicture.asset('assets/icon/appbarshop.svg'),
          //     );
          //   }),
          // ),
        ],
        titleSpacing: 0.0,
        // backgroundColor: Colors.transparent,
        elevation: 0,
        // bottom: PreferredSize(
        //   preferredSize: const Size.fromHeight(40),
        //   child: Obx(() {
        //     var categories = controller.productDetials['categories'];
        //     if (categories == null || categories is! List || categories.isEmpty) {
        //       return const SizedBox.shrink();
        //     }
        //     return Container(
        //       height: 40,
        //       padding: const EdgeInsets.symmetric(horizontal: 16),
        //       alignment: Alignment.centerLeft,
        //       child: ListView.separated(
        //         scrollDirection: Axis.horizontal,
        //         itemCount: categories.length,
        //         separatorBuilder: (context, index) => Icon(Icons.chevron_right, size: 16, color: context.themeSecondrytext),
        //         itemBuilder: (context, index) {
        //           return Text(
        //             categories[index]['name'] ?? '',
        //             style: TextStyle(fontSize: 12, color: context.themeSecondrytext, fontWeight: FontWeight.w500),
        //           );
        //         },
        //       ),
        //     );
        //   }),
        // ),
      ),
      body: Column(
        children: [
          const OfflineRibbon(),
          Expanded(
            child: Obx(() {
              final isOffline = !Get.find<InternetconnectionController>()
                  .connectionStatus
                  .value;
              if (isOffline &&
                  controller.productDetials.isEmpty &&
                  !controller.isLoading.value) {
                return InternetConnectionError(
                  onRetry: () {
                    controller.getProductDetials(id: controller.productId);
                  },
                );
              }
              return Stack(
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    left: 0,
                    bottom: 0,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Obx(
                          //   () {
                          //     return ProductGallery(
                          //         controller: controller,
                          //         isLoading: controller.isLoading.value,
                          //         productGallery: controller.productDetials['type'] ==
                          //                 'variant'
                          //             ? controller.productDetials['variant_ids']
                          //                     [controller.selectedVariantIndex.value]
                          //                 ['gallery']
                          //             : controller.productGallery.isEmpty
                          //                 ? [
                          //                     controller
                          //                         .productDetials['featured_image']
                          //                   ]
                          //                 : controller.productGallery);
                          //   },
                          // ),
                          Obx(() {
                            List<dynamic> gallery = [];

                            if (controller.productDetials['type'] ==
                                    'variable' ||
                                controller.productDetials['type'] ==
                                    'variant') {
                              var variants = controller.productVariants;
                              if (variants.isNotEmpty &&
                                  controller.selectedVariantIndex.value <
                                      variants.length) {
                                var selectedVariant = variants[
                                    controller.selectedVariantIndex.value];

                                if (selectedVariant['gallery'] != null &&
                                    selectedVariant['gallery'].isNotEmpty) {
                                  gallery =
                                      List.from(selectedVariant['gallery']);
                                }

                                // Include front_image and back_image if available and not already in gallery
                                if (selectedVariant['front_image'] != null) {
                                  gallery.add(selectedVariant['front_image']);
                                }
                                if (selectedVariant['back_image'] != null) {
                                  gallery.add(selectedVariant['back_image']);
                                }
                              }

                              if (gallery.isEmpty) {
                                // 🔄 Fallback to featured_image or product gallery
                                gallery = controller.productGallery.isEmpty
                                    ? [
                                        controller
                                            .productDetials['featured_image']
                                      ]
                                    : controller.productGallery;
                              }
                            } else {
                              // Non-variant product
                              gallery = controller.productGallery.isEmpty
                                  ? [
                                      controller
                                          .productDetials['featured_image']
                                    ]
                                  : controller.productGallery;
                            }

                            return Stack(
                              children: [
                                ProductGallery(
                                  controller: controller,
                                  isLoading: controller.isLoading.value,
                                  productGallery: gallery,
                                ),
                                // 💰 Innovative Floating Price Badge
                                // Positioned(
                                //   bottom: 16,
                                //   right: 16,
                                //   child: Obx(() {
                                //     final details = controller.productDetials;
                                //     final variants = (details['variants'] ?? details['variant_ids'] ?? []) as List;
                                //     if (variants.isEmpty) return const SizedBox.shrink();

                                //     int index = controller.selectedVariantIndex.value;
                                //     if (index >= variants.length) index = 0;
                                //     var selectedVariant = variants[index];

                                //     double price = double.tryParse(selectedVariant['price']?.toString() ?? '0') ?? 0;
                                //     double? salePrice = double.tryParse(selectedVariant['sale_price']?.toString() ?? '');
                                //     if (salePrice != null && salePrice <= 0) salePrice = null;

                                //     double displayPrice = (salePrice != null && salePrice < price) ? salePrice : price;
                                //     bool hasDiscount = salePrice != null && salePrice < price;

                                //     if (!hasDiscount) return const SizedBox.shrink();

                                //     return Container(
                                //       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                //       decoration: BoxDecoration(
                                //         color: Colors.white.withOpacity(0.9),
                                //         borderRadius: BorderRadius.circular(30),
                                //         boxShadow: [
                                //           BoxShadow(
                                //             color: Colors.black.withOpacity(0.1),
                                //             blurRadius: 10,
                                //             offset: const Offset(0, 4),
                                //           ),
                                //         ],
                                //       ),
                                //       child: Text(
                                //         "₹${displayPrice.toStringAsFixed(2)}",
                                //         style: TextStyle(
                                //           color: context.themeTextColor,
                                //           fontSize: 16,
                                //           fontWeight: FontWeight.w900,
                                //           fontFamily: 'Poppins',
                                //         ),
                                //       ),
                                //     );
                                //   }),
                                // ),
                              ],
                            );
                          }),

                          const SizedBox(height: 8.0),
                          Obx(() {
                            List<dynamic> gallery = [];
                            if (controller.productDetials['type'] ==
                                    'variable' ||
                                controller.productDetials['type'] ==
                                    'variant') {
                              var variants = controller.productVariants;
                              if (variants.isNotEmpty &&
                                  controller.selectedVariantIndex.value <
                                      variants.length) {
                                var selectedVariant = variants[
                                    controller.selectedVariantIndex.value];
                                if (selectedVariant['gallery'] != null &&
                                    selectedVariant['gallery'].isNotEmpty) {
                                  gallery =
                                      List.from(selectedVariant['gallery']);
                                }
                                if (selectedVariant['front_image'] != null) {
                                  gallery.add(selectedVariant['front_image']);
                                }
                                if (selectedVariant['back_image'] != null) {
                                  gallery.add(selectedVariant['back_image']);
                                }
                              }
                              if (gallery.isEmpty) {
                                gallery = controller.productGallery.isEmpty
                                    ? [
                                        controller
                                            .productDetials['featured_image']
                                      ]
                                    : controller.productGallery;
                              }
                            } else {
                              gallery = controller.productGallery.isEmpty
                                  ? [
                                      controller
                                          .productDetials['featured_image']
                                    ]
                                  : controller.productGallery;
                            }

                            final validGallery = gallery.where((item) {
                              final img = HelperFunctions().getImage(item);
                              return img.isNotEmpty &&
                                  img != HelperFunctions.getNoImage();
                            }).toList();

                            return validGallery.length <= 1
                                ? Container()
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: List.generate(
                                      validGallery.length,
                                      (index) => Obx(() {
                                        return Container(
                                          width: controller.selectedPageIndex
                                                      .value ==
                                                  index
                                              ? 30
                                              : 9,
                                          height: 9,
                                          margin: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: controller
                                                          .selectedPageIndex
                                                          .value ==
                                                      index
                                                  ? context.themeRedColor
                                                  : context.themegreyColor),
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

                                    // 🏷️ Product Title
                                    Obx(() => controller
                                                .productDetials['name'] ==
                                            null
                                        ? const ShimmerEffect(
                                            height: 20, width: 200)
                                        : Text(
                                            controller.productDetials['name']
                                                .toString(),
                                            style: txtTheme()
                                                .displayMedium!
                                                .copyWith(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  height: 1.2,
                                                  color: context.themeTextColor,
                                                ),
                                          )),
                                    const SizedBox(height: 12),

                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // 💰 Price Section
                                        Expanded(
                                          child: Obx(() {
                                            final details =
                                                controller.productDetials;
                                            final variants =
                                                (details['variants'] ??
                                                    details['variant_ids'] ??
                                                    []) as List;

                                            if (variants.isEmpty &&
                                                details['price'] == null) {
                                              return const ShimmerEffect(
                                                  height: 24, width: 120);
                                            }

                                            int index = controller
                                                .selectedVariantIndex.value;

                                            var selectedVariant;
                                            if (variants.isNotEmpty &&
                                                index < variants.length) {
                                              selectedVariant = variants[index];
                                            } else {
                                              selectedVariant =
                                                  details; // Fallback to main product price
                                            }

                                            double price = (double.tryParse(
                                                        selectedVariant['price']
                                                                ?.toString() ??
                                                            details['price']
                                                                ?.toString() ??
                                                            '0') ??
                                                    0)
                                                .toConvertedPrice();
                                            double? salePriceRaw =
                                                double.tryParse(selectedVariant[
                                                            'sale_price']
                                                        ?.toString() ??
                                                    details['sale_price']
                                                        ?.toString() ??
                                                    '');
                                            double? salePrice =
                                                (salePriceRaw != null &&
                                                        salePriceRaw > 0)
                                                    ? salePriceRaw
                                                        .toConvertedPrice()
                                                    : null;

                                            bool hasDiscount =
                                                salePrice != null &&
                                                    salePrice < price;
                                            double displayPrice =
                                                hasDiscount ? salePrice! : price;

                                            final catalogMode =
                                                controller.productDetials['catalog_mode'];
                                            final bool isCatalogMode =
                                                (catalogMode is Map &&
                                                        catalogMode['is_enabled'] == true) ||
                                                    displayPrice <= 0.0 ||
                                                    price <= 0.0;
                                            final String catalogButtonText =
                                                (catalogMode is Map &&
                                                        catalogMode['button_text'] != null)
                                                    ? catalogMode['button_text']
                                                        .toString()
                                                    : 'Contact for Pricing';
                                            if (isCatalogMode) {
                                              hasDiscount = false;
                                            }

                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: isCatalogMode
                                                          ? () {
                                                              showCatalogModeBottomSheet(
                                                                context,
                                                                productName: controller
                                                                        .productDetials['name']
                                                                        ?.toString() ??
                                                                    'Product',
                                                                productId: controller
                                                                        .productId
                                                                        ?.toString() ??
                                                                    '',
                                                                productImage: controller
                                                                    .productDetials['featured_image'],
                                                                buttonText:
                                                                    catalogButtonText,
                                                              );
                                                            }
                                                          : null,
                                                      child: Text(
                                                        isCatalogMode
                                                            ? catalogButtonText
                                                            : "${controller.currencySymbol.value}${displayPrice.toStringAsFixed(2)}",
                                                        style: txtTheme()
                                                            .displayMedium!
                                                            .copyWith(
                                                              fontSize: isCatalogMode
                                                                  ? 20
                                                                  : 24,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              color: isCatalogMode
                                                                  ? context
                                                                      .themePrimaryColor
                                                                  : context
                                                                      .themeTextColor,
                                                              fontFamily:
                                                                  'Poppins',
                                                            ),
                                                      ),
                                                    ),
                                                    if (hasDiscount && !isCatalogMode) ...[
                                                      const SizedBox(width: 8),
                                                      Flexible(
                                                        child: Text(
                                                          "${controller.currencySymbol.value}${price.toStringAsFixed(2)}",
                                                          style: txtTheme()
                                                              .headlineSmall!
                                                              .copyWith(
                                                                fontSize: 14,
                                                                color: context
                                                                    .themeTextColor
                                                                    .withOpacity(
                                                                        0.4),
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough,
                                                                fontFamily:
                                                                    'Lato',
                                                              ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                if (hasDiscount && !isCatalogMode) ...[
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: context
                                                          .themeRedColor
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: Text(
                                                      "${((price - salePrice!) * 100 / price).round()}% OFF",
                                                      style: TextStyle(
                                                        color: context
                                                            .themeRedColor,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Text(
                                                        isCatalogMode
                                                            ? "Custom B2B & Wholesale Pricing"
                                                            : "Inclusive of all taxes",
                                                        style: txtTheme()
                                                            .headlineSmall!
                                                            .copyWith(
                                                                color: isCatalogMode
                                                                    ? context.themePrimaryColor
                                                                    : context.themeGreenColor,
                                                                fontWeight: isCatalogMode
                                                                    ? FontWeight.w600
                                                                    : FontWeight.normal,
                                                                fontSize: 11)),
                                                  ],
                                                ),
                                              ],
                                            );
                                          }),
                                        ),
                                        const SizedBox(width: 12),
                                        // 🏢 Brand Tag (Relocated to Right)
                                        Obx(() {
                                          var brand = controller
                                              .productDetials['brand'];
                                          if (brand == null || brand is! Map)
                                            return const SizedBox.shrink();
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: context.themegreyColor
                                                  .withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (brand['featured_image'] !=
                                                    null)
                                                  Builder(
                                                    builder: (context) {
                                                      final brandImg =
                                                          HelperFunctions()
                                                              .getImage(brand[
                                                                  'featured_image']);
                                                      if (brandImg.isEmpty ||
                                                          brandImg ==
                                                              HelperFunctions
                                                                  .getNoImage() ||
                                                          !(Uri.tryParse(
                                                                      brandImg)
                                                                  ?.hasAuthority ??
                                                              false)) {
                                                        return const SizedBox
                                                            .shrink();
                                                      }
                                                      return Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: context
                                                              .themeWhiteColor,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: ClipOval(
                                                          child:
                                                              CachedNetworkImage(
                                                            imageUrl: brandImg,
                                                            height: 18,
                                                            width: 18,
                                                            fit: BoxFit.cover,
                                                            errorWidget: (context,
                                                                    url,
                                                                    error) =>
                                                                const SizedBox
                                                                    .shrink(),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                const SizedBox(width: 8),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      "BRAND",
                                                      style: TextStyle(
                                                        fontSize: 8,
                                                        color: context
                                                            .themeTextColor
                                                            .withOpacity(0.5),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                    Text(
                                                      brand['name'] ?? '',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: context
                                                            .themeTextColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(width: 4),
                                                const Icon(Icons.verified,
                                                    color: Colors.blue,
                                                    size: 14),
                                              ],
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                    //const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: Obx(() {
                                        final rawContent = controller
                                            .productDetials['content']
                                            ?.toString();
                                        if (rawContent == null ||
                                            rawContent.isEmpty) {
                                          return Container();
                                        }
                                        final hasToggle =
                                            _shouldShowToggle(rawContent);
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ConstrainedBox(
                                              constraints: !hasToggle ||
                                                      controller
                                                          .isContentExpanded
                                                          .value
                                                  ? const BoxConstraints()
                                                  : const BoxConstraints(
                                                      maxHeight: 120),
                                              child: ClipRect(
                                                child: Stack(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  children: [
                                                    if (!hasToggle ||
                                                        controller
                                                            .isContentExpanded
                                                            .value)
                                                      HtmlWidget(rawContent)
                                                    else
                                                      OverflowBox(
                                                        alignment:
                                                            Alignment.topCenter,
                                                        minHeight: 0.0,
                                                        maxHeight:
                                                            double.infinity,
                                                        child: HtmlWidget(
                                                            rawContent),
                                                      ),
                                                    if (hasToggle &&
                                                        !controller
                                                            .isContentExpanded
                                                            .value)
                                                      Positioned(
                                                        bottom: 0,
                                                        left: 0,
                                                        right: 0,
                                                        child: Container(
                                                          height: 40,
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              begin: Alignment
                                                                  .topCenter,
                                                              end: Alignment
                                                                  .bottomCenter,
                                                              colors: [
                                                                Theme.of(
                                                                        context)
                                                                    .scaffoldBackgroundColor
                                                                    .withOpacity(
                                                                        0.0),
                                                                Theme.of(
                                                                        context)
                                                                    .scaffoldBackgroundColor,
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (hasToggle)
                                              InkWell(
                                                onTap: () {
                                                  controller.isContentExpanded
                                                      .toggle();
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 4),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        controller
                                                                .isContentExpanded
                                                                .value
                                                            ? 'See Less'
                                                            : 'See All',
                                                        style: const TextStyle(
                                                          color: Colors.blue,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                      Icon(
                                                        controller
                                                                .isContentExpanded
                                                                .value
                                                            ? Icons
                                                                .keyboard_arrow_up
                                                            : Icons
                                                                .keyboard_arrow_down,
                                                        color: Colors.blue,
                                                        size: 16,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                              Obx(() {
                                var status =
                                    controller.productDetials['status'];
                                var variants =
                                    controller.productDetials['variants'];
                                var content =
                                    controller.productDetials['app_content'];
                                var tags = controller.productDetials['tags'];

                                bool isComingSoon = false;
                                if (status != null && status is Map) {
                                  String name = (status['name'] ?? '')
                                      .toString()
                                      .toLowerCase();
                                  isComingSoon = name.contains('coming soon');
                                }

                                bool hasVariants = variants != null &&
                                    variants is List &&
                                    variants.isNotEmpty;
                                bool hasContent = content != null &&
                                    content.toString().trim().isNotEmpty;
                                bool hasTags = tags != null &&
                                    tags is List &&
                                    tags.isNotEmpty;

                                // If everything in this section is hidden, don't show the divider or padding
                                if (isComingSoon &&
                                    !hasVariants &&
                                    !hasContent &&
                                    !hasTags) {
                                  return const SizedBox.shrink();
                                }

                                return Column(
                                  children: [
                                    Divider(
                                      thickness: 10,
                                      color: context.themegreyColor,
                                    ),
                                    Padding(
                                      padding: pageSurroundingPadding,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // 1. Attribute Selector (Color/Size)
                                          Obx(() {
                                            if (controller
                                                .productAttributes.isEmpty)
                                              return const SizedBox.shrink();
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: controller
                                                  .productAttributes
                                                  .map<Widget>((attr) {
                                                String name =
                                                    attr['name'] ?? '';
                                                List values =
                                                    attr['values'] ?? [];
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text("Select $name",
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14)),
                                                    const SizedBox(height: 10),
                                                    Wrap(
                                                      spacing: 12,
                                                      children: values
                                                          .map<Widget>((val) {
                                                        bool isSelected = controller
                                                                .selectedVariant[
                                                                    name]
                                                                ?.toString()
                                                                .toLowerCase() ==
                                                            val
                                                                .toString()
                                                                .toLowerCase();
                                                        // bool isColor = name
                                                        //         .toLowerCase()
                                                        //         .contains('color') ||
                                                        //     name
                                                        //         .toLowerCase()
                                                        //         .contains('colour');

                                                        // if (isColor) {
                                                        //   // Try to parse color or use a default if it's a name
                                                        //   return GestureDetector(
                                                        //     onTap: () => controller
                                                        //         .onSelectVariant(name,
                                                        //             val.toString()),
                                                        //     child: Container(
                                                        //       width: 36,
                                                        //       height: 36,
                                                        //       decoration: BoxDecoration(
                                                        //         shape: BoxShape.circle,
                                                        //         border: Border.all(
                                                        //           color: isSelected
                                                        //               ? context.themeRedColor
                                                        //               : Colors
                                                        //                   .transparent,
                                                        //           width: 2,
                                                        //         ),
                                                        //       ),
                                                        //       padding:
                                                        //           const EdgeInsets.all(
                                                        //               2),
                                                        //       child: Container(
                                                        //         decoration: BoxDecoration(
                                                        //             shape:
                                                        //                 BoxShape.circle,
                                                        //             color: _getColorFromName(
                                                        //                 val.toString()),
                                                        //             boxShadow: [
                                                        //               BoxShadow(
                                                        //                   color: Colors
                                                        //                       .black
                                                        //                       .withOpacity(
                                                        //                           0.1),
                                                        //                   blurRadius: 4)
                                                        //             ]),
                                                        //       ),
                                                        //     ),
                                                        //   );
                                                        // }

                                                        return ChoiceChip(
                                                          label: Text(
                                                              val.toString()),
                                                          selected: isSelected,
                                                          onSelected:
                                                              (selected) {
                                                            if (selected)
                                                              controller
                                                                  .onSelectVariant(
                                                                      name,
                                                                      val.toString());
                                                          },
                                                          selectedColor: context
                                                              .themeRedColor,
                                                          labelStyle: TextStyle(
                                                            color: isSelected
                                                                ? Colors.white
                                                                : context
                                                                    .themeTextColor,
                                                            fontWeight:
                                                                isSelected
                                                                    ? FontWeight
                                                                        .bold
                                                                    : FontWeight
                                                                        .normal,
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                    const SizedBox(height: 20),
                                                  ],
                                                );
                                              }).toList(),
                                            );
                                          }),

                                          // 1b. Variants Selector List
                                          Obx(() {
                                            var variants =
                                                controller.productVariants;
                                            if (variants.isEmpty)
                                              return const SizedBox.shrink();

                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("Available Combinations",
                                                    style: txtTheme()
                                                        .headlineSmall!
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: context
                                                                .themeTextColor)),
                                                const SizedBox(height: 10),
                                                SizedBox(
                                                  height: 190,
                                                  child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount: variants.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      var variant =
                                                          variants[index];
                                                      return Obx(() {
                                                        bool isSelected = controller
                                                                .selectedVariantIndex
                                                                .value ==
                                                            index;
                                                        return GestureDetector(
                                                          onTap: () => controller
                                                              .selectVariantByIndex(
                                                                  index),
                                                          child: Container(
                                                            width: 140,
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 12),
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: isSelected
                                                                  ? context
                                                                      .themePrimaryColor
                                                                      .withOpacity(
                                                                          0.05)
                                                                  : context
                                                                      .themeWhiteColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              border:
                                                                  Border.all(
                                                                color: isSelected
                                                                    ? context
                                                                        .themeRedColor
                                                                    : context
                                                                        .themegreyColor,
                                                                width:
                                                                    isSelected
                                                                        ? 2
                                                                        : 1,
                                                              ),
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                    child:
                                                                        Container(
                                                                      color: Colors
                                                                          .grey
                                                                          .shade50,
                                                                      child:
                                                                          () {
                                                                        final variantImg = HelperFunctions().getImage(variant['front_image'] ??
                                                                            variant['featured_image'] ??
                                                                            controller.productDetials['featured_image']);
                                                                        final bool
                                                                            hasValidImg =
                                                                            variantImg.isNotEmpty &&
                                                                                variantImg != HelperFunctions.getNoImage() &&
                                                                                (Uri.tryParse(variantImg)?.hasAuthority ?? false);
                                                                        if (!hasValidImg) {
                                                                          return const ProductImagePlaceholder(
                                                                              radius: 8);
                                                                        }
                                                                        return CachedNetworkImage(
                                                                          imageUrl:
                                                                              variantImg,
                                                                          fit: BoxFit
                                                                              .contain,
                                                                          width:
                                                                              double.infinity,
                                                                          errorWidget: (context, url, error) =>
                                                                              const ProductImagePlaceholder(radius: 8),
                                                                          placeholder: (context, url) =>
                                                                              Container(
                                                                            color:
                                                                                Colors.grey.shade100,
                                                                            child:
                                                                                const Center(
                                                                              child: SizedBox(
                                                                                width: 20,
                                                                                height: 20,
                                                                                child: CircularProgressIndicator(strokeWidth: 2),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      }(),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 8),
                                                                Text(
                                                                  variant['name']
                                                                          ?.toString() ??
                                                                      'Variant ${index + 1}',
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                (() {
                                                                    final vP = (double.tryParse((variant['sale_price'] ?? variant['price'] ?? '0.00').toString()) ?? 0.0);
                                                                    final isVContact = vP <= 0.0;
                                                                    return Text(
                                                                      isVContact
                                                                          ? "Contact for Pricing"
                                                                          : "${controller.currencySymbol.value}${vP.toConvertedPrice().toStringAsFixed(2)}",
                                                                      style: TextStyle(
                                                                          fontSize: isVContact ? 10 : 12,
                                                                          color: isVContact ? context.themePrimaryColor : context.themeRedColor,
                                                                          fontWeight: FontWeight.bold),
                                                                    );
                                                                  })(),
                                                                const SizedBox(
                                                                    height: 4),
                                                                (() {
                                                                  final vStatus = variant[
                                                                          'stock_status']
                                                                      ?.toString()
                                                                      .toLowerCase()
                                                                      .replaceAll(
                                                                          '_',
                                                                          '')
                                                                      .replaceAll(
                                                                          ' ',
                                                                          '');
                                                                  var qty = variant[
                                                                          'quantity'] ??
                                                                      variant[
                                                                          'stock'] ??
                                                                      variant[
                                                                          'stock_quantity'];
                                                                  bool inStock =
                                                                      true;
                                                                  int?
                                                                      parsedQty;

                                                                  if (vStatus ==
                                                                      'outofstock') {
                                                                    inStock =
                                                                        false;
                                                                  } else if (qty !=
                                                                      null) {
                                                                    parsedQty =
                                                                        int.tryParse(
                                                                            qty.toString());
                                                                    if (parsedQty !=
                                                                            null &&
                                                                        parsedQty <=
                                                                            0) {
                                                                      inStock =
                                                                          false;
                                                                    }
                                                                  }

                                                                  return Text(
                                                                    !inStock
                                                                        ? "Out of Stock"
                                                                        : qty ==
                                                                                null
                                                                            ? "In Stock"
                                                                            : "In Stock${parsedQty != null ? ' ($parsedQty)' : ''}",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        color: inStock
                                                                            ? context
                                                                                .themeGreenColor
                                                                            : context
                                                                                .themeRedColor,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  );
                                                                })(),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      });
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                              ],
                                            );
                                          }),

                                          // 2. Quantity Selector
                                          Obx(() {
                                            var status = controller
                                                .productDetials['status'];
                                            bool isComingSoon = false;
                                            if (status != null &&
                                                status is Map) {
                                              String name =
                                                  (status['name'] ?? '')
                                                      .toString()
                                                      .toLowerCase();
                                              isComingSoon =
                                                  name.contains('coming soon');
                                            }

                                            if (isComingSoon)
                                              return const SizedBox.shrink();

                                            return Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text("Product Quantity:",
                                                        style: txtTheme()
                                                            .headlineSmall!
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: context
                                                                    .themeTextColor)),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: context.isDark
                                                            ? context
                                                                .themeCardColor
                                                            : context
                                                                .themeWhiteColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        border: Border.all(
                                                          color: context.isDark
                                                              ? context
                                                                  .themeBorderColor
                                                              : const Color(
                                                                  0xFFE2E8F0),
                                                          width: 1.2,
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.02),
                                                            blurRadius: 4,
                                                            offset:
                                                                const Offset(
                                                                    0, 1),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Material(
                                                            color: Colors
                                                                .transparent,
                                                            child: InkWell(
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .horizontal(
                                                                left: Radius
                                                                    .circular(
                                                                        20),
                                                              ),
                                                              onTap: () {
                                                                HapticFeedback
                                                                    .selectionClick();
                                                                controller
                                                                    .decrement();
                                                              },
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 8,
                                                                ),
                                                                child: Obx(
                                                                  () => Icon(
                                                                    Icons
                                                                        .remove_rounded,
                                                                    size: 18,
                                                                    color: controller.count.value <=
                                                                            1
                                                                        ? context
                                                                            .themeTextColor
                                                                            .withOpacity(
                                                                                0.3)
                                                                        : context
                                                                            .themeTextColor,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            constraints:
                                                                const BoxConstraints(
                                                                    minWidth:
                                                                        32),
                                                            alignment: Alignment
                                                                .center,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        4),
                                                            child: Obx(
                                                              () => Text(
                                                                controller.count
                                                                    .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: context
                                                                      .themeTextColor,
                                                                  fontFamily:
                                                                      'Poppins',
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Material(
                                                            color: Colors
                                                                .transparent,
                                                            child: InkWell(
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .horizontal(
                                                                right: Radius
                                                                    .circular(
                                                                        20),
                                                              ),
                                                              onTap: () {
                                                                HapticFeedback
                                                                    .selectionClick();
                                                                controller
                                                                    .increment();
                                                              },
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 8,
                                                                ),
                                                                child: Icon(
                                                                  Icons
                                                                      .add_rounded,
                                                                  size: 18,
                                                                  color: context
                                                                      .themeTextColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (controller.box.read(
                                                                    'userData')?[
                                                                'saap_code'] !=
                                                            null &&
                                                        controller.box.read(
                                                                    'userData')?[
                                                                'saap_code'] !=
                                                            '')
                                                      AppButton(
                                                        width: 100,
                                                        fontSize: 10,
                                                        itemText: 'Bulk Add',
                                                        keypressEvent:
                                                            () async {
                                                          var newcount = await HelperFunctions
                                                                  .showQuantitySelectBox(
                                                                      controller
                                                                          .count
                                                                          .value) ??
                                                              1;
                                                          if (newcount > 0) {
                                                            final stock = controller
                                                                .availableStock;
                                                            if (stock != null &&
                                                                newcount >
                                                                    stock) {
                                                              newcount = stock;
                                                              Get.snackbar(
                                                                'Stock Limit',
                                                                'Only $stock items available in stock',
                                                                snackPosition:
                                                                    SnackPosition
                                                                        .BOTTOM,
                                                                duration:
                                                                    const Duration(
                                                                        seconds:
                                                                            2),
                                                              );
                                                            }
                                                            controller.count
                                                                    .value =
                                                                newcount;
                                                          }
                                                        },
                                                      )
                                                  ],
                                                ),
                                              ],
                                            );
                                          }),

                                          // 3. Bulk Add Total Info
                                          if (controller.box.read('userData')?[
                                                      'saap_code'] !=
                                                  null &&
                                              controller.box.read('userData')?[
                                                      'saap_code'] !=
                                                  '')
                                            Obx(() => Column(
                                                  children: [
                                                    const SizedBox(height: 12),
                                                    Text(
                                                        'Total Quantity : ${controller.count.value * (controller.productDetials['packet'] ?? 1)}',
                                                        style: txtTheme()
                                                            .headlineSmall!
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: context
                                                                    .themeTextColor)),
                                                    const SizedBox(height: 10),
                                                  ],
                                                )),

                                          // 4. Description Section
                                          Obx(() {
                                            var content = controller
                                                .productDetials['content'];
                                            var longContent = controller
                                                .productDetials['long_content'];
                                            var appContent = controller
                                                .productDetials['app_content'];

                                            if ((content == null ||
                                                    content
                                                        .toString()
                                                        .trim()
                                                        .isEmpty) &&
                                                (longContent == null ||
                                                    longContent
                                                        .toString()
                                                        .trim()
                                                        .isEmpty) &&
                                                (appContent == null ||
                                                    appContent
                                                        .toString()
                                                        .trim()
                                                        .isEmpty)) {
                                              return const SizedBox.shrink();
                                            }

                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 14),
                                                // const Text("Product Description",
                                                //     style: TextStyle(
                                                //         fontWeight: FontWeight.bold,
                                                //         fontSize: 16)),
                                                // const SizedBox(height: 10),
                                                // if (content != null &&
                                                //     content.toString().isNotEmpty)
                                                //   Padding(
                                                //     padding: const EdgeInsets.only(
                                                if (longContent != null &&
                                                    longContent
                                                        .toString()
                                                        .isNotEmpty)
                                                  Obx(() {
                                                    final isExpanded = controller
                                                        .isLongContentExpanded
                                                        .value;
                                                    final rawLongContent =
                                                        longContent.toString();
                                                    final hasToggle =
                                                        _shouldShowToggle(
                                                            rawLongContent);
                                                    return Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        ConstrainedBox(
                                                          constraints: !hasToggle ||
                                                                  isExpanded
                                                              ? const BoxConstraints()
                                                              : const BoxConstraints(
                                                                  maxHeight:
                                                                      120),
                                                          child: ClipRect(
                                                            child: Stack(
                                                              alignment: Alignment
                                                                  .bottomCenter,
                                                              children: [
                                                                if (!hasToggle ||
                                                                    isExpanded)
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            4),
                                                                    child:
                                                                        HtmlWidget(
                                                                      rawLongContent,
                                                                      customStylesBuilder:
                                                                          (element) {
                                                                        return {
                                                                          'font-weight':
                                                                              'normal',
                                                                          'font-size':
                                                                              '14px',
                                                                          'font-family':
                                                                              'inherit',
                                                                          'color':
                                                                              'inherit',
                                                                        };
                                                                      },
                                                                      customWidgetBuilder:
                                                                          (element) {
                                                                        if (element.localName ==
                                                                                'h6' ||
                                                                            element.localName ==
                                                                                'span') {
                                                                          return null;
                                                                        }
                                                                        return null;
                                                                      },
                                                                    ),
                                                                  )
                                                                else
                                                                  OverflowBox(
                                                                    alignment:
                                                                        Alignment
                                                                            .topCenter,
                                                                    minHeight:
                                                                        0.0,
                                                                    maxHeight:
                                                                        double
                                                                            .infinity,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              4),
                                                                      child:
                                                                          HtmlWidget(
                                                                        rawLongContent,
                                                                        customStylesBuilder:
                                                                            (element) {
                                                                          return {
                                                                            'font-weight':
                                                                                'normal',
                                                                            'font-size':
                                                                                '14px',
                                                                            'font-family':
                                                                                'inherit',
                                                                            'color':
                                                                                'inherit',
                                                                          };
                                                                        },
                                                                        customWidgetBuilder:
                                                                            (element) {
                                                                          if (element.localName == 'h6' ||
                                                                              element.localName == 'span') {
                                                                            return null;
                                                                          }
                                                                          return null;
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),
                                                                if (hasToggle &&
                                                                    !isExpanded)
                                                                  Positioned(
                                                                    bottom: 0,
                                                                    left: 0,
                                                                    right: 0,
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          40,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        gradient:
                                                                            LinearGradient(
                                                                          begin:
                                                                              Alignment.topCenter,
                                                                          end: Alignment
                                                                              .bottomCenter,
                                                                          colors: [
                                                                            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                                                                            Theme.of(context).scaffoldBackgroundColor,
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        if (hasToggle)
                                                          InkWell(
                                                            onTap: () {
                                                              controller
                                                                  .isLongContentExpanded
                                                                  .toggle();
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          4),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Text(
                                                                    isExpanded
                                                                        ? 'See Less'
                                                                        : 'See All',
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          13,
                                                                    ),
                                                                  ),
                                                                  Icon(
                                                                    isExpanded
                                                                        ? Icons
                                                                            .keyboard_arrow_up
                                                                        : Icons
                                                                            .keyboard_arrow_down,
                                                                    color: Colors
                                                                        .blue,
                                                                    size: 16,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    );
                                                  }),
                                                if (appContent != null &&
                                                    appContent
                                                        .toString()
                                                        .isNotEmpty)
                                                  HtmlWidget(
                                                    appContent.toString(),
                                                    customStylesBuilder:
                                                        (element) {
                                                      return {
                                                        'font-weight': 'normal',
                                                        // 'font-size': '14px',
                                                      };
                                                    },
                                                  ),
                                                const SizedBox(height: 16),
                                              ],
                                            );
                                          }),

                                          // 5. Tags Section
                                          Obx(() {
                                            var tags = controller
                                                .productDetials['tags'];
                                            if (tags == null ||
                                                tags is! List ||
                                                tags.isEmpty)
                                              return const SizedBox.shrink();
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 14),
                                                Row(
                                                  children: [
                                                    Icon(Icons.label_outline,
                                                        size: 18,
                                                        color: context
                                                            .themeTextColor),
                                                    const SizedBox(width: 8),
                                                    Text("Tags",
                                                        style: txtTheme()
                                                            .headlineSmall!
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14)),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                Wrap(
                                                  spacing: 10,
                                                  runSpacing: 10,
                                                  children:
                                                      tags.map<Widget>((tag) {
                                                    return Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 14,
                                                          vertical: 8),
                                                      decoration: BoxDecoration(
                                                        color: context
                                                            .themePrimaryColor
                                                            .withOpacity(0.05),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color: context
                                                                .themePrimaryColor
                                                                .withOpacity(
                                                                    0.1)),
                                                      ),
                                                      child: Text(
                                                          "#${tag['name'] ?? ''}",
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: context
                                                                  .themePrimaryColor)),
                                                    );
                                                  }).toList(),
                                                ),
                                              ],
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }),
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: context.isDark
                                    ? context.themeBorderColor.withOpacity(0.3)
                                    : const Color(0xFFE2E8F0),
                              ),
                              Padding(
                                padding: pageSurroundingPadding,
                                child: Obx(() {
                                  final reviews = controller.productReview;

                                  double avgRating = 0.0;
                                  if (controller
                                          .reviewSummary['average_rating'] !=
                                      null) {
                                    avgRating = double.tryParse(controller
                                            .reviewSummary['average_rating']
                                            .toString()) ??
                                        0.0;
                                  } else if (reviews.isNotEmpty) {
                                    double totalRating = 0.0;
                                    for (var rev in reviews) {
                                      totalRating +=
                                          (rev['rating'] ?? 0).toDouble();
                                    }
                                    avgRating = totalRating / reviews.length;
                                  } else if (controller
                                          .productDetials['average_rating'] !=
                                      null) {
                                    avgRating = double.tryParse(controller
                                            .productDetials['average_rating']
                                            .toString()) ??
                                        0.0;
                                  }

                                  int count5 = 0;
                                  int count4 = 0;
                                  int count3 = 0;
                                  int count2 = 0;
                                  int count1 = 0;
                                  final summaryBreakdown =
                                      controller.reviewSummary['breakdown'];
                                  if (summaryBreakdown is Map) {
                                    count5 = int.tryParse(
                                            summaryBreakdown['5']?.toString() ??
                                                '0') ??
                                        0;
                                    count4 = int.tryParse(
                                            summaryBreakdown['4']?.toString() ??
                                                '0') ??
                                        0;
                                    count3 = int.tryParse(
                                            summaryBreakdown['3']?.toString() ??
                                                '0') ??
                                        0;
                                    count2 = int.tryParse(
                                            summaryBreakdown['2']?.toString() ??
                                                '0') ??
                                        0;
                                    count1 = int.tryParse(
                                            summaryBreakdown['1']?.toString() ??
                                                '0') ??
                                        0;
                                  } else {
                                    for (var rev in reviews) {
                                      int r = rev['rating'] ?? 0;
                                      if (r == 5)
                                        count5++;
                                      else if (r == 4)
                                        count4++;
                                      else if (r == 3)
                                        count3++;
                                      else if (r == 2)
                                        count2++;
                                      else if (r == 1) count1++;
                                    }
                                  }
                                  int total = controller
                                              .reviewSummary['total_reviews'] !=
                                          null
                                      ? (int.tryParse(controller
                                              .reviewSummary['total_reviews']
                                              .toString()) ??
                                          reviews.length)
                                      : reviews.length;

                                  Widget buildRatingProgressRow(
                                      int stars, int count) {
                                    double pct =
                                        total > 0 ? count / total : 0.0;
                                    return Row(
                                      children: [
                                        Text(
                                          "$stars",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: context.themeTextColor,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.star_rounded,
                                            color: Colors.amber, size: 10),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            child: LinearProgressIndicator(
                                              value: pct,
                                              minHeight: 4,
                                              backgroundColor:
                                                  context.themegreyColor,
                                              valueColor:
                                                  const AlwaysStoppedAnimation<
                                                      Color>(Colors.amber),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        SizedBox(
                                          width: 14,
                                          child: Text(
                                            "$count",
                                            textAlign: TextAlign.end,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: context.themeTextColor
                                                  .withOpacity(0.5),
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "Customer Reviews",
                                                style: txtTheme()
                                                    .headlineSmall!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              if (reviews.isNotEmpty) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: context
                                                        .themePrimaryColor
                                                        .withOpacity(0.08),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    reviews.length.toString(),
                                                    style: TextStyle(
                                                      color: context
                                                          .themePrimaryColor,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'Poppins',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          if (reviews.isNotEmpty)
                                            InkWell(
                                              onTap: () {
                                                Get.to(AllReview(
                                                  reviewData: reviews,
                                                  controller: controller,
                                                  name: controller
                                                      .productDetials['name'],
                                                  rating: 0,
                                                ));
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "All Reviews",
                                                      style: txtTheme()
                                                          .headlineSmall!
                                                          .copyWith(
                                                            color: context
                                                                .themePrimaryColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Icon(
                                                      Icons
                                                          .chevron_right_rounded,
                                                      size: 16,
                                                      color: context
                                                          .themePrimaryColor,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      if (reviews.isEmpty) ...[
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 24),
                                          decoration: BoxDecoration(
                                            color: context.isDark
                                                ? context.themeCardColor
                                                : context.themeWhiteColor,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: context.isDark
                                                  ? context.themeBorderColor
                                                  : const Color(0xFFE2E8F0),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.02),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.amber
                                                      .withOpacity(0.12),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.star_rounded,
                                                  size: 28,
                                                  color: Colors.amber.shade700,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                "No Reviews Yet",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  color: context.themeTextColor,
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                "Be the first to share your experience with this product!",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: context.themeTextColor
                                                      .withOpacity(0.55),
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                      ] else ...[
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: context.themeWhiteColor,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: context.themegreyColor
                                                  .withOpacity(0.6),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.015),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .baseline,
                                                      textBaseline: TextBaseline
                                                          .alphabetic,
                                                      children: [
                                                        Text(
                                                          avgRating
                                                              .toStringAsFixed(
                                                                  1),
                                                          style: TextStyle(
                                                            fontSize: 36,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: context
                                                                .themeTextColor,
                                                            fontFamily:
                                                                'Poppins',
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          "/5.0",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: context
                                                                .themeTextColor
                                                                .withOpacity(
                                                                    0.4),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontFamily:
                                                                'Poppins',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    RatingBarIndicator(
                                                      rating: avgRating,
                                                      itemBuilder:
                                                          (context, index) =>
                                                              const Icon(
                                                        Icons.star_rounded,
                                                        color: Colors.amber,
                                                      ),
                                                      itemCount: 5,
                                                      itemSize: 18.0,
                                                      direction:
                                                          Axis.horizontal,
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      "Based on ${reviews.length} ${reviews.length == 1 ? 'review' : 'reviews'}",
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: context
                                                            .themeTextColor
                                                            .withOpacity(0.5),
                                                        fontFamily: 'Poppins',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                height: 70,
                                                width: 1,
                                                color: context.themegreyColor,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16),
                                              ),
                                              Expanded(
                                                flex: 6,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    buildRatingProgressRow(
                                                        5, count5),
                                                    const SizedBox(height: 3),
                                                    buildRatingProgressRow(
                                                        4, count4),
                                                    const SizedBox(height: 3),
                                                    buildRatingProgressRow(
                                                        3, count3),
                                                    const SizedBox(height: 3),
                                                    buildRatingProgressRow(
                                                        2, count2),
                                                    const SizedBox(height: 3),
                                                    buildRatingProgressRow(
                                                        1, count1),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          separatorBuilder: (context, index) =>
                                              Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12),
                                            child: Divider(
                                              thickness: 0.8,
                                              color: context.themegreyColor,
                                            ),
                                          ),
                                          itemCount: reviews.length > 2
                                              ? 2
                                              : reviews.length,
                                          itemBuilder: (context, index) {
                                            final item = reviews[index];
                                            final reviewerName = item['name'] ??
                                                item['customer_id']?['name'] ??
                                                item['customer_name'] ??
                                                item['customer']?['name'] ??
                                                item['user_name'] ??
                                                item['user']?['name'] ??
                                                'Guest';
                                            final dateStr = controller.getDate(
                                                item['created_at'] ??
                                                    item['updated_at']);
                                            final reviewText =
                                                item['summary'] ??
                                                    item['comment'] ??
                                                    item['review'] ??
                                                    '';
                                            final num ratingVal =
                                                item['rating'] ?? 0;

                                            return customerReview(
                                              profileimage:
                                                  HelperFunctions().getImage(
                                                item['customer']
                                                        ?['featured_image'] ??
                                                    item['customer_id']
                                                        ?['featured_image'] ??
                                                    item['customer_id']
                                                        ?['avatar'],
                                              ),
                                              name: "$reviewerName | $dateStr",
                                              review: reviewText.toString(),
                                              rating: ratingVal.toInt(),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                              color: context.themePrimaryColor,
                                              width: 1.5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          minimumSize:
                                              const Size(double.infinity, 48),
                                          backgroundColor: context
                                              .themePrimaryColor
                                              .withOpacity(0.04),
                                          elevation: 0,
                                        ),
                                        onPressed: () {
                                          if (AuthDetails.isUserLogin()) {
                                            reviewModal(context, controller);
                                          } else {
                                            HelperFunctions.showLoginDialog(
                                              'You need to log in to add a review.',
                                            );
                                          }
                                        },
                                        icon: Icon(
                                          Icons.edit_outlined,
                                          size: 16,
                                          color: context.themePrimaryColor,
                                        ),
                                        label: Text(
                                          'Write a Review',
                                          style: txtTheme()
                                              .headlineSmall!
                                              .copyWith(
                                                color:
                                                    context.themePrimaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                              const SizedBox(
                                height: 110,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: 0,
                      child: Obx(
                        () {
                          final catalogMode =
                              controller.productDetials['catalog_mode'];
                          final bool isCatalogMode = (catalogMode is Map &&
                                  catalogMode['is_enabled'] == true) ||
                              controller.effectivePrice <= 0.0;
                          final String catalogButtonText = (catalogMode is Map &&
                                  catalogMode['button_text'] != null)
                              ? catalogMode['button_text'].toString()
                              : 'Contact for Pricing';

                          return OrderButton(
                            isAlreadyInCart: !controller.isRegistry.value &&
                                !isCatalogMode &&
                                controller.effectivePrice > 0.0 &&
                                controller.isAlreadyInCart.value,
                            isOutOfStock: controller.isOutOfStock,
                            btntext: () {
                              if (controller.isRegistry.value)
                                return 'Request Quote';
                              if (isCatalogMode)
                                return catalogButtonText;
                              if (controller.isOutOfStock) return 'Out of Stock';
                              var status = controller.productDetials['status'];
                              if (status != null && status is Map) {
                                String name = (status['name'] ?? '')
                                    .toString()
                                    .toLowerCase();
                                String type = (status['type'] ?? '')
                                    .toString()
                                    .toLowerCase();
                                if (name.contains('coming soon') ||
                                    type.contains('coming-soon')) {
                                  return 'Coming Soon';
                                }
                              }
                              return controller.isAlreadyInCart.value
                                  ? 'Already in cart'
                                  : 'Add to Bag';
                            }(),
                            controller: controller,
                            wishListTap: () async {
                              if (!Get.find<InternetconnectionController>()
                                  .connectionStatus
                                  .value) {
                                HelperFunctions.defaultdialogbox(
                                    'You are offline. Please reconnect to perform this action.',
                                    context.themeRedColor);
                                return;
                              }
                              if (AuthDetails.isUserLogin()) {
                                await wishListController.addProductToWishlist(
                                    productid: controller.productId,
                                    variant_id: controller.currentVariantId);
                                await wishListController.getwishlist();
                              } else {
                                HelperFunctions.showLoginDialog(
                                    'You need to log in to add a product to your wishlist.');
                              }
                            },
                            addToCartTap: () async {
                              if (!Get.find<InternetconnectionController>()
                                  .connectionStatus
                                  .value) {
                                HelperFunctions.defaultdialogbox(
                                    'You are offline. Please reconnect to perform this action.',
                                    context.themeRedColor);
                                return;
                              }
                              if (controller.isRegistry.value) {
                                if (!AuthDetails.isUserLogin()) {
                                  HelperFunctions.showLoginDialog(
                                      'You need to log in to request a quote.');
                                  return;
                                }
                                final form = controller.registryForm.value;
                                if (form == null) return;
                                Get.dialog(QuoteRequestDialog(
                                  productDetails: Map<String, dynamic>.from(
                                      controller.productDetials),
                                  productId:
                                      controller.productId?.toString() ?? '',
                                  currentVariantId: controller.currentVariantId,
                                  isSubmittingQuote: controller.isSubmittingQuote,
                                  onSubmit: controller.submitQuoteRequest,
                                  form: form,
                                ));
                                return;
                              }

                              if (isCatalogMode) {
                                showCatalogModeBottomSheet(
                                  context,
                                  productName: controller.productDetials['name']
                                          ?.toString() ??
                                      'Product',
                                  productId:
                                      controller.productId?.toString() ?? '',
                                  productImage: controller
                                      .productDetials['featured_image'],
                                  buttonText: catalogButtonText,
                                );
                                return;
                              }

                            var status = controller.productDetials['status'];
                            bool isComingSoon = false;
                            if (status != null && status is Map) {
                              String name = (status['name'] ?? '')
                                  .toString()
                                  .toLowerCase();
                              String type = (status['type'] ?? '')
                                  .toString()
                                  .toLowerCase();
                              isComingSoon = name.contains('coming soon') ||
                                  type.contains('coming-soon');
                            }

                            if (isComingSoon) {
                              HelperFunctions.defaultdialogbox(
                                  'This product is coming soon and cannot be added to the bag yet.',
                                  context.themeRedColor);
                              return;
                            }

                            if (!AuthDetails.isUserLogin()) {
                              showCartAuthBottomSheet();
                              return;
                            }

                            if (controller.isAlreadyInCart.value) {
                              _showAddedToCartBottomSheet(context, controller);
                            } else {
                              HelperFunctions().showOverlayLoader();
                              final isVariableProduct =
                                  controller.productVariants.isNotEmpty;
                              final String? checkVarId = isVariableProduct
                                  ? controller.currentVariantId
                                  : null;
                              if (wishListController.isProductInWishlist(
                                  controller.productId.toString(),
                                  variantId: checkVarId)) {
                                await wishListController.addProductToWishlist(
                                    productid: controller.productId.toString(),
                                    variant_id: checkVarId);
                              }
                              try {
                                await controller.addToCart();
                              } finally {
                                HelperFunctions().hideOverlayLoader();
                              }
                              if (context.mounted) {
                                _showAddedToCartBottomSheet(
                                    context, controller);
                              }
                            }
                          },
                        );
                      },
                    )),
                  Positioned(
                    bottom: 70,
                    right: 16,
                    child: Obx(() {
                      if (controller.relatedProducts.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return _buildMoreLikeThisButton(context, controller);
                    }),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    ));
  }

  Widget _buildMoreLikeThisButton(
      BuildContext context, ProductdetialController controller) {
    return GestureDetector(
      onTap: () {
        _showRelatedProductsBottomSheet(context, controller);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: themegradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: themegradient[1].withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              "More Like This",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRelatedProductsBottomSheet(
      BuildContext context, ProductdetialController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: Container(
            decoration: BoxDecoration(
              color: context.themeWhiteColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? context.themeBorderColor
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Header Row: Title
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Text(
                    "You May Also Like",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.themeTextColor,
                    ),
                  ),
                ),
                Divider(
                    height: 1,
                    thickness: 1,
                    color: context.themeBorderColor.withOpacity(0.3)),

                // Grid content
                Expanded(
                  child: Obx(() {
                    if (controller.isRelatedLoading.value) {
                      return _buildShimmerGrid();
                    }

                    if (controller.relatedProducts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_bag_outlined,
                                size: 60, color: context.themeSecondrytext),
                            const SizedBox(height: 16),
                            Text(
                              "No recommendations found",
                              style: TextStyle(
                                  color: context.themeSecondrytext,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: controller.relatedProducts.length,
                      itemBuilder: (context, index) {
                        final product = controller.relatedProducts[index];
                        return _buildProductCard(context, controller, product);
                      },
                    );
                  }),
                ),

                // Footer Action Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.themePrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Close",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void _showAddedToCartBottomSheet(
      BuildContext context, ProductdetialController controller) {
    final ScrollController relatedScrollController = ScrollController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        final productsList = controller.relatedProducts.isNotEmpty
            ? controller.relatedProducts
            : controller.similarProduct;

        return ScrollConfiguration(
          behavior:
              ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: Container(
            decoration: BoxDecoration(
              color: context.themeWhiteColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? context.themeBorderColor
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Header Row: Shop Icon + "Already In Cart" on Left, "Checkout" on Right
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icon/addtobag.svg',
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                              context.themeGreenColor, BlendMode.srcIn),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Already In Cart",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.themeGreenColor,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        BottombarController.switchTab(2);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.themePrimaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            "Checkout",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios,
                              size: 12, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Current Product Summary Tile
                Obx(() {
                  final productDetails = controller.productDetials;
                  if (productDetails.isEmpty) return const SizedBox.shrink();
                  final imgUrl = _getProductImage(productDetails);
                  final name = productDetails['name']?.toString() ?? '';
                  Map? currentVariant;
                  if (controller.selectedVariantIndex.value <
                      controller.productVariants.length) {
                    final v = controller
                        .productVariants[controller.selectedVariantIndex.value];
                    if (v is Map) currentVariant = v;
                  }
                  double? rootPrice = HelperFunctions.parsePrice(
                      currentVariant?['price'] ?? productDetails['price']);
                  double? rootSalePrice = HelperFunctions.parsePrice(
                      currentVariant?['sale_price'] ??
                          productDetails['sale_price']);
                  double p = (rootPrice ?? 0.0).toConvertedPrice();
                  double sp = (rootSalePrice ?? 0.0).toConvertedPrice();
                  if (p <= 0.0 && sp > 0.0) {
                    p = sp;
                    sp = 0.0;
                  }
                  double displayPrice = (sp > 0 && sp < p) ? sp : p;

                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? context.themegreyColor.withOpacity(0.5)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: (imgUrl.isNotEmpty &&
                                  imgUrl != HelperFunctions.getNoImage() &&
                                  (Uri.tryParse(imgUrl)?.hasAuthority ?? false))
                              ? CachedNetworkImage(
                                  imageUrl: imgUrl,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      const SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: ProductImagePlaceholder(
                                      radius: 8,
                                      padding: EdgeInsets.all(6),
                                    ),
                                  ),
                                )
                              : const SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: ProductImagePlaceholder(
                                    radius: 8,
                                    padding: EdgeInsets.all(6),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: context.themeTextColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                displayPrice <= 0.0
                                    ? "Contact for Pricing"
                                    : "${controller.currencySymbol.value}${displayPrice.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: displayPrice <= 0.0 ? 11 : 13,
                                  fontWeight: FontWeight.bold,
                                  color: context.themePrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 16),
                Divider(
                    height: 1,
                    thickness: 1,
                    color: context.themeBorderColor.withOpacity(0.3)),
                const SizedBox(height: 16),

                // Section Title: Related Products
                Text(
                  "Related Products",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: context.themeTextColor,
                  ),
                ),
                const SizedBox(height: 12),

                // Horizontal Scroll List of Related Products
                Obx(() {
                  if (controller.isRelatedLoading.value) {
                    return SizedBox(
                      height: 190,
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        itemBuilder: (context, index) => Shimmer.fromColors(
                          baseColor: context.isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade300,
                          highlightColor: context.isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade100,
                          child: Container(
                            width: 130,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: context.themeWhiteColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  if (productsList.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Text(
                          "No related products available",
                          style: TextStyle(
                              color: context.themeSecondrytext, fontSize: 13),
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 220,
                    child: ListView.builder(
                      controller: relatedScrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: productsList.length,
                      itemBuilder: (context, index) {
                        final item = productsList[index];
                        return SizedBox(
                          width: 145,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _buildProductCard(context, controller, item),
                          ),
                        );
                      },
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Footer Button: Continue Shopping
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.themeBorderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Continue Shopping",
                      style: TextStyle(
                        color: context.themeTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          height: 10,
                          width: double.infinity,
                          color: Colors.grey),
                      const SizedBox(height: 6),
                      Container(height: 10, width: 80, color: Colors.grey),
                      const SizedBox(height: 6),
                      Container(height: 12, width: 50, color: Colors.grey),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getProductImage(dynamic product) {
    if (product == null) return HelperFunctions.getNoImage();

    // 1. Check featured_image at root
    if (product['featured_image'] != null) {
      return HelperFunctions().getImage(product['featured_image']);
    }

    // 2. Check variants[0] front_image
    if (product['variants'] != null &&
        (product['variants'] as List).isNotEmpty) {
      var variant = product['variants'][0];
      if (variant != null && variant is Map) {
        if (variant['front_image'] != null) {
          return HelperFunctions().getImage(variant['front_image']);
        }
        if (variant['featured_image'] != null) {
          return HelperFunctions().getImage(variant['featured_image']);
        }
      }
    }

    return HelperFunctions.getNoImage();
  }

  Widget _buildProductCard(BuildContext context,
      ProductdetialController controller, dynamic product) {
    String imgUrl = _getProductImage(product);
    String name = product['name']?.toString() ?? '';

    double? rootPrice = HelperFunctions.parsePrice(product['price']);
    double? rootSalePrice = HelperFunctions.parsePrice(product['sale_price']);

    double price = (rootPrice ?? 0.0).toConvertedPrice();
    double salePrice = (rootSalePrice ?? 0.0).toConvertedPrice();

    if (price <= 0.0) {
      final variants =
          (product['variants'] ?? product['variant_ids'] ?? []) as List;
      if (variants.isNotEmpty) {
        Map? chosenVariant;
        // 1. Look for default variant with positive price
        for (var v in variants) {
          if (v is Map && v['is_default'] == true) {
            double p = HelperFunctions.parsePrice(v['price']) ?? 0.0;
            double sp = HelperFunctions.parsePrice(v['sale_price']) ?? 0.0;
            if (p > 0 || sp > 0) {
              chosenVariant = v;
              break;
            }
          }
        }
        // 2. Look for any variant with positive price
        if (chosenVariant == null) {
          for (var v in variants) {
            if (v is Map) {
              double p = HelperFunctions.parsePrice(v['price']) ?? 0.0;
              double sp = HelperFunctions.parsePrice(v['sale_price']) ?? 0.0;
              if (p > 0 || sp > 0) {
                chosenVariant = v;
                break;
              }
            }
          }
        }
        // 3. Fallback to first variant
        chosenVariant ??=
            (variants.first is Map) ? variants.first as Map : null;

        if (chosenVariant != null) {
          double? varPrice = HelperFunctions.parsePrice(chosenVariant['price']);
          double? varSalePrice =
              HelperFunctions.parsePrice(chosenVariant['sale_price']);
          if (varPrice != null && varPrice > 0) {
            price = varPrice.toConvertedPrice();
          }
          if (varSalePrice != null && varSalePrice > 0) {
            salePrice = varSalePrice.toConvertedPrice();
          }
        }
      }
    }

    if (price <= 0.0 && salePrice > 0.0) {
      price = salePrice;
      salePrice = 0.0;
    }

    bool hasDiscount = salePrice > 0.0 && salePrice < price;
    double displayPrice = hasDiscount ? salePrice : price;
    int discountPercent =
        hasDiscount ? ((price - salePrice) * 100 / price).round() : 0;

    return GestureDetector(
      onTap: () {
        Get.back(); // close bottom sheet
        Get.toNamed(
          Routes.PRODUCTDETAILS,
          arguments: {'productId': product['_id'].toString()},
          preventDuplicates: false,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.themeWhiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: context.isDark
                  ? context.themeBorderColor.withOpacity(0.3)
                  : Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image container
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: imgUrl.isEmpty ||
                            imgUrl == HelperFunctions.getNoImage() ||
                            !(Uri.tryParse(imgUrl)?.hasAuthority ?? false)
                        ? const ProductImagePlaceholder(radius: 12)
                        : CachedNetworkImage(
                            imageUrl: imgUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.contain,
                            errorWidget: (context, url, error) =>
                                const ProductImagePlaceholder(radius: 12),
                            placeholder: (context, url) => Container(
                              color: context.isDark
                                  ? context.themegreyColor.withOpacity(0.3)
                                  : Colors.grey.shade100,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: context.themePrimaryColor,
                                ),
                              ),
                            ),
                          ),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: context.themeRedColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "$discountPercent% OFF",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Details container
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.themeTextColor,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          (displayPrice <= 0.0 || price <= 0.0)
                              ? "Contact for Pricing"
                              : "${controller.currencySymbol.value}${displayPrice.toStringAsFixed(2)}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: (displayPrice <= 0.0 || price <= 0.0) ? 11 : 13,
                            fontWeight: FontWeight.bold,
                            color: (displayPrice <= 0.0 || price <= 0.0) ? context.themePrimaryColor : context.themeTextColor,
                          ),
                        ),
                      ),
                      if (hasDiscount && displayPrice > 0.0 && price > 0.0) ...[
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "${controller.currencySymbol.value}${price.toStringAsFixed(2)}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: context.themeTextColor.withOpacity(0.4),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

reviewModal(BuildContext context, ProductdetialController controller) {
  TextEditingController reviewController = TextEditingController();
  int rating = 3;
  return Get.dialog(AlertDialog(
      content: SizedBox(
        // width: MediaQuery.of(context).size.width * 80,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Write Review',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                        color: context.themeSecondrytext,
                        // fontFamily: 'Poppins',
                        fontSize: 14)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: reviewController,
                  maxLength: 300,
                  scrollPhysics: const AlwaysScrollableScrollPhysics(),
                  onChanged: (value) {
                    // .text = value;
                  },
                  cursorColor: context.themePrimaryColor,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFE2E8F0), width: 1)),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFE2E8F0), width: 1)),
                  ),
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  style: TextStyle(fontSize: 14),
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
                          style: txtTheme().headlineSmall!.copyWith(
                                color: context.themeTextColor,
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
                  style: themeButton,
                  child: Text('Submit'.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        // fontFamily: 'Poppins'
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
    this.wishListTap,
    required this.addToCartTap,
    required this.controller,
    required this.btntext,
    this.isAlreadyInCart = false,
    this.isOutOfStock = false,
  }) : super(key: key);

  final VoidCallback? wishListTap;
  final String btntext;
  final bool isAlreadyInCart;
  final bool isOutOfStock;
  final Function() addToCartTap;
  final ProductdetialController controller;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isWishlistLoading = false;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleWishlist() async {
    if (_isWishlistLoading) return;

    if (!Get.find<InternetconnectionController>().connectionStatus.value) {
      HelperFunctions.defaultdialogbox(
          'You are offline. Please reconnect to perform this action.',
          context.themeRedColor);
      return;
    }

    if (!AuthDetails.isUserLogin()) {
      HelperFunctions.showLoginDialog(
          'You need to log in to add a product to your wishlist.');
      return;
    }

    // Haptic feedback
    HapticFeedback.mediumImpact();

    final wishlistCtrl = Get.find<WishlistController>();
    final productId = widget.controller.productId.toString();
    final currentVarId = widget.controller.currentVariantId;
    final isVariableProduct = widget.controller.productVariants.isNotEmpty;
    final String? checkVarId = isVariableProduct ? currentVarId : null;

    setState(() {
      _isWishlistLoading = true;
    });

    try {
      final wasAdded = await wishlistCtrl.toggleWishlist(
        productid: productId,
        variant_id: checkVarId,
        productDetails: widget.controller.productDetials,
      );

      if (wasAdded) {
        HelperFunctions().showSnackBarSuccess('Added to Wishlist');
      } else {
        HelperFunctions().showSnackBarSuccess('Removed from Wishlist');
      }
    } catch (e) {
      if (mounted) {
        HelperFunctions.defaultdialogbox(
            'Failed to update wishlist', context.themeRedColor);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isWishlistLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Color.fromARGB(96, 168, 164, 164),
                spreadRadius: 0,
                blurRadius: 02),
          ],
          color: context.themeWhiteColor,
        ),
        width: Get.width,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (_isWishlistLoading) return;
                  _controller
                      .forward(
                        from: 0.0,
                      )
                      .then((value) => _controller.reverse());
                  _toggleWishlist();
                },
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Obx(() {
                      final wishlistCtrl = Get.find<WishlistController>();
                      final productId = widget.controller.productId.toString();
                      final isVariableProduct =
                          widget.controller.productVariants.isNotEmpty;
                      final String? checkVarId = isVariableProduct
                          ? widget.controller.currentVariantId
                          : null;
                      final isInWishlist = wishlistCtrl.isProductInWishlist(
                          productId,
                          variantId: checkVarId);
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Transform.scale(
                            scale: _scaleAnimation.value,
                            child: isInWishlist
                                ? SvgPicture.asset(
                                    'assets/icon/like.svg',
                                    width: 18,
                                    height: 18,
                                  )
                                : SvgPicture.asset(
                                    'assets/icon/unlike.svg',
                                    width: 18,
                                    height: 18,
                                    colorFilter: ColorFilter.mode(
                                        context.themeTextColor,
                                        BlendMode.srcIn),
                                  ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isInWishlist ? "WISHLISTED" : "WISHLIST",
                            style: txtTheme().headlineMedium!.copyWith(
                                  fontSize: 16,
                                  color: isInWishlist
                                      ? context.themeRedColor
                                      : context.themeTextColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          )
                        ],
                      );
                    });
                  },
                ),
              ),
            ),
            VerticalDivider(
              width: 20,
              thickness: 1.5,
              indent: 10,
              endIndent: 10,
              color: context.themegreyColor,
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.isOutOfStock ? null : widget.addToCartTap,
                child: Obx(() {
                  final catalogMode =
                      widget.controller.productDetials['catalog_mode'];
                  final bool isCatalogMode = (catalogMode is Map &&
                          catalogMode['is_enabled'] == true) ||
                      widget.controller.effectivePrice <= 0.0;
                  final isContactOrQuote =
                      isCatalogMode || widget.controller.isRegistry.value;
                  return Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (isContactOrQuote)
                        Icon(
                          Icons.contact_mail_outlined,
                          size: 18,
                          color: context.themePrimaryColor,
                        )
                      else
                        SvgPicture.asset(
                          'assets/icon/addtobag.svg',
                          width: 16,
                          color: widget.isOutOfStock
                              ? Colors.grey
                              : widget.isAlreadyInCart
                                  ? Colors.green
                                  : context.themeRedColor,
                        ),
                      const SizedBox(width: 8),
                      Text(widget.btntext,
                          style: txtTheme().headlineMedium!.copyWith(
                              color: widget.isOutOfStock
                                  ? Colors.grey
                                  : isContactOrQuote
                                      ? context.themePrimaryColor
                                      : widget.isAlreadyInCart
                                          ? Colors.green
                                          : context.themeRedColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ],
                  );
                }),
              ),
            ),
          ],
        ));
  }
}

class ProductGallery extends StatelessWidget {
  final ProductdetialController controller;
  final bool isLoading;
  final List productGallery;
  const ProductGallery({
    super.key,
    required this.controller,
    required this.productGallery,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Shimmer.fromColors(
          enabled: true,
          direction: ShimmerDirection.ltr,
          loop: 0,
          period: const Duration(seconds: 1),
          baseColor: Colors.grey.shade300,
          highlightColor: const Color.fromARGB(255, 197, 197, 197),
          child: SizedBox(
            height: Get.height * 0.6,
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return const SizedBox(
                  width: 10,
                );
              },
              shrinkWrap: false,
              itemCount: 3,
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: Get.height * 0.6,
                    width: 300,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    final validGallery = productGallery.where((item) {
      if (item == null) return false;
      final img = HelperFunctions().getImage(item);
      return img.isNotEmpty &&
          img != HelperFunctions.getNoImage() &&
          (Uri.tryParse(img)?.hasAuthority ?? false);
    }).toList();

    if (validGallery.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.45,
          width: double.infinity,
          child: const ProductImagePlaceholder(
            radius: 8,
            padding: EdgeInsets.all(28),
          ),
        ),
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: validGallery.length == 1
          ? InkWell(
              onTap: () {
                Get.to(() => ImageSlider(),
                    arguments: {"images": validGallery});
              },
              child: Container(
                color: Colors.grey.shade50,
                child: CachedNetworkImage(
                  filterQuality: FilterQuality.high,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  imageUrl: HelperFunctions().getImage(validGallery[0]),
                  errorWidget: (context, url, error) =>
                      const ProductImagePlaceholder(
                    radius: 8,
                    padding: EdgeInsets.all(28),
                  ),
                  progressIndicatorBuilder: (context, url, progress) =>
                      Container(
                    decoration: BoxDecoration(color: Colors.grey.shade300),
                    height: 165,
                    child: Center(
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: HelperFunctions().loadingIndicator(),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : PageView.builder(
              controller: controller.pageController,
              padEnds: false,
              onPageChanged: controller.selectedPageIndex,
              itemCount: validGallery.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Get.to(() => ImageSlider(), arguments: {
                      "images": validGallery,
                      "initialPage": index
                    });
                  },
                  child: Container(
                    color: Colors.grey.shade50,
                    child: CachedNetworkImage(
                      filterQuality: FilterQuality.low,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      imageUrl: HelperFunctions().getImage(validGallery[index]),
                      errorWidget: (context, url, error) =>
                          const ProductImagePlaceholder(
                        radius: 8,
                        padding: EdgeInsets.all(28),
                      ),
                      progressIndicatorBuilder: (context, url, progress) =>
                          Container(
                        decoration: BoxDecoration(color: Colors.grey.shade300),
                        height: 165,
                        child: Center(
                          child: SizedBox(
                            height: 40,
                            width: 40,
                            child: HelperFunctions().loadingIndicator(),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
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
            style: TextStyle(fontSize: 14, color: context.themeSecondrytext))
      ],
    );
  }
}

Color _getColorFromName(String colorName) {
  switch (colorName.toLowerCase().trim()) {
    case 'levnder':
    case 'lavender':
      return const Color(0xFFE6E6FA);
    case 'pink':
      return Colors.pinkAccent;
    case 'grey':
    case 'gray':
      return Colors.grey;
    case 'white':
      return Colors.white;
    case 'camel brown':
      return const Color(0xFF20558A);
    case 'mustard lime':
      return const Color(0xFFE1AD01);
    case 'red':
      return Colors.red;
    case 'blue':
      return Colors.blue;
    case 'black':
      return Colors.black;
    case 'green':
      return Colors.green;
    case 'yellow':
      return Colors.yellow;
    default:
      return Colors.grey.shade300;
  }
}
