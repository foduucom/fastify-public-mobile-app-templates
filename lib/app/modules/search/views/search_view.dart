import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:foduu_ecommerce/app/modules/product/views/product_view.dart';
import 'package:foduu_ecommerce/app/modules/shop/bindings/shop_binding.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_view.dart';
import '../../../../components/studio_widget/studio_search_bar_rounded.dart';
import '../../../../components/studio_widget/studio_products.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';

import '../controllers/search_controller.dart';

class SearchView extends GetView<SearchsController> {
  const SearchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => HelperFunctions().closeKeyboard(context),
        child: Obx(() {
          final isSearchMode = controller.queryText.value.trim().isNotEmpty;

          return Column(
            children: [
              if (controller.sectionTypes.contains('search'))
                _SearchBar(controller: controller),
              Expanded(
                child: _buildBody(context, colorScheme, textTheme, isSearchMode),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ColorScheme colorScheme,
      TextTheme textTheme, bool isSearchMode) {
    // ── Browse mode: CMS-authored layout, when the backend has one ──
    if (!isSearchMode && controller.widgetList.isNotEmpty) {
      return FoduuStudioLayoutView(
        onRefresh: () => controller.fetchLayout(SearchsController.pageSlug),
        widgetList: controller.widgetList,
        isLoading: controller.isLayoutLoading,
      );
    }

    // ── Browse mode, backend/CMS gave nothing: show nothing ──
    if (!isSearchMode &&
        controller.widgetList.isEmpty &&
        !controller.isLayoutLoading.value) {
      return const SizedBox.shrink();
    }

    // ── Initial loading state (search) ──
    if (controller.isSearching.value &&
        controller.searchProduct.isEmpty &&
        controller.searchCategories.isEmpty &&
        controller.searchBlogs.isEmpty) {
      return _buildGridShimmer(colorScheme);
    }

    return RefreshIndicator(
      onRefresh: () async {
        controller.getSearchSuggestion(
            text: controller.searchTextController.text);
      },
      child: SingleChildScrollView(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // ── CMS FREE-WILL SECTIONS (banner, rich_text, etc.) ──
              ...controller.buildWidgetsExcluding(['search', 'products']),

              // ── RECENT SEARCHES (CHIPS) ──
              if (controller.recentSearchList.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Recent Searches",
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Icon(Icons.history,
                                  size: 20,
                                  color: colorScheme.onSurfaceVariant),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                controller.recentSearchList.take(6).map((item) {
                              return ActionChip(
                                label: Text(item['name']?.toString() ?? ''),
                                backgroundColor: colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.4),
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                labelStyle: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w500),
                                onPressed: () {
                                  controller.searchTextController.text =
                                      item['name']?.toString() ?? '';
                                  controller.getSearchSuggestion(
                                      text:
                                          controller.searchTextController.text);
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                  // ── EMPTY STATE ──
                  if (!controller.isSearching.value &&
                      controller.searchProduct.isEmpty &&
                      controller.searchCategories.isEmpty &&
                      controller.searchBlogs.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Column(
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 80,
                                color:
                                    colorScheme.outline.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            Text("No results found",
                                style: textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text("Try searching with a different keyword.",
                                style: TextStyle(
                                    color: colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ),

                  // ── RESULT GROUPS, in the order the CMS lays them out ──
                  for (final type in controller.resultOrder) ...[
                    if (type == 'products')
                      ..._buildProductsGroup(textTheme, colorScheme),
                    if (type == 'categories')
                      ..._buildCategoriesGroup(textTheme, colorScheme),
                    if (type == 'blog')
                      ..._buildBlogsGroup(textTheme, colorScheme),
                  ],

                  // ── PAGINATION LOADER ──
                  if (!controller.searchesProducts)
                    const SizedBox(height: 40)
                  else if (controller.isFetchingMore.value)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CupertinoActivityIndicator(radius: 14),
                      ),
                    )
                  else if (!controller.hasNextPage &&
                      controller.searchProduct.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text("No more products",
                            style:
                                TextStyle(color: colorScheme.onSurfaceVariant)),
                      ),
                    )
                  else
                    const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }



  Widget _groupTitle(String text, TextTheme textTheme, ColorScheme cs) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Text(text,
            style: textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface)),
      );

  // ── Products ──
  List<Widget> _buildProductsGroup(TextTheme textTheme, ColorScheme cs) {
    if (controller.searchProduct.isEmpty) return const [];
    final isSearchMode = controller.queryText.value.trim().isNotEmpty;
    return [
      _groupTitle(
          isSearchMode ? "Products" : "Discover Products", textTheme, cs),
      TrendingProductSection(
        externalProducts: controller.searchProduct,
        externalHasMore: controller.hasNextPage,
        externalIsLoadingMore: controller.isFetchingMore.value,
        onLoadMore: controller.loadNextPage,
        hideHeader: true,
        onProductTap: (product) {
          final productId = product['_id']?.toString() ?? '';
          final productName = product['name']?.toString() ?? '';
          if (productId.isNotEmpty) {
            controller.saveRecentSearch(
                id: productId, name: productName, type: 'product');
            Get.to(() => ProductView(),
                binding: ShopBinding(), arguments: {'productId': productId});
          }
        },
        contentJson: const {
          'view': 'grid',
          'layout': 'standard',
          'columns': '2',
        },
      ),
    ];
  }

  // ── Categories ──
  List<Widget> _buildCategoriesGroup(TextTheme textTheme, ColorScheme cs) {
    if (controller.searchCategories.isEmpty) return const [];
    return [
      _groupTitle("Categories", textTheme, cs),
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
                final rawChildren = category['children'];
                final children = rawChildren is List ? rawChildren : [];
                Get.toNamed(Routes.SHOPPRODUCTLISTVIEW, arguments: {
                  'source': 'category',
                  if (children.isNotEmpty) 'categoryId': category['_id'],
                  if (children.isEmpty) 'productId': category['_id'],
                  'categorySlug': category['slug'],
                  'name': name,
                  if (children.isNotEmpty) 'children': children,
                });
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
                        color: cs.surfaceContainerHighest,
                        border: Border.all(
                            color: cs.outline.withValues(alpha: 0.15)),
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: HelperFunctions()
                              .getImage(category['featured_image']),
                          errorWidget: (_, __, ___) => Icon(
                              Icons.category_outlined,
                              color: cs.onSurfaceVariant),
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
  List<Widget> _buildBlogsGroup(TextTheme textTheme, ColorScheme cs) {
    if (controller.searchBlogs.isEmpty) return const [];
    return [
      _groupTitle("Blogs", textTheme, cs),
      ...controller.searchBlogs.map((blog) {
        final title = (blog['name'] ?? blog['title'] ?? '').toString();
        final excerpt = (blog['excerpt'] ?? '')
            .toString()
            .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
        final placeholder = Container(
          width: 72,
          height: 72,
          color: cs.surfaceContainerHighest,
          child: Icon(Icons.article_outlined, color: cs.onSurfaceVariant),
        );
        return InkWell(
          onTap: () {
            final blogId = blog['_id'] ?? blog['id'];
            if (blogId == null) return;
            controller.saveRecentSearch(
                id: blogId.toString(), name: title, type: 'blog');
            Get.toNamed(Routes.BLOG_DETAILS, arguments: {'id': blogId});
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl:
                        HelperFunctions().getImage(blog['featured_image']),
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => placeholder,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      if (excerpt.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(excerpt,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    ];
  }

  // ── Grid Shimmer Loading Effect ──
  Widget _buildGridShimmer(ColorScheme colorScheme) {
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surface,
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
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

// ─── Search Bar ─────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final SearchsController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: SearchBarRounded(
        searchHintText: controller.searchPlaceholder,
        SearchsController: controller.searchTextController,
        onChanged: (value) {
          controller.onSearchChanged(value);
        },
      ),
    );
  }
}
