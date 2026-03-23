import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/model.dart';
import '../controller/order_details_controller.dart';


class OrderDetailView extends GetView<OrderDetailController> {
  const OrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEECE8),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildTopBar(),
            const SizedBox(height: 8),

            Expanded(
              child: Obx(() {
                // ── Loading ─────────────────────────────
                if (controller.isLoading.value &&
                    controller.order.value == null) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF1A1A1A)),
                  );
                }
                // ── Error ────────────────────────────────
                if (controller.error.value.isNotEmpty &&
                    controller.order.value == null) {
                  return _buildError();
                }

                final order = controller.order.value;
                if (order == null) return const SizedBox();
                return _buildContent(order);
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 44, height: 44,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: Color(0xFF1A1A1A)),
            ),
          ),
          const Expanded(
            child: Text('Order Details',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A))),
          ),
          // Refresh button
          GestureDetector(
            onTap: () => controller.refresh(),
            child: Container(
              width: 44, height: 44,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.refresh_rounded,
                  size: 20, color: Color(0xFF1A1A1A)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Main Content ──────────────────────────────────────────
  Widget _buildContent(OrderModel order) {
    return RefreshIndicator(
      color: const Color(0xFF1A1A1A),
      onRefresh: controller.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          children: [
            // 1. Order Header Card
            _buildHeaderCard(order),
            const SizedBox(height: 16),

            // 2. Products Card
            _buildSectionCard(
              title: 'Products (${order.products.length})',
              child: Column(
                children: List.generate(
                  order.products.length,
                      (i) => Column(
                    children: [
                      _ProductRow(product: order.products[i]),
                      if (i < order.products.length - 1)
                        const Divider(
                            height: 20,
                            color: Color(0xFFF0EEEB)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Delivery Address Card
            _buildSectionCard(
              title: 'Delivery Address',
              child: _buildAddressBlock(order.address),
            ),
            const SizedBox(height: 16),

            // 4. Payment Info Card
            _buildSectionCard(
              title: 'Payment Info',
              child: _buildPaymentBlock(order),
            ),
            const SizedBox(height: 16),

            // 5. Price Summary Card
            _buildSectionCard(
              title: 'Price Summary',
              child: _buildPriceSummary(order),
            ),

            // Notes (if any)
            if (order.notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Notes',
                child: Text(order.notes,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B6B6B),
                        height: 1.5)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Header Card ───────────────────────────────────────────
  Widget _buildHeaderCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order Number',
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9E9E9E))),
                    const SizedBox(height: 4),
                    Text('# ${order.orderNo}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A),
                            letterSpacing: 0.5)),
                  ],
                ),
              ),
              _StatusChip(isPaid: order.isPaid),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF0EEEB), height: 1),
          const SizedBox(height: 16),

          // 3-column info row
          Row(
            children: [
              _InfoTile(
                icon: Icons.local_shipping_outlined,
                label: 'Method',
                value: order.paymentMethod.toUpperCase(),
              ),
              _VerticalDivider(),
              _InfoTile(
                icon: Icons.receipt_long_outlined,
                label: 'Payment',
                value: order.paymentStatus == 'paid'
                    ? 'Paid'
                    : 'Unpaid',
                valueColor: order.isPaid
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFF57F17),
              ),
              _VerticalDivider(),
              _InfoTile(
                icon: Icons.shopping_bag_outlined,
                label: 'Items',
                value:
                '${order.products.length} item${order.products.length != 1 ? 's' : ''}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Address Block ─────────────────────────────────────────
  Widget _buildAddressBlock(OrderAddress a) {
    if (a.address.isEmpty && a.name.isEmpty) {
      return const Text('No delivery address provided.',
          style: TextStyle(
              fontSize: 13, color: Color(0xFF9E9E9E)));
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
              color: const Color(0xFFF5F3F0),
              borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.location_on_outlined,
              size: 20, color: Color(0xFF6B6B6B)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (a.name.isNotEmpty)
                Text(a.name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A))),
              const SizedBox(height: 4),
              if (a.address.isNotEmpty)
                Text(a.address,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B6B6B),
                        height: 1.5)),
              if (a.pincode.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text('Pincode: ${a.pincode}',
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9E9E9E))),
              ],
              if (a.mobile.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.phone_outlined,
                      size: 13, color: Color(0xFF9E9E9E)),
                  const SizedBox(width: 4),
                  Text(a.mobile,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9E9E9E))),
                ]),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── Payment Block ─────────────────────────────────────────
  Widget _buildPaymentBlock(OrderModel order) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
              color: const Color(0xFFF5F3F0),
              borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.payment_outlined,
              size: 20, color: Color(0xFF6B6B6B)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.paymentMethod.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A))),
              const SizedBox(height: 4),
              Row(children: [
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: order.isPaid
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFF57F17),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  order.isPaid
                      ? 'Payment received'
                      : 'Payment pending',
                  style: TextStyle(
                      fontSize: 12,
                      color: order.isPaid
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFF57F17)),
                ),
              ]),
            ],
          ),
        ),
        Text('${order.currency}${order.total.toStringAsFixed(0)}',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A))),
      ],
    );
  }

  // ── Price Summary ─────────────────────────────────────────
  Widget _buildPriceSummary(OrderModel order) {
    return Column(
      children: [
        _PriceLine(
            label: 'Subtotal',
            value:
            '${order.currency}${order.subtotal.toStringAsFixed(0)}'),
        const SizedBox(height: 10),
        _PriceLine(
            label: 'Shipping',
            value: order.shippingCharges == 0
                ? 'Free'
                : '${order.currency}${order.shippingCharges.toStringAsFixed(0)}'),
        if (order.discount > 0) ...[
          const SizedBox(height: 10),
          _PriceLine(
              label: 'Discount',
              value:
              '-${order.currency}${order.discount.toStringAsFixed(0)}',
              valueColor: const Color(0xFF2E7D32)),
        ],
        const SizedBox(height: 14),
        const Divider(color: Color(0xFFF0EEEB), height: 1),
        const SizedBox(height: 14),
        _PriceLine(
          label: 'Total',
          value:
          '${order.currency}${order.total.toStringAsFixed(0)}',
          isBold: true,
        ),
      ],
    );
  }

  // ── Error ─────────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline,
              size: 48, color: Color(0xFFB0AEAB)),
          const SizedBox(height: 16),
          const Text('Failed to load order.',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A))),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: controller.refresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A1A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // ── White Section Card ────────────────────────────────────
  Widget _buildSectionCard(
      {required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A))),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ── Product Row ───────────────────────────────────────────────────
class _ProductRow extends StatelessWidget {
  final OrderProduct product;
  const _ProductRow({required this.product});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Thumbnail
        Container(
          width: 58, height: 58,
          decoration: BoxDecoration(
              color: const Color(0xFFF5F3F0),
              borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: product.imageUrl.isNotEmpty
              ? CachedNetworkImage(
            imageUrl: product.imageUrl,
            fit: BoxFit.contain,
            placeholder: (_, __) => const Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFD0D0D0))),
            errorWidget: (_, __, ___) => const Icon(
                Icons.inventory_2_outlined,
                size: 24,
                color: Color(0xFFD0D0D0)),
          )
              : const Icon(Icons.inventory_2_outlined,
              size: 24, color: Color(0xFFD0D0D0)),
        ),
        const SizedBox(width: 12),

        // Name + variant
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A))),
              if (product.variantName.isNotEmpty &&
                  product.variantName != product.name) ...[
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF5F3F0),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(product.variantName,
                      style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B6B6B))),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                '₹${product.unitPrice.toStringAsFixed(0)}  ×  ${product.qty}',
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E)),
              ),
            ],
          ),
        ),

        // Line total
        Text('₹${product.total.toStringAsFixed(0)}',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A))),
      ],
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final bool isPaid;
  const _StatusChip({required this.isPaid});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPaid
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        isPaid ? 'Completed' : 'Tracking',
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isPaid
                ? const Color(0xFF2E7D32)
                : const Color(0xFFF57F17)),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? valueColor;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF9E9E9E)),
          const SizedBox(height: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: Color(0xFF9E9E9E))),
          const SizedBox(height: 2),
          Text(value,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? const Color(0xFF1A1A1A))),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 40, color: const Color(0xFFF0EEEB));
  }
}

class _PriceLine extends StatelessWidget {
  final String label, value;
  final bool isBold;
  final Color? valueColor;
  const _PriceLine({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isBold ? 15 : 13,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                color: const Color(0xFF6B6B6B))),
        Text(value,
            style: TextStyle(
                fontSize: isBold ? 15 : 13,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
                color: valueColor ?? const Color(0xFF1A1A1A))),
      ],
    );
  }
}
