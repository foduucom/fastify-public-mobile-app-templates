import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/components/home_component/studio_search_bar_rounded.dart';
import 'package:foduu_ecommerce/components/search_bar_rounded.dart';
import 'package:shimmer/shimmer.dart';
import '/app/modules/product/views/product_view.dart';
import '/app/modules/shop/bindings/shop_binding.dart';
import '/app/routes/app_pages.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';

import '../controllers/search_controller.dart';
import 'filter_view.dart';

// ── Safe capitalize ──────────
String _cap(dynamic value) {
  if (value == null) return '';
  final s = value.toString().trim();
  if (s.isEmpty) return '';
  return s[0].toUpperCase() + s.substring(1);
}

class SearchView extends GetView<SearchsController> {
  const SearchView({Key? key}) : super(key: key);
  
  ColorScheme get colorScheme => Theme.of(Get.context!).colorScheme;
  TextTheme get textTheme => Theme.of(Get.context!).textTheme;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => HelperFunctions().closeKeyboard(context),
      child: Scaffold(
        backgroundColor: colorScheme.background,

        // Remove the default AppBar completely
        appBar: null,

        body: SafeArea(
          child: Column(
            children: [
              // ── CUSTOM HEADER WITH SEARCH BAR AND ICONS ──
              SearchViewHeader(
                width: width,
                height: height,
                searchTextController: controller.searchTextController,
                onSearchChanged: (value) {
                  controller.getSearchSuggestion(text: value);
                },
                onCartTap: () => Get.toNamed(Routes.CART),
                onMessageTap: () => print("Message tapped"),
                onNotificationTap: () => Get.toNamed(Routes.NOTIFICATION),
              ),

              SizedBox(height: 8),
              // ── POPULAR KEYWORDS SECTION ──
              // Container with vertical gap of 12px
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row with "Popular keyword" and "Filter"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Popular keyword",
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final result = await showFilterBottomSheet(
                              context,
                              controller.activeFilter.value,
                            );
                            if (result != null) {
                              controller.applyFilter(result);
                            }
                          },
                          child: Obx(() {
                            final count =
                                controller.activeFilter.value.activeFilterCount;
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Filter",
                                  style: textTheme.titleSmall?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (count > 0) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$count',
                                      style: textTheme.labelSmall?.copyWith(
                                        color: colorScheme.onPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8), // Gap between row and wrap

                  // Wrap with popular keyword buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 1, // Horizontal gap between buttons
                      runSpacing: 2, // Vertical gap between rows
                      children: [
                        // Example keywords - you can replace with dynamic data from controller
                        _buildKeywordButton(context, "Accessories"),
                        _buildKeywordButton(context, "Dresses"),
                        _buildKeywordButton(context, "Shoes"),
                        _buildKeywordButton(context, "Tops"),
                        _buildKeywordButton(context, "Jeans"),
                        _buildKeywordButton(context, "Books & Stationery"),
                        _buildKeywordButton(context, "Toys & Games"),
                        _buildKeywordButton(context, "Food & Beverages"),
                        _buildKeywordButton(context, "Health & Wellness"),
                        _buildKeywordButton(context, "Automotive"),
                        // Add more keywords as needed
                      ],
                    ),
                  ),
                ],
              ),

              // ── SCROLLABLE CONTENT ──
              Expanded(
                child: Obx(() {
                  // ── INITIAL LOADING STATE ──
                  if (controller.isSearching.value &&
                      controller.searchProduct.isEmpty) {
                    return _buildGridShimmer();
                  }

                  return SingleChildScrollView(
                    controller: controller.scrollController,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Recent Searches",
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    Icon(Icons.history,
                                        size: 20,
                                        color: colorScheme.onSurfaceVariant),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: controller.recentSearchList
                                      .take(6)
                                      .map((item) {
                                    return ActionChip(
                                      label:
                                          Text(item['name']?.toString() ?? ''),
                                      backgroundColor: colorScheme
                                          .surfaceVariant
                                          .withOpacity(0.4),
                                      side: BorderSide.none,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      labelStyle: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.w500),
                                      onPressed: () {
                                        controller.searchTextController.text =
                                            item['name']?.toString() ?? '';
                                        controller.getSearchSuggestion(
                                            text: controller
                                                .searchTextController.text);
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
                                : "Search Results",
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),

                        // ── EMPTY STATE ──
                        if (!controller.isSearching.value &&
                            controller.searchProduct.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 60),
                              child: Column(
                                children: [
                                  Icon(Icons.search_off_rounded,
                                      size: 80,
                                      color:
                                          colorScheme.outline.withOpacity(0.5)),
                                  const SizedBox(height: 16),
                                  Text("No products found",
                                      style: textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Text(
                                      "Try searching with a different keyword.",
                                      style: TextStyle(
                                          color: colorScheme.onSurfaceVariant)),
                                ],
                              ),
                            ),
                          ),

                        // ── PRODUCT GRID ──
                        if (controller.searchProduct.isNotEmpty)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
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
                                  final productId =
                                      product['_id']?.toString() ?? '';
                                  final productName =
                                      product['name']?.toString() ?? '';
                                  if (productId.isNotEmpty) {
                                    controller.saveRecentSearch(
                                        id: productId,
                                        name: productName,
                                        type: 'product');
                                    Get.to(() => ProductView(),
                                        binding: ShopBinding(),
                                        arguments: {'productId': productId});
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
                          } else if (!controller.hasNextPage &&
                              controller.searchProduct.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text("No more products",
                                    style: TextStyle(
                                        color: colorScheme.onSurfaceVariant)),
                              ),
                            );
                          }
                          return const SizedBox(height: 40);
                        }),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add this helper method inside your SearchView class
  Widget _buildKeywordButton(BuildContext context, String keyword) {
    var controller = Get.find<SearchsController>();
    return ElevatedButton(
      onPressed: () {
        // When keyword is tapped, populate search field and trigger search
        controller.searchTextController.text = keyword;
        controller.getSearchSuggestion(text: keyword);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              30), // Using height value for consistent rounding
        ),
      ),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(30), // Matching parent container style
          border: Border.all(
            color: colorScheme.outline,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            keyword,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  // ── GRID SHIMMER EFFECT (Keep as is) ──
  Widget _buildGridShimmer() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.62,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: colorScheme.surfaceVariant,
          highlightColor: colorScheme.surface,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
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
        final cleanPath =
            filepath.startsWith('/') ? filepath.substring(1) : filepath;
        return 'https://mywatch.vbought.com/images/$cleanPath';
      }
    }
    return '';
  }

  // Helper method to safely get price from variants
  double _getPrice(String field) {
    final variants = product['variants'];

    // If variants is null or empty
    if (variants == null) return 0.0;

    // If variants is a List (array)
    if (variants is List && variants.isNotEmpty) {
      final firstVariant = variants[0];
      if (firstVariant is Map) {
        return double.tryParse(firstVariant[field]?.toString() ?? '0') ?? 0.0;
      }
    }

    // If variants is a Map (object)
    if (variants is Map) {
      return double.tryParse(variants[field]?.toString() ?? '0') ?? 0.0;
    }

    return 0.0;
  }

  // Helper method to get quantity (handles null as unlimited)
  int? _getQuantity() {
    final variants = product['variants'];

    if (variants == null) return null; // Unlimited stock

    if (variants is List && variants.isNotEmpty) {
      final firstVariant = variants[0];
      if (firstVariant is Map) {
        final quantityValue = firstVariant['quantity'];
        if (quantityValue == null) return null; // Unlimited stock
        return int.tryParse(quantityValue.toString());
      }
    }

    if (variants is Map) {
      final quantityValue = variants['quantity'];
      if (quantityValue == null) return null; // Unlimited stock
      return int.tryParse(quantityValue.toString());
    }

    return null; // Default to unlimited if can't determine
  }

  // Helper method to get badge color based on type
  Color _getBadgeColor(String type, ColorScheme colorScheme) {
    switch (type) {
      case 'trending':
        return Colors.purple.shade600;
      case 'recommended':
        return Colors.green.shade600;
      default:
        return colorScheme.primary;
    }
  }

  // Helper method to get badge icon based on type
  IconData _getBadgeIcon(String type) {
    switch (type) {
      case 'featured':
        return Icons.star;
      case 'hot':
        return Icons.local_fire_department;
      case 'trending':
        return Icons.trending_up;
      case 'recommended':
        return Icons.thumb_up;
      default:
        return Icons.label;
    }
  }

  // Helper method to check if product is out of stock
  bool _isOutOfStock() {
    final quantity = _getQuantity();
    // Only out of stock if quantity is explicitly 0
    return quantity != null && quantity <= 0;
  }

  // Helper method to check if stock is limited
  bool _isStockLimited() {
    final quantity = _getQuantity();
    return quantity != null && quantity > 0;
  }

  // Helper method to get display quantity
  int? _getDisplayQuantity() {
    final quantity = _getQuantity();
    if (quantity == null) return null;
    if (quantity <= 0) return null;
    return quantity;
  }

  // Helper method to get stock status
  String _getStockStatus() {
    final quantity = _getQuantity();
    if (quantity == null) return 'UNLIMITED';
    if (quantity <= 0) return 'OUT OF STOCK';
    if (quantity <= 10) return 'LOW STOCK';
    return 'IN STOCK';
  }

  // Helper method to get stock status color
  Color _getStockStatusColor(int? quantity, ColorScheme colorScheme) {
    if (quantity == null) return Colors.blue.shade600;
    if (quantity <= 0) return Colors.red.shade600;
    if (quantity <= 10) return Colors.orange.shade600;
    return Colors.green.shade600;
  }

  // Helper method to get stock status icon
  IconData _getStockStatusIcon(int? quantity) {
    if (quantity == null) return Icons.invert_colors_off_outlined;
    if (quantity <= 0) return Icons.inventory_2_outlined;
    if (quantity <= 10) return Icons.warning_amber_rounded;
    return Icons.check_circle_outline;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final String imageUrl = _getImageUrl();
    final String name = product['name']?.toString() ?? 'Unknown Product';

    // Safely parse prices
    final double price = _getPrice('price');
    final double salePrice = _getPrice('sale_price');
    final bool hasDiscount = salePrice > 0 && salePrice < price;

    // Get quantity
    // Get quantity and stock status
    final int? quantity = _getQuantity();
    final bool isOutOfStock = _isOutOfStock();
    final bool isLimitedStock = _isStockLimited();
    final bool isLowStock =
        isLimitedStock && quantity != null && quantity <= 10;
    final bool isUnlimited = quantity == null;

    // Get product flags
    // final bool featured = product['featured'] ?? false;
    final bool hot = product['hot'] ?? false;
    final bool trending = product['trending'] ?? false;
    // final bool recommended = product['recommended'] ?? false;

    final double displayPrice = hasDiscount ? salePrice : price;

    // Collect active badges
    final Map<String, bool> badges = {
      'hot': hot,
      'trend': trending,
    };

    final List<String> activeBadges = badges.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    return InkWell(
      onTap: isOutOfStock ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOutOfStock
                ? colorScheme.error.withOpacity(0.3)
                : colorScheme.outline.withOpacity(0.15),
          ),
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
              flex: 4,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Container(
                      width: double.infinity,
                      color: colorScheme.surfaceVariant.withOpacity(0.5),
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                  child: CupertinoActivityIndicator()),
                              errorWidget: (context, url, error) => Icon(
                                  Icons.image_not_supported_outlined,
                                  color: colorScheme.outline),
                            )
                          : Icon(Icons.image_not_supported_outlined,
                              color: colorScheme.outline),
                    ),
                  ),

                  // Out of Stock Overlay
                  if (isOutOfStock)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15)),
                        color: Colors.black.withOpacity(0.7),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.shopping_cart_outlined,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'OUT OF STOCK',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Top Left Badges Stack
                  if (activeBadges.isNotEmpty && !isOutOfStock)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: activeBadges.map((badge) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _getBadgeColor(badge, colorScheme),
                                  _getBadgeColor(badge, colorScheme)
                                      .withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: _getBadgeColor(badge, colorScheme)
                                      .withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getBadgeIcon(badge),
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  badge.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),

            // ── Details Section ──
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product Title with indicators
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                  color: isOutOfStock
                                      ? colorScheme.onSurfaceVariant
                                      : null,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hot && !isOutOfStock)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber.shade700,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    // Price Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price and discount section

                        if (hasDiscount && !isOutOfStock)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              "₹${price.toStringAsFixed(2)}",
                              style: textTheme.bodyMedium?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: colorScheme.onSurfaceVariant
                                    .withOpacity(0.7),
                              ),
                            ),
                          ),
                        Text(
                          "₹${displayPrice.toStringAsFixed(2)}",
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isOutOfStock
                                ? colorScheme.onSurfaceVariant.withOpacity(0.6)
                                : colorScheme.primary,
                          ),
                        ),

                        // Stock status
                        if (isLowStock && !isOutOfStock)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Low Stock',
                              style: textTheme.labelSmall?.copyWith(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                      ],
                    ),
                    // Discount text
                    if (hasDiscount && price > 0 && !isOutOfStock)
                      Text(
                        "${((price - salePrice) / price * 100).round()}% off",
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
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
