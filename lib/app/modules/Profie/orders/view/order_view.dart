import 'package:cached_network_image/cached_network_image.dart';
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
    final height = Get.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: Text(
            'Orders'.tr,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: height * 0.025,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async => controller.onRefresh(),
          child: Obx(
            () => controller.isLoading.isFalse && controller.orderList.isEmpty
                ? const NoOrders()
                : ListView.separated(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 14),
                    itemCount: controller.isLoading.isTrue &&
                            controller.orderList.isEmpty
                        ? 6
                        : controller.orderList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
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

  String _constructImageUrl(Map imageObj) {
    final filepath = imageObj['filepath']?.toString() ?? '';
    if (filepath.isNotEmpty) {
      final cleanPath =
          filepath.startsWith('/') ? filepath.substring(1) : filepath;
      return 'https://mywatch.vbought.com/images/$cleanPath';
    }
    final url = imageObj['download_url']?.toString() ?? '';
    return _fixImageUrl(url);
  }

  String _fixImageUrl(String url) {
    if (url.isEmpty) return '';
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    if (uri.host.endsWith('.vbought.com') &&
        uri.host != 'mywatch.vbought.com') {
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
        if (match != null) return _constructImageUrl(match);
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

      final directName = first['name']?.toString();
      if (directName != null && directName.isNotEmpty) return directName;

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

    return GestureDetector(
      onTap: () => Get.toNamed(
        Routes.ORDER_PRODUCTS,
        arguments: {'order': item},
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.outline.withOpacity(0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Product Image ──────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 68,
                height: 68,
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 68,
                        height: 68,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _imageFallback(theme),
                        errorWidget: (_, __, ___) => _imageFallback(theme),
                      )
                    : _imageFallback(theme),
              ),
            ),
            const SizedBox(width: 12),

            // ── Order Info ─────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          productName,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            fontFamily: 'lato',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (productCount > 1)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '+${productCount - 1} more',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: theme.primary,
                              fontFamily: 'lato',
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Order #$orderId',
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.onSurface.withValues(alpha: 0.4),
                      fontSize: 11,
                      fontFamily: 'lato',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (orderDate.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      orderDate,
                      style: textTheme.bodySmall?.copyWith(
                        color: theme.onSurface.withValues(alpha: 0.35),
                        fontSize: 11,
                        fontFamily: 'lato',
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$currency$total',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: theme.primary,
                          fontSize: 14,
                          fontFamily: 'lato',
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

            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.onSurface.withValues(alpha: 0.3),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback(ColorScheme theme) {
    return Container(
      width: 68,
      height: 68,
      color: theme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Icon(
        Icons.shopping_bag_outlined,
        color: theme.onSurface.withValues(alpha: 0.3),
        size: 26,
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
    final theme = Theme.of(context).colorScheme;
    Color color;
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'paid':
      case 'completed':
        color = const Color(0xFF3BC24F);
        break;
      case 'pending':
      case 'unpaid':
      case 'processing':
        color = const Color(0xFFF9A825);
        break;
      case 'cancelled':
      case 'failed':
        color = theme.error;
        break;
      default:
        color = theme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              status.tr,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                fontFamily: 'lato',
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
    final theme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: theme.surfaceContainerHighest,
      highlightColor: theme.surface,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.outline.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: theme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 10,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: theme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    width: 140,
                    decoration: BoxDecoration(
                        color: theme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 10,
                        width: 60,
                        decoration: BoxDecoration(
                            color: theme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      Container(
                        height: 10,
                        width: 72,
                        decoration: BoxDecoration(
                            color: theme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(5)),
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
            child: Image(image: AssetImage('assets/images/emptyimagecart.png')),
          ),
          const SizedBox(height: 20),
          Text(
            'whoops_no_order_yet'.tr,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                fontFamily: 'Plus Jakarta Sans'),
          ),
          const SizedBox(height: 10),
          Text(
            'look_like_you_have_no_orders_yet.'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontFamily: 'lato'),
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
