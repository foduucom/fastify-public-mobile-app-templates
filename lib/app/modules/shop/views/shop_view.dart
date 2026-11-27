import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';

import 'package:foduu_ecommerce/app/modules/shop/controllers/shop_controller.dart';
import 'package:foduu_ecommerce/app/modules/shop/views/widgets/shop_filter_drawer.dart';
import 'package:foduu_ecommerce/components/home_component/home_category.dart';
import 'package:foduu_ecommerce/components/home_component/home_products.dart';
import 'package:foduu_ecommerce/components/parent_web_product_card.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_view.dart';

class ShopView extends GetView<ShopController> {
  const ShopView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ShopController>()) {
      Get.lazyPut(() => ShopController());
    }
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
          if (controller.isPlainShopEntry.value &&
              !controller.isListView.value) {
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
                "${controller.totalProducts.value > 0 ? controller.totalProducts.value : controller.products.length} items",
                style: textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          );
        }),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _ShopHeaderToolbar(
            controller: controller,
            onFilterTap: () {
              controller.ensureFilterDataLoaded();
              controller.ensureCategoryTreeLoaded();
              scaffoldKey.currentState?.openDrawer();
            },
          ),
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
              hasError: controller.hasError,
              errorMessage: controller.errorMessage,
              isStale: controller.isStale,
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
                        onRefresh: () async {
                          await Future.wait([
                            controller.fetchProducts(isRefresh: true),
                            controller.fetchLayout(ShopController.pageSlug),
                          ]);
                        },
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
        controller.selectedAttributes.isNotEmpty ||
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
            _activeChip(
                "Featured", controller.removeFeaturedFilter, colorScheme),

          if (controller.isHot.value)
            _activeChip("Hot", () {
              controller.isHot.value = false;
              controller.fetchProducts(isRefresh: true);
            }, colorScheme),

          if (controller.isTrending.value)
            _activeChip(
                "Trending", controller.removeTrendingFilter, colorScheme),

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

          ...controller.selectedCategories.map((category) {
            final item = controller.availableCategories
                .where((c) => c is Map && c['slug']?.toString() == category)
                .firstOrNull;
            final label = item is Map
                ? item['name']?.toString() ?? _categoryLabel(category)
                : _categoryLabel(category);
            return _activeChip(
                label, () => controller.toggleCategory(category), colorScheme);
          }),

          ...controller.selectedBrands.map((brand) => _activeChip(
              _brandLabel(brand),
              () => controller.toggleBrand(brand),
              colorScheme)),
          ...controller.selectedAttributes.entries
              .expand((entry) => entry.value.map(
                    (value) => _activeChip('${entry.key}: $value', () {
                      controller.toggleAttribute(entry.key, value);
                      controller.fetchProducts(isRefresh: true);
                    }, colorScheme),
                  )),
          if (controller.minPrice.value > 0 ||
              controller.maxPrice.value < 10000)
            _activeChip(
                _priceLabel(), controller.clearPriceFilter, colorScheme),
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

  String _categoryLabel(String slug) {
    for (final category in controller.availableCategories) {
      if (category is Map && category['slug']?.toString() == slug) {
        return category['name']?.toString() ?? slug;
      }
    }
    for (final root in controller.categoryTreeByType['product'] ?? []) {
      for (final node in root.flattened) {
        if (node.slug == slug) return node.name;
      }
    }
    return slug.replaceAll('-', ' ').capitalizeFirst ?? slug;
  }

  String _brandLabel(String slug) {
    for (final brand in controller.availableBrands) {
      if (brand is Map && brand['slug']?.toString() == slug) {
        return brand['name']?.toString() ?? slug;
      }
    }
    return slug.replaceAll('-', ' ').capitalizeFirst ?? slug;
  }

  String _priceLabel() {
    final minimum = controller.minPrice.value.round();
    final maximum = controller.maxPrice.value.round();
    if (minimum == 0) return 'Under ₹$maximum';
    if (maximum >= 10000) return 'Over ₹$minimum';
    return '₹$minimum – ₹$maximum';
  }

  // ── MAIN PRODUCT GRID (shared TrendingProductSection, externally driven) ──
  Widget _buildProductGrid(ColorScheme colorScheme, TextTheme textTheme) {
    if (controller.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              controller.productsError.value.isEmpty
                  ? Icons.inventory_2_outlined
                  : Icons.cloud_off_outlined,
              size: 72,
              color: colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
                controller.productsError.value.isEmpty
                    ? "No products match your filters"
                    : "Couldn't load products",
                style: textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            if (controller.productsError.value.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Check your connection and try again.',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => controller.fetchProducts(isRefresh: true),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      );
    }

    return Obx(() {
      final isList = controller.isListView.value;
      final cmsJson = controller.contentJsonFor('products');
      final columns = int.tryParse(cmsJson?['columns']?.toString() ?? '2') ?? 2;
      final spacing =
          double.tryParse(cmsJson?['spacing']?.toString() ?? '12') ?? 12;
      final layout = cmsJson?['layout']?.toString() ?? 'parent_web';
      final aspectRatio =
          double.tryParse(cmsJson?['aspect_ratio']?.toString() ?? '0.58') ??
              0.58;
      if (isList) {
        return ListView.builder(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: controller.products.length +
              (controller.hasNextPage || controller.products.isNotEmpty
                  ? 1
                  : 0),
          itemBuilder: (context, index) {
            if (index >= controller.products.length) {
              if (!controller.hasNextPage && !controller.isFetchingMore.value) {
                return Padding(
                  padding: const EdgeInsets.all(22),
                  child: Center(
                      child: Text(
                          "You've viewed all ${controller.products.length} items",
                          style: textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant))),
                );
              }
              if (controller.paginationError.value.isNotEmpty) {
                return Center(
                  child: TextButton.icon(
                    onPressed: () => controller.fetchProducts(isRefresh: false),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry loading products'),
                  ),
                );
              }
              if (!controller.isFetchingMore.value) {
                controller.fetchProducts(isRefresh: false);
              }
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final p = controller.products[index];
            return ParentWebProductCard(
              product:
                  p is Map<String, dynamic> ? p : Map<String, dynamic>.from(p),
              isList: true,
            );
          },
        );
      }

      return SingleChildScrollView(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            TrendingProductSection(
              externalProducts: controller.products,
              externalHasMore: controller.hasNextPage,
              externalIsLoadingMore: controller.isFetchingMore.value,
              onLoadMore: () => controller.fetchProducts(isRefresh: false),
              hideHeader: true,
              contentJson: {
                'view': 'grid',
                'layout': layout,
                'columns': columns.toString(),
                'spacing': spacing.toString(),
                'aspect_ratio': aspectRatio.toString(),
              },
            ),
            if (controller.paginationError.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton.icon(
                  onPressed: () => controller.fetchProducts(isRefresh: false),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry loading products'),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildGridShimmer() {
    final cmsJson = controller.contentJsonFor('products');
    final columns =
        (int.tryParse(cmsJson?['columns']?.toString() ?? '2') ?? 2).clamp(1, 4);
    final spacing =
        (double.tryParse(cmsJson?['spacing']?.toString() ?? '12') ?? 12)
            .clamp(0, 40)
            .toDouble();
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: columns >= 3 ? 0.52 : 0.58,
        ),
        itemCount: columns * 2,
        itemBuilder: (_, __) => Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16))),
      ),
    );
  }
}

// ─── SHOP HEADER TOOLBAR (Filter, Count, Grid/List Switcher, Sort) ───
class _ShopHeaderToolbar extends StatelessWidget {
  final ShopController controller;
  final VoidCallback onFilterTap;

  const _ShopHeaderToolbar({
    required this.controller,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final total = controller.totalProducts.value > 0
          ? controller.totalProducts.value
          : controller.products.length;
      final isList = controller.isListView.value;

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
        child: Row(
          children: [
            // 1. Filter Trigger Button
            _FilterTrigger(
              count: controller.activeFilterCount,
              onTap: onFilterTap,
            ),
            const SizedBox(width: 8),

            // 2. Results text counter
            Expanded(
              child: Text(
                "There are $total results in total",
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),

            // 3. Layout Switcher (List vs Grid)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // List icon
                  InkWell(
                    onTap: () => controller.setViewMode(true),
                    borderRadius:
                        const BorderRadius.horizontal(left: Radius.circular(8)),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      color: isList
                          ? colorScheme.primary.withOpacity(0.15)
                          : Colors.transparent,
                      child: Icon(
                        Icons.view_agenda_outlined,
                        size: 18,
                        color: isList
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  // Grid icon
                  InkWell(
                    onTap: () => controller.setViewMode(false),
                    borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(8)),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      color: !isList
                          ? colorScheme.primary.withOpacity(0.15)
                          : Colors.transparent,
                      child: Icon(
                        Icons.grid_view_rounded,
                        size: 18,
                        color: !isList
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),

            // 4. Sort Trigger Dropdown
            PopupMenuButton<ShopSortOption>(
              onSelected: controller.applySortOption,
              itemBuilder: (_) => [
                CheckedPopupMenuItem(
                  value: ShopSortOption.priceHighLow,
                  checked: controller.selectedSortOption.value ==
                      ShopSortOption.priceHighLow,
                  child: const Text("Price, high to low"),
                ),
                CheckedPopupMenuItem(
                  value: ShopSortOption.priceLowHigh,
                  checked: controller.selectedSortOption.value ==
                      ShopSortOption.priceLowHigh,
                  child: const Text("Price: low to high"),
                ),
                CheckedPopupMenuItem(
                  value: ShopSortOption.newest,
                  checked: controller.selectedSortOption.value ==
                      ShopSortOption.newest,
                  child: const Text("Newest"),
                ),
                CheckedPopupMenuItem(
                  value: ShopSortOption.featured,
                  checked: controller.selectedSortOption.value ==
                      ShopSortOption.featured,
                  child: const Text("Featured"),
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
          ],
        ),
      );
    });
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.tune_rounded, size: 16),
            const SizedBox(width: 4),
            const Text("Filter", style: TextStyle(fontSize: 12)),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.arrow_drop_down, size: 18),
        ],
      ),
    );
  }
}
