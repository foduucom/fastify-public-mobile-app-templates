import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zouhi/app/modules/shop/bindings/shop_binding.dart';
import 'package:zouhi/app/modules/shop/views/productdetail_view.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/search_bar_rounded.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/modules/auth/auth_details.dart';
import 'package:zouhi/components/cart_auth_bottom_sheet.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zouhi/app/controllers/currency_controller.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:zouhi/components/catalog_mode_bottom_sheet.dart';

import 'package:zouhi/app/modules/cart/controllers/cart_controller.dart';
import 'package:zouhi/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:zouhi/app/controllers/internetconnection_controller.dart';
import 'package:zouhi/components/offline_ribbon.dart';
import 'package:zouhi/components/check_internet_widget.dart';
import 'package:zouhi/app/modules/search/controllers/search_controller.dart';
import 'package:zouhi/app/data/models/product_model.dart';
import 'package:zouhi/components/home_component/trending_product_card.dart';
import 'package:zouhi/components/home_component/blog_section.dart';
import 'package:zouhi/app/modules/shop/views/registry_quote_flow.dart';
import 'package:zouhi/components/product_image_placeholder.dart';
import 'package:zouhi/components/shimmer_effects.dart';

class SearchView extends GetView<SearchsController> {
  SearchView({Key? key}) : super(key: key);

  String get _currencySymbol {
    if (Get.isRegistered<CurrencyController>()) {
      return Get.find<CurrencyController>()
              .selectedCurrency['symbol']
              ?.toString() ??
          currency;
    }
    return currency;
  }

  final WishlistController wishlistController = Get.find<WishlistController>();
  final CartController cartController = Get.find<CartController>();

  String getPrice(dynamic price) {
    if (price == null) return '0.00';
    double val = 0.0;
    if (price is Map && price.containsKey('\$numberDecimal')) {
      val = double.tryParse(price['\$numberDecimal'].toString()) ?? 0.0;
    } else {
      val = double.tryParse(price.toString()) ?? 0.0;
    }
    return val.toConvertedPrice().toStringAsFixed(2);
  }

  Map<String, String> getProductDisplayPrices(dynamic product) {
    if (product == null || product is! Map) {
      return {'sellingPrice': '0.00', 'originalPrice': ''};
    }

    double? originalPrice;
    double? salePrice;

    List variants =
        (product['variants'] ?? product['variant_ids'] ?? []) as List;
    Map? defaultVariant;
    for (var v in variants) {
      if (v is Map && v['is_default'] == true) {
        defaultVariant = v;
        break;
      }
    }
    defaultVariant ??= (variants.isNotEmpty && variants.first is Map)
        ? variants.first as Map
        : null;

    if (defaultVariant != null) {
      originalPrice =
          double.tryParse(defaultVariant['price']?.toString() ?? '');
      salePrice =
          double.tryParse(defaultVariant['sale_price']?.toString() ?? '');
    } else {
      originalPrice = double.tryParse(product['price']?.toString() ?? '');
      salePrice = double.tryParse(product['sale_price']?.toString() ??
          product['salePrice']?.toString() ??
          '');
    }

    if (salePrice != null && salePrice <= 0) salePrice = null;

    if (originalPrice != null) originalPrice = originalPrice.toConvertedPrice();
    if (salePrice != null) salePrice = salePrice.toConvertedPrice();

    final double? oPrice = originalPrice;
    final double? sPrice = salePrice;
    bool hasDiscount = sPrice != null && oPrice != null && sPrice < oPrice;

    String sellingPriceStr = hasDiscount
        ? sPrice.toStringAsFixed(2)
        : (oPrice?.toStringAsFixed(2) ?? '0.00');

    String originalPriceStr = hasDiscount ? oPrice.toStringAsFixed(2) : '';

    return {
      'sellingPrice': sellingPriceStr,
      'originalPrice': originalPriceStr,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HelperFunctions().closeKeyboard(context),
      child: Scaffold(
        backgroundColor: context.themeWhiteColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          toolbarHeight: 70,
          title: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Get.back(),
                icon: Icon(Icons.arrow_back_ios,
                    color: context.themeTextColor, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() => SearchBarRounded(
                      searchHintText: controller.currentHint,
                      focusNode: controller.searchFocusNode,
                      SearchsController: controller.searchTextController,
                      onChanged: controller.onQueryChanged,
                      onFieldSubmitted: (value) {
                        controller.addToRecentSearch(value);
                        controller.searchNow(value);
                      },
                    )),
              ),
              Obx(() => controller.query.value.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      onPressed: controller.clearSearch,
                      icon: const Icon(Icons.close, color: Colors.grey),
                    )),
            ],
          ),
          backgroundColor: context.themeWhiteColor,
          elevation: 0,
          shadowColor: context.themeBorderColor,
          surfaceTintColor: Colors.transparent,
        ),
        body: Column(
          children: [
            const OfflineRibbon(),
            Expanded(
              child: Obx(
                () {
                  final q = controller.query.value;
                  final hasResults = controller.searchProduct.isNotEmpty ||
                      controller.searchCategory.isNotEmpty ||
                      controller.searchBlog.isNotEmpty;
                  final loading = controller.isProductsLoading.value ||
                      controller.isCategoriesLoading.value ||
                      controller.isBlogsLoading.value;

                  final isOffline = !Get.find<InternetconnectionController>()
                      .connectionStatus
                      .value;
                  if (isOffline && q.isNotEmpty && !hasResults) {
                    return InternetConnectionError(
                      onRetry: () => controller.searchNow(q),
                    );
                  }

                  // Empty / 1-character query: discovery content.
                  if (q.length < SearchsController.minQueryLength) {
                    return _buildDiscoverView();
                  }

                  if (!hasResults && !loading) return _buildNoResults(q);

                  return Column(
                    children: [
                      _buildFilterChips(),
                      Expanded(child: _buildResults(loading)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoverView() {
    final hasHistory = controller.recentSearchList.isNotEmpty ||
        controller.recentProducts.isNotEmpty;
    final nothingLoaded = controller.trendingCategoryProduct.isEmpty &&
        controller.featuredProducts.isEmpty &&
        controller.featuredBlogs.isEmpty;

    if (controller.isDiscoverLoading.value && nothingLoaded && !hasHistory) {
      return _discoverSkeleton();
    }

    final popularNames = controller.trendingCategoryProduct
        .map((c) => c is Map ? (c['name'] ?? '').toString() : '')
        .where((n) => n.isNotEmpty)
        .take(8)
        .toList();

    final sections = <Widget>[
      if (controller.recentSearchList.isNotEmpty) _buildRecentSearchChips(),
      if (popularNames.isNotEmpty) _buildTrendingSearches(popularNames),
      if (controller.recentProducts.isNotEmpty) _buildRecentProductsSection(),
      if (controller.trendingCategoryProduct.isNotEmpty) _buildShopByCategory(),
      if (controller.featuredProducts.isNotEmpty) _buildTrendingCarousel(),
      if (controller.featuredBlogs.isNotEmpty)
        _buildBlogSection(
            "Learn & get inspired", controller.featuredBlogs.take(4).toList()),
    ];

    return RefreshIndicator(
      onRefresh: () async => controller.getDiscoverData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            for (int i = 0; i < sections.length; i++)
              _FadeSlideIn(delayMs: 60 * i, child: sections[i]),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon,
      {String? actionText, VoidCallback? onAction}) {
    final primaryColor = Get.context!.themePrimaryColor;
    final textColor = Get.context!.themeTextColor;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: primaryColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.5,
                color: textColor,
              ),
            ),
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionText,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: primaryColor,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Trending searches with brand-tinted interactive chips.
  Widget _buildTrendingSearches(List<String> names) {
    final primaryColor = Get.context!.themePrimaryColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Trending Searches", Iconsax.trend_up),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 9,
            children: [
              for (int i = 0; i < names.length; i++)
                GestureDetector(
                  onTap: () {
                    controller.searchTextController.text = names[i];
                    controller.addToRecentSearch(names[i]);
                    controller.searchNow(names[i]);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 7.5),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.22),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          i < 2 ? Iconsax.flash_1 : Iconsax.trend_up,
                          size: 13,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          names[i],
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Returning users: their last searches as removable chips.
  Widget _buildRecentSearchChips() {
    final items = controller.recentSearchList.take(8).toList();
    final textColor = Get.context!.themeTextColor;
    final greyColor = Get.context!.themegreyColor;
    final borderColor = Get.context!.themeBorderColor;
    final secondaryTextColor = Get.context!.themeSecondrytext;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Recent Searches", Iconsax.clock,
            actionText: "Clear all", onAction: controller.clearRecentSearches),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final recent in items)
                InputChip(
                  label: Text(
                    (recent['name'] ?? '').toString(),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  backgroundColor: greyColor.withOpacity(0.55),
                  side: BorderSide(
                    color: borderColor.withOpacity(0.5),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onPressed: () {
                    controller.searchTextController.text = recent['name'];
                    controller.searchNow(recent['name']);
                    controller.addToRecentSearch(recent['name']);
                  },
                  onDeleted: () {
                    controller.recentSearchList.remove(recent);
                    controller.box
                        .write('recentSearch', controller.recentSearchList);
                  },
                  deleteIconColor: secondaryTextColor,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShopByCategory() {
    final cats = controller.trendingCategoryProduct.take(6).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Shop by category", Iconsax.category,
            actionText: "View all",
            onAction: () => BottombarController.switchTab(1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 122,
            ),
            itemCount: cats.length,
            itemBuilder: (_, i) => _categoryTile(cats[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingCarousel() {
    final products = controller.featuredProducts.take(8).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Best sellers", Iconsax.trend_up,
            actionText: "See all",
            onAction: () => BottombarController.switchTab(1)),
        SizedBox(
          height: 290,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => SizedBox(
                width: 170, child: _buildModernProductCard(products[i])),
          ),
        ),
      ],
    );
  }

  Widget _discoverSkeleton() => AppShimmer(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitleSkeleton(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                      6,
                      (_) => const SkeletonBox(
                          width: 96, height: 32, borderRadius: 16)),
                ),
              ),
              _sectionTitleSkeleton(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: List.generate(
                      3,
                      (_) => const Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: SkeletonBox(height: 120, borderRadius: 16),
                            ),
                          )),
                ),
              ),
              _sectionTitleSkeleton(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(child: SkeletonBox(height: 230, borderRadius: 16)),
                    SizedBox(width: 12),
                    Expanded(child: SkeletonBox(height: 230, borderRadius: 16)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  // ---------------------------------------------------------------------------
  // Results
  // ---------------------------------------------------------------------------

  static const int _allTabLimit = 4;

  Widget _buildFilterChips() {
    final tabs = <SearchTab, String>{
      SearchTab.all: 'All',
      SearchTab.products: 'Products (${controller.productsTotal.value})',
      SearchTab.categories: 'Categories (${controller.searchCategory.length})',
      SearchTab.blogs: 'Magazine (${controller.searchBlog.length})',
    };
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: tabs.entries.map((e) {
          final selected = controller.activeTab.value == e.key;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(e.value),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) => controller.activeTab.value = e.key,
              selectedColor: Get.context!.themePrimaryColor,
              backgroundColor: Get.context!.themegreyColor,
              side: BorderSide.none,
              labelStyle: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Get.context!.themeTextColor,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResults(bool loading) {
    final tab = controller.activeTab.value;
    final showProducts = tab == SearchTab.all || tab == SearchTab.products;
    final showCategories = tab == SearchTab.all || tab == SearchTab.categories;
    final showBlogs = tab == SearchTab.all || tab == SearchTab.blogs;
    final isAll = tab == SearchTab.all;

    final products = controller.searchProduct;
    final categories = controller.searchCategory;
    final blogs = controller.searchBlog;

    return SingleChildScrollView(
      controller: controller.resultsScroll,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showCategories)
            if (controller.isCategoriesLoading.value && categories.isEmpty)
              _categorySkeleton()
            else if (categories.isNotEmpty)
              tab == SearchTab.categories
                  ? _buildCategoryGrid(categories)
                  : _buildCategorySection("Categories", categories),
          if (showProducts)
            if (controller.isProductsLoading.value && products.isEmpty)
              _productSkeleton()
            else if (products.isNotEmpty) ...[
              _buildProductSection("Products",
                  isAll ? products.take(_allTabLimit).toList() : products),
              if (isAll && controller.productsTotal.value > _allTabLimit)
                _seeAllButton(
                    "See all ${controller.productsTotal.value} products",
                    SearchTab.products),
              if (!isAll && controller.isProductsMore.value)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                      child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2))),
                ),
            ],
          if (showBlogs)
            if (controller.isBlogsLoading.value && blogs.isEmpty)
              _blogSkeleton()
            else if (blogs.isNotEmpty)
              tab == SearchTab.blogs
                  ? _buildBlogList(blogs)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlogSection(
                          title: "Magazine",
                          blogList: blogs.take(_allTabLimit).toList(),
                          isLoading: false,
                          seeAllText: blogs.length > _allTabLimit
                              ? "See all ${blogs.length}"
                              : "Explore All",
                          isPillSeeAll: true,
                          onSeeAllTap: () => blogs.length > _allTabLimit
                              ? controller.activeTab.value = SearchTab.blogs
                              : Get.toNamed(Routes.BLOG),
                          onBlogTap: _openBlog,
                        ),
                      ],
                    ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _openBlog(dynamic blog) {
    controller.addToRecentSearch(controller.query.value);
    controller.addToRecentlyViewed(blog, 'blog');
    Get.toNamed(Routes.BLOGDETAILS, arguments: {'id': blog['_id']});
  }

  Widget _seeAllButton(String label, SearchTab tab) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => controller.activeTab.value = tab,
          child: Text(label),
        ),
      ),
    );
  }

  Widget _buildNoResults(String q) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Icon(Iconsax.search_status,
                    size: 72, color: Get.context!.themeBorderColor),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "No results for '$q'",
                    textAlign: TextAlign.center,
                    style: txtTheme().headlineSmall!.copyWith(
                        color: Get.context!.themeSecondrytext),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Check the spelling or try a more general word.",
                  style: txtTheme()
                      .bodySmall!
                      .copyWith(color: Get.context!.themeSecondrytext),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Never a dead end: show what is popular instead.
          if (controller.trendingCategoryProduct.isNotEmpty)
            _buildCategorySection("Browse Categories",
                controller.trendingCategoryProduct.take(6).toList()),
          if (controller.featuredProducts.isNotEmpty)
            _buildProductSection(
                "Best sellers", controller.featuredProducts.take(4).toList()),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ---- Skeletons --------------------------------------------------------------

  Widget _sectionTitleSkeleton() => const Padding(
        padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: SkeletonLine(width: 110, height: 16),
      );

  Widget _categorySkeleton() => AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitleSkeleton(),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: 5,
                itemBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Column(children: [
                    SkeletonCircle(size: 70),
                    SizedBox(height: 8),
                    SkeletonLine(width: 56, height: 10),
                  ]),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _productSkeleton() => AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitleSkeleton(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  Expanded(child: SkeletonBox(height: 230, borderRadius: 16)),
                  SizedBox(width: 12),
                  Expanded(child: SkeletonBox(height: 230, borderRadius: 16)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _blogSkeleton() => AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitleSkeleton(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SkeletonBox(height: 190, borderRadius: 20),
            ),
          ],
        ),
      );

  // ---- Category grid / blog list (used by the filter tabs) -----------------------

  Widget _buildCategoryGrid(List categories) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisExtent: 134,
        ),
        itemCount: categories.length,
        itemBuilder: (_, i) => _categoryTile(categories[i]),
      ),
    );
  }

  Widget _buildBlogList(List blogs) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      itemCount: blogs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final blog = blogs[i];
        return GestureDetector(
          onTap: () => _openBlog(blog),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  width: 96,
                  height: 72,
                  fit: BoxFit.cover,
                  imageUrl: HelperFunctions().getImage(blog['featured_image']),
                  errorWidget: (_, __, ___) => Container(
                    width: 96,
                    height: 72,
                    color: Colors.grey.shade100,
                    child: Icon(Iconsax.document,
                        color: Colors.grey.shade300, size: 28),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HighlightText(
                  text: (blog['name'] ?? blog['title'] ?? '').toString(),
                  query: controller.query.value,
                  maxLines: 3,
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Get.context!.themeTextColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategorySection(String title, List categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Get.context!.themeTextColor),
          ),
        ),
        SizedBox(
          height: 138,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SizedBox(
                  width: 104,
                  child: _categoryTile(categories[index]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _categoryTile(dynamic category) {
    final whiteColor = Get.context!.themeWhiteColor;
    final borderColor = Get.context!.themeBorderColor;
    final textColor = Get.context!.themeTextColor;
    final greyColor = Get.context!.themegreyColor;
    final secondaryTextColor = Get.context!.themeSecondrytext;
    final primaryColor = Get.context!.themePrimaryColor;

    return GestureDetector(
      onTap: () {
        controller.addToRecentSearch(controller.query.value);
        controller.addToRecentlyViewed(category, 'category');

        final slug = (category['slug'] ?? '').toString().toLowerCase();
        final name = (category['name'] ?? '').toString().toLowerCase();
        if (slug == 'cable-assemblies' || name.contains('cable assembl')) {
          Get.toNamed(Routes.CABLE_ASSEMBLIES);
          return;
        }
        if (slug == 'mtp-solution' ||
            slug.contains('mtp') ||
            name.contains('mtp')) {
          Get.toNamed(Routes.MTP_SOLUTION);
          return;
        }

        BottombarController.switchTab(1, arguments: {
          'productId': category['_id'],
          'categorySlug': category['slug'] ?? category['_id'],
          'name': category['name'],
          'source': 'category'
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor.withOpacity(0.55),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: greyColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl:
                      HelperFunctions().getImage(category['featured_image']),
                  fit: BoxFit.cover,
                  placeholder: (_, url) => Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    ),
                  ),
                  errorWidget: (_, url, error) => Icon(
                    Iconsax.category,
                    color: secondaryTextColor,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category['name'] ?? '',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                height: 1.25,
                color: textColor,
              ),
            ),
            // Nested categories: show where they live (also tells apart
            // categories that share a name).
            if ((category['parent_name'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                'in ${category['parent_name']}',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductSection(String title, List products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Get.context!.themeTextColor),
              ),
              //const Icon(Iconsax.filter_edit, size: 20, color: Colors.grey),
            ],
          ),
        ),
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisExtent: 284,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildModernProductCard(product);
          },
        ),
      ],
    );
  }

  Widget _buildModernProductCard(Product product) {
    double oPriceVal =
        (double.tryParse(product.price) ?? 0.0).toConvertedPrice();
    double sPriceVal =
        (double.tryParse(product.salePrice) ?? 0.0).toConvertedPrice();

    String price = oPriceVal.toStringAsFixed(2);
    String salePrice = sPriceVal.toStringAsFixed(2);
    bool hasDiscount = sPriceVal > 0.0 && oPriceVal > sPriceVal;
    String productId = product.id;

    // Logic to find a default variant ID if it's a simple product
    String? variantId = product.defaultVariantId;

    String discountRate = '';
    if (hasDiscount) {
      if (oPriceVal > 0) {
        discountRate = '${(100 - (sPriceVal * 100 / oPriceVal)).round()}% off';
      }
    }

    return GestureDetector(
      onTap: () {
        controller.addToRecentSearch(controller.query.value);
        controller.addToRecentlyViewed(product.toJson(), 'product');
        Get.to(() => ProductdetailView(),
            binding: ShopBinding(), arguments: {'productId': product.id});
      },
      child: TrendingProducts(
        index: 0,
        lowestPrice: '',
        highestPrice: '',
        assetImage: HelperFunctions().getImage(product.featuredImage),
        productName: product.name,
        discountPrice: hasDiscount ? price : '',
        productPrice: hasDiscount ? salePrice : price,
        discountRate: discountRate,
        isCatalogMode: product.isCatalogMode,
        catalogButtonText: product.catalogButtonText,
        onCatalogModeTap: () {
          final ctx = Get.context;
          if (ctx == null) return;
          showCatalogModeBottomSheet(
            ctx,
            productName: product.name,
            productId: productId,
            productImage: product.featuredImage,
            buttonText: product.catalogButtonText,
          );
        },
        productType: product.type,
        productId: productId,
        variantId: variantId,
        isOutOfStock: product.isOutOfStock,
        rating: product.averageRating,
        reviewCount: product.reviewCount,
        isRegistryProduct: product.isRegistry,
        onRequestQuote: () =>
            RegistryQuoteFlow().open(productId, variantId: variantId),
        onAddToCart: product.isCatalogMode
            ? null
            : () async {
                if (controller.isProcessingCart) return;
                controller.isProcessingCart = true;
          try {
            if (!AuthDetails.isUserLogin()) {
              showCartAuthBottomSheet();
              return;
            }
            await cartController.addToCart(
              productId: productId,
              quantity: 1,
              variantId: variantId ?? '',
              productType: product.type,
            );
          } finally {
            controller.isProcessingCart = false;
          }
        },
        onlike: () async {
          if (controller.isProcessingLike) return;
          controller.isProcessingLike = true;
          try {
            if (!HelperFunctions.checkAndPromptLogin(
                message: "Please login to add products to your wishlist.")) {
              return;
            }
            if (wishlistController.wishlistProductIds.contains(productId)) {
              wishlistController.wishlistProductIds.remove(productId);
              await wishlistController.removeProductFromWishlist(
                  productid: productId, variant_id: variantId);
            } else {
              wishlistController.wishlistProductIds.add(productId);
              await wishlistController.addProductToWishlist(
                  productid: productId, variant_id: variantId);
            }
          } finally {
            controller.isProcessingLike = false;
          }
        },
        likeWidget: GetBuilder<WishlistController>(
          builder: (wishController) {
            bool isLiked =
                wishController.wishlistProductIds.contains(productId);
            return Icon(
              isLiked ? Iconsax.heart5 : Iconsax.heart,
              size: 16,
              color: isLiked ? Colors.red : Colors.grey,
            );
          },
        ),
      ),
    );
  }

  Widget _buildBlogSection(String title, List blogs) {
    return BlogSection(
      title: title,
      blogList: blogs,
      isLoading: false,
      seeAllText: "Explore All",
      isPillSeeAll: true,
      onSeeAllTap: () => Get.toNamed(Routes.BLOG),
      onBlogTap: _openBlog,
    );
  }

  Widget _buildRecentProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recently Viewed",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Get.context!.themeTextColor),
              ),
              GestureDetector(
                onTap: () {
                  controller.recentProducts.clear();
                  controller.box.write('recentProducts', []);
                },
                child: Text(
                  "Clear All",
                  style: TextStyle(
                      color: Get.context!.themeSecondrytext,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 190,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: controller.recentProducts.length,
            itemBuilder: (context, index) {
              final item = controller.recentProducts[index];
              if (item is! Map) return const SizedBox.shrink();

              // Determine the type of the recently viewed item
              String type = item['recentlyViewedType'] ??
                  (item['price'] != null ? 'product' : 'category');

              if (type == 'category') {
                return _buildSmallCategoryCard(item);
              } else if (type == 'blog') {
                return _buildSmallBlogCard(item);
              } else {
                return _buildSmallProductCard(item);
              }
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCardBadge({required String type}) {
    IconData icon;
    Color iconColor;
    String label;

    if (type == 'category') {
      icon = Iconsax.category;
      iconColor = Colors.orange;
      label = "CATEGORY";
    } else if (type == 'blog') {
      icon = Iconsax.document;
      iconColor = Colors.blue;
      label = "BLOG";
    } else {
      icon = Iconsax.shopping_bag;
      iconColor = themePrimaryColor;
      label = "PRODUCT";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 7.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallProductCard(dynamic product) {
    final priceData = getProductDisplayPrices(product);
    String price = priceData['sellingPrice'] ?? '0.00';
    String originalPrice = priceData['originalPrice'] ?? '';
    bool hasDiscount = originalPrice.isNotEmpty;

    return GestureDetector(
      onTap: () {
        controller.addToRecentlyViewed(product, 'product');
        Get.to(() => ProductdetailView(),
            binding: ShopBinding(), arguments: {'productId': product['_id']});
      },
      child: Container(
        width: 140,
        height: 190,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Get.context!.themeWhiteColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    height: 115,
                    width: 140,
                    child: (HelperFunctions()
                                .getImage(product['featured_image'])
                                .isNotEmpty &&
                            HelperFunctions()
                                    .getImage(product['featured_image']) !=
                                HelperFunctions.getNoImage())
                        ? CachedNetworkImage(
                            height: 115,
                            width: 140,
                            imageUrl: HelperFunctions()
                                .getImage(product['featured_image']),
                            fit: BoxFit.contain,
                            errorWidget: (context, url, error) =>
                                const ProductImagePlaceholder(radius: 0),
                          )
                        : const ProductImagePlaceholder(radius: 0),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: _buildCardBadge(type: 'product'),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product['name'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: txtTheme().bodySmall!.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                          height: 1.25,
                          color: Colors.black87),
                    ),
                    Row(
                      children: [
                        Text(
                          "$_currencySymbol$price",
                          style: txtTheme().bodySmall!.copyWith(
                              color: themePrimaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12),
                        ),
                        // if (hasDiscount) ...[
                        //   const SizedBox(width: 4),
                        //   Flexible(
                        //     child: Text(
                        //       "$_currencySymbol$originalPrice",
                        //       overflow: TextOverflow.ellipsis,
                        //       style: txtTheme().bodySmall!.copyWith(
                        //           color: Colors.grey,
                        //           decoration: TextDecoration.lineThrough,
                        //           fontSize: 9.5),
                        //     ),
                        //   ),
                        // ],
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

  Widget _buildSmallCategoryCard(dynamic category) {
    return GestureDetector(
      onTap: () {
        controller.addToRecentlyViewed(category, 'category');
        BottombarController.switchTab(1, arguments: {
          'productId': category['_id'],
          'categorySlug': category['slug'] ?? category['_id'],
          'name': category['name'],
          'source': 'category'
        });
      },
      child: Container(
        width: 85,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color.fromRGBO(
                      255, 128, 0, 1), // Golden/Orange color
                  width: 2.0, // Border width
                ),
              ),
              child: ClipOval(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 203, 212, 233),
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      imageUrl: HelperFunctions().getImage(
                          category['featured_image'],
                          moduleName: "categories"),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.error,
                          color: Colors.grey,
                        ),
                      ),
                      progressIndicatorBuilder: (context, url, progress) =>
                          Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: HelperFunctions().loadingIndicator(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 76, // Match the container width
              child: Text(
                category['name']?.toString() ?? '',
                style: txtTheme().bodyMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSmallBlogCard(dynamic blog) {
    return GestureDetector(
      onTap: () {
        controller.addToRecentlyViewed(blog, 'blog');
        Get.toNamed(Routes.BLOGDETAILS, arguments: {'id': blog['_id']});
      },
      child: Container(
        width: 240,
        height: 190,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: CachedNetworkImage(
                    height: 110,
                    width: double.infinity,
                    imageUrl:
                        HelperFunctions().getImage(blog['featured_image']),
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      height: 110,
                      width: double.infinity,
                      color: Colors.grey.shade100,
                      child: Icon(Iconsax.document,
                          color: Colors.grey.shade300, size: 30),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      "NEW",
                      style: txtTheme().bodySmall!.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      blog['name'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: txtTheme().bodyMedium!.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            height: 1.25,
                            color: Colors.black,
                          ),
                    ),
                    Row(
                      children: [
                        Text(
                          "Read Story",
                          style: txtTheme().bodySmall!.copyWith(
                                color: themePrimaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 12,
                          color: themePrimaryColor,
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

/// Bolds the part of [text] that matches any word of [query].
class _HighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;
  final int maxLines;

  const _HighlightText({
    required this.text,
    required this.query,
    required this.style,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    final words = query
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map(RegExp.escape)
        .toList();
    if (words.isEmpty) {
      return Text(text, maxLines: maxLines, overflow: TextOverflow.ellipsis, style: style);
    }
    final re = RegExp(words.join('|'), caseSensitive: false);
    final spans = <TextSpan>[];
    int last = 0;
    for (final m in re.allMatches(text)) {
      if (m.start > last) spans.add(TextSpan(text: text.substring(last, m.start)));
      spans.add(TextSpan(
          text: text.substring(m.start, m.end),
          style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Get.context!.themePrimaryColor)));
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return Text.rich(TextSpan(style: style, children: spans),
        maxLines: maxLines, overflow: TextOverflow.ellipsis);
  }
}

/// Fades and slides its child up slightly on first build.
class _FadeSlideIn extends StatelessWidget {
  final Widget child;
  final int delayMs;
  const _FadeSlideIn({required this.child, this.delayMs = 0});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (_, t, c) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 16 * (1 - t)), child: c),
      ),
      child: child,
    );
  }
}
