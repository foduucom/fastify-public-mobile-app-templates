import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';

import 'package:foduu_ecommerce/app/modules/shop/controllers/shop_controller.dart';
import 'package:foduu_ecommerce/app/modules/shop/views/widgets/shop_filter_drawer.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/home_component/home_category.dart';
import 'package:foduu_ecommerce/components/parent_web_product_card.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_view.dart';

class ShopView extends GetView<ShopController> {
  const ShopView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: colorScheme.surface,
      drawer: ShopFilterDrawer(controller: controller),
      onDrawerChanged: (isOpen) {
        if (isOpen) {
          controller.ensureFilterDataLoaded();
          controller.ensureCategoryTreeLoaded();
          controller.filterDrawerOpenTick.value++;
        }
      },
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              controller.ensureFilterDataLoaded();
              controller.ensureCategoryTreeLoaded();
              controller.filterDrawerOpenTick.value++;
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Obx(() {
          final isPlain = controller.isPlainShopEntry.value;
          final name = controller.collectionName.value;
          return Text(
            isPlain || name == "All Products" ? "Shop" : name,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          );
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search products',
            onPressed: () => Get.toNamed(Routes.SEARCH),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _ShopHeaderToolbar(
            controller: controller,
            onFilterTap: () {
              controller.ensureFilterDataLoaded();
              controller.ensureCategoryTreeLoaded();
              controller.filterDrawerOpenTick.value++;
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
          // ── CMS CANVAS MODE (plain tab entry, grid mode, no active filters) ──
          // Renders the full CMS layout from api/mobile-app/shop (and live
          // Studio socket broadcasts) via FoduuStudioLayoutView.
          if (controller.isPlainShopEntry.value &&
              !controller.isListView.value &&
              !controller.hasActiveFilters) {
            return FoduuStudioLayoutView(
              widgetList: controller.widgetList,
              isLoading: controller.isLayoutLoading,
              hasError: controller.hasError,
              errorMessage: controller.errorMessage,
              scrollController: controller.scrollController,
              loadingWidget: _buildGridShimmer(),
              footerWidget: const SizedBox(height: 88),
              onRefresh: () => controller.fetchLayout(
                ShopController.pageSlug,
                useCache: false,
              ),
            );
          }

          // ── FILTERED / LIST CATALOG MODE ──
          final isList = controller.isListView.value;
          final totalCount = controller.totalProducts.value > 0
              ? controller.totalProducts.value
              : controller.products.length;
          final promotionalWidgets =
              controller.buildWidgetsExcluding(['categories', 'products']);

          return RefreshIndicator(
            onRefresh: () => Future.wait([
              controller.fetchProducts(isRefresh: true),
              controller.fetchLayout(ShopController.pageSlug),
            ]),
            child: CustomScrollView(
              controller: controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // 1. ACTIVE FILTER CHIPS (directly beneath toolbar)
                if (_hasActiveFilters())
                  SliverToBoxAdapter(
                    child: _buildActiveFilterChips(colorScheme),
                  ),

                // 2. SUB CATEGORY STRIP (if category drilling is active)
                if (controller.filterCurrentCategories.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildSubCategorySection(colorScheme),
                  ),

                // 3. PRODUCT CATALOG: SHIMMER / EMPTY / GRID / LIST
                if (controller.isLoading.value && controller.products.isEmpty)
                  _buildSliverShimmerGrid()
                else if (controller.products.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(colorScheme, textTheme),
                  )
                else if (isList)
                  SliverPadding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final p = controller.products[index];
                          return ParentWebProductCard(
                            product: p is Map<String, dynamic>
                                ? p
                                : Map<String, dynamic>.from(p),
                            isList: true,
                          );
                        },
                        childCount: controller.products.length,
                      ),
                    ),
                  )
                else
                  Builder(builder: (context) {
                    final cmsJson = controller.contentJsonFor('products');
                    final cols = int.tryParse(
                            cmsJson?['columns']?.toString() ?? '2') ??
                        2;
                    final spacing = double.tryParse(
                            cmsJson?['spacing']?.toString() ?? '10') ??
                        10;
                    final rawRatio = double.tryParse(
                            cmsJson?['aspect_ratio']?.toString() ?? '') ??
                        0.60;
                    final aspectRatio = (rawRatio > 0 && rawRatio <= 0.85)
                        ? rawRatio
                        : (cols >= 3 ? 0.50 : 0.60);

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      sliver: SliverGrid(
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          childAspectRatio: aspectRatio,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final p = controller.products[index];
                            return ParentWebProductCard(
                              product: p is Map<String, dynamic>
                                  ? p
                                  : Map<String, dynamic>.from(p),
                              isList: false,
                            );
                          },
                          childCount: controller.products.length,
                        ),
                      ),
                    );
                  }),

                // 4. INFINITE SCROLL LOADING INDICATOR / END OF LIST
                if (controller.hasNextPage)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (controller.products.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildEndOfListFooter(
                        colorScheme, textTheme, totalCount),
                  ),

                // 5. POST-CATALOG CMS SECTIONS (Banners, Sliders, Trust Badges, Blogs)
                // Appears naturally when scrolling past products, exactly matching
                // Image 4 and parent website /product structure.
                if (promotionalWidgets.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: promotionalWidgets,
                      ),
                    ),
                  ),
              ],
            ),
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
    return controller.hasActiveFilters;
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

          if (controller.searchQuery.value.isNotEmpty)
            _activeChip('"${controller.searchQuery.value}"', () {
              controller.clearProductSearch();
            }, colorScheme),

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

          ...controller.selectedCategories.map((cat) {
            String label = cat;
            final found = controller.availableCategories
                .firstWhereOrNull((c) => c['slug'] == cat || c['_id'] == cat);
            if (found != null && found['name'] != null) {
              label = found['name'].toString();
            }
            return _activeChip(label, () {
              controller.toggleCategory(cat);
            }, colorScheme);
          }),

          ...controller.selectedBrands
              .map((brand) => _activeChip(brand.capitalizeFirst!, () {
                    controller.toggleBrand(brand);
                  }, colorScheme)),

          if (controller.minPrice.value > 0 || controller.maxPrice.value < 10000)
            _activeChip(
              "${controller.formatPriceForInput(controller.minPrice.value)} - ${controller.formatPriceForInput(controller.maxPrice.value)}",
              () {
                controller.updatePriceRange(const RangeValues(0, 10000));
              },
              colorScheme,
            ),
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

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 72, color: colorScheme.outline.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              "No products found",
              style:
                  textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Try adjusting or clearing your filters to see more results.",
              textAlign: TextAlign.center,
              style: textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: controller.clearAllFilters,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text("Clear Filters"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridShimmer() {
    final cmsJson = controller.contentJsonFor('products');
    final cols =
        int.tryParse(cmsJson?['columns']?.toString() ?? '2') ?? 2;
    final spacing =
        double.tryParse(cmsJson?['spacing']?.toString() ?? '10') ?? 10;
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: cols >= 3 ? 0.50 : 0.60,
      ),
      itemCount: cols * 3,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverShimmerGrid() {
    final cmsJson = controller.contentJsonFor('products');
    final cols =
        int.tryParse(cmsJson?['columns']?.toString() ?? '2') ?? 2;
    final spacing =
        double.tryParse(cmsJson?['spacing']?.toString() ?? '10') ?? 10;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: cols >= 3 ? 0.50 : 0.60,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          childCount: cols * 3,
        ),
      ),
    );
  }

  Widget _buildEndOfListFooter(
      ColorScheme colorScheme, TextTheme textTheme, int totalCount) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 24.0, bottom: 28.0, left: 32.0, right: 32.0),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: colorScheme.outline.withOpacity(0.25),
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 14,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  "You've viewed all $totalCount items",
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Divider(
              color: colorScheme.outline.withOpacity(0.25),
              thickness: 1,
            ),
          ),
        ],
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
                controller.isLoading.value && total == 0
                    ? "Loading..."
                    : "$total Products",
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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
