import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app_colors.dart';
import '../controller/checkout_controller.dart';


class CheckoutView extends StatelessWidget {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CheckoutController());

    return Scaffold(
      backgroundColor: const Color(0xFFEEECE8),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildTopBar(),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Cart Items ────────────────────────────
                    Obx(() => Column(
                      children: controller.cartItems
                          .map((item) => _CheckoutItemCard(
                          item: item, controller: controller))
                          .toList(),
                    )),
                    const SizedBox(height: 16),

                    // ── White Card Section ────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [

                          // ── Address ──────────────────────────
                          // _buildAddressRow(controller),
                          _divider(),

                          // ── Payment Method ────────────────────
                          _buildSectionPad(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const _SectionTitle(
                                    title: 'Payment method'),
                                const SizedBox(height: 12),
                                Obx(() => _Dropdown(
                                  hint: 'Select Payment method',
                                  value: controller
                                      .selectedPaymentMethod
                                      .value
                                      .isEmpty
                                      ? null
                                      : controller
                                      .selectedPaymentMethod.value,
                                  items: controller.paymentMethods,
                                  onChanged: (v) => controller
                                      .selectedPaymentMethod.value = v!,
                                )),
                              ],
                            ),
                          ),
                          _divider(),

                          // ── Promo / Voucher ────────────────────
                          _buildSectionPad(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const _SectionTitle(
                                    title: 'Promo/voucher'),
                                const SizedBox(height: 12),
                                Obx(() => _Dropdown(
                                  hint: 'Select voucher',
                                  value: controller
                                      .selectedVoucher.value.isEmpty
                                      ? null
                                      : controller.selectedVoucher.value,
                                  items: controller.vouchers,
                                  onChanged: (v) =>
                                      controller.applyVoucher(v!),
                                )),
                              ],
                            ),
                          ),
                          _divider(),

                          // ── SubTotal ───────────────────────────
                          _buildSectionPad(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const _SectionTitle(title: 'SubTotal'),
                                const SizedBox(height: 14),
                                _dashedDivider(),
                                const SizedBox(height: 12),
                                Obx(() => _PriceLine(
                                  label:
                                  'Item (${controller.cartItems.length}x):',
                                  value: controller.subTotal.value,
                                  isGray: true,
                                )),
                                const SizedBox(height: 10),
                                Obx(() => _PriceLine(
                                  label: 'Delivery:',
                                  value: controller.deliveryFee.value,
                                  isGray: true,
                                )),
                                Obx(() {
                                  if (controller.discount.value <= 0) {
                                    return const SizedBox.shrink();
                                  }
                                  return Column(
                                    children: [
                                      const SizedBox(height: 10),
                                      _PriceLine(
                                        label: 'Discount:',
                                        value:
                                        -controller.discount.value,
                                        isGray:     true,
                                        isDiscount: true,
                                      ),
                                    ],
                                  );
                                }),
                                const SizedBox(height: 12),
                                _dashedDivider(),
                                const SizedBox(height: 14),
                                Obx(() => _PriceLine(
                                  label: 'Order total',
                                  value: controller.total.value,
                                  isBold: true,
                                )),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Checkout Button ───────────────────────────────────────
      // ── Checkout Button ───────────────────────────────────────────
      bottomNavigationBar: Obx(() => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        color: const Color(0xFFEEECE8),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            // ✅ Now calls placeOrder() directly
            onPressed: controller.isPlacingOrder.value
                ? null
                : () => controller.placeOrder(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A1A),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFD0CFC9),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
            ),
            child: controller.isPlacingOrder.value
                ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: AppColors.scaffoldBackground))
                : const Text('Place Order',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      )),

    );
  }

  // ── Top Bar ───────────────────────────────────────────────────
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
                  color: AppColors.scaffoldBackground, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: Color(0xFF1A1A1A)),
            ),
          ),
          const Expanded(
            child: Text('Checkout',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A))),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }


  Widget _divider() =>
      Container(height: 1, color: const Color(0xFFF0EEEB));

  Widget _dashedDivider() => Row(
    children: List.generate(
      40,
          (_) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          height: 1,
          color: const Color(0xFFDDDDDD),
        ),
      ),
    ),
  );

  Widget _buildSectionPad({required Widget child}) =>
      Padding(padding: const EdgeInsets.all(20), child: child);
}

// ── Checkout Item Card ────────────────────────────────────────────
class _CheckoutItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final CheckoutController   controller;
  const _CheckoutItemCard(
      {required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    final name  = controller.itemName(item);
    final price = controller.itemPrice(item);
    final image = controller.itemImage(item);
    final qty   = controller.itemQuantity(item);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          // Image
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
                color: const Color(0xFFF5F3F0),
                borderRadius: BorderRadius.circular(14)),
            clipBehavior: Clip.antiAlias,
            child: image.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: image,
              fit: BoxFit.contain,
              placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFD0D0D0))),
              errorWidget: (_, __, ___) => const Icon(
                  Icons.chair_outlined,
                  size: 40, color: Color(0xFFD0D0D0)),
            )
                : const Icon(Icons.chair_outlined,
                size: 40, color: Color(0xFFD0D0D0)),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A1A)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text('\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A))),
              ],
            ),
          ),

          // Qty badge
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
                color: const Color(0xFFF0EEEB),
                borderRadius: BorderRadius.circular(50)),
            child: Text('× $qty',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A))),
          ),
        ],
      ),
    );
  }
}

// ── Dropdown ──────────────────────────────────────────────────────
class _Dropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _Dropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3F0),
        borderRadius: BorderRadius.circular(50),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint,
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFFB0AEAB))),
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF9E9E9E)),
          items: items
              .map((e) => DropdownMenuItem(
            value: e,
            child: Text(e,
                style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A1A1A))),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ── Price Line ────────────────────────────────────────────────────
class _PriceLine extends StatelessWidget {
  final String label;
  final double value;
  final bool isGray;
  final bool isBold;
  final bool isDiscount;
  const _PriceLine({
    required this.label,
    required this.value,
    this.isGray     = false,
    this.isBold     = false,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
    isGray ? const Color(0xFF9E9E9E) : const Color(0xFF1A1A1A);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize:   isBold ? 16 : 14,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                color:      color)),
        Text(
          isDiscount
              ? '-\$${value.abs().toStringAsFixed(2)}'
              : '\$${value.toStringAsFixed(2)}',
          style: TextStyle(
              fontSize:   isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              color:      isDiscount ? Colors.green : color),
        ),
      ],
    );
  }
}

// ── Section Title ─────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            fontSize:   16,
            fontWeight: FontWeight.w700,
            color:      Color(0xFF1A1A1A)));
  }
}
