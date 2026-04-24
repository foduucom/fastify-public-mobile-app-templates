import 'package:flutter/material.dart';
import '../../../../../components/app_bar.dart';
import '../../../../../components/buttons/appbutton.dart';
import '../../../../../constants/constants.dart';
import '/app/modules/bottomar/controllers/bottombar_controller.dart';
import '/app/routes/app_pages.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '/app/modules/Profie/orders/controller/orders_controller.dart';
import '../../../../../components/app_back_button.dart';

class OrdersView extends GetView<OrdersController> {
  OrdersView({Key? key}) : super(key: key);

  @override
  OrdersController get controller {
    if (!Get.isRegistered<OrdersController>()) {
      Get.put(OrdersController());
    }
    return Get.find<OrdersController>();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ── AppBar ──────────────────────────────────────────────────────
      appBar:  CustomAppBar(title: ' MY Order'),

      body: Column(
        children: [
          const SizedBox(height: 16),

          // ── Tab Toggle ─────────────────────────────────────────────
          Obx(() => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  _TabButton(
                    label: 'My Order',
                    isActive: controller.selectedTab.value == 0,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    onTap: () => controller.selectedTab.value = 0,
                  ),
                  _TabButton(
                    label: 'History',
                    isActive: controller.selectedTab.value == 1,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    onTap: () => controller.selectedTab.value = 1,
                  ),
                ],
              ),
            ),
          )),

          const SizedBox(height: 16),

          // ── Order List ─────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              color: colorScheme.primary,
              onRefresh: () async => controller.onRefresh(),
              child: Obx(() =>
              controller.isLoading.isFalse &&
                  controller.orderList.isEmpty
                  ? const NoOrders()
                  : ListView.separated(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                itemCount: controller.isLoading.isTrue &&
                    controller.orderList.isEmpty
                    ? 4
                    : controller.orderList.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  if (controller.isLoading.isTrue &&
                      controller.orderList.isEmpty) {
                    return const OrderListShimmer();
                  }
                  return OrderCard(
                    item: controller.orderList[index],
                    listIndex: index,
                  );
                },
              )),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab Button ────────────────────────────────────────────────────────────────
class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              fontWeight:
              isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Order Card ────────────────────────────────────────────────────────────────
class OrderCard extends StatelessWidget {
  const OrderCard(
      {super.key, required this.item, required this.listIndex});

  final dynamic item;
  final int listIndex;

  String _constructImageUrl(Map imageObj) {
    final filepath = imageObj['filepath']?.toString() ?? '';
    if (filepath.isNotEmpty) {
      final cleanPath =
          filepath.startsWith('/') ? filepath.substring(1) : filepath;
      return '$imageBase$cleanPath';
    }
    return '';
  }

  String _getProductImage() {
    try {
      final products = item['products'];
      if (products is! List || products.isEmpty) return '';
      final first = products.first;
      if (first == null || first is! Map) return '';
      final productObj = first['product_id'];
      if (productObj == null || productObj is! Map) return '';
      final fi = productObj['featured_image'];
      if (fi is Map) {
        final url = _constructImageUrl(fi);
        if (url.isNotEmpty) return url;
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  String _getFirstProductName() {
    try {
      final products = item['products'];
      if (products is! List || products.isEmpty) return 'Order';
      final first = products.first;
      if (first == null || first is! Map) return 'Order';
      final directName = first['name']?.toString();
      if (directName != null && directName.isNotEmpty) return directName;
      final productObj = first['product_id'];
      if (productObj is Map) {
        return productObj['name']?.toString() ?? 'Order';
      }
      return 'Order';
    } catch (_) {
      return 'Order';
    }
  }

  String _getDiscount() {
    try {
      final products = item['products'];
      if (products is! List || products.isEmpty) return '';
      final first = products.first;
      final productObj = first is Map ? first['product_id'] : null;
      if (productObj is! Map) return '';
      final price = double.tryParse(
          productObj['price']?.toString() ?? '') ??
          0;
      final salePrice = double.tryParse(
          productObj['sale_price']?.toString() ?? '') ??
          0;
      if (price > 0 && salePrice > 0 && price > salePrice) {
        final pct = ((price - salePrice) / price * 100).round();
        return '$pct%';
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    final paymentStatus =
    (item['payment_status'] ?? 'Pending').toString();
    final currency  = (item['currency'] ?? '\$').toString();
    final total     = (item['total'] ?? '0').toString();
    final createdAt = item['created_at']?.toString();
    final orderDate = (createdAt != null && createdAt.isNotEmpty)
        ? HelperFunctions().toCarbonToHumanDateFormat(createdAt)
        : '';
    final products     = item['products'];
    final productCount = (products is List) ? products.length : 0;
    final imageUrl     = _getProductImage();
    final productName  = _getFirstProductName();
    final discount     = _getDiscount();

    // sale price for display
    String salePrice = '';
    try {
      final p = products is List && products.isNotEmpty
          ? products.first['product_id']
          : null;
      if (p is Map) {
        salePrice = p['sale_price']?.toString() ?? '';
      }
    } catch (_) {}

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.ORDER_PRODUCTS,
          arguments: {'order': item}),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Date + Status Row ───────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  orderDate,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                _StatusBadge(status: paymentStatus),
              ],
            ),

            const SizedBox(height: 6),

            // ── Product Row ─────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Image + discount badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _imageFallback(colorScheme),
                      )
                          : _imageFallback(colorScheme),
                    ),
                    if (discount.isNotEmpty)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            discount,
                            style: TextStyle(
                              color: colorScheme.onError,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 14),

                // Info column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (productCount > 0)
                        Text(
                          'For ${productCount}Kg',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            '$currency$total',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          if (salePrice.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              '$currency$salePrice',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.error,
                                decoration: TextDecoration.lineThrough,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Action Buttons ──────────────────────────────────────
            Row(
              children: [
                // Detail — outline
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.toNamed(
                        Routes.ORDER_PRODUCTS,
                        arguments: {'order': item}),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurface,
                      side:
                      BorderSide(color: colorScheme.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                      const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Detail',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Tracking — filled green
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                      const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Tracking',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback(ColorScheme scheme) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: scheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.shopping_bag_outlined,
          color: scheme.onSurface.withValues(alpha: 0.3), size: 28),
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Color color;
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'paid':
      case 'completed':
      case 'towards you':
        color = colorScheme.primary;
        break;
      case 'pending':
      case 'unpaid':
      case 'processing':
      case 'on process':
        color = colorScheme.secondary;
        break;
      case 'cancelled':
      case 'failed':
        color = colorScheme.error;
        break;
      default:
        color = colorScheme.onSurfaceVariant;
    }

    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Shimmer ───────────────────────────────────────────────────────────────────
class OrderListShimmer extends StatelessWidget {
  const OrderListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade600 : Colors.grey.shade100,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _shimmerBox(100, 12),
                _shimmerBox(80, 28),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _shimmerBox(90, 90, radius: 10),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(double.infinity, 14),
                      const SizedBox(height: 8),
                      _shimmerBox(80, 12),
                      const SizedBox(height: 10),
                      _shimmerBox(100, 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _shimmerBox(double.infinity, 44, radius: 30)),
                const SizedBox(width: 12),
                Expanded(child: _shimmerBox(double.infinity, 44, radius: 30)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(double w, double h, {double radius = 6}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

}

// ── No Orders ─────────────────────────────────────────────────────────────────
class NoOrders extends StatelessWidget {
  const NoOrders({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: pageSurroundingPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Image(
                image:
                AssetImage('assets/images/emptyimagecart.png')),
          ),
          const SizedBox(height: 20),
          Text(
            'whoops_no_order_yet'.tr,
            style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            'look_like_you_have_no_orders_yet.'.tr,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          AppButton(
            keypressEvent: () {
              Get.find<BottombarController>()
                  .currentPageIndex
                  .value = 0;
              Get.find<BottombarController>()
                  .pageController
                  .jumpToPage(0);
              Get.back();
              Get.back();
            },
            itemText: 'start Shopping'.tr,
          ),
        ],
      ),
    );
  }
}