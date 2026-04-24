import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '/app/modules/product/controllers/product_controller.dart';
import '/app/routes/app_pages.dart';
import '../../../../components/shimmer/shimmer_effects.dart';
import '/constants/helper_functions.dart';
import '/constants/product_helper.dart';
import 'package:get/get.dart';

class ProductView extends GetView<ProductController> {
  ProductView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.create(() => ProductController(), permanent: false);
    final controller = Get.find<ProductController>();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(context, controller, colorScheme),
        body: Column(
          children: [
            SizedBox(
              height: 60,
            ),
            // ── Product Gallery (fixed, not scrollable) ──────────────
            Obx(() => _ProductImageGallery(
                  images: controller.galleryUrls,
                  isLoading: controller.isLoading.value,
                  currentIndex: controller.currentImageIndex,
                  onPageChanged: (i) => controller.currentImageIndex.value = i,
                )),

            // ── Info Sheet (scrollable) ──────────────────────────────
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Drag handle ────────────────────────────────
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 8),
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      // ── Name + Badges row ──────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return const ShimmerEffect(height: 26, width: 200);
                          }
                          return Text(
                            controller.productDetials['name']?.toString() ?? '',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                              fontSize: 20,
                              height: 1.3,
                            ),
                          );
                        }),
                      ),

                      // ── Rating row ─────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return const SizedBox.shrink();
                          }
                          final rating =
                              controller.productDetials['average_rating'];
                          final count =
                              controller.productDetials['rating_count'];
                          final ratingVal = rating == null
                              ? 0.0
                              : double.tryParse(rating.toString()) ?? 0.0;
                          return Row(
                            children: [
                              RatingBarIndicator(
                                rating: ratingVal,
                                itemBuilder: (_, __) => Icon(Icons.star_rounded,
                                    color: Colors.amber.shade500),
                                unratedColor: colorScheme.outlineVariant,
                                itemCount: 5,
                                itemSize: 16,
                                direction: Axis.horizontal,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                ratingVal.toStringAsFixed(1),
                                style: textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${count ?? 0} reviews)',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),

                      // ── Status/badge pills ──────────────────────────
                      Obx(() {
                        if (controller.isLoading.value) {
                          return const SizedBox.shrink();
                        }
                        final p = controller.productDetials;
                        final status = p['status'];
                        final tags = p['tags'];
                        print("tags === $tags");
                        final brand = p['brand'];
                        print("brand === $brand");
                        final statusName =
                            status is Map ? status['name']?.toString() : null;
                        final isFeatured = p['featured'] == true;
                        final isHot = p['hot'] == true;
                        final isTrending = p['trending'] == true;
                        final isRecommended = p['recommended'] == true;
                        final isDigital = p['is_digital'] == true;

                        final badges = <_BadgeData>[
                          if (statusName != null)
                            _BadgeData(statusName, Colors.green.shade600),
                          if (isFeatured) _BadgeData('Featured', Colors.teal),
                          if (isHot) _BadgeData('🔥 Hot', Colors.deepOrange),
                          if (isTrending) _BadgeData('Trending', Colors.purple),
                          if (isRecommended)
                            _BadgeData('Recommended', Colors.indigo),
                          if (isDigital) _BadgeData('Digital', Colors.blue),
                        ];

                        if (badges.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: badges
                                .map((b) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: b.color.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                            color:
                                                b.color.withValues(alpha: 0.3)),
                                      ),
                                      child: Text(b.label,
                                          style: TextStyle(
                                              color: b.color,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600)),
                                    ))
                                .toList(),
                          ),
                        );
                      }),

                      // ── Brand & Tags ────────────────────────────────
                      Obx(() {
                        if (controller.isLoading.value) {
                          return const SizedBox.shrink();
                        }
                        final p = controller.productDetials;
                        final brand = p['brand'];
                        final tags = p['tags'];

                        final brandName =
                            brand is Map ? brand['name']?.toString() : null;
                        final tagNames = tags is List
                            ? tags
                                .whereType<Map>()
                                .map((t) => t['name']?.toString() ?? '')
                                .where((n) => n.isNotEmpty)
                                .toList()
                            : <String>[];

                        if (brandName == null && tagNames.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              if (brandName != null)
                                _pill('🏷 $brandName',
                                    Colors.indigo.shade400, colorScheme),
                              ...tagNames.map((t) => _pill(
                                  '# $t', Colors.teal.shade600, colorScheme)),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 14),

                      // ── Divider ────────────────────────────────────
                      Divider(
                          height: 1,
                          color: colorScheme.surfaceContainerHighest),

                      // ── Price Section ───────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return const ShimmerEffect(height: 32, width: 140);
                          }
                          final priceInfo = ProductHelper.calculatePriceInfo(
                            Map<String, dynamic>.from(
                                controller.productDetials),
                            variantIndex: controller.selectedVariantIndex.value,
                          );
                          final hasSale = priceInfo['salePrice'] != null &&
                              priceInfo['salePrice'] != '0' &&
                              priceInfo['salePrice'] != '';

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '₹${hasSale ? priceInfo['salePrice'] : priceInfo['productPrice']}',
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                  fontSize: 26,
                                ),
                              ),
                              if (hasSale) ...[
                                const SizedBox(width: 10),
                                Text(
                                  '₹${priceInfo['productPrice']}',
                                  style: textTheme.bodyMedium?.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor:
                                        colorScheme.onSurfaceVariant,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    priceInfo['discountRate'] ?? '',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        }),
                      ),

                      // ── Short Description ───────────────────────────
                      Obx(() {
                        final content = controller.productDetials['content'];
                        if (content == null ||
                            content.toString().trim().isEmpty) {
                          return const SizedBox.shrink();
                        }
                        // Strip HTML tags so flutter_html's layout bugs don't
                        // cause the large blank gap between this section and Variants.
                        final plainText = content
                            .toString()
                            .replaceAll(RegExp(r'<[^>]*>'), '')
                            .replaceAll('&nbsp;', ' ')
                            .replaceAll('&amp;', '&')
                            .replaceAll('&lt;', '<')
                            .replaceAll('&gt;', '>')
                            .replaceAll('&quot;', '"')
                            .replaceAll('&#39;', "'")
                            .trim();
                        if (plainText.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              plainText,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 8),

                      // ── Variants ────────────────────────────────────
                      Obx(() {
                        if (controller.labels.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: controller.labels.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, parentIndex) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Select ',
                                              style: textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                            TextSpan(
                                              text: controller
                                                  .labels[parentIndex],
                                              style: textTheme.bodyMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: List.generate(
                                          controller
                                              .labelVariant[parentIndex].length,
                                          (index) {
                                            return GestureDetector(
                                              onTap: () =>
                                                  controller.onSelectVariant(
                                                controller.labels[parentIndex],
                                                controller.labelVariant[
                                                    parentIndex][index],
                                              ),
                                              child: Obx(() {
                                                final isSelected =
                                                    controller.selectedVariant[
                                                            controller.labels[
                                                                parentIndex]] ==
                                                        controller.labelVariant[
                                                            parentIndex][index];
                                                return AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? colorScheme.primary
                                                        : colorScheme
                                                            .surfaceContainerHighest,
                                                    border: Border.all(
                                                      width: 1.5,
                                                      color: isSelected
                                                          ? colorScheme.primary
                                                          : colorScheme.outline,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  child: Text(
                                                    controller.labelVariant[
                                                        parentIndex][index],
                                                    style: textTheme.labelMedium
                                                        ?.copyWith(
                                                      color: isSelected
                                                          ? colorScheme
                                                              .onPrimary
                                                          : colorScheme
                                                              .onSurface,
                                                      fontWeight: isSelected
                                                          ? FontWeight.bold
                                                          : FontWeight.w500,
                                                    ),
                                                  ),
                                                );
                                              }),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }),

                      // ── Quantity Selector ───────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Quantity',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                                fontSize: 15,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    colorScheme.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _StepperBtn(
                                    icon: Icons.remove,
                                    colorScheme: colorScheme,
                                    onTap: controller.decrement,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Obx(() => Text(
                                          controller.count.toString(),
                                          style: textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.primary,
                                            fontSize: 16,
                                          ),
                                        )),
                                  ),
                                  _StepperBtn(
                                    icon: Icons.add,
                                    colorScheme: colorScheme,
                                    onTap: controller.increment,
                                    filled: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),
                      Divider(
                          height: 1,
                          color: colorScheme.surfaceContainerHighest),

                      // ── Long Description ────────────────────────────
                      Obx(() {
                        final longContent =
                            controller.productDetials['long_content'] ?? '';
                        if (longContent.toString().isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Product Details',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Html(
                                  data: longContent.toString(),
                                  style: {
                                    'body': Style(
                                      fontFamily: 'Lato',
                                      margin: Margins.zero,
                                      padding: HtmlPaddings.zero,
                                    ),
                                    'p': Style(
                                      margin: Margins.zero,
                                      padding: HtmlPaddings.zero,
                                    ),
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _OrderButton(
          btntext: 'Add to Cart',
          controller: controller,
          wishListTap: () async {},
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

  PreferredSizeWidget _buildAppBar(BuildContext context,
      ProductController controller, ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: colorScheme.surface.withValues(alpha: 0.0),
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              color: colorScheme.onSurface, size: 18),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.share_outlined,
                color: colorScheme.onSurface, size: 18),
            onPressed: () {},
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

// ── Image Gallery ─────────────────────────────────────────────────────────────
// Layout:
//  • Top section  – a clean, centred, padded image card (no bleed)
//  • Bottom strip – horizontal thumbnail row acting as the page indicator
class _ProductImageGallery extends StatefulWidget {
  final List<String> images;
  final bool isLoading;
  final RxInt currentIndex;
  final ValueChanged<int> onPageChanged;

  const _ProductImageGallery({
    required this.images,
    required this.isLoading,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  State<_ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<_ProductImageGallery> {
  final PageController _pageController = PageController();
  final ScrollController _thumbController = ScrollController();

  // Height of the thumbnail strip + its padding
  static const double _thumbStripHeight = 80.0;
  static const double _thumbSize = 60.0;

  @override
  void dispose() {
    _pageController.dispose();
    _thumbController.dispose();
    super.dispose();
  }

  void _onThumbTap(int i) {
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenW = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;

    // Image fills from y=0 behind the transparent AppBar (full-bleed).
    // topPadding is part of the section height so the card area is tall enough,
    // but the card itself has no artificial top gap.
    final sectionHeight = topPadding + screenW * 0.30 + _thumbStripHeight;

    return SizedBox(
      height: sectionHeight,
      width: double.infinity,
      child: Column(
        children: [
          // ── Main image card ─────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: widget.isLoading
                  ? _buildMainShimmer()
                  : widget.images.isEmpty
                      ? _buildPlaceholder()
                      : _buildPageView(colorScheme, screenW * 0.82),
            ),
          ),

          // ── Thumbnail strip (BOTTOM) ────────────────────────────────
          if (!widget.isLoading && widget.images.isNotEmpty)
            SizedBox(
              height: _thumbStripHeight,
              child: widget.images.length == 1
                  ? Center(
                      child: Container(
                        width: 24,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    )
                  : ListView.separated(
                      controller: _thumbController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: widget.images.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) => _ThumbChip(
                        imageUrl: widget.images[i],
                        size: _thumbSize,
                        isSelected: widget.currentIndex,
                        index: i,
                        colorScheme: colorScheme,
                        onTap: () => _onThumbTap(i),
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  // Rest of the methods remain the same...
  Widget _buildPageView(ColorScheme colorScheme, double cardSize) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: widget.onPageChanged,
      itemCount: widget.images.length,
      itemBuilder: (_, i) => _buildImageCard(widget.images[i], colorScheme),
    );
  }

  Widget _buildImageCard(String url, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.contain,
          placeholder: (_, __) => _buildMainShimmer(),
          errorWidget: (ctx, __, ___) => Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: Theme.of(ctx).colorScheme.outline,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainShimmer() =>
      const Center(child: CircularProgressIndicator(strokeWidth: 2));

  Widget _buildPlaceholder() => Center(
      child: Icon(Icons.image_outlined,
          size: 56, color: Theme.of(context).colorScheme.outline));
}

// ── Thumbnail chip ─────────────────────────────────────────────────────────────
class _ThumbChip extends StatelessWidget {
  final String imageUrl;
  final double size;
  final RxInt isSelected;
  final int index;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _ThumbChip({
    required this.imageUrl,
    required this.size,
    required this.isSelected,
    required this.index,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = isSelected.value == index;
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  selected ? colorScheme.primary : colorScheme.outlineVariant,
              width: selected ? 2.0 : 1.2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          padding: const EdgeInsets.all(4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Icon(
                Icons.image_not_supported_outlined,
                size: 20,
                color: colorScheme.outline,
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ── Stepper button (pill style, matches cart view) ────────────────────────────
class _StepperBtn extends StatelessWidget {
  final IconData icon;
  final ColorScheme colorScheme;
  final VoidCallback onTap;
  final bool filled;

  const _StepperBtn({
    required this.icon,
    required this.colorScheme,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: filled ? colorScheme.primary : colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(icon,
            size: 16,
            color: filled ? colorScheme.onPrimary : colorScheme.onSurface),
      ),
    );
  }
}

// ── Badge data model ──────────────────────────────────────────────────────────
class _BadgeData {
  final String label;
  final Color color;
  const _BadgeData(this.label, this.color);
}

// ── Bottom CTA bar (matches cart_view style) ──────────────────────────────────
class _OrderButton extends StatelessWidget {
  final VoidCallback wishListTap;
  final String btntext;
  final VoidCallback addToCartTap;
  final ProductController controller;

  const _OrderButton({
    Key? key,
    required this.wishListTap,
    required this.addToCartTap,
    required this.controller,
    required this.btntext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Row(
        children: [
          // ── Wishlist button ──────────────────────────────────────────
          GestureDetector(
            onTap: wishListTap,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: colorScheme.outline,
                  width: 1.2,
                ),
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                color: colorScheme.error,
                size: 24,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ── Add to Cart button ───────────────────────────────────────
          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: addToCartTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined,
                        color: colorScheme.onPrimary, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      btntext,
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Keep public export alias so callers that use `OrderButton` still compile.
typedef OrderButton = _OrderButton;

Widget _pill(String label, Color color, ColorScheme cs) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
