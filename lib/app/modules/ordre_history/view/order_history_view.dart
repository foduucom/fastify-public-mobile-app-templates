import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../components/app_bar/custom_app_bar.dart';
import '../../../../components/app_bar/custom_app_bar2.dart';

import '../controller/order_controller.dart';
import '../model/model.dart';


class OrderHistoryView extends GetView<OrderHistoryController> {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEECE8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            AppTopBar(title: 'History'),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTabSwitcher(),
                  const SizedBox(height: 12),
                  const Text('List your order',
                      style: TextStyle(
                          fontSize:   16,
                          fontWeight: FontWeight.w700,
                          color:      Color(0xFF1A1A1A))),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Obx(() {
                // ── Loading ───────────────────────────────
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF1A1A1A)),
                  );
                }

                final orders = controller.selectedTab.value == 0
                    ? controller.trackingOrders
                    : controller.completedOrders;

                if (orders.isEmpty) return _buildEmptyState();
                return _buildOrderList(orders);
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab Switcher ──────────────────────────────────────────
  Widget _buildTabSwitcher() {
    return Obx(() => Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          _TabButton(
            label:      'Track your order',
            isSelected: controller.selectedTab.value == 0,
            onTap:      () => controller.selectedTab.value = 0,
          ),
          _TabButton(
            label:      'Order completed',
            isSelected: controller.selectedTab.value == 1,
            onTap:      () => controller.selectedTab.value = 1,
          ),
        ],
      ),
    ));
  }

  // ── Order List ────────────────────────────────────────────
  Widget _buildOrderList(List<OrderModel> orders) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scroll) {
        // Load more when near bottom
        if (scroll.metrics.pixels >=
            scroll.metrics.maxScrollExtent - 200) {
          controller.fetchOrders();
        }
        return false;
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        itemCount: orders.length +
            (controller.isLoadingMore.value ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) {
          if (i == orders.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                    color: Color(0xFF1A1A1A)),
              ),
            );
          }
          return _OrderCard(order: orders[i]);
        },
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width:  90, height: 90,
              decoration: BoxDecoration(
                  color:        Colors.white,
                  borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.inventory_2_outlined,
                  size: 40, color: Color(0xFFB0AEAB)),
            ),
            const SizedBox(height: 24),
            const Text('No orders yet!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize:   18,
                    fontWeight: FontWeight.w700,
                    color:      Color(0xFF1A1A1A))),
            const SizedBox(height: 10),
            const Text('You have not placed any orders yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: Color(0xFF9E9E9E))),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () => Get.toNamed('/productlistview'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                ),
                child: const Text('Start Shopping',
                    style: TextStyle(
                        fontSize:   15,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Order Card ────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/order-detail', arguments: order),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            // ── Thumbnail ──────────────────────────────────
            Container(
              width:  72, height: 72,
              decoration: BoxDecoration(
                  color:        const Color(0xFFF5F3F0),
                  borderRadius: BorderRadius.circular(14)),
              clipBehavior: Clip.antiAlias,
              child: order.thumbnailUrl.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl:    order.thumbnailUrl,
                fit:         BoxFit.contain,
                placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFD0D0D0))),
                errorWidget: (_, __, ___) => const Icon(
                    Icons.inventory_2_outlined,
                    size: 32,
                    color: Color(0xFFD0D0D0)),
              )
                  : const Icon(Icons.inventory_2_outlined,
                  size: 32, color: Color(0xFFD0D0D0)),
            ),
            const SizedBox(width: 14),

            // ── Info ───────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.firstProductName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize:   14,
                          fontWeight: FontWeight.w600,
                          color:      Color(0xFF1A1A1A))),
                  const SizedBox(height: 4),
                  Text('Order #${order.orderNo}',
                      style: const TextStyle(
                          fontSize: 12,
                          color:    Color(0xFF9E9E9E))),
                  const SizedBox(height: 6),
                  Row(children: [
                    Text(
                      '${order.currency}${order.total.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize:   15,
                          fontWeight: FontWeight.w700,
                          color:      Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${order.products.length} item${order.products.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                          fontSize: 12,
                          color:    Color(0xFF9E9E9E)),
                    ),
                  ]),
                ],
              ),
            ),

            // ── Status badge ───────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(order: order),
                const SizedBox(height: 8),
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFF9E9E9E), size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderModel order;
  const _StatusBadge({required this.order});

  @override
  Widget build(BuildContext context) {
    final bool paid = order.isPaid;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: paid
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        paid ? 'Completed' : 'Tracking',
        style: TextStyle(
            fontSize:   11,
            fontWeight: FontWeight.w600,
            color:      paid
                ? const Color(0xFF2E7D32)
                : const Color(0xFFF57F17)),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool   isSelected;
  final VoidCallback onTap;
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: double.infinity,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF1A1A1A)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontSize:   13,
                    fontWeight: FontWeight.w600,
                    color:      isSelected
                        ? Colors.white
                        : const Color(0xFF9E9E9E))),
          ),
        ),
      ),
    );
  }
}
