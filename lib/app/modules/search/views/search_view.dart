import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/components/home_component/studio_search_bar_rounded.dart';
import 'package:foduu_ecommerce/components/search_bar_rounded.dart';
import 'package:shimmer/shimmer.dart';
import '/app/modules/product/views/product_view.dart';
import '/app/modules/shop/bindings/shop_binding.dart';
import '/components/product_grid_card.dart';
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
                          "Popular Brands",
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
                    child: Obx(() {
                      if (controller.isBrandsLoading.value) {
                        return _buildBrandsShimmer();
                      }

                      if (controller.brands.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Wrap(
                        spacing: 8, // Horizontal gap between buttons
                        runSpacing: 8, // Vertical gap between rows
                        children: controller.brands.map((brand) {
                          final name = brand['name']?.toString() ?? '';
                          final slug = brand['slug']?.toString() ?? '';
                          final isSelected =
                              controller.selectedBrandSlug.value == slug;

                          return _buildKeywordButton(
                              context, name, slug, isSelected);
                        }).toList(),
                      );
                    }),
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
                              childAspectRatio: 0.70,
                            ),
                            itemCount: controller.searchProduct.length,
                            itemBuilder: (context, index) {
                              final product = controller.searchProduct[index];
                              return ProductGridCard(
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
                                    Get.toNamed(Routes.PRODUCTDETAILS,
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

  // Update this helper method inside your SearchView class
  Widget _buildKeywordButton(
      BuildContext context, String keyword, String slug, bool isSelected) {
    var controller = Get.find<SearchsController>();
    return ElevatedButton(
      onPressed: () {
        // When brand is tapped, fetch products by brand
        controller.fetchProductsByBrand(slug);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Ink(
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            keyword,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  // ── BRANDS SHIMMER EFFECT ──
  Widget _buildBrandsShimmer() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(6, (index) {
        return Shimmer.fromColors(
          baseColor: colorScheme.surfaceVariant,
          highlightColor: colorScheme.surface,
          child: Container(
            width: 80 + (index % 3) * 20.0,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        );
      }),
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
