import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/components/buttons/appbutton.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import '/app/modules/bottomar/controllers/bottombar_controller.dart';
import '/app/routes/app_pages.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '/app/modules/Profie/orders/controller/orders_controller.dart';

class OrdersView extends GetView<OrdersController> {
  OrdersView({Key? key}) : super(key: key);
  var controllerval = Get.lazyPut(() => OrdersController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('Orders'.tr), elevation: 0.0),
        body: RefreshIndicator(
          onRefresh: () async => controller.onRefresh(),
          child: Obx(
                () => controller.isLoading.isFalse && controller.orderList.isEmpty
                ? const NoOrders()
                : ListView.separated(
              controller: controller.scrollController,
              padding: const EdgeInsets.symmetric(
                  vertical: 16, horizontal: 12),
              itemCount: controller.isLoading.isTrue &&
                  controller.orderList.isEmpty
                  ? 6
                  : controller.orderList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (controller.isLoading.isTrue &&
                    controller.orderList.isEmpty) {
                  return const OrderListShimmer();
                }
                return OrderCard(
                  item: controller.orderList[index],
                  // Pass index to guarantee globally unique hero tags
                  listIndex: index,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Order Card ────────────────────────────────────────────────────────────────

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.item, required this.listIndex});

  final dynamic item;
  final int listIndex;

  // ─── FIXED: Using the correct domain "mywatch.vbought.com" ──────────────────
  String _constructImageUrl(Map imageObj) {
    // 1. Try to build directly from filepath
    final filepath = imageObj['filepath']?.toString() ?? '';
    if (filepath.isNotEmpty) {
      // Ensure we don't have double slashes if filepath starts with '/'
      final cleanPath = filepath.startsWith('/') ? filepath.substring(1) : filepath;
      // ✅ FIXED: Changed to mywatch.vbought.com
      return 'https://mywatch.vbought.com/images/$cleanPath';
    }

    // 2. Fallback to download_url if filepath is missing
    final url = imageObj['download_url']?.toString() ?? '';
    return _fixImageUrl(url);
  }

  String _fixImageUrl(String url) {
    if (url.isEmpty) return '';
    final uri = Uri.tryParse(url);
    if (uri == null) return url;

    // ✅ FIXED: Check and replace with mywatch.vbought.com
    if (uri.host.endsWith('.vbought.com') && uri.host != 'mywatch.vbought.com') {
      return url.replaceFirst(uri.host, 'mywatch.vbought.com');
    }
    return url;
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

      final frontImageId = productObj['front_image']?.toString() ?? '';
      final gallery = productObj['gallery'];

      if (gallery is List && frontImageId.isNotEmpty) {
        final match = gallery.firstWhere(
              (g) => g is Map && (g['_id'] ?? g['id'])?.toString() == frontImageId,
          orElse: () => null,
        );

        if (match != null) {
          return _constructImageUrl(match);
        }
      }

      return '';
    } catch (e) {
      debugPrint('🚨 OrderCard image error: $e');
      return '';
    }
  }

  String _getFirstProductName() {
    try {
      final products = item['products'];
      if (products is! List || products.isEmpty) return 'Order';

      final first = products.first;
      if (first == null || first is! Map) return 'Order';

      // Direct name field on product line item
      final directName = first['name']?.toString();
      if (directName != null && directName.isNotEmpty) return directName;

      // Populated product_id object
      final productObj = first['product_id'];
      if (productObj is Map) {
        return productObj['name']?.toString() ?? 'Order';
      }

      return 'Order';
    } catch (e) {
      return 'Order';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final orderId =
    (item['order_no'] ?? item['_id'] ?? item['id'] ?? '').toString();
    final paymentStatus = (item['payment_status'] ?? 'Pending').toString();
    final currency = (item['currency'] ?? '₹').toString();
    final total = (item['total'] ?? '0').toString();
    final createdAt = item['created_at']?.toString();
    final orderDate = (createdAt != null && createdAt.isNotEmpty)
        ? HelperFunctions().toCarbonToHumanDateFormat(createdAt)
        : '';
    final products = item['products'];
    final productCount = (products is List) ? products.length : 0;

    final imageUrl = _getProductImage();
    final productName = _getFirstProductName();

    debugPrint('🎯 FINAL BUILT IMAGE URL: "$imageUrl"');

    final heroTag = 'orders_list_img_${listIndex}_$orderId';

    return GestureDetector(
      onTap: () => Get.toNamed(
        Routes.ORDER_PRODUCTS,
        arguments: {'order': item}, // pass the full order map
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.outline.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Product Image ──────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (_, error, ___) {
                  debugPrint('🚨 Failed to load image from network: $imageUrl');
                  return _imageFallback(theme);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _imageFallback(theme);
                },
              )
                  : _imageFallback(theme),
            ),
            const SizedBox(width: 12),

            // ── Order Info ─────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // don't take infinite height
                children: [
                  // Product name + item count badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          productName,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (productCount > 1)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.onSurface.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '+${productCount - 1} more',
                            style: textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: theme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  Text(
                    'Order #$orderId',
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.onSurface.withOpacity(0.45),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (orderDate.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      orderDate,
                      style: textTheme.bodySmall?.copyWith(
                        color: theme.onSurface.withOpacity(0.35),
                        fontSize: 11,
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$currency$total',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primary,
                          fontSize: 14,
                        ),
                      ),
                      Flexible(
                        child: _StatusBadge(status: paymentStatus),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.onSurface.withOpacity(0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback(ColorScheme theme) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: theme.onSurface.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.shopping_bag_outlined,
        color: theme.onSurface.withOpacity(0.3),
        size: 28,
      ),
    );
  }
}

// ─── Status Badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'paid':
      case 'completed':
        color = Colors.green;
        break;
      case 'pending':
      case 'unpaid':
      case 'processing':
        color = Colors.orange;
        break;
      case 'cancelled':
      case 'failed':
        color = Colors.red;
        break;
      default:
        color = Theme.of(context).colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              status.tr,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shimmer ───────────────────────────────────────────────────────────────────

class OrderListShimmer extends StatelessWidget {
  const OrderListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ FIXED: Replaced FractionallySizedBox to prevent layout crashes
                  Container(
                    height: 10,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    width: 150,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 10,
                        width: 60,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                      ),
                      Container(
                        height: 10,
                        width: 80,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── No Orders ─────────────────────────────────────────────────────────────────

class NoOrders extends StatelessWidget {
  const NoOrders({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: pageSurroundingPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child:
            Image(image: AssetImage('assets/images/emptyimagecart.png')),
          ),
          const SizedBox(height: 20),
          Text(
            'whoops_no_order_yet'.tr,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 18, color: Colors.black),
          ),
          const SizedBox(height: 10),
          Text(
            'look_like_you_have_no_orders_yet.'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          AppButton(
            keypressEvent: () {
              Get.find<BottombarController>().currentPageIndex.value = 0;
              Get.find<BottombarController>().pageController.jumpToPage(0);
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