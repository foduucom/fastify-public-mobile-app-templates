import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
              // ── HEADER: search bar only when the CMS allots it ──
              Obx(() {
                final showBar = controller.sectionTypes.isEmpty ||
                    controller.sectionTypes.contains('search');
                if (!showBar) return const SizedBox(height: 8);
                return SearchViewHeader(
                  width: width,
                  height: height,
                  searchTextController: controller.searchTextController,
                  hintText: controller.searchPlaceholder,
                  onSearchChanged: controller.onSearchChanged,
                  onCartTap: () => Get.toNamed(Routes.CART),
                  //onMessageTap: () => scaffoldKey.currentState?.openDrawer(),
                  //onNotificationTap: () => Get.toNamed(Routes.NOTIFICATION),
                );
              }),

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

              // ── RECENT SEARCHES ──
              Obx(() => _buildRecentSearches(context)),

              // ── BODY: CMS layout in browse mode, unified results otherwise ──
              Expanded(
                child: Obx(() {
                  final isSearchMode =
                      controller.queryText.value.trim().isNotEmpty ||
                          controller.selectedBrandSlug.value.isNotEmpty ||
                          controller.activeFilter.value.hasActiveFilters;

                  if (!isSearchMode && controller.widgetList.isNotEmpty) {
                    return FoduuStudioLayoutView(
                      onRefresh: () =>
                          controller.fetchLayout(SearchsController.pageSlug),
                      widgetList: controller.widgetList,
                      isLoading: controller.isLayoutLoading,
                      hasError: controller.hasError,
                      errorMessage: controller.errorMessage,
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
              Icon(Icons.history,
                  size: 20, color: colorScheme.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.recentSearchList.take(6).map((item) {
              return ActionChip(
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

    return SingleChildScrollView(
      controller: controller.scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Other CMS blocks (banner, rich text, ...) above the results.
          if (isSearchMode)
            ...controller.buildWidgetsExcluding(
                ['search', 'products', 'categories', 'blog']),

          if (!hasAny && !controller.isSearching.value)
            _buildEmptyState()
          else
            for (final type in order) ...[
              if (type == 'products')
                ..._buildProductsGroup(context, isSearchMode),
              if (type == 'categories') ..._buildCategoriesGroup(context),
              if (type == 'blog') ..._buildBlogsGroup(context),
            ],

          // ── PAGINATION LOADER (products) ──
          if (controller.searchesProducts)
            Builder(builder: (_) {
              if (controller.isFetchingMore.value) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CupertinoActivityIndicator(radius: 14)),
                );
              } else if (!controller.hasNextPage &&
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded,
                size: 80, color: colorScheme.outline.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text("No results found",
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
              final productId = product['_id']?.toString() ?? '';
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
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: HelperFunctions()
                              .getImage(category['featured_image']),
                          errorWidget: (_, __, ___) => Icon(
                              Icons.category_outlined,
                              color: colorScheme.onSurfaceVariant),
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
    final placeholder = Container(
      width: 72,
      height: 72,
      color: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.article_outlined, color: colorScheme.onSurfaceVariant),
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
