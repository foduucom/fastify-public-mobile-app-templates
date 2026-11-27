import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/components/app_image_placeholder.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/category/views/category_dialog.dart';
import 'package:foduu_ecommerce/app/modules/shop/shop_navigation.dart';
import 'package:foduu_ecommerce/components/buttons/appbutton.dart';
import 'package:foduu_ecommerce/components/home_component/customDrawer.dart';
import 'package:foduu_ecommerce/components/home_component/studio_search_bar_rounded.dart';
import 'package:foduu_ecommerce/constants/theme.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_view.dart';
import 'package:foduu_ecommerce/models/blog_model.dart';
import 'package:shimmer/shimmer.dart';
import '/components/product_grid_card.dart';
import '/app/routes/app_pages.dart';
import '/constants/helper_functions.dart';
import '/constants/product_helper.dart';
import 'package:get/get.dart';

import '../controllers/search_controller.dart';
import 'filter_view.dart';

class SearchView extends GetView<SearchsController> {
  SearchView({Key? key}) : super(key: key);

  ColorScheme get colorScheme => Theme.of(Get.context!).colorScheme;
  TextTheme get textTheme => Theme.of(Get.context!).textTheme;

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => HelperFunctions().closeKeyboard(context),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: colorScheme.background,
        drawer: Drawer(
          child: AuthDetails.isUserLogin()
              ? const CustomDrawer()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                        child: Text(
                      'Login to View Profile',
                      style: txtTheme().displayMedium,
                    )),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: Get.width * 0.6,
                      child: AppButton(
                          itemText: 'Login',
                          keypressEvent: () {
                            Get.offAllNamed(Routes.LOGIN);
                          }),
                    ),
                  ],
                ),
        ),

        // Remove the default AppBar completely
        appBar: null,

        body: SafeArea(
          child: Column(
            children: [
              // The page owns the search field; CMS search sections are excluded
              // by the controller to prevent rendering a duplicate field.
              Obx(() {
                return SearchViewHeader(
                  width: width,
                  height: height,
                  searchTextController: controller.searchTextController,
                  hintText: controller.searchPlaceholder,
                  onSearchChanged: controller.onSearchChanged,
                  showClear: controller.queryText.value.isNotEmpty,
                  onClear: () {
                    controller.searchTextController.clear();
                    controller.onSearchChanged('');
                  },
                  onSubmitted: (text) {
                    HelperFunctions().closeKeyboard(context);
                    controller.getSearchSuggestion(text: text);
                  },
                  onCartTap: () => Get.toNamed(Routes.CART),
                  //onMessageTap: () => scaffoldKey.currentState?.openDrawer(),
                  //onNotificationTap: () => Get.toNamed(Routes.NOTIFICATION),
                );
              }),

              Obx(() => _buildAutocomplete(context)),

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
                              brandOptions: controller.brands
                                  .whereType<Map>()
                                  .map((brand) => {
                                        'label':
                                            brand['name']?.toString() ?? '',
                                        'value': brand['slug']?.toString() ??
                                            brand['_id']?.toString() ??
                                            '',
                                      })
                                  .where((brand) =>
                                      brand['label']!.isNotEmpty &&
                                      brand['value']!.isNotEmpty)
                                  .toList(),
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

              // ── RECENT SEARCHES ──
              Obx(() => _buildRecentSearches(context)),

              // ── BODY: CMS layout in browse mode, unified results otherwise ──
              Expanded(
                child: Obx(() {
                  final isSearchMode = controller.searchSubmitted.value ||
                      controller.selectedBrandSlug.value.isNotEmpty ||
                      (controller.queryText.value.trim().isEmpty &&
                          controller.activeFilter.value.hasActiveFilters);

                  if (!isSearchMode && controller.widgetList.isNotEmpty) {
                    return FoduuStudioLayoutView(
                      onRefresh: () =>
                          controller.fetchLayout(SearchsController.pageSlug),
                      widgetList: controller.widgetList,
                      isLoading: controller.isLayoutLoading,
                      hasError: controller.hasError,
                      errorMessage: controller.errorMessage,
                      isStale: controller.isStale,
                    );
                  }

                  if (!isSearchMode &&
                      controller.widgetList.isEmpty &&
                      controller.isLayoutLoading.value) {
                    return _buildGridShimmer();
                  }

                  if (controller.isSearching.value &&
                      controller.searchProduct.isEmpty &&
                      controller.searchCategories.isEmpty &&
                      controller.searchBlogs.isEmpty) {
                    return _buildGridShimmer();
                  }

                  return _buildResults(context, isSearchMode);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAutocomplete(BuildContext context) {
    final query = controller.queryText.value.trim();
    if (query.isEmpty) return const SizedBox.shrink();
    final products = controller.autocompleteProducts;
    final categories = controller.autocompleteCategories;
    final blogs = controller.autocompleteBlogs;
    final brands = controller.autocompleteBrands;
    if (controller.isAutocompleteLoading.value &&
        products.isEmpty &&
        categories.isEmpty &&
        blogs.isEmpty &&
        brands.isEmpty) {
      return const Padding(
          padding: EdgeInsets.all(12), child: LinearProgressIndicator());
    }
    final suggestions = <Widget>[];
    for (final item in products) {
      if (item is! Map) continue;
      final name = (item['name'] ?? item['title'] ?? '').toString();
      final rawProductId = item['product_id'];
      final id = (item['_id'] ??
                  item['id'] ??
                  (rawProductId is Map
                      ? rawProductId['_id'] ?? rawProductId['id']
                      : rawProductId))
              ?.toString() ??
          '';
      if (name.isEmpty || id.isEmpty) continue;
      final imageUrl = HelperFunctions.resolveProductImage(item);
      final priceInfo =
          ProductHelper.calculatePriceInfo(Map<String, dynamic>.from(item));
      final price = ProductHelper.formatPrice(
          priceInfo['productPrice']?.toString() ?? '');
      suggestions.add(ListTile(
        dense: true,
        leading: _suggestionImage(imageUrl, Icons.shopping_bag_outlined),
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(price.isEmpty ? 'Product' : '$price · Product'),
        onTap: () {
          controller.saveRecentSearch(id: id, name: name, type: 'product');
          Get.toNamed(Routes.PRODUCTDETAILS, arguments: {'productId': id});
        },
      ));
    }
    for (final item in categories) {
      if (item is! Map) continue;
      final name = (item['name'] ?? '').toString();
      final id = (item['_id'] ?? item['id'] ?? '').toString();
      if (name.isEmpty || id.isEmpty) continue;
      final imageUrl = HelperFunctions()
          .getImage(item['featured_image'] ?? item['image'] ?? item['icon']);
      suggestions.add(ListTile(
        dense: true,
        leading: _suggestionImage(imageUrl, Icons.category_outlined),
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: const Text('Category'),
        onTap: () {
          controller.saveRecentSearch(id: id, name: name, type: 'category');
          openShop({
            'productId': id,
            'categorySlug': item['slug'],
            'name': name,
            'source': 'category'
          });
        },
      ));
    }
    for (final item in brands) {
      if (item is! Map) continue;
      final name = (item['name'] ?? '').toString();
      final slug = (item['slug'] ?? '').toString();
      if (name.isEmpty || slug.isEmpty) continue;
      suggestions.add(ListTile(
        dense: true,
        leading: const Icon(Icons.sell_outlined),
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: const Text('Brand'),
        onTap: () => controller.fetchProductsByBrand(slug),
      ));
    }
    for (final item in blogs) {
      if (item is! Map) continue;
      final name = (item['title'] ?? item['name'] ?? '').toString();
      if (name.isEmpty) continue;
      final imageUrl = HelperFunctions().getImage(item['featured_image'] ??
          item['featured_image_url'] ??
          item['image'] ??
          item['cover_image']);
      suggestions.add(ListTile(
        dense: true,
        leading: _suggestionImage(imageUrl, Icons.article_outlined),
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: const Text('Article'),
        onTap: () {
          final blog = BlogModel.fromJson(Map<String, dynamic>.from(item));
          controller.saveRecentSearch(
              id: blog.id, name: blog.title, type: 'blog');
          Get.toNamed(Routes.BLOG_DETAILS, arguments: {'blog': blog});
        },
      ));
    }
    if (suggestions.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ListTile(
          dense: true,
          leading: const Icon(Icons.search),
          title: const Text('No suggestions found'),
          subtitle: const Text('Submit the search to see matching results.'),
          onTap: () => controller.getSearchSuggestion(text: query),
        ),
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 250),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        clipBehavior: Clip.antiAlias,
        child: ListView(
            shrinkWrap: true, padding: EdgeInsets.zero, children: suggestions),
      ),
    );
  }

  Widget _suggestionImage(String imageUrl, IconData fallback) {
    final noImage = HelperFunctions.getNoImage();
    if (imageUrl.isEmpty || imageUrl == noImage) {
      return SizedBox(
        width: 44,
        height: 44,
        child: Icon(fallback, color: colorScheme.onSurfaceVariant),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => SizedBox(
          width: 44,
          height: 44,
          child: Icon(fallback, color: colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }

  // ── RECENT SEARCHES (compact chips under the brands) ──
  Widget _buildRecentSearches(BuildContext context) {
    if (controller.queryText.value.isNotEmpty ||
        controller.recentSearchList.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Recent Searches",
                  style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface)),
              TextButton(
                  onPressed: controller.clearRecentSearches,
                  child: const Text('Clear')),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.recentSearchList.take(6).map((item) {
              return InputChip(
                label: Text(item['name']?.toString() ?? ''),
                backgroundColor:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                labelStyle: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface, fontWeight: FontWeight.w500),
                onPressed: () {
                  final name = item['name']?.toString() ?? '';
                  controller.searchTextController.text = name;
                  controller.getSearchSuggestion(text: name);
                },
                onDeleted: () => controller.removeRecentItem(item),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── UNIFIED RESULTS: groups follow the CMS section order ──
  Widget _buildResults(BuildContext context, bool isSearchMode) {
    final order = controller.resultOrder;
    final hasAny = controller.searchProduct.isNotEmpty ||
        controller.searchCategories.isNotEmpty ||
        controller.searchBlogs.isNotEmpty;
    final selectedType = controller.selectedResultType.value;
    final visibleTypes = selectedType == 'all'
        ? order
        : order.where((type) => type == selectedType).toList();
    final selectedCount = switch (selectedType) {
      'products' => controller.searchProduct.length,
      'categories' => controller.searchCategories.length,
      'blog' => controller.searchBlogs.length,
      _ => controller.totalResultCount,
    };

    return SingleChildScrollView(
      controller: controller.scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.searchError.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.wifi_off_outlined, size: 36),
                  const SizedBox(height: 8),
                  const Text('Search could not be loaded.'),
                  TextButton(
                    onPressed: controller.retrySearch,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          // Other CMS blocks (banner, rich text, ...) above the results.
          if (isSearchMode)
            ...controller.buildWidgetsExcluding(
                ['search', 'products', 'categories', 'blog']),

          if (isSearchMode) _buildResultTabs(),

          if (controller.searchError.value.isEmpty &&
              (!hasAny || selectedCount == 0) &&
              !controller.isSearching.value)
            _buildEmptyState(selectedType)
          else
            for (final type in visibleTypes) ...[
              if (type == 'products')
                ..._buildProductsGroup(context, isSearchMode),
              if (type == 'categories') ..._buildCategoriesGroup(context),
              if (type == 'blog') ..._buildBlogsGroup(context),
            ],

          // ── PAGINATION LOADER (products) ──
          if (controller.searchesProducts &&
              (selectedType == 'all' || selectedType == 'products'))
            Builder(builder: (_) {
              if (controller.isFetchingMore.value) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CupertinoActivityIndicator(radius: 14)),
                );
              }
              if (controller.paginationError.value.isNotEmpty) {
                return TextButton(
                  onPressed: controller.loadNextPage,
                  child: const Text('Could not load more products. Retry'),
                );
              }
              if (!controller.hasNextPage &&
                  controller.searchProduct.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text("No more products",
                        style: TextStyle(color: colorScheme.onSurfaceVariant)),
                  ),
                );
              }
              return const SizedBox(height: 40);
            }),
        ],
      ),
    );
  }

  Widget _buildResultTabs() {
    final names = {
      'all': 'All (${controller.totalResultCount})',
      'products': 'Products (${controller.searchProduct.length})',
      'categories': 'Categories (${controller.searchCategories.length})',
      'blog': 'Blogs (${controller.searchBlogs.length})',
    };
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: controller.visibleResultTypes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type = controller.visibleResultTypes[index];
          final selected = controller.selectedResultType.value == type;
          return ChoiceChip(
            label: Text(names[type] ?? type),
            selected: selected,
            onSelected: (_) => controller.selectResultType(type),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState([String selectedType = 'all']) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded,
                size: 80, color: colorScheme.outline.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
                selectedType == 'all'
                    ? "No results found"
                    : "No ${selectedType == 'blog' ? 'blogs' : selectedType} found",
                style: textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Try searching with a different keyword.",
                style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _groupTitle(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Text(text,
            style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
      );

  // ── Products ──
  List<Widget> _buildProductsGroup(BuildContext context, bool isSearchMode) {
    if (controller.searchProduct.isEmpty) return const [];
    return [
      _groupTitle(isSearchMode ? "Products" : "Discover Products"),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
              final rawProductId = product['product_id'];
              final productId = (product['_id'] ??
                          product['id'] ??
                          (rawProductId is Map
                              ? rawProductId['_id'] ?? rawProductId['id']
                              : rawProductId))
                      ?.toString() ??
                  '';
              final productName = product['name']?.toString() ?? '';
              if (productId.isNotEmpty) {
                controller.saveRecentSearch(
                    id: productId, name: productName, type: 'product');
                Get.toNamed(Routes.PRODUCTDETAILS,
                    arguments: {'productId': productId});
              }
            },
          );
        },
      ),
    ];
  }

  // ── Categories ──
  List<Widget> _buildCategoriesGroup(BuildContext context) {
    if (controller.searchCategories.isEmpty) return const [];
    return [
      _groupTitle("Categories"),
      SizedBox(
        height: 104,
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
                    type: 'category');
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
                            color: colorScheme.outline.withValues(alpha: 0.15)),
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
                                  size: 66,
                                ),
                              )
                            : const AppImagePlaceholder.circular(
                                size: 66,
                              ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ];
  }

  // ── Blogs ──
  List<Widget> _buildBlogsGroup(BuildContext context) {
    if (controller.searchBlogs.isEmpty) return const [];
    return [
      _groupTitle("Blogs"),
      ...controller.searchBlogs.map((blog) => _blogTile(blog)),
    ];
  }

  Widget _blogTile(BlogModel blog) {
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
                  Text(blog.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(blog.cleanExcerpt,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ],
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
