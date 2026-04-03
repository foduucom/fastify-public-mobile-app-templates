import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '/app/modules/product/controllers/product_controller.dart';
import '/core/services/wishlistService.dart';
import '/app/routes/app_pages.dart';
import '../../../../components/shimmer/shimmer_effects.dart';
import '/constants/constants.dart';
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

    // ✅ WRAPPED IN SAFE AREA
    return SafeArea(
      top: false, // Keep top false so the image slider goes beautifully behind the status bar
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(context, controller, colorScheme),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Product Gallery ──
              Obx(() {
                return _ProductImageGallery(
                  images: controller.galleryUrls,
                  isLoading: controller.isLoading.value,
                  currentIndex: controller.currentImageIndex,
                  onPageChanged: (i) => controller.currentImageIndex.value = i,
                );
              }),

              // ── Product Info Card ──
              Container(
                transform: Matrix4.translationValues(0, -20, 0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // ── Name ──
                    Padding(
                      padding: pageSurroundingPadding,
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const ShimmerEffect(height: 28, width: 200);
                        }
                        return Text(
                          controller.productDetials['name']?.toString() ?? '',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 22,
                            height: 1.2, // ✅ Keep text tight
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 5),

                    // ── Rating ──
                    Padding(
                      padding: pageSurroundingPadding,
                      child: Obx(() {
                        if(controller.isLoading.value) return const SizedBox.shrink();
                        final rating = controller.productDetials['average_rating'];
                        final count = controller.productDetials['rating_count'];
                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.amber.shade200),
                              ),
                              child: Row(
                                children: [
                                  RatingBarIndicator(
                                    rating: rating == null ? 0.0 : double.tryParse(rating.toString()) ?? 0.0,
                                    itemBuilder: (_, __) => Icon(Icons.star_rounded, color: Colors.amber.shade500),
                                    unratedColor: Colors.amber.shade200,
                                    itemCount: 5,
                                    itemSize: 16,
                                    direction: Axis.horizontal,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '(${count ?? 0} reviews)',
                                    style: textTheme.bodySmall?.copyWith(color: Colors.amber.shade700, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ),

                    const SizedBox(height: 5),

                    // ── Price ──
                    Padding(
                      padding: pageSurroundingPadding,
                      child: Obx(() {
                        if (controller.isLoading.value) return const ShimmerEffect(height: 28, width: 120);

                        final priceInfo = ProductHelper.calculatePriceInfo(
                          Map<String, dynamic>.from(controller.productDetials),
                          variantIndex: controller.selectedVariantIndex.value,
                        );
                        final hasSale = priceInfo['salePrice'] != null && priceInfo['salePrice'] != '0' && priceInfo['salePrice'] != '';

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${hasSale ? priceInfo['salePrice'] : priceInfo['productPrice']}',
                              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 26),
                            ),
                            if (hasSale) ...[
                              const SizedBox(width: 10),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3.0),
                                child: Text(
                                  '₹${priceInfo['productPrice']}',
                                  style: textTheme.titleMedium?.copyWith(decoration: TextDecoration.lineThrough, color: Colors.grey.shade500),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                margin: const EdgeInsets.only(bottom: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
                                child: Text(
                                  priceInfo['discountRate'] ?? '',
                                  style: textTheme.labelSmall?.copyWith(color: Colors.green.shade700, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        );
                      }),
                    ),

                    const SizedBox(height: 4),

                    // ── Short description ──
                    Padding(
                      padding: pageSurroundingPadding,
                      child: Obx(() {
                        final content = controller.productDetials['content'];
                        if (content == null || content.toString().isEmpty) return const SizedBox.shrink();
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          // ✅ FIXED: Strip out HTML margins that cause extra height
                          child: HtmlWidget(
                            content.toString(),
                            customStylesBuilder: (element) {
                              if (element.localName == 'p' || element.localName == 'body') {
                                return {'margin': '0', 'padding': '0'};
                              }
                              return null;
                            },
                          ),
                        );
                      }),
                    ),

                    // ── Variants ──
                    Padding(
                      padding: pageSurroundingPadding,
                      child: Obx(() {
                        if (controller.labels.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: controller.labels.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 16),
                              itemBuilder: (context, parentIndex) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('Select ', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.grey.shade600, fontSize: 14)),
                                        Text(controller.labels[parentIndex], style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: List.generate(
                                        controller.labelVariant[parentIndex].length,
                                            (index) {
                                          return GestureDetector(
                                            onTap: () => controller.onSelectVariant(controller.labels[parentIndex], controller.labelVariant[parentIndex][index]),
                                            child: Obx(() {
                                              final isSelected = controller.selectedVariant[controller.labels[parentIndex]] == controller.labelVariant[parentIndex][index];
                                              return AnimatedContainer(
                                                duration: const Duration(milliseconds: 200),
                                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: isSelected ? colorScheme.primary : Colors.white,
                                                  border: Border.all(width: 1.5, color: isSelected ? colorScheme.primary : Colors.grey.shade300),
                                                  borderRadius: BorderRadius.circular(10),
                                                  boxShadow: isSelected ? [BoxShadow(color: colorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : [],
                                                ),
                                                child: Text(
                                                  controller.labelVariant[parentIndex][index],
                                                  style: textTheme.labelLarge?.copyWith(
                                                    color: isSelected ? Colors.white : Colors.black87,
                                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // ── Quantity selector ──
                    Padding(
                      padding: pageSurroundingPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quantity', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _QtyButton(icon: Icons.remove, colorScheme: colorScheme, onTap: controller.decrement),
                              const SizedBox(width: 14),
                              Obx(() => Container(
                                width: 46, height: 46,
                                decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                  child: Text(controller.count.toString(), style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary, fontSize: 18)),
                                ),
                              )),
                              const SizedBox(width: 14),
                              _QtyButton(icon: Icons.add, colorScheme: colorScheme, onTap: controller.increment, filled: true),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Long description ──
                    Padding(
                      padding: pageSurroundingPadding,
                      child: Obx(() {
                        final longContent = controller.productDetials['long_content'] ?? '';
                        if (longContent.toString().isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Product Details', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black)),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              // ✅ FIXED: Enforced strict zero margin and padding styles on the body and paragraphs
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
                                  }
                              ),
                            ),
                          ],
                        );
                      }),
                    ),

                    // Reduced bottom spacing since SafeArea handles it now
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: OrderButton(
          btntext: 'Add to Cart',
          controller: controller,
          wishListTap: () async {
            // Wishlist Logic
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

  PreferredSizeWidget _buildAppBar(BuildContext context, ProductController controller, ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))]),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 18),
        ),
      ),
    );
  }
}

// ── CUSTOM IMAGE GALLERY ────────────────────────────────────────────────────────────
class _ProductImageGallery extends StatefulWidget {
  final List<String> images;
  final bool isLoading;
  final RxInt currentIndex;
  final ValueChanged<int> onPageChanged;

  const _ProductImageGallery({required this.images, required this.isLoading, required this.currentIndex, required this.onPageChanged});

  @override
  State<_ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<_ProductImageGallery> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final galleryHeight = MediaQuery.of(context).size.height * 0.45;

    return SizedBox(
      height: galleryHeight,
      width: double.infinity,
      child: Stack(
        children: [
          Container(height: galleryHeight, color: Colors.grey.shade100),
          if (widget.isLoading)
            _buildShimmer(galleryHeight)
          else if (widget.images.isEmpty)
            _buildPlaceholder(galleryHeight)
          else
            PageView.builder(
              controller: _pageController,
              onPageChanged: widget.onPageChanged,
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: CachedNetworkImage(
                    imageUrl: widget.images[index],
                    fit: BoxFit.contain,
                    placeholder: (_, __) => _buildShimmer(galleryHeight),
                    errorWidget: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
                  ),
                );
              },
            ),
          if (!widget.isLoading && widget.images.length > 1)
            Positioned(
              bottom: 30, left: 0, right: 0,
              child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
                      (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: widget.currentIndex.value == i ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(color: widget.currentIndex.value == i ? colorScheme.primary : Colors.grey.shade400, borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              )),
            ),
        ],
      ),
    );
  }

  Widget _buildShimmer(double height) => Container(height: height, child: const Center(child: CircularProgressIndicator()));
  Widget _buildPlaceholder(double height) => SizedBox(height: height, child: Center(child: Icon(Icons.image_outlined, size: 64, color: Colors.grey.shade400)));
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final ColorScheme colorScheme;
  final VoidCallback onTap;
  final bool filled;

  const _QtyButton({required this.icon, required this.colorScheme, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46, height: 46,
        decoration: BoxDecoration(
          color: filled ? colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: filled ? colorScheme.primary : Colors.grey.shade300, width: 1.5),
        ),
        child: Icon(icon, size: 20, color: filled ? Colors.white : Colors.black87),
      ),
    );
  }
}

class OrderButton extends StatelessWidget {
  final VoidCallback wishListTap;
  final String btntext;
  final VoidCallback addToCartTap;
  final ProductController controller;

  const OrderButton({Key? key, required this.wishListTap, required this.addToCartTap, required this.controller, required this.btntext}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 20, offset: const Offset(0, -6))]),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: wishListTap,
              child: Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.pink.shade100)),
                child: Center(child: Icon(Icons.favorite_border_rounded, color: Colors.pink.shade400, size: 24)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: addToCartTap,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Text(btntext, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}