import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '/components/app_image_placeholder.dart';
import '/components/parent_web_product_card.dart';
import '/app/modules/category/views/category_dialog.dart';
import '/app/modules/shop/shop_navigation.dart';
import '/core/foduuStudio/foduu_studio_layout_view.dart';
import '/models/blog_model.dart';
import '/app/routes/app_pages.dart';
import '/constants/helper_functions.dart';

import '../controllers/search_controller.dart';
import '/constants/product_helper.dart';

class SearchView extends GetView<SearchsController> {
  const SearchView({Key? key}) : super(key: key);

  ColorScheme get colorScheme => Theme.of(Get.context!).colorScheme;
  TextTheme get textTheme => Theme.of(Get.context!).textTheme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HelperFunctions().closeKeyboard(context),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: null,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Top In-Line Modern Search Bar ──
              _buildTopSearchBar(context),

              // ── 2. Dynamic Body based on Search Mode ──
              Expanded(
                child: Obx(() {
                  switch (controller.searchMode.value) {
                    case SearchMode.browse:
                      return _buildBrowseView(context);
                    case SearchMode.autocomplete:
                      return _buildAutocompleteOverlay(context);
                    case SearchMode.results:
                      return _buildSearchResultsView(context);
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. TOP MODERN SEARCH BAR (In-Line, Back Btn + Pill Input)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTopSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          // Circular Back Arrow Button
          GestureDetector(
            onTap: () {
              if (controller.searchMode.value != SearchMode.browse) {
                controller.clearSearch();
              } else {
                Get.back();
              }
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back,
                  color: colorScheme.onSurface, size: 20),
            ),
          ),
          const SizedBox(width: 10),

          // Search Field Container (Full-width clean pill, no filter button)
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.25),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(Icons.search,
                      color: colorScheme.onSurfaceVariant, size: 20),
                  const SizedBox(width: 8),

                  // Text Field - explicitly filled: false to remove dark theme background artifact
                  Expanded(
                    child: TextField(
                      controller: controller.searchTextController,
                      onChanged: controller.onSearchChanged,
                      onSubmitted: (val) {
                        HelperFunctions().closeKeyboard(context);
                        controller.submitSearch(val);
                      },
                      textInputAction: TextInputAction.search,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        filled: false,
                        fillColor: Colors.transparent,
                        hintText: controller.searchPlaceholder,
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.8),
                          fontSize: 13.5,
                        ),
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),

                  // Clear Button (X)
                  AnimatedBuilder(
                    animation: controller.searchTextController,
                    builder: (_, __) {
                      if (controller.searchTextController.text.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return GestureDetector(
                        onTap: () {
                          controller.clearSearch();
                          HelperFunctions().closeKeyboard(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(
                            Icons.cancel,
                            size: 18,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. STATE 1: ZERO-QUERY BROWSE VIEW (100% CMS Studio Layout)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildBrowseView(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchLayout(SearchsController.pageSlug),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recent Searches Chips
            Obx(() => _buildRecentSearchesSection(context)),

            // Popular Brands Horizontal Carousel
            Obx(() => _buildBrandsSection(context)),

            const SizedBox(height: 6),

            // Dynamic CMS Sections from mobile-app/search (Categories, Trending Products, Blogs)
            Obx(() {
              if (controller.isLayoutLoading.value &&
                  controller.widgetList.isEmpty) {
                return _buildBrowseShimmer(context);
              }

              if (controller.widgetList.isNotEmpty) {
                return FoduuStudioLayoutView.embedded(
                  widgetList: controller.widgetList,
                  isLoading: controller.isLayoutLoading,
                  hasError: controller.hasError,
                  errorMessage: controller.errorMessage,
                );
              }

              return const SizedBox.shrink();
            }),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Recent Searches Section ──
  Widget _buildRecentSearchesSection(BuildContext context) {
    if (controller.recentSearchList.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.history,
                      size: 18, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    'Recent Searches',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: controller.clearRecentSearches,
                child: Text(
                  'Clear All',
                  style: textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.recentSearchList.take(8).map((item) {
                final name =
                    (item is Map ? item['name'] : item)?.toString() ?? '';
                if (name.isEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      controller.searchTextController.text = name;
                      controller.submitSearch(name);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => controller.removeRecentItem(item),
                            child: Icon(Icons.close,
                                size: 14, color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Popular Brands Section ──
  Widget _buildBrandsSection(BuildContext context) {
    if (controller.brands.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Brands',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.brands.map((brand) {
                final name = brand['name']?.toString() ?? '';
                final slug = brand['slug']?.toString() ?? '';
                final isSelected = controller.selectedBrandSlug.value == slug;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => controller.fetchProductsByBrand(slug),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : colorScheme.outline.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        name,
                        style: textTheme.bodySmall?.copyWith(
                          color:
                              isSelected ? Colors.white : colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. STATE 2: PREDICTIVE AUTOCOMPLETE OVERLAY (Parent Web /search/global)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildAutocompleteOverlay(BuildContext context) {
    final cleanQuery = controller.queryText.value.trim();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Loader
          if (controller.isAutocompleteLoading.value)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CupertinoActivityIndicator(radius: 12)),
            ),

          // Action Banner: Direct query execution (Clean trimmed query)
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              HelperFunctions().closeKeyboard(context);
              controller.submitSearch();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.search,
                      size: 18, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Search for "$cleanQuery"',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      size: 14, color: Theme.of(context).primaryColor),
                ],
              ),
            ),
          ),

          // ── Products Suggestions ──
          if (controller.autocompleteProducts.isNotEmpty) ...[
            _autocompleteGroupHeader("PRODUCTS"),
            ...controller.autocompleteProducts
                .map((p) => _autocompleteProductTile(context, p)),
            const SizedBox(height: 12),
          ],

          // ── Categories Suggestions ──
          if (controller.autocompleteCategories.isNotEmpty) ...[
            _autocompleteGroupHeader("CATEGORIES"),
            ...controller.autocompleteCategories
                .map((c) => _autocompleteCategoryTile(context, c)),
            const SizedBox(height: 12),
          ],

          // ── Blogs Suggestions ──
          if (controller.autocompleteBlogs.isNotEmpty) ...[
            _autocompleteGroupHeader("BLOGS"),
            ...controller.autocompleteBlogs
                .map((b) => _autocompleteBlogTile(context, b)),
            const SizedBox(height: 12),
          ],

          // If no suggestions found
          if (!controller.isAutocompleteLoading.value &&
              !controller.hasAutocompleteResults) ...[
            if (cleanQuery.length >= 2)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 32,
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5)),
                      const SizedBox(height: 6),
                      Text(
                        'No instant suggestions found for "$cleanQuery"',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap the blue banner above to see all results',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Retain recent searches & popular brands so the user is never stuck
            _buildRecentSearchesSection(context),
            _buildBrandsSection(context),
          ],
        ],
      ),
    );
  }

  Widget _autocompleteGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _autocompleteProductTile(BuildContext context, dynamic item) {
    if (item is! Map) return const SizedBox.shrink();
    final itemMap = Map<String, dynamic>.from(item);
    final name = (itemMap['name'] ?? itemMap['title'] ?? '').toString();
    final id = (itemMap['_id'] ?? itemMap['id'] ?? '').toString();

    // Standard image resolution matching ShopView & ParentWebProductCard
    final imgUrl = HelperFunctions.resolveProductImage(itemMap);

    // Calculate pricing metadata
    final priceInfo = ProductHelper.calculatePriceInfo(itemMap);
    final priceStr = priceInfo['productPrice']?.toString() ?? '';
    final regularPriceStr = priceInfo['salePrice']?.toString() ?? '';
    final formattedPrice = ProductHelper.formatPrice(priceStr);
    final formattedRegular = ProductHelper.formatPrice(regularPriceStr);

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        controller.saveRecentSearch(id: id, name: name, type: 'product');
        Get.toNamed(Routes.PRODUCTDETAILS, arguments: {'productId': id});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 44,
                height: 44,
                color: colorScheme.surfaceContainerHighest,
                child: (imgUrl.isNotEmpty &&
                        imgUrl != HelperFunctions.getNoImage())
                    ? CachedNetworkImage(
                        imageUrl: imgUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Icon(Icons.image_outlined,
                            size: 22, color: colorScheme.onSurfaceVariant),
                      )
                    : Icon(Icons.shopping_bag_outlined,
                        size: 22, color: colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (formattedPrice.isNotEmpty) ...[
                        Text(
                          formattedPrice,
                          style: textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (formattedRegular.isNotEmpty &&
                            formattedRegular != formattedPrice) ...[
                          const SizedBox(width: 6),
                          Text(
                            formattedRegular,
                            style: textTheme.labelSmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Product',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.north_west,
                size: 14, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _autocompleteCategoryTile(BuildContext context, dynamic item) {
    if (item is! Map) return const SizedBox.shrink();
    final itemMap = Map<String, dynamic>.from(item);
    final name = (itemMap['name'] ?? '').toString();
    final slug = (itemMap['slug'] ?? '').toString();
    final id = (itemMap['_id'] ?? itemMap['id'] ?? '').toString();
    final rawImg =
        itemMap['featured_image'] ?? itemMap['image'] ?? itemMap['icon'];
    final catImg = HelperFunctions().getImage(rawImg);

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        controller.saveRecentSearch(id: id, name: name, type: 'category');
        openShop({
          'productId': id,
          'categorySlug': slug,
          'name': name,
          'source': 'category',
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 44,
                height: 44,
                color: colorScheme.surfaceContainerHighest,
                child: (catImg.isNotEmpty &&
                        catImg != HelperFunctions.getNoImage())
                    ? CachedNetworkImage(
                        imageUrl: catImg,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Icon(Icons.folder_outlined,
                            size: 22, color: colorScheme.onSurfaceVariant),
                      )
                    : Icon(Icons.folder_outlined,
                        size: 22, color: colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.north_west,
                size: 14, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _autocompleteBlogTile(BuildContext context, dynamic item) {
    if (item is! Map) return const SizedBox.shrink();
    final itemMap = Map<String, dynamic>.from(item);
    final name = (itemMap['name'] ?? itemMap['title'] ?? '').toString();
    final id = (itemMap['_id'] ?? itemMap['id'] ?? '').toString();
    final rawImg =
        itemMap['featured_image'] ?? itemMap['image'] ?? itemMap['cover_image'];
    final blogImg = HelperFunctions().getImage(rawImg);

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        controller.saveRecentSearch(id: id, name: name, type: 'blog');
        Get.toNamed(Routes.BLOG);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 44,
                height: 44,
                color: colorScheme.surfaceContainerHighest,
                child: (blogImg.isNotEmpty &&
                        blogImg != HelperFunctions.getNoImage())
                    ? CachedNetworkImage(
                        imageUrl: blogImg,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Icon(
                            Icons.article_outlined,
                            size: 22,
                            color: colorScheme.onSurfaceVariant),
                      )
                    : Icon(Icons.article_outlined,
                        size: 22, color: colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Blog',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.north_west,
                size: 14, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. STATE 3: FULL SEARCH RESULTS (Tabs, Sticky Sort/Filter, Product Grid)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSearchResultsView(BuildContext context) {
    return Column(
      children: [
        // Entity Tabs
        _buildEntityTabs(context),

        // Quick Sort Bar (Filter removed)
        _buildSortAndFilterBar(context),

        // Main Results Body
        Expanded(
          child: Obx(() {
            if (controller.isSearching.value &&
                controller.searchProduct.isEmpty &&
                controller.searchCategories.isEmpty &&
                controller.searchBlogs.isEmpty) {
              return _buildGridShimmer();
            }

            if (!controller.isSearching.value &&
                controller.totalResultCount == 0) {
              return _buildEmptyState(context);
            }

            return SingleChildScrollView(
              controller: controller.scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tab 0: All OR Tab 1: Products
                  if (controller.selectedTabIndex.value == 0 ||
                      controller.selectedTabIndex.value == 1)
                    ..._buildProductsSection(context),

                  // Tab 0: All OR Tab 2: Categories
                  if (controller.selectedTabIndex.value == 0 ||
                      controller.selectedTabIndex.value == 2)
                    ..._buildCategoriesSection(context),

                  // Tab 0: All OR Tab 3: Blogs
                  if (controller.selectedTabIndex.value == 0 ||
                      controller.selectedTabIndex.value == 3)
                    ..._buildBlogsSection(context),

                  // Infinite Scroll Loader
                  if (controller.searchesProducts)
                    Obx(() {
                      if (controller.isFetchingMore.value) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                              child: CupertinoActivityIndicator(radius: 14)),
                        );
                      } else if (!controller.hasNextPage &&
                          controller.searchProduct.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              "No more products",
                              style: TextStyle(
                                  color: colorScheme.onSurfaceVariant),
                            ),
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
    );
  }

  // ── Entity Switcher Tabs ──
  Widget _buildEntityTabs(BuildContext context) {
    return Obx(() {
      final tabs = [
        {'title': 'All', 'count': controller.totalResultCount},
        {'title': 'Products', 'count': controller.searchProduct.length},
        {'title': 'Categories', 'count': controller.searchCategories.length},
        {'title': 'Blogs', 'count': controller.searchBlogs.length},
      ];

      return Container(
        height: 44,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: tabs.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final isSelected = controller.selectedTabIndex.value == index;
            final tab = tabs[index];

            return GestureDetector(
              onTap: () => controller.selectedTabIndex.value = index,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      '${tab['title']}',
                      style: textTheme.bodySmall?.copyWith(
                        color:
                            isSelected ? Colors.white : colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${tab['count']})',
                      style: textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.8)
                            : colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // ── Quick Sort Bar (Filter removed) ──
  Widget _buildSortAndFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom:
              BorderSide(color: colorScheme.outline.withValues(alpha: 0.12)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Result Count
          Obx(
            () => Text(
              '${controller.searchProduct.length} items found',
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          // Sort Trigger
          InkWell(
            onTap: () => _showSortModal(context),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.swap_vert,
                      size: 18, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 4),
                  Obx(
                    () => Text(
                      _getSortLabel(controller.selectedSort.value),
                      style: textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Products Grid ──
  List<Widget> _buildProductsSection(BuildContext context) {
    if (controller.searchProduct.isEmpty) return const [];

    return [
      if (controller.selectedTabIndex.value == 0)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            "Products",
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.62,
        ),
        itemCount: controller.searchProduct.length,
        itemBuilder: (context, index) {
          final product =
              controller.searchProduct[index] as Map<String, dynamic>;
          return ParentWebProductCard(
            product: product,
            isList: false,
            onTap: () {
              final productId = product['_id']?.toString() ?? '';
              final productName = product['name']?.toString() ?? '';
              if (productId.isNotEmpty) {
                controller.saveRecentSearch(
                  id: productId,
                  name: productName,
                  type: 'product',
                );
                Get.toNamed(Routes.PRODUCTDETAILS,
                    arguments: {'productId': productId});
              }
            },
          );
        },
      ),
    ];
  }

  // ── Categories Horizontal List ──
  List<Widget> _buildCategoriesSection(BuildContext context) {
    if (controller.searchCategories.isEmpty) return const [];

    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          "Categories",
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      SizedBox(
        height: 106,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.searchCategories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, i) {
            final category = controller.searchCategories[i];
            final name = category['name']?.toString() ?? '';
            return GestureDetector(
              onTap: () {
                controller.saveRecentSearch(
                  id: category['_id']?.toString() ?? '',
                  name: name,
                  type: 'category',
                );
                final children = category['children'];
                if (children is List && children.isNotEmpty) {
                  Get.dialog(CategoryDialog(category: category),
                      barrierDismissible: true);
                } else {
                  openShop({
                    'productId': category['_id'],
                    'categorySlug': category['slug'],
                    'name': name,
                    'source': 'category',
                  });
                }
              },
              child: SizedBox(
                width: 76,
                child: Column(
                  children: [
                    Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.surfaceContainerHighest,
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.15),
                        ),
                      ),
                      child: ClipOval(
                        child: (HelperFunctions()
                                    .getImage(category['featured_image'])
                                    .isNotEmpty &&
                                HelperFunctions()
                                        .getImage(category['featured_image']) !=
                                    HelperFunctions.getNoImage())
                            ? CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: HelperFunctions()
                                    .getImage(category['featured_image']),
                                errorWidget: (_, __, ___) =>
                                    const AppImagePlaceholder.circular(
                                        size: 66),
                              )
                            : const AppImagePlaceholder.circular(size: 66),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ];
  }

  // ── Blogs List ──
  List<Widget> _buildBlogsSection(BuildContext context) {
    if (controller.searchBlogs.isEmpty) return const [];

    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          "Blogs",
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      ...controller.searchBlogs.map((blog) => _blogTile(context, blog)),
    ];
  }

  Widget _blogTile(BuildContext context, BlogModel blog) {
    const placeholder = AppImagePlaceholder(
      width: 72,
      height: 72,
      radius: 10,
      fit: BoxFit.cover,
    );

    return InkWell(
      onTap: () {
        controller.saveRecentSearch(
            id: blog.id, name: blog.title, type: 'blog');
        Get.toNamed(Routes.BLOG_DETAILS, arguments: {'blog': blog});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: blog.imageUrl != null && blog.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: blog.imageUrl!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => placeholder,
                    )
                  : placeholder,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blog.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    blog.cleanExcerpt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sort Bottom Sheet ──
  void _showSortModal(BuildContext context) {
    Get.bottomSheet(
      Material(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort By',
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              _sortOptionTile(context, 'Relevance', 'relevance'),
              _sortOptionTile(context, 'Price: Low to High', 'price_asc'),
              _sortOptionTile(context, 'Price: High to Low', 'price_desc'),
              _sortOptionTile(context, 'Newest First', 'newest'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sortOptionTile(BuildContext context, String label, String key) {
    final isSelected = controller.selectedSort.value == key;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected
              ? Theme.of(context).primaryColor
              : colorScheme.onSurface,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).primaryColor)
          : null,
      onTap: () {
        controller.setSort(key);
        Get.back();
      },
    );
  }

  String _getSortLabel(String key) {
    switch (key) {
      case 'price_asc':
        return 'Price: Low';
      case 'price_desc':
        return 'Price: High';
      case 'newest':
        return 'Newest';
      default:
        return 'Relevance';
    }
  }

  // ── Empty State ──
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 80,
              color: colorScheme.outline.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              "No results found",
              style:
                  textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Try searching with a different keyword or removing filters.",
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.clearSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Back to Discover',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Browse Shimmer ──
  Widget _buildBrowseShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(
                4,
                (_) => Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(width: 140, height: 20, color: Colors.white),
            const SizedBox(height: 14),
            Row(
              children: List.generate(
                2,
                (_) => Expanded(
                  child: Container(
                    height: 180,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Grid Shimmer ──
  Widget _buildGridShimmer() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.62,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: colorScheme.surfaceContainerHighest,
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
