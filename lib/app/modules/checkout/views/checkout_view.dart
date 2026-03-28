import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/app/modules/cart/controllers/cart_controller.dart';
import '../controllers/checkout_controller.dart';
import '/constants/constants.dart';
import '/constants/theme.dart';
import '/components/buttons/bottombutton.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class CheckOutView extends GetView<CheckOutController> {
  CheckOutView({Key? key}) : super(key: key);

  final cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Details',
                style: txtTheme()
                    .titleLarge!
                    .copyWith(fontWeight: FontWeight.bold, fontFamily: 'Lato'),
              ),
              const Text(
                'Step 3 of 3',
                style: TextStyle(fontFamily: 'lato', fontSize: 12),
              ),
            ],
          ),
          elevation: 0,
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: pageSurroundingPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Payment Method',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Obx(
                            () => controller.paymentOptions.isEmpty
                                ? const PaymentMethodShimmer()
                                : ListView.separated(
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 10),
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: controller.paymentOptions.length,
                                    itemBuilder: (context, index) {
                                      return _buildPaymentTile(index);
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(thickness: 10),
                    Padding(
                      padding: pageSurroundingPadding,
                      child: _buildOrderSummary(context),
                    ),
                  ],
                ),
              ),
            ),
            Obx(
              () => bottomButton(
                buttonText: 'Place Order',
                priceText: cartController.total.value.toString(),
                keypressEvent: () => controller.processOrder(),
                otherText: 'View Details',
                opacity: 1.0,
                deliveryAmount: '0.0',
                totalAmount: cartController.total.value.toString(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Payment tile ──────────────────────────────────────────────────────

  Widget _buildPaymentTile(int index) {
    final option = controller.paymentOptions[index];
    return GestureDetector(
      onTap: () {
        controller.selectedIndex.value = index;
        controller.deliveryOption.value = option;
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Obx(
          () => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                const SizedBox(width: 10),
                SvgPicture.asset(
                  option['image'] ?? 'assets/icon/card.svg',
                  width: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    option['method'].toString(),
                    style: const TextStyle(fontFamily: 'lato', fontSize: 16),
                  ),
                ),
                Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Container(
                      height: 7.0,
                      width: 7.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: controller.selectedIndex.value == index
                            ? Colors.red
                            : Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Order summary ─────────────────────────────────────────────────────

  Widget _buildOrderSummary(BuildContext context) {
    final textTheme = txtTheme();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Summary',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Obx(() => _summaryRow(
              'Subtotal',
              '₹${cartController.subTotal.value.toStringAsFixed(2)}',
              textTheme,
            )),
        const SizedBox(height: 8),
        Obx(() => cartController.savings > 0
            ? _summaryRow(
                'You Save',
                '-₹${cartController.savings.toStringAsFixed(2)}',
                textTheme,
                valueColor: Colors.green,
              )
            : const SizedBox.shrink()),
        const SizedBox(height: 8),
        _summaryRow('Delivery', '₹0.00', textTheme),
        const SizedBox(height: 12),
        Divider(color: Colors.grey.withValues(alpha: 0.3)),
        const SizedBox(height: 12),
        Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${cartController.total.value.toStringAsFixed(2)}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            )),
      ],
    );
  }

  Widget _summaryRow(
    String label,
    String value,
    TextTheme textTheme, {
    Color? valueColor,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.bodyMedium),
        Text(
          value,
          style: valueStyle ??
              textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
        ),
      ],
    );
  }
}

// ── Shimmer placeholder ───────────────────────────────────────────────

class PaymentMethodShimmer extends StatelessWidget {
  const PaymentMethodShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      enabled: true,
      direction: ShimmerDirection.ltr,
      loop: 0,
      period: const Duration(seconds: 1),
      baseColor: Theme.of(context).primaryColor,
      highlightColor: const Color.fromARGB(255, 197, 197, 197),
      child: Column(
        children: [
          _shimmerTile(),
          const SizedBox(height: 20),
          _shimmerTile(),
        ],
      ),
    );
  }

  Widget _shimmerTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(3),
      ),
      width: Get.width,
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 14,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ],
      ),
    );
  }
}
