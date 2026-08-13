import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';

import 'package:foduu_ecommerce/app/modules/product/views/product_view.dart';
import 'package:foduu_ecommerce/app/modules/shop/bindings/shop_binding.dart';
import 'package:foduu_ecommerce/app/modules/shop/controllers/shop_controller.dart';
import 'package:foduu_ecommerce/components/studio_widget/studio_category.dart';
import 'package:foduu_ecommerce/components/studio_widget/product_grid_card.dart';

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
          Obx(() {
            final count = controller.activeFilterCount;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.tune_rounded),
                  onPressed: () => _showFilterBottomSheet(context),
                ),
                if (count > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: PopScope(
        canPop: controller.filterCategoryStack.isEmpty,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          controller.goUpFilterCategory();
        },
        child: Obx(() {
          return Column(
            children: [
              // ── ACTIVE FILTER CHIPS (Horizontal Scroll) ──
              if (_hasActiveFilters()) _buildActiveFilterChips(colorScheme),

              // ── SUB CATEGORY STRIP (only when entered with category context) ──
              _buildSubCategorySection(colorScheme),

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
      ),
    );
  }

  // ─── SUB CATEGORY STRIP + BREADCRUMB ─────────────────────────────────
  Widget _buildSubCategorySection(ColorScheme colorScheme) {
    if (controller.filterCurrentCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (controller.filterCategoryStack.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                GestureDetector(
                  onTap: controller.goUpFilterCategory,
                  child: Icon(Icons.arrow_back_ios_new,
                      size: 14, color: colorScheme.primary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      [
                        'All',
                        ...controller.filterCategoryStack.map((e) =>
                            (e['cat'] as Map)['name']?.toString() ?? ''),
                      ].join(' › '),
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        CategoryHome(
          categoryData: {
            'categories': controller.filterCurrentCategories,
            'view': 'list',
            'layout': 'circular',
            'list_view_type': 'horizontal',
          },
          onCategoryTap: (category) {
            controller.selectedCategories.clear();
            final slug = category['slug']?.toString();
            if (slug != null && slug.isNotEmpty) {
              controller.selectedCategories.add(slug);
            }
            controller.drillIntoCategory(category);
            controller.applyFiltersAndRefresh();
          },
        ),
      ],
    );
  }

  // ─── ACTIVE FILTER HELPERS ────────────────────────────────────────────
  bool _hasActiveFilters() {
    return controller.isFeatured.value ||
        controller.isHot.value ||
        controller.isTrending.value ||
        controller.isRecommended.value ||
        controller.isRecentlyViewed.value ||
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

          if (controller.isTrending.value)
            _activeChip("Trending", () {
              controller.isTrending.value = false;
              controller.fetchProducts(isRefresh: true);
            }, colorScheme),

          if (controller.isRecommended.value)
            _activeChip("Recommended", () {
              controller.isRecommended.value = false;
              controller.fetchProducts(isRefresh: true);
            }, colorScheme),

          if (controller.isRecentlyViewed.value)
            _activeChip("Recently Viewed", () {
              controller.isRecentlyViewed.value = false;
              controller.fetchProducts(isRefresh: true);
            }, colorScheme),

          // ...controller.selectedCategories.map((cat) => _activeChip(
          //       controller.availableCategories
          //               .firstWhereOrNull((c) => c['slug'] == cat)?['name']
          //               ?.toString() ??
          //           cat.capitalizeFirst!,
          //       () {
          //         controller.toggleCategory(cat);
          //         controller.fetchProducts(isRefresh: true);
          //       },
          //       colorScheme,
          //     )),

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

// ─── FIXED FILTER BOTTOM SHEET ──────────────────────────────────────
  void _showFilterBottomSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // ✅ Store initial values to compare changes
    final initialFeatured = controller.isFeatured.value;
    final initialHot = controller.isHot.value;
    final initialTrending = controller.isTrending.value;
    final initialRecommended = controller.isRecommended.value;
    final initialPriceRange = controller.currentPriceRange.value;
    final initialCategories = List<String>.from(controller.selectedCategories);
    final initialBrands = List<String>.from(controller.selectedBrands);
    final initialSortBy = controller.sortBy.value;
    final initialSortOrder = controller.sortOrder.value;

    // ✅ Create temporary controllers for the bottom sheet
    final tempFeatured = false.obs;
    final tempHot = false.obs;
    final tempTrending = false.obs;
    final tempRecommended = false.obs;
    final tempPriceRange = Rx<RangeValues>(initialPriceRange);
    final tempCategories = <String>{}.obs;
    final tempBrands = <String>{}.obs;
    final tempSortBy = initialSortBy.obs;
    final tempSortOrder = initialSortOrder.obs;

    // Initialize temp values
    tempFeatured.value = initialFeatured;
    tempHot.value = initialHot;
    tempTrending.value = initialTrending;
    tempRecommended.value = initialRecommended;
    tempCategories.addAll(initialCategories);
    tempBrands.addAll(initialBrands);

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.85,
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
                  borderRadius: BorderRadius.circular(10)),
            ),

            // Header with filter count
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() {
                    // Calculate count from temp values for immediate feedback
                    int tempCount = 0;
                    if (tempFeatured.value) tempCount++;
                    if (tempHot.value) tempCount++;
                    if (tempTrending.value) tempCount++;
                    if (tempRecommended.value) tempCount++;
                    tempCount += tempCategories.length;
                    tempCount += tempBrands.length;
                    if (tempPriceRange.value.start > 0 ||
                        tempPriceRange.value.end < 10000) tempCount++;
                    if (tempSortBy.value != "created_at") tempCount++;

                    return Row(
                      children: [
                        Text("Sort & Filter",
                            style: textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        if (tempCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$tempCount',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ],
                    );
                  }),
                  TextButton(
                    onPressed: () {
                      // ✅ RESET ALL TEMP VALUES
                      tempFeatured.value = false;
                      tempHot.value = false;
                      tempTrending.value = false;
                      tempRecommended.value = false;
                      tempCategories.clear();
                      tempBrands.clear();
                      tempPriceRange.value = const RangeValues(0, 10000);
                      tempSortBy.value = "created_at";
                      tempSortOrder.value = "desc";
                      debugPrint("🔄 Filters Reset in UI");
                    },
                    child: Text("Reset All",
                        style: TextStyle(color: colorScheme.error)),
                  )
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. SORTING SECTION
                    _buildSortSection(
                        colorScheme, textTheme, tempSortBy, tempSortOrder),
                    const SizedBox(height: 24),

                    // 2. PRODUCT FLAGS SECTION
                    _buildFlagsSection(
                      colorScheme,
                      textTheme,
                      tempFeatured,
                      tempHot,
                      tempTrending,
                      tempRecommended,
                    ),
                    const SizedBox(height: 24),

                    // 3. PRICE RANGE SECTION
                    _buildPriceSection(
                      colorScheme,
                      textTheme,
                      tempPriceRange,
                    ),
                    const SizedBox(height: 24),

                    // 4. CATEGORIES SECTION
                    _buildCategoriesSection(
                      colorScheme,
                      textTheme,
                      tempCategories,
                    ),
                    const SizedBox(height: 24),

                    // 5. BRANDS SECTION
                    _buildBrandsSection(
                      colorScheme,
                      textTheme,
                      tempBrands,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Apply Button
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
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          // ✅ Apply all temp filters to actual controller
                          controller.isFeatured.value = tempFeatured.value;
                          controller.isHot.value = tempHot.value;
                          controller.isTrending.value = tempTrending.value;
                          controller.isRecommended.value =
                              tempRecommended.value;
                          controller.selectedCategories.clear();
                          controller.selectedCategories.addAll(tempCategories);
                          controller.selectedBrands.clear();
                          controller.selectedBrands.addAll(tempBrands);
                          controller.currentPriceRange.value =
                              tempPriceRange.value;
                          controller.minPrice.value =
                              tempPriceRange.value.start;
                          controller.maxPrice.value = tempPriceRange.value.end;
                          controller.sortBy.value = tempSortBy.value;
                          controller.sortOrder.value = tempSortOrder.value;

                          Get.back(); // Close sheet
                          controller
                              .applyFiltersAndRefresh(); // Refresh with new filters
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Apply Filters",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

// ─── SORT SECTION ────────────────────────────────────────────────
  Widget _buildSortSection(
    ColorScheme colorScheme,
    TextTheme textTheme,
    RxString tempSortBy,
    RxString tempSortOrder,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Sort By",
            style:
                textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _sortChipWidget("Newest", "created_at", "desc", tempSortBy,
                    tempSortOrder, colorScheme),
                _sortChipWidget("Price: Low-High", "price", "asc", tempSortBy,
                    tempSortOrder, colorScheme),
                _sortChipWidget("Price: High-Low", "price", "desc", tempSortBy,
                    tempSortOrder, colorScheme),
              ],
            )),
      ],
    );
  }

  Widget _sortChipWidget(
    String label,
    String by,
    String order,
    RxString tempSortBy,
    RxString tempSortOrder,
    ColorScheme colorScheme,
  ) {
    bool isSelected = tempSortBy.value == by && tempSortOrder.value == order;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: colorScheme.primaryContainer,
      onSelected: (_) {
        tempSortBy.value = by;
        tempSortOrder.value = order;
      },
    );
  }

// ─── FLAGS SECTION ────────────────────────────────────────────────
  Widget _buildFlagsSection(
    ColorScheme colorScheme,
    TextTheme textTheme,
    RxBool tempFeatured,
    RxBool tempHot,
    RxBool tempTrending,
    RxBool tempRecommended,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Product Type",
            style:
                textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Obx(() => Column(
              children: [
                CheckboxListTile(
                  title: const Text("Featured Products"),
                  value: tempFeatured.value,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (val) => tempFeatured.value = val ?? false,
                ),
                CheckboxListTile(
                  title: const Text("Hot Trending"),
                  value: tempHot.value,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (val) => tempHot.value = val ?? false,
                ),
                CheckboxListTile(
                  title: const Text("Trending"),
                  value: tempTrending.value,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (val) => tempTrending.value = val ?? false,
                ),
                CheckboxListTile(
                  title: const Text("Recommended"),
                  value: tempRecommended.value,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (val) => tempRecommended.value = val ?? false,
                ),
              ],
            )),
      ],
    );
  }

// ─── PRICE SECTION ────────────────────────────────────────────────
  Widget _buildPriceSection(
    ColorScheme colorScheme,
    TextTheme textTheme,
    Rx<RangeValues> tempPriceRange,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Price Range",
            style:
                textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Obx(() => Column(
              children: [
                RangeSlider(
                  values: tempPriceRange.value,
                  min: 0,
                  max: 10000,
                  divisions: 100,
                  activeColor: colorScheme.primary,
                  labels: RangeLabels(
                    "₹${tempPriceRange.value.start.round()}",
                    "₹${tempPriceRange.value.end.round()}",
                  ),
                  onChanged: (RangeValues values) {
                    tempPriceRange.value = values;
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("₹${tempPriceRange.value.start.round()}"),
                    Text("₹${tempPriceRange.value.end.round()}"),
                  ],
                )
              ],
            )),
      ],
    );
  }

// ─── CATEGORIES SECTION ───────────────────────────────────────────
  Widget _buildCategoriesSection(
    ColorScheme colorScheme,
    TextTheme textTheme,
    RxSet<String> tempCategories,
  ) {
    // ✅ Replace with your actual categories from API
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Categories",
            style:
                textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Obx(() {
          if (controller.isCategoriesLoading.value &&
              controller.availableCategories.isEmpty) {
            return const Center(
                child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CupertinoActivityIndicator(),
            ));
          }

          if (controller.availableCategories.isEmpty) {
            return const Text("No categories available",
                style: TextStyle(fontSize: 12, color: Colors.grey));
          }

          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.availableCategories.map((cat) {
              final String slug = cat['slug']?.toString() ?? '';
              final String name = cat['name']?.toString() ?? 'Unknown';
              bool isSelected = tempCategories.contains(slug);
              return FilterChip(
                label: Text(name),
                selected: isSelected,
                selectedColor: colorScheme.primaryContainer,
                onSelected: (val) {
                  if (val) {
                    tempCategories.add(slug);
                  } else {
                    tempCategories.remove(slug);
                  }
                },
              );
            }).toList(),
          );
        }),
      ],
    );
  }

// ─── BRANDS SECTION ───────────────────────────────────────────────
  Widget _buildBrandsSection(
    ColorScheme colorScheme,
    TextTheme textTheme,
    RxSet<String> tempBrands,
  ) {
    // ✅ Replace with your actual brands from API
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Brands",
            style:
                textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Obx(() {
          if (controller.isBrandsLoading.value &&
              controller.availableBrands.isEmpty) {
            return const Center(
                child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CupertinoActivityIndicator(),
            ));
          }

          if (controller.availableBrands.isEmpty) {
            return const Text("No brands available",
                style: TextStyle(fontSize: 12, color: Colors.grey));
          }

          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.availableBrands.map((brand) {
              final String slug = brand['slug']?.toString() ?? '';
              final String name = brand['name']?.toString() ?? 'Unknown';
              bool isSelected = tempBrands.contains(slug);
              return FilterChip(
                label: Text(name),
                selected: isSelected,
                selectedColor: colorScheme.primaryContainer,
                onSelected: (val) {
                  if (val) {
                    tempBrands.add(slug);
                  } else {
                    tempBrands.remove(slug);
                  }
                },
              );
            }).toList(),
          );
        }),
      ],
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
              childAspectRatio: 0.58,
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
          childAspectRatio: 0.58,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16))),
      ),
    );
  }
}
