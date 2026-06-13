import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:foduu_ecommerce/components/ProductGallery.dart';
import 'package:foduu_ecommerce/app/modules/product/controllers/product_controller.dart';
import 'package:foduu_ecommerce/core/services/wishlistService.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import '../../../../components/shimmer/shimmer_effects.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/product_helper.dart';
import 'package:foduu_ecommerce/constants/theme.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class _BadgeData {
  final String label;
  final Color fg;
  final Color bg;
  _BadgeData(this.label, this.fg, this.bg);
}

class ProductView extends GetView<ProductController> {
  ProductView({Key? key}) : super(key: key);

  Widget _buildBadges(BuildContext context, Map<String, dynamic> details) {
    final badges = <_BadgeData>[];
    // final status = details['status'];
    // if (status is Map && status['name'] != null) {
    //   badges.add(_BadgeData(status['name'].toString(), Colors.green.shade700,
    //       Colors.green.shade50));
    // }
    if (details['featured'] == true) {
      badges.add(
        _BadgeData('Featured', Colors.amber.shade700, Colors.amber.shade50),
      );
    }
    if (details['trending'] == true) {
      badges.add(
        _BadgeData('Trending', Colors.purple.shade700, Colors.purple.shade50),
      );
    }
    if (details['hot'] == true) {
      badges.add(_BadgeData('Hot', Colors.red.shade700, Colors.red.shade50));
    }
    if (details['recommended'] == true) {
      badges.add(
        _BadgeData('Recommended', Colors.blue.shade700, Colors.blue.shade50),
      );
    }
    if (badges.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: badges
          .map(
            (b) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: b.bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: b.fg.withValues(alpha: 0.3)),
              ),
              child: Text(
                b.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: b.fg,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBrandCategories(
    BuildContext context,
    Map<String, dynamic> details,
  ) {
    final brand =
        details['brand'] is Map ? details['brand']['name']?.toString() : null;
    final cats = details['categories'] is List
        ? (details['categories'] as List)
            .map((c) => c['name']?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .join(', ')
        : null;
    if ((brand == null || brand.isEmpty) && (cats == null || cats.isEmpty))
      return const SizedBox.shrink();
    return Row(
      children: [
        if (brand != null && brand.isNotEmpty) ...[
          Icon(
            Icons.storefront_outlined,
            size: 14,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: 4),
          Text(
            brand,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
        if (brand != null &&
            brand.isNotEmpty &&
            cats != null &&
            cats.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '·',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
        if (cats != null && cats.isNotEmpty) ...[
          Icon(
            Icons.category_outlined,
            size: 14,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              cats,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStockSku(
    BuildContext context,
    Map<String, dynamic> details,
    int variantIndex,
  ) {
    final variants = details['variants'];
    if (variants is! List || variants.isEmpty) return const SizedBox.shrink();
    final idx = variantIndex.clamp(0, variants.length - 1);
    final variant = variants[idx] as Map<String, dynamic>;
    final variantQty = variant['quantity'];
    final bool isUnlimited = variantQty == null;
    final int qty = int.tryParse(variantQty?.toString() ?? '0') ?? 0;
    final bool inStock = isUnlimited || qty > 0;
    final sku = variant['sku']?.toString() ?? '';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: inStock ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: inStock ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                isUnlimited
                    ? 'Unlimited'
                    : (inStock ? 'In Stock ($qty)' : 'Out of Stock'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: inStock ? Colors.green.shade800 : Colors.red.shade800,
                ),
              ),
            ],
          ),
        ),
        if (sku.isNotEmpty) ...[
          const SizedBox(width: 10),
          Text(
            'SKU: $sku',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildTaxInfo(BuildContext context, Map<String, dynamic> details) {
    final isTaxable = details['isTaxable'] == true;
    final tax = details['tax']?.toString() ?? '0';
    return Text(
      isTaxable ? 'Tax: $tax% applicable' : 'Inclusive of all taxes',
      style: TextStyle(
        fontSize: 12,
        color: isTaxable
            ? Theme.of(context).colorScheme.outline
            : Colors.green.shade700,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildPublishedDate(
    BuildContext context,
    Map<String, dynamic> details,
  ) {
    final raw = details['published_at']?.toString();
    if (raw == null || raw.isEmpty) return const SizedBox.shrink();
    try {
      final dt = DateTime.parse(raw).toLocal();
      final formatted = DateFormat('MMMM d, yyyy').format(dt);
      return Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 13,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: 5),
          Text(
            'Published: $formatted',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildTags(BuildContext context, Map<String, dynamic> details) {
    final tags = details['tags'];
    if (tags is! List || tags.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Tags',
          style: txtTheme().titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: tags
              .map<Widget>(
                (tag) => Chip(
                  label: Text(
                    (tag is Map ? tag['name']?.toString() : tag?.toString()) ??
                        '',
                    style: const TextStyle(fontSize: 12),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Get.create(() => ProductController(), permanent: false);
    final controller = Get.find<ProductController>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Obx(() {
            if (controller.productDetials['name'] == null) {
              return const ShimmerEffect(height: 10, width: 100);
            } else {
              return Text(
                controller.productDetials['name'].toString(),
                style: Theme.of(context).textTheme.titleLarge,
              );
            }
          }),
          actions: const [
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   children: [
            //     IconButton(
            //         onPressed: () {},
            //         icon: SvgPicture.asset('assets/icon/appbarshare.svg')),
            //     Obx(
            //       () => Get.find<BottombarController>().cartbadge(
            //           child: CartIcon(() {
            //             Get.toNamed(Routes.CART);
            //           }),
            //           badgeNumber: 0),
            //     ),
            //     const SizedBox(
            //       width: 14,
            //     )
            //   ],
            // )
          ],
          titleSpacing: 0.0,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Obx(() {
                final galleryImages = ProductHelper.getProductGallery(
                  Map<String, dynamic>.from(controller.productDetials),
                  variantIndex: controller.selectedVariantIndex.value,
                );

                return ProductGallery(
                  isLoading: controller.isLoading.value,
                  controller: controller,
                  productGallery: galleryImages,
                );
              }),
              const SizedBox(height: 8.0),
              Column(
                children: [
                  Padding(
                    padding: pageSurroundingPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        // Badges row
                        Obx(() {
                          if (controller.productDetials['name'] == null)
                            return const SizedBox.shrink();
                          return _buildBadges(
                            context,
                            Map<String, dynamic>.from(
                              controller.productDetials,
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        Obx(
                          () => controller.productDetials['name'] == null
                              ? const ShimmerEffect(height: 10, width: 100)
                              : Text(
                                  controller.productDetials['name'].toString(),
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                        ),
                        const SizedBox(height: 6),
                        // Brand + Categories
                        Obx(() {
                          if (controller.productDetials['name'] == null)
                            return const SizedBox.shrink();
                          return _buildBrandCategories(
                            context,
                            Map<String, dynamic>.from(
                              controller.productDetials,
                            ),
                          );
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Obx(() {
                            return controller.productDetials['content'] != null
                                ? HtmlWidget(
                                    controller.productDetials['content']
                                        .toString(),
                                  )
                                : Container();
                          }),
                        ),
                        Obx(
                          () => Row(
                            children: [
                              RatingBarIndicator(
                                rating: controller
                                            .productDetials['average_rating'] ==
                                        null
                                    ? 0.0
                                    : double.parse(
                                        controller
                                            .productDetials['average_rating']
                                            .toString(),
                                      ),
                                itemBuilder: (context, index) => Icon(
                                  Icons.star,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                unratedColor: Theme.of(
                                  context,
                                ).colorScheme.outline,
                                itemCount: 5,
                                itemSize: 18.0,
                                direction: Axis.horizontal,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                controller.productDetials['rating_count'] ==
                                        null
                                    ? '0'
                                    : controller.productDetials['rating_count']
                                        .toString(),
                                style: txtTheme().titleLarge!.copyWith(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Obx(() {
                          if (controller.productDetials['name'] == null) {
                            return const ShimmerEffect(height: 10, width: 50);
                          } else {
                            final priceInfo = ProductHelper.calculatePriceInfo(
                              Map<String, dynamic>.from(
                                controller.productDetials,
                              ),
                              variantIndex:
                                  controller.selectedVariantIndex.value,
                            );

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "₹${priceInfo['productPrice']}",
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    const SizedBox(width: 08),
                                    priceInfo['salePrice'] == "0" ||
                                            priceInfo['salePrice'] == ""
                                        ? const SizedBox.shrink()
                                        : Text(
                                            "₹${priceInfo['salePrice']}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  decoration:
                                                      TextDecoration.lineThrough,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.outline,
                                                ),
                                          ),
                                    const SizedBox(width: 08),
                                    if (priceInfo['discountRate'] != null &&
                                        priceInfo['discountRate']!.isNotEmpty)
                                      Text(
                                        priceInfo['discountRate'] ?? '',
                                        style: txtTheme().titleLarge!.copyWith(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                  ],
                                ),
                                _buildStockSku(
                                  context,
                                  Map<String, dynamic>.from(
                                    controller.productDetials,
                                  ),
                                  controller.selectedVariantIndex.value,
                                ),
                              ],
                            );
                          }
                        }),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Obx(() {
                              if (controller.productDetials['name'] == null)
                                return const SizedBox.shrink();
                              return _buildTaxInfo(
                                context,
                                Map<String, dynamic>.from(
                                  controller.productDetials,
                                ),
                              );
                            }),
                            Obx(() {
                              if (controller.productDetials['name'] == null)
                                return const SizedBox.shrink();
                              return _buildPublishedDate(
                                context,
                                Map<String, dynamic>.from(
                                  controller.productDetials,
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Theme.of(context).dividerTheme.color),
                  Padding(
                    padding: pageSurroundingPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() {
                          return Column(
                            children: [
                              ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, parentIndex) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Select ${controller.labels[parentIndex]}',
                                            style: txtTheme()
                                                .titleLarge!
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          Obx(() {
                                            final currentSelection =
                                                controller.selectedVariant[
                                                    controller
                                                        .labels[parentIndex]];
                                            return Text(
                                              currentSelection?.toString() ??
                                                  '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: SizedBox(
                                          height: 40,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemCount: controller
                                                .labelVariant[parentIndex]
                                                .length,
                                            itemBuilder: (context, index) {
                                              return GestureDetector(
                                                onTap: () {
                                                  controller.onSelectVariant(
                                                    controller
                                                        .labels[parentIndex],
                                                    controller.labelVariant[
                                                        parentIndex][index],
                                                  );
                                                },
                                                child: Obx(() {
                                                  return Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                      right: 10,
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 15,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        width: controller
                                                                    .selectedVariant[controller
                                                                        .labels[
                                                                    parentIndex]] ==
                                                                controller.labelVariant[
                                                                        parentIndex]
                                                                    [index]
                                                            ? 2.5
                                                            : 1.5,
                                                        color: controller
                                                                    .selectedVariant[controller
                                                                        .labels[
                                                                    parentIndex]] ==
                                                                controller.labelVariant[
                                                                        parentIndex]
                                                                    [index]
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .primary
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .outline,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        08,
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        controller.labelVariant[
                                                            parentIndex][index],
                                                        style: Theme.of(
                                                          context,
                                                        ).textTheme.labelLarge,
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return const SizedBox(height: 10);
                                },
                                itemCount: controller.labels.length,
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Quantity:",
                              style: txtTheme().titleLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Container(
                              width: Get.width * 0.32,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      controller.decrement();
                                    },
                                    icon: Container(
                                      padding: const EdgeInsets.all(0.01),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(02),
                                        border: Border.all(
                                          width: 1.2,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outline,
                                        ),
                                      ),
                                      child: const Icon(Icons.remove, size: 14),
                                    ),
                                  ),
                                  Obx(() {
                                    return Text(
                                      controller.count.toString(),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    );
                                  }),
                                  IconButton(
                                    onPressed: () {
                                      controller.increment();
                                    },
                                    icon: Container(
                                      padding: const EdgeInsets.all(0.01),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(02),
                                        border: Border.all(
                                          width: 1.2,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outline,
                                        ),
                                      ),
                                      child: const Icon(Icons.add, size: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Tags
                        Obx(() {
                          if (controller.productDetials['name'] == null)
                            return const SizedBox.shrink();
                          return _buildTags(
                            context,
                            Map<String, dynamic>.from(
                              controller.productDetials,
                            ),
                          );
                        }),
                        Padding(
                          padding: EdgeInsets.zero,
                          child: Obx(() {
                            return Html(
                              data: controller.productDetials['long_content'] ??
                                  "",
                              style: {"body": Style(fontFamily: "Lato")},
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  _buildReviewsSection(context, controller),
                  const SizedBox(height: 50),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: OrderButton(
          btntext: 'Add to Bag',
          controller: controller,
          wishListTap: () async {
            final productDetails = controller.productDetials;
            String variantSlug = '';
            String? variantId;
            if (productDetails['variants'] != null &&
                (productDetails['variants'] as List).isNotEmpty) {
              final variants = productDetails['variants'] as List;
              final selectedIndex = controller.selectedVariantIndex.value;
              if (selectedIndex < variants.length) {
                variantSlug = variants[selectedIndex]['slug'] ??
                    variants[selectedIndex]['variant_slug'] ??
                    '';
                variantId = (variants[selectedIndex]['_id'] ??
                        variants[selectedIndex]['id'])
                    ?.toString();
              }
            } else {
              variantSlug = productDetails['variant_slug'] ??
                  productDetails['slug'] ??
                  '';
              variantId =
                  (productDetails['_id'] ?? productDetails['id'])?.toString();
            }

            await WishListService.to.toggleWishlist(
              productId: controller.productId,
              variantSlug: variantSlug,
              variantId: variantId,
            );
          },
          addToCartTap: () async {
            HelperFunctions().showOverlayLoader();

            await controller.addToCart().then((value) {
              Get.until((route) => !Get.isDialogOpen!);
              return Get.toNamed(Routes.CART);
            });
          },
        ),
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context, ProductController controller) {
    return Obx(() {
      if (controller.isLoadingReviews.value) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final summary = controller.reviewsData['summary'];
      final reviewsObj = controller.reviewsData['reviews'];
      if (summary == null || reviewsObj == null) {
        return const SizedBox.shrink();
      }

      final docs = reviewsObj['docs'] as List? ?? [];
      final averageRating =
          double.tryParse(summary['average_rating']?.toString() ?? '0.0') ??
              0.0;
      final totalReviews =
          int.tryParse(summary['total_reviews']?.toString() ?? '0') ?? 0;
      final breakdown = summary['breakdown'] as Map? ?? {};

      return Padding(
        padding: pageSurroundingPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Customer Reviews ($totalReviews)",
                  style: txtTheme()
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => _showAddReviewModal(context, controller),
                  icon: const Icon(Icons.rate_review, size: 18),
                  label: const Text(
                    "Add Review",
                    style: TextStyle(
                        fontFamily: 'Lato', fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (totalReviews > 0) ...[
              // Breakdown stats
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Lato'),
                      ),
                      RatingBarIndicator(
                        rating: averageRating,
                        itemBuilder: (context, index) => Icon(
                          Icons.star,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        unratedColor: Theme.of(context).colorScheme.outline,
                        itemCount: 5,
                        itemSize: 18.0,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$totalReviews reviews",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: List.generate(5, (index) {
                        final star = 5 - index;
                        final count = int.tryParse(
                                breakdown[star.toString()]?.toString() ??
                                    '0') ??
                            0;
                        final pct =
                            totalReviews > 0 ? count / totalReviews : 0.0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              Text("$star star",
                                  style: const TextStyle(
                                      fontSize: 12, fontFamily: 'Lato')),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withOpacity(0.1),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).colorScheme.primary),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text("$count",
                                  style: const TextStyle(
                                      fontSize: 12, fontFamily: 'Lato')),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Reviews List
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: docs.length,
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final reviewItem = docs[index] as Map;
                  final name = reviewItem['name']?.toString() ?? 'Anonymous';
                  final comment = reviewItem['comment']?.toString() ?? '';
                  final rating =
                      int.tryParse(reviewItem['rating']?.toString() ?? '0') ??
                          0;
                  final rawDate = reviewItem['created_at']?.toString();
                  String dateStr = '';
                  if (rawDate != null) {
                    try {
                      dateStr = controller.getDate(rawDate);
                    } catch (_) {}
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'A',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                if (dateStr.isNotEmpty)
                                  Text(
                                    dateStr,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          RatingBarIndicator(
                            rating: rating.toDouble(),
                            itemBuilder: (context, index) => Icon(
                              Icons.star,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            unratedColor: Theme.of(context).colorScheme.outline,
                            itemCount: 5,
                            itemSize: 14.0,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        comment,
                        style: const TextStyle(
                            fontFamily: 'Lato', fontSize: 13, height: 1.4),
                      ),
                    ],
                  );
                },
              ),
            ] else ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    "No reviews yet. Be the first to review this product!",
                    style: TextStyle(
                        fontFamily: 'Lato', fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  void _showAddReviewModal(BuildContext context, ProductController controller) {
    int selectedRating = 5;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Write a Review",
                    style: txtTheme()
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Select Rating",
                style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setState) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final star = index + 1;
                      return IconButton(
                        icon: Icon(
                          star <= selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Theme.of(context).colorScheme.primary,
                          size: 36,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedRating = star;
                          });
                        },
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text(
                "Your Comment",
                style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Share your experience with this product...",
                  hintStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary, width: 2),
                  ),
                ),
                style: const TextStyle(fontFamily: 'Lato', fontSize: 14),
              ),
              const SizedBox(height: 20),
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: controller.isSubmittingReview.value
                        ? null
                        : () async {
                            final comment = commentController.text.trim();
                            if (comment.isEmpty) {
                              HelperFunctions()
                                  .showSnackBarError("Please write a comment.");
                              return;
                            }
                            await controller.postReview(
                              comment: comment,
                              rating: selectedRating,
                            );
                            Navigator.pop(context);
                          },
                    child: controller.isSubmittingReview.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Submit Review",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
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
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1.2,
          ),
        ),
      ),
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                widget.wishListTap();
                _controller
                    .forward(from: 0.0)
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
                        child: Obx(() {
                          final isInWishlist = WishListService.to.isInWishlist(
                            widget.controller.productId,
                          );
                          return SvgPicture.asset(
                            isInWishlist
                                ? 'assets/icon/like.svg'
                                : 'assets/icon/unlike.svg',
                          );
                        }),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "WISHLIST",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
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
                  SvgPicture.asset('assets/icon/addtobag.svg', width: 16),
                  const SizedBox(width: 10),
                  Text(
                    widget.btntext,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
