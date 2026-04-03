import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../routes/app_pages.dart';
import '../../cart/views/cards.dart';
import '/app/modules/cart/controllers/cart_controller.dart';
import '../controllers/checkout_controller.dart';
import '/constants/constants.dart';
import '/components/buttons/bottombutton.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class CheckOutView extends GetView<CheckOutController> {
  CheckOutView({Key? key}) : super(key: key);

  final cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,

      // ── AppBar matching design ──────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,

        // ── Left: circular back button ─────────────────────────────
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black87,
                size: 20,
              ),
            ),
          ),
        ),

        // ── Center: title ──────────────────────────────────────────
        centerTitle: true,
        title: Text(
          'Payment Method',
          style: textTheme.titleLarge?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        // ── Right: circular + button ───────────────────────────────
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddNewCardView()));
              },

                // onTap: () => Get.toNamed(Routes.ADD_CARD),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.black87,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
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
                        const SizedBox(height: 8),
                        Text(
                          'Payment Method',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(() => controller.paymentOptions.isEmpty
                            ? const PaymentMethodShimmer()
                            : ListView.separated(
                          separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.paymentOptions.length,
                          itemBuilder: (context, index) =>
                              _buildPaymentTile(
                                  index, colorScheme, textTheme),
                        )),
                      ],
                    ),
                  ),
                  Divider(thickness: 10, color: Colors.grey.shade100),
                  Padding(
                    padding: pageSurroundingPadding,
                    child: _buildOrderSummary(context, textTheme),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),

          // ── Bottom Place Order Button ─────────────────────────────
          Obx(() => bottomButton(
            buttonText: 'Place Order',
            priceText: cartController.total.value.toString(),
            keypressEvent: () => controller.processOrder(),
            otherText: 'View Details',
            opacity: 1.0,
            deliveryAmount: '0.0',
            totalAmount: cartController.total.value.toString(),
          )),
        ],
      ),
    );
  }

  // ── Payment Tile ──────────────────────────────────────────────────────
  Widget _buildPaymentTile(
      int index, ColorScheme colorScheme, TextTheme textTheme) {
    final option = controller.paymentOptions[index];

    return GestureDetector(
      onTap: () {
        controller.selectedIndex.value = index;
        controller.deliveryOption.value = option;
      },
      child: Obx(() {
        final isSelected = controller.selectedIndex.value == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
              isSelected ? colorScheme.primary : Colors.grey.shade200,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: SvgPicture.asset(
                    option['image'] ?? 'assets/icon/card.svg',
                    colorFilter: ColorFilter.mode(
                        colorScheme.primary, BlendMode.srcIn),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Label
              Expanded(
                child: Text(
                  option['method'].toString(),
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),

              // Radio circle
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Order Summary ─────────────────────────────────────────────────────
  Widget _buildOrderSummary(BuildContext context, TextTheme textTheme) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Summary',
          style: textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 16),
        Obx(() => _summaryRow(
          'Subtotal',
          '\$${cartController.subTotal.value.toStringAsFixed(2)}',
          textTheme,
        )),
        const SizedBox(height: 8),
        Obx(() => cartController.savings > 0
            ? _summaryRow(
          'You Save',
          '-\$${cartController.savings.toStringAsFixed(2)}',
          textTheme,
          valueColor: Colors.green,
        )
            : const SizedBox.shrink()),
        const SizedBox(height: 8),
        _summaryRow('Delivery', 'FREE', textTheme,
            valueColor: colorScheme.primary),
        const SizedBox(height: 12),
        Divider(color: Colors.grey.shade200, thickness: 1),
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
              '\$${cartController.total.value.toStringAsFixed(2)}',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
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
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: textTheme.bodyMedium
                ?.copyWith(color: Colors.black87)),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}

// ── Shimmer ───────────────────────────────────────────────────────────────────
class PaymentMethodShimmer extends StatelessWidget {
  const PaymentMethodShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      child: Column(
        children: [
          _shimmerTile(),
          const SizedBox(height: 12),
          _shimmerTile(),
          const SizedBox(height: 12),
          _shimmerTile(),
        ],
      ),
    );
  }

  Widget _shimmerTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}