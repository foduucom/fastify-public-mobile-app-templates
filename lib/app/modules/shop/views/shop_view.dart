import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';

import '/app/modules/product/views/product_view.dart';
import '/app/modules/shop/bindings/shop_binding.dart';
import '/app/modules/shop/controllers/shop_controller.dart';
import '/components/product_grid_card.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';

class ShopView extends GetView<ShopController> {
  const ShopView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => ShopController());
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        centerTitle: true,
        title: Obx(() => Column(
              children: [
                Text(
                  controller.collectionName.value,
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${controller.totalProducts.value} items",
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            )),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.tune_rounded), // Filter Icon
        //     onPressed: () => _showFilterBottomSheet(context),
        //   ),
        //   const SizedBox(width: 8),
        // ],
      ),
      body: Obx(() {
        return Column(
          children: [
            // ── ACTIVE FILTER CHIPS (Horizontal Scroll) ──
            //if (_hasActiveFilters()) _buildActiveFilterChips(colorScheme),

            // ── PRODUCT GRID ──
            Expanded(
              child: controller.isLoading.value
                  ? _buildGridShimmer()
                  : RefreshIndicator(
                      onRefresh: () =>
                          controller.fetchProducts(isRefresh: true),
                      child: _buildProductGrid(colorScheme, textTheme),
                    ),
            ),
          ],
        );
      }),
    );
  }

  // ── MAIN PRODUCT GRID (REUSED FROM PREVIOUS) ───────────────────────────
  Widget _buildProductGrid(ColorScheme colorScheme, TextTheme textTheme) {
    if (controller.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 80, color: colorScheme.outline.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text("No products match your filters",
                style: textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      controller: controller.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.70,
            ),
            itemCount: controller.products.length,
            itemBuilder: (context, index) {
              final product = controller.products[index];
              return ProductGridCard(
                product: product,
                onTap: () {
                  final productId = product['_id']?.toString() ?? '';
                  if (productId.isNotEmpty) {
                    Get.toNamed(Routes.PRODUCTDETAILS,
                        arguments: {'productId': productId});
                  }
                },
              );
            },
          ),
          if (controller.isFetchingMore.value)
            const Padding(
                padding: EdgeInsets.all(24.0),
                child: CupertinoActivityIndicator(radius: 14)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGridShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.62,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16))),
      ),
    );
  }
}
