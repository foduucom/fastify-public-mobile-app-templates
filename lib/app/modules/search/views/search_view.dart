import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_fastify_template/app/modules/search/views/filter_view.dart';
import 'package:shimmer/shimmer.dart';
import '/app/modules/product/views/product_view.dart';
import '/app/modules/shop/bindings/shop_binding.dart';
import '/app/routes/app_pages.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';
import '/core/foduuStudio/foduu_studio_layout_view.dart';
import 'package:new_fastify_template/components/studio_widget/studio_products.dart';
import 'package:new_fastify_template/models/blog_model.dart';
import '../controllers/search_controller.dart';

class SearchView extends GetView<SearchsController> {
  const SearchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => HelperFunctions().closeKeyboard(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        // ── AppBar ──────────────────────────────────────────────────
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back,
                    color: colorScheme.onSurface, size: 20),
              ),
            ),
          ),
          centerTitle: true,
          title: Text(
            'Search',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Search Bar — respects CMS searchPlaceholder ──────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Icon(Icons.search,
                        color: colorScheme.onSurfaceVariant, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Obx(
                        () => TextField(
                          controller: controller.searchTextController,
                          onChanged: (v) => controller.onSearchChanged(v),
                          style: textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: controller.searchPlaceholder,
                            hintStyle: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                            filled: true,
                            fillColor: Colors.transparent,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: controller.searchTextController,
                      builder: (_, __) {
                        return controller.searchTextController.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  controller.searchTextController.clear();
                                  controller.onSearchChanged('');
                                  HelperFunctions().closeKeyboard(context);
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  child: Icon(Icons.cancel_outlined,
                                      size: 18,
                                      color: colorScheme.onSurfaceVariant),
                                ),
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                    Container(
                      width: 1,
                      height: 22,
                      color: colorScheme.outline,
                    ),
                    GestureDetector(
                      onTap: () async {
                        final filter = await showFilterBottomSheet(
                          context,
                          controller.currentFilter,
                        );
                        if (filter != null) {
                          controller.applyFilter(filter);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        child: Icon(Icons.tune_rounded,
                            color: colorScheme.onSurface, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Popular Brands ───────────────────────────────────────
            _buildBrandsSection(context),

            // ── Recent Searches ──────────────────────────────────────
            Obx(() => _buildRecentSearches(context)),

            const SizedBox(height: 8),

            // ── Body: CMS dynamic layout in browse mode; search results otherwise ──
            Expanded(
              child: Obx(() {
                final isSearchMode =
                    controller.queryText.value.trim().isNotEmpty ||
                        controller.selectedBrandSlug.value.isNotEmpty ||
                        controller.activeFilter.value.hasActiveFilters;

                // When user is not searching and CMS allocated widgets, render CMS layout
                if (!isSearchMode && controller.widgetList.isNotEmpty) {
                  return FoduuStudioLayoutView(
                    onRefresh: () =>
                        controller.fetchLayout(SearchsController.pageSlug),
                    widgetList: controller.widgetList,
                    isLoading: controller.isLayoutLoading,
                  );
                }

                // Shimmer during layout loading
                if (!isSearchMode &&
                    controller.widgetList.isEmpty &&
                    controller.isLayoutLoading.value) {
                  return _buildShimmer(context);
                }

                // If CMS has 0 widgets allocated and not searching, show clean empty state (Image 2)
                if (!isSearchMode && controller.widgetList.isEmpty) {
                  return const SizedBox.shrink();
                }

                // Shimmer during active search
                if (controller.isSearching.value &&
                    controller.searchProduct.isEmpty &&
                    controller.searchCategories.isEmpty &&
                    controller.searchBlogs.isEmpty) {
                  return _buildShimmer(context);
                }

                // Results grouped strictly by backend CMS resultOrder
                return _buildResults(context, isSearchMode);
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Popular Brands Section ──────────────────────────────────────────────
  Widget _buildBrandsSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      if (controller.brands.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: controller.brands.take(8).map((brand) {
              final name = brand['name']?.toString() ?? '';
              final slug = brand['slug']?.toString() ?? '';
              final isSelected = controller.selectedBrandSlug.value == slug;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    if (isSelected) {
                      controller.fetchProductsByBrand('');
                    } else {
                      controller.fetchProductsByBrand(slug);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      name,
                      style: textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  // ── Recent Searches ─────────────────────────────────────────────────────
  Widget _buildRecentSearches(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (controller.queryText.value.isNotEmpty ||
        controller.recentSearchList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Searches',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  )),
              GestureDetector(
                onTap: () {
                  controller.recentSearchList.clear();
                  controller.box.remove('recentSearch');
                },
                child: Text('Clear All',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.recentSearchList.take(6).map((item) {
              final name = item['name']?.toString() ?? '';
              return GestureDetector(
                onTap: () {
                  controller.searchTextController.text = name;
                  controller.onSearchChanged(name);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(name,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          )),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          controller.recentSearchList.remove(item);
                          controller.box.write('recentSearch',
                              controller.recentSearchList.toList());
                        },
                        child: Icon(Icons.close,
                            size: 14, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Unified Results: groups follow the CMS section order ────────────────
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
          // Other CMS blocks (banner, rich text, ...) above the results if in search mode
          if (isSearchMode)
            ...controller.buildWidgetsExcluding(
                ['search', 'products', 'categories', 'blog']),

          if (!hasAny && !controller.isSearching.value)
            _buildEmptyState(context)
          else
            for (final type in order) ...[
              if (type == 'products')
                ..._buildProductsGroup(context, isSearchMode),
              if (type == 'categories') ..._buildCategoriesGroup(context),
              if (type == 'blog') ..._buildBlogsGroup(context),
            ],

          // Pagination Loader
          if (controller.searchesProducts)
            Obx(() {
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
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant)),
                  ),
                );
              }
              return const SizedBox(height: 40);
            }),
        ],
      ),
    );
  }

  // ── Products Group ──────────────────────────────────────────────────────
  List<Widget> _buildProductsGroup(BuildContext context, bool isSearchMode) {
    if (controller.searchProduct.isEmpty) return const [];
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          isSearchMode ? "Products" : "Discover Products",
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
          return StudioProductCard(
            product: product,
            onTap: () {
              final productId = product['_id']?.toString() ?? '';
              final productName = product['name']?.toString() ?? '';
              if (productId.isNotEmpty) {
                controller.saveRecentSearch(
                    id: productId, name: productName, type: 'product');
                Get.to(
                  () => ProductView(),
                  binding: ShopBinding(),
                  arguments: {'productId': productId},
                );
              }
            },
          );
        },
      ),
    ];
  }

  // ── Categories Group ────────────────────────────────────────────────────
  List<Widget> _buildCategoriesGroup(BuildContext context) {
    if (controller.searchCategories.isEmpty) return const [];
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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
                Get.toNamed(
                  Routes.SHOPPRODUCTLISTVIEW,
                  arguments: {
                    'categoryId': category['_id'],
                    'categorySlug': category['slug'],
                    'name': name,
                    'source': 'category',
                  },
                );
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

  // ── Blogs Group ─────────────────────────────────────────────────────────
  List<Widget> _buildBlogsGroup(BuildContext context) {
    if (controller.searchBlogs.isEmpty) return const [];
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
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

  Widget _buildEmptyState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded,
                size: 80, color: colorScheme.outline.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('No results found',
                style: textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Try searching with a different keyword.',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade600 : Colors.grey.shade100,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(
                  4,
                  (_) => Container(
                      width: 100,
                      height: 36,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30))),
                ),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.62,
                ),
                itemCount: 4,
                itemBuilder: (_, __) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
