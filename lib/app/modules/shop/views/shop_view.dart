import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';

import 'package:foduu_ecommerce/app/modules/shop/controllers/shop_controller.dart';
import 'package:foduu_ecommerce/app/modules/shop/views/widgets/shop_filter_drawer.dart';
import 'package:foduu_ecommerce/components/studio_widget/studio_category.dart';
import 'package:foduu_ecommerce/components/studio_widget/studio_products.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_view.dart';

class ShopView extends GetView<ShopController> {
  const ShopView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => ShopController());
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: colorScheme.background,
      drawer: ShopFilterDrawer(controller: controller),
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        centerTitle: true,
        title: Obx(() {
          if (controller.isPlainShopEntry.value) {
            return Text(
              "Shop",
              style:
                  textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            );
          }
          return Column(
            children: [
              Text(
                controller.collectionName.value,
                style:
                    textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                "${controller.totalProducts.value} items",
                style: textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          );
        }),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Obx(() {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Flexible(
                    child: _FilterTrigger(
                      count: controller.activeFilterCount,
                      onTap: () {
                        controller.ensureFilterDataLoaded();
                        controller.ensureCategoryTreeLoaded();
                        scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PopupMenuButton<ShopSortOption>(
                      onSelected: controller.applySortOption,
                      itemBuilder: (_) => [
                        CheckedPopupMenuItem(
                          value: ShopSortOption.featured,
                          checked: controller.selectedSortOption.value ==
                              ShopSortOption.featured,
                          child: const Text("Featured"),
                        ),
                        CheckedPopupMenuItem(
                          value: ShopSortOption.priceLowHigh,
                          checked: controller.selectedSortOption.value ==
                              ShopSortOption.priceLowHigh,
                          child: const Text("Price: Low to High"),
                        ),
                        CheckedPopupMenuItem(
                          value: ShopSortOption.priceHighLow,
                          checked: controller.selectedSortOption.value ==
                              ShopSortOption.priceHighLow,
                          child: const Text("Price: High to Low"),
                        ),
                        CheckedPopupMenuItem(
                          value: ShopSortOption.newest,
                          checked: controller.selectedSortOption.value ==
                              ShopSortOption.newest,
                          child: const Text("Newest"),
                        ),
                        CheckedPopupMenuItem(
                          value: ShopSortOption.trending,
                          checked: controller.selectedSortOption.value ==
                              ShopSortOption.trending,
                          child: const Text("Trending"),
                        ),
                      ],
                      child: _SortTrigger(label: controller.sortLabel),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
      body: PopScope(
        canPop: controller.filterCategoryStack.isEmpty,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          controller.goUpFilterCategory();
        },
        child: Obx(() {
          if (controller.isPlainShopEntry.value) {
            return FoduuStudioLayoutView(
              onRefresh: () => controller.fetchLayout(ShopController.pageSlug),
              widgetList: controller.widgetList,
              isLoading: controller.isLayoutLoading,
            );
          }
          // ── FILTERED / DASHBOARD ENTRY ──
          return Column(
            children: [
              // ── CMS FREE-WILL SECTIONS (banner, rich_text, etc.) ──
              ...controller.buildWidgetsExcluding(['categories', 'products']),

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
                        ...controller.filterCategoryStack.map(
                            (e) => (e['cat'] as Map)['name']?.toString() ?? ''),
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

  // ── MAIN PRODUCT GRID (shared TrendingProductSection, externally driven) ──
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
      child: TrendingProductSection(
        externalProducts: controller.products,
        externalHasMore: controller.hasNextPage,
        externalIsLoadingMore: controller.isFetchingMore.value,
        onLoadMore: () => controller.fetchProducts(isRefresh: false),
        hideHeader: true,
        contentJson: const {
          'view': 'grid',
          'layout': 'standard',
          'columns': '2',
        },
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

// ─── HEADER TRIGGER CHIPS ────────────────────────────────────────────────
class _FilterTrigger extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _FilterTrigger({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.tune_rounded, size: 18),
            const SizedBox(width: 6),
            const Flexible(
              child: Text("Filter", overflow: TextOverflow.ellipsis),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SortTrigger extends StatelessWidget {
  final String label;

  const _SortTrigger({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              "Sort: $label",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}
