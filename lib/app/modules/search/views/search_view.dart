import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:foduu_ecommerce/app/modules/product/views/product_view.dart';
import 'package:foduu_ecommerce/app/modules/shop/bindings/shop_binding.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import '../../../../components/studio_widget/studio_search_bar_rounded.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';

import '../controllers/search_controller.dart';

// ── Safe capitalize ──────────
String _cap(dynamic value) {
  if (value == null) return '';
  final s = value.toString().trim();
  if (s.isEmpty) return '';
  return s[0].toUpperCase() + s.substring(1);
}

class SearchView extends GetView<SearchsController> {
  const SearchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: () => HelperFunctions().closeKeyboard(context),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: colorScheme.background,

          // ── PREMIUM APP BAR WITH INTEGRATED SEARCH ──
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70.0),
            child: AppBar(
              backgroundColor: colorScheme.background,
              elevation: 0,
              titleSpacing: 0,
              iconTheme: IconThemeData(color: colorScheme.onBackground),
              title: Padding(
                padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
                child: SearchBarRounded(
                  SearchsController: controller.searchTextController,
                  onChanged: (value) {
                    controller.getSearchSuggestion(text: value);
                  },
                  searchHintText: 'Search products, categories...',
                ),
              ),
            ),
          ),

          // ── SCROLLABLE CONTENT ──
          body: Obx(() {
            // ── INITIAL LOADING STATE ──
            if (controller.isSearching.value && controller.searchProduct.isEmpty) {
              return _buildGridShimmer(colorScheme);
            }

            return SingleChildScrollView(
              controller: controller.scrollController, // ✅ Attached Pagination Controller
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── RECENT SEARCHES (CHIPS) ──
                  if (controller.searchTextController.text.isEmpty &&
                      controller.recentSearchList.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Recent Searches",
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Icon(Icons.history, size: 20, color: colorScheme.onSurfaceVariant),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: controller.recentSearchList.take(6).map((item) {
                              return ActionChip(
                                label: Text(item['name']?.toString() ?? ''),
                                backgroundColor: colorScheme.surfaceVariant.withOpacity(0.4),
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                labelStyle: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w500),
                                onPressed: () {
                                  controller.searchTextController.text = item['name']?.toString() ?? '';
                                  controller.getSearchSuggestion(text: controller.searchTextController.text);
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                  // ── SECTION TITLE ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Text(
                      controller.searchTextController.text.trim().isEmpty
                          ? "Discover Products"
                          : "Search Results", // Removed length since it paginates now
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),

                  // ── EMPTY STATE ──
                  if (!controller.isSearching.value && controller.searchProduct.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Column(
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 80, color: colorScheme.outline.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            Text("No products found",
                                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text("Try searching with a different keyword.",
                                style: TextStyle(color: colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ),

                  // ── PRODUCT GRID ──
                  if (controller.searchProduct.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(), // Scroll handled by SingleChildScrollView
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.62,
                      ),
                      itemCount: controller.searchProduct.length,
                      itemBuilder: (context, index) {
                        final product = controller.searchProduct[index];
                        return _ProductGridCard(
                          product: product,
                          onTap: () {
                            final productId = product['_id']?.toString() ?? '';
                            final productName = product['name']?.toString() ?? '';
                            if (productId.isNotEmpty) {
                              controller.saveRecentSearch(
                                  id: productId, name: productName, type: 'product');
                              Get.to(() => ProductView(),
                                  binding: ShopBinding(), arguments: {'productId': productId});
                            }
                          },
                        );
                      },
                    ),

                  // ── PAGINATION LOADER ──
                  Obx(() {
                    if (controller.isFetchingMore.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: CupertinoActivityIndicator(radius: 14),
                        ),
                      );
                    } else if (!controller.hasNextPage && controller.searchProduct.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text("No more products", style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        ),
                      );
                    }
                    return const SizedBox(height: 40); // Bottom padding
                  }),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Grid Shimmer Loading Effect ──
  Widget _buildGridShimmer(ColorScheme colorScheme) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.62,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

// ── Beautiful Product Grid Card ─────────────────────────────────────────────
class _ProductGridCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;

  const _ProductGridCard({required this.product, required this.onTap});

  // Safe Image URL Extractor
  String _getImageUrl() {
    final featuredImg = product['featured_image'];
    if (featuredImg != null && featuredImg is Map) {
      final downloadUrl = featuredImg['download_url']?.toString() ?? '';
      final filepath = featuredImg['filepath']?.toString() ?? '';

      if (downloadUrl.isNotEmpty) return downloadUrl;
      if (filepath.isNotEmpty) {
        final cleanPath = filepath.startsWith('/') ? filepath.substring(1) : filepath;
        return 'https://mywatch.vbought.com/images/$cleanPath';
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final String imageUrl = _getImageUrl();
    final String name = product['name']?.toString() ?? 'Unknown Product';

    // Safely parse prices
    final double price = double.tryParse(product['price']?.toString() ?? '0') ?? 0.0;
    final double salePrice = double.tryParse(product['sale_price']?.toString() ?? '0') ?? 0.0;
    final bool hasDiscount = salePrice > 0 && salePrice < price;
    final double displayPrice = hasDiscount ? salePrice : price;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image Section ──
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Container(
                      width: double.infinity,
                      color: colorScheme.surfaceVariant.withOpacity(0.5),
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(child: CupertinoActivityIndicator()),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.image_not_supported_outlined, color: colorScheme.outline),
                      )
                          : Icon(Icons.image_not_supported_outlined, color: colorScheme.outline),
                    ),
                  ),
                  // Discount Badge
                  if (hasDiscount && price > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${((price - salePrice) / price * 100).round()}% OFF",
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Details Section ──
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product Title
                    Text(
                      name,
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Price Row
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasDiscount)
                          Text(
                            "₹${price.toStringAsFixed(2)}",
                            style: textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        Text(
                          "₹${displayPrice.toStringAsFixed(2)}",
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
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
      ),
    );
  }
}