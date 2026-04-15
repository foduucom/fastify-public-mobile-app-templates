import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';

import '/app/modules/product/views/product_view.dart';
import '/app/modules/shop/bindings/shop_binding.dart';
import '/app/modules/shop/controllers/shop_controller.dart';
import '/components/product_grid_card.dart';

class ShopView extends GetView<ShopController> {
  const ShopView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => ShopController());
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        centerTitle: true,
        title: Obx(() => Column(
              children: [
                Text(
                  controller.collectionName.value,
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${controller.totalProducts.value} items",
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded), // Filter Icon
            onPressed: () => _showFilterBottomSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        return Column(
          children: [
            // ── ACTIVE FILTER CHIPS (Horizontal Scroll) ──
            if (_hasActiveFilters()) _buildActiveFilterChips(colorScheme),

            // ── PRODUCT GRID ──
            Expanded(
              child: controller.isLoading.value
                  ? _buildGridShimmer()
                  : RefreshIndicator(
                      onRefresh: () =>
                          controller.fetchProducts(isRefresh: true),
                      child: _buildProductGrid(colorScheme, textTheme),
                    ),
            ),
          ],
        );
      }),
    );
  }

  // ─── ACTIVE FILTER HELPERS ────────────────────────────────────────────
  bool _hasActiveFilters() {
    return controller.isFeatured.value ||
        controller.isHot.value ||
        controller.selectedCategories.isNotEmpty ||
        controller.selectedBrands.isNotEmpty ||
        controller.minPrice.value > 0 ||
        controller.maxPrice.value < 10000;
  }

  Widget _buildActiveFilterChips(ColorScheme colorScheme) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Clear All Button
          ActionChip(
            label: const Text("Clear All"),
            avatar: const Icon(Icons.close, size: 16),
            backgroundColor: colorScheme.errorContainer,
            labelStyle: TextStyle(color: colorScheme.onErrorContainer),
            onPressed: () => controller.clearAllFilters(),
          ),
          const SizedBox(width: 8),

          if (controller.isFeatured.value)
            _activeChip("Featured", () {
              controller.isFeatured.value = false;
              controller.fetchProducts(isRefresh: true);
            }, colorScheme),

          if (controller.isHot.value)
            _activeChip("Hot", () {
              controller.isHot.value = false;
              controller.fetchProducts(isRefresh: true);
            }, colorScheme),

          ...controller.selectedCategories
              .map((cat) => _activeChip(cat.capitalizeFirst!, () {
                    controller.toggleCategory(cat);
                    controller.fetchProducts(isRefresh: true);
                  }, colorScheme)),

          ...controller.selectedBrands
              .map((brand) => _activeChip(brand.capitalizeFirst!, () {
                    controller.toggleBrand(brand);
                    controller.fetchProducts(isRefresh: true);
                  }, colorScheme)),
        ],
      ),
    );
  }

  Widget _activeChip(
      String label, VoidCallback onDeleted, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onDeleted,
        backgroundColor: colorScheme.primaryContainer,
        labelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
        side: BorderSide.none,
      ),
    );
  }

  // ─── PREMIUM FILTER BOTTOM SHEET ──────────────────────────────────────
  void _showFilterBottomSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Get.bottomSheet(
      Container(
        height:
            MediaQuery.of(context).size.height * 0.75, // 75% of screen height
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle Bar
            const SizedBox(height: 12),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: colorScheme.outline.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10))),

            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Sort & Filter",
                      style: textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      controller.clearAllFilters();
                      Get.back();
                    },
                    child: Text("Clear All",
                        style: TextStyle(color: colorScheme.error)),
                  )
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable Filter Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. SORTING
                    Text("Sort By",
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _sortChip("Newest", "created_at", "desc", colorScheme),
                        _sortChip(
                            "Price: Low-High", "price", "asc", colorScheme),
                        _sortChip(
                            "Price: High-Low", "price", "desc", colorScheme),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 2. QUICK TOGGLES
                    Text("Collections",
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Obx(() => CheckboxListTile(
                          title: const Text("Featured Products"),
                          value: controller.isFeatured.value,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (val) =>
                              controller.isFeatured.value = val!,
                        )),
                    Obx(() => CheckboxListTile(
                          title: const Text("Hot Trending"),
                          value: controller.isHot.value,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (val) => controller.isHot.value = val!,
                        )),
                    const SizedBox(height: 16),

                    // 3. PRICE RANGE
                    Text("Price Range",
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Obx(() => Column(
                          children: [
                            RangeSlider(
                              values: controller.currentPriceRange.value,
                              min: 0,
                              max: 10000,
                              divisions: 100,
                              activeColor: colorScheme.primary,
                              labels: RangeLabels(
                                "₹${controller.currentPriceRange.value.start.round()}",
                                "₹${controller.currentPriceRange.value.end.round()}",
                              ),
                              onChanged: (RangeValues values) {
                                controller.currentPriceRange.value = values;
                                controller.minPrice.value = values.start;
                                controller.maxPrice.value = values.end;
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("₹${controller.minPrice.value.round()}"),
                                Text("₹${controller.maxPrice.value.round()}"),
                              ],
                            )
                          ],
                        )),
                    const SizedBox(height: 24),

                    // 4. CATEGORIES (Mocked for UI, wire these to your actual category list)
                    Text("Categories",
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Obx(() => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _categoryChip(
                                "electronics", "Electronics", colorScheme),
                            _categoryChip("clothing", "Clothing", colorScheme),
                            _categoryChip(
                                "home-decor", "Home Decor", colorScheme),
                            _categoryChip("toys", "Toys", colorScheme),
                          ],
                        )),
                  ],
                ),
              ),
            ),

            // Apply Button Sticky Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5))
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(); // Close sheet
                      controller.fetchProducts(isRefresh: true); // Trigger API
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Apply Filters",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _sortChip(
      String label, String by, String order, ColorScheme colorScheme) {
    return Obx(() {
      bool isSelected =
          controller.sortBy.value == by && controller.sortOrder.value == order;
      return ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: colorScheme.primaryContainer,
        onSelected: (val) {
          controller.sortBy.value = by;
          controller.sortOrder.value = order;
        },
      );
    });
  }

  Widget _categoryChip(String slug, String label, ColorScheme colorScheme) {
    bool isSelected = controller.selectedCategories.contains(slug);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: colorScheme.primaryContainer,
      onSelected: (val) => controller.toggleCategory(slug),
    );
  }

  // ── MAIN PRODUCT GRID (REUSED FROM PREVIOUS) ───────────────────────────
  Widget _buildProductGrid(ColorScheme colorScheme, TextTheme textTheme) {
    if (controller.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 80, color: colorScheme.outline.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text("No products match your filters",
                style: textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      controller: controller.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.62,
            ),
            itemCount: controller.products.length,
            itemBuilder: (context, index) {
              final product = controller.products[index];
              return ProductGridCard(
                product: product,
                onTap: () {
                  final productId = product['_id']?.toString() ?? '';
                  if (productId.isNotEmpty) {
                    Get.to(() => ProductView(),
                        binding: ShopBinding(),
                        arguments: {'productId': productId});
                  }
                },
              );
            },
          ),
          if (controller.isFetchingMore.value)
            const Padding(
                padding: EdgeInsets.all(24.0),
                child: CupertinoActivityIndicator(radius: 14)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGridShimmer() {
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
                color: Colors.white, borderRadius: BorderRadius.circular(16))),
      ),
    );
  }
}
