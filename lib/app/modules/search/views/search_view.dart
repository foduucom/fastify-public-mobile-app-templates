import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '/app/modules/product/views/product_view.dart';
import '/app/modules/shop/bindings/shop_binding.dart';
import '/app/routes/app_pages.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';
import '/constants/product_helper.dart';
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
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.more_vert,
                    color: colorScheme.onSurface, size: 22),
              ),
            ),
          ],
        ),

        // ✅ Body is NOT wrapped in Obx — only individual sections are
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Search Bar — stable, never in Obx ─────────────────────
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
                      child: TextField(
                        controller: controller.searchTextController,
                        onChanged: (v) =>
                            controller.getSearchSuggestion(text: v),
                        style: textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),

                          // ✅ these 3 lines make TextField fully transparent
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
                    AnimatedBuilder(
                      animation: controller.searchTextController,
                      builder: (_, __) {
                        return controller.searchTextController.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  controller.searchTextController.clear();
                                  controller.getSearchSuggestion(text: '');
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
                      onTap: () {},
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

            const SizedBox(height: 16),

            // ✅ Expanded gives bounded height to scrollable content
            Expanded(
              child: Obx(() {
                if (controller.isSearching.value &&
                    controller.searchProduct.isEmpty) {
                  return _buildShimmer(context);
                }

                return SingleChildScrollView(
                  controller: controller.scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Recent Searches ──────────────────────────────
                      if (controller.recentSearchList.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Last Search',
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                        fontSize: 17,
                                      )),
                                  GestureDetector(
                                    onTap: () {
                                      controller.recentSearchList.clear();
                                      controller.box.remove('recentSearch');
                                    },
                                    child: Text('Clear All',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        )),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: controller.recentSearchList
                                    .take(8)
                                    .map((item) {
                                  final name = item['name']?.toString() ?? '';
                                  return GestureDetector(
                                    onTap: () {
                                      controller.searchTextController.text =
                                          name;
                                      controller.getSearchSuggestion(
                                          text: name);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: colorScheme.surface,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                            color: colorScheme.outline),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(name,
                                              style: textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                                fontWeight: FontWeight.w500,
                                              )),
                                          const SizedBox(width: 6),
                                          GestureDetector(
                                            onTap: () {
                                              controller.recentSearchList
                                                  .remove(item);
                                              controller.box.write(
                                                  'recentSearch',
                                                  controller.recentSearchList
                                                      .toList());
                                            },
                                            child: Icon(Icons.close,
                                                size: 14,
                                                color: colorScheme
                                                    .onSurfaceVariant),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 28),
                            ],
                          ),
                        ),

                      // ── Search Results ───────────────────────────────
                      if (controller.searchProduct.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                controller.searchTextController.text
                                        .trim()
                                        .isEmpty
                                    ? 'Last seen'
                                    : 'Search Results',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                  fontSize: 17,
                                ),
                              ),
                              Text('See All',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.68,
                          ),
                          itemCount: controller.searchProduct.length,
                          itemBuilder: (context, index) {
                            final product = controller.searchProduct[index]
                                as Map<String, dynamic>;
                            return _ProductCard(
                              product: product,
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                              onTap: () {
                                final productId =
                                    product['_id']?.toString() ?? '';
                                final productName =
                                    product['name']?.toString() ?? '';
                                if (productId.isNotEmpty) {
                                  controller.saveRecentSearch(
                                      id: productId,
                                      name: productName,
                                      type: 'product');
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
                        const SizedBox(height: 28),
                      ],

                      // ── Best Store ───────────────────────────────────
                      if (controller.searchProduct.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Best Store',
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                        fontSize: 17,
                                      )),
                                  GestureDetector(
                                    onTap: () => Get.toNamed(Routes.EXPLORE),
                                    child: Text('See All',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        )),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              ..._dummyStores.map((store) => _StoreTile(
                                    store: store,
                                    textTheme: textTheme,
                                    colorScheme: colorScheme,
                                  )),
                            ],
                          ),
                        ),

                      // ── Empty State ──────────────────────────────────
                      if (!controller.isSearching.value &&
                          controller.searchProduct.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: Column(
                              children: [
                                Icon(Icons.search_off_rounded,
                                    size: 80, color: colorScheme.outline),
                                const SizedBox(height: 16),
                                Text('No products found',
                                    style: textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text(
                                  'Try searching with a different keyword.',
                                  style: TextStyle(
                                      color: colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ),

                      if (controller.isFetchingMore.value)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                              child: CupertinoActivityIndicator(radius: 14)),
                        )
                      else
                        const SizedBox(height: 32),
                    ],
                  ),
                );
              }),
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
                childAspectRatio: 0.68,
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
    );
  }

  static final _dummyStores = [
    {
      'name': 'The Store Pantry',
      'time': '19 mins',
      'distance': '0.6 km',
      'rating': '4.4',
      'promo': true,
      'image':
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200',
    },
    {
      'name': 'Farm to Feast Store',
      'time': '15 mins',
      'distance': '0.6 km',
      'rating': '4.4',
      'promo': true,
      'image':
          'https://images.unsplash.com/photo-1588347818481-1e4bb5a52f21?w=200',
    },
  ];
}

// ── Product Card ──────────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final priceInfo = ProductHelper.calculatePriceInfo(product);
    final imageUrl = ProductHelper.getProductImage(product);
    final name = ProductHelper.getProductName(product);

    final displayPrice =
        double.tryParse(priceInfo['productPrice']?.toString() ?? '0') ?? 0.0;
    final originalPrice =
        double.tryParse(priceInfo['salePrice']?.toString() ?? '0') ?? 0.0;
    final hasDiscount = originalPrice > 0 && originalPrice > displayPrice;
    final discountPct = hasDiscount
        ? ((originalPrice - displayPrice) / originalPrice * 100).round()
        : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 11,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(15)),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                  color: colorScheme.surfaceContainerHighest),
                              errorWidget: (_, __, ___) => Container(
                                color: colorScheme.surfaceContainerHighest,
                                child: Icon(Icons.image_not_supported_outlined,
                                    color: colorScheme.onSurfaceVariant),
                              ),
                            )
                          : Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: Icon(Icons.image_not_supported_outlined,
                                  color: colorScheme.onSurfaceVariant),
                            ),
                    ),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$discountPct%',
                          style: TextStyle(
                              color: colorScheme.onError,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            fontSize: 13,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Text(
                    //   'For 1Kg',
                    //   style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    //       color: colorScheme.onSurfaceVariant, fontSize: 11),
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${displayPrice.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                    fontSize: 13,
                                  ),
                            ),
                            if (hasDiscount)
                              Text(
                                '₹${originalPrice.toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      color: colorScheme.error,
                                      decorationColor: colorScheme.error,
                                      fontSize: 11,
                                    ),
                              ),
                          ],
                        ),
                        GestureDetector(
                          onTap: onTap,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.add,
                                color: Theme.of(context).colorScheme.primary,
                                size: 18),
                          ),
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

// ── Store Tile ────────────────────────────────────────────────────────────────
class _StoreTile extends StatelessWidget {
  final Map<String, dynamic> store;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _StoreTile({
    required this.store,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: store['image'] as String? ?? '',
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 64,
                height: 64,
                color: colorScheme.surfaceContainerHighest,
                child: Icon(Icons.store, color: colorScheme.onSurfaceVariant),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (store['promo'] == true)
                  Text(
                    'PROMO',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  store['name'] as String? ?? '',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(store['time'] as String? ?? '',
                        style: textTheme.bodySmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant)),
                    const SizedBox(width: 10),
                    Text(store['distance'] as String? ?? '',
                        style: textTheme.bodySmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant)),
                    const SizedBox(width: 10),
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 3),
                    Text(store['rating'] as String? ?? '',
                        style: textTheme.bodySmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right,
              color: colorScheme.onSurfaceVariant, size: 22),
        ],
      ),
    );
  }
}

// ── Product Card, Store Tile unchanged below ──────────────────────────────────
// ... (keep your existing _ProductCard and _StoreTile as-is)
