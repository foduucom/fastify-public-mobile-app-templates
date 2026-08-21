import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:foduu_ecommerce/app/modules/product/views/product_view.dart';
import 'package:foduu_ecommerce/app/modules/shop/bindings/shop_binding.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_view.dart';
import '../../../../components/studio_widget/studio_search_bar_rounded.dart';
import '../../../../components/studio_widget/studio_products.dart';
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
        elevation: 0,
        titleSpacing: 0,
        toolbarHeight: 64,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: SearchBarRounded(
            SearchsController: controller.searchTextController,
            onChanged: (value) {
              controller.getSearchSuggestion(text: value);
            },
            searchHintText: 'Search products, categories...',
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => HelperFunctions().closeKeyboard(context),
        child: Obx(() {
          final isSearchMode =
              controller.searchTextController.text.trim().isNotEmpty;

          // ── Browse mode: CMS-authored layout, when the backend has one ──
          if (!isSearchMode && controller.widgetList.isNotEmpty) {
            return FoduuStudioLayoutView(
              onRefresh: () =>
                  controller.fetchLayout(SearchsController.pageSlug),
              widgetList: controller.widgetList,
              isLoading: controller.isLayoutLoading,
            );
          }

          // ── Initial loading state (default product browse / search) ──
          if (controller.isSearching.value &&
              controller.searchProduct.isEmpty) {
            return _buildGridShimmer(colorScheme);
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (isSearchMode) {
                controller.getSearchSuggestion(
                    text: controller.searchTextController.text);
              } else {
                controller.loadAllProducts();
              }
            },
            child: SingleChildScrollView(
              controller: controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── RECENT SEARCHES (CHIPS) ──
                  if (!isSearchMode && controller.recentSearchList.isNotEmpty)
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

                  // ── SECTION TITLE ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Text(
                      isSearchMode ? "Search Results" : "Discover Products",
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),

                  // ── EMPTY STATE ──
                  if (!controller.isSearching.value &&
                      controller.searchProduct.isEmpty)
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
                            Text("No products found",
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

                  // ── PRODUCT GRID ──
                  if (controller.searchProduct.isNotEmpty)
                    TrendingProductSection(
                      externalProducts: controller.searchProduct,
                      externalHasMore: controller.hasNextPage,
                      externalIsLoadingMore: controller.isFetchingMore.value,
                      onLoadMore: controller.loadNextPage,
                      hideHeader: true,
                      onProductTap: (product) {
                        final productId = product['_id']?.toString() ?? '';
                        final productName =
                            product['name']?.toString() ?? '';
                        if (productId.isNotEmpty) {
                          controller.saveRecentSearch(
                              id: productId,
                              name: productName,
                              type: 'product');
                          Get.to(() => ProductView(),
                              binding: ShopBinding(),
                              arguments: {'productId': productId});
                        }
                      },
                      contentJson: const {
                        'view': 'grid',
                        'layout': 'standard',
                        'columns': '2',
                      },
                    ),

                  // ── PAGINATION LOADER ──
                  if (controller.isFetchingMore.value)
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
        }),
      ),
    );
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
