import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/address/controllers/address_list_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:foduu_ecommerce/components/buttons/primary_action_button.dart';
import 'package:foduu_ecommerce/components/commonWidgets/secondary_app_header.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/helpers/dialog_helper.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import '../controllers/checkout_controllers.dart';
import '/constants/constants.dart';
import '/constants/theme.dart';

class CheckoutViews extends GetView<CheckOutController> {
  CheckoutViews({super.key});

  final cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    var width = Get.width;
    var height = Get.height;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.02,
        ),
        child: Column(
          children: [
            SizedBox(height: height * 0.0005),
            // HEADER PAGE
            SecondaryAppHeader(
              title: "Checkout",
              showRight: false,
            ),
            SizedBox(height: height * 0.012),

            // ADDRESS BAR (Integrated from first design)
            _buildAddressBar(width, height, context),

            SizedBox(height: height * 0.01),

            // PAYMENT METHODS SECTION (Integrated from second design)
            _buildPaymentMethodsSection(width, height, context),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(width, height, context),
    );
  }

  // ── Address Bar Widget (with edit functionality) ──────────────────────────────
  Widget _buildAddressBar(double width, double height, BuildContext context) {
    return Container(
      width: width * 0.94,
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.026,
        vertical: height * 0.012,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height * 0.015),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: height * 0.056,
            height: height * 0.056,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height * 0.01),
            ),
            alignment: Alignment.center,
            child: Center(
              child: Icon(
                Icons.location_on_outlined,
                size: height * 0.0315,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          SizedBox(width: width * 0.025),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Your Address",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: height * 0.018,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: height * 0.004),

                // Use selectedAddressString instead of selectedAddress
                Obx(() => Text(
                      controller.selectedAddressString.value.isNotEmpty
                          ? controller.selectedAddressString.value
                          : "No address selected. Please add an address.",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: height * 0.013,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        color: controller.selectedAddressString.value.isNotEmpty
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : Theme.of(context).colorScheme.error,
                      ),
                    )),
              ],
            ),
          ),

          // Edit icon - opens address form for editing
          GestureDetector(
            onTap: () {
              if (controller.selectedAddressString.value.isNotEmpty) {
                _showEditAddressBottomSheet(width, height, context);
              } else {
                // If no address selected, navigate to address list
                Get.toNamed(Routes.ADDRESS_LIST)?.then((_) {
                  // Refresh address when coming back
                  controller.refreshAddress();
                });
              }
            },
            child: SizedBox(
              width: height * 0.035,
              height: height * 0.035,
              child: Obx(() => Icon(
                    controller.selectedAddressString.value.isNotEmpty
                        ? Icons.edit_outlined
                        : Icons.add_location_alt_outlined,
                    size: height * 0.02,
                    color: Theme.of(context).colorScheme.primary,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  // ── Edit Address Bottom Sheet Method ───────────────────────────────────
  void _showEditAddressBottomSheet(
      double width, double height, BuildContext context) {
    // Get the selected address data from controller
    final selectedAddressMap = controller.selectedAddressData.value;

    print('Selected Address Map: $selectedAddressMap'); // Debug print
    print(
        'Selected Address Map Type: ${selectedAddressMap.runtimeType}'); // Debug print

    if (selectedAddressMap.isEmpty) {
      Get.snackbar(
        "Error",
        "No address selected to edit",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Theme.of(context).colorScheme.error,
        colorText: Theme.of(context).colorScheme.onError,
      );
      return;
    }

    // Make sure we're passing the address as a Map
    final addressData = Map<String, dynamic>.from(selectedAddressMap);

    print('Address Data to pass: $addressData'); // Debug print

    // Navigate to AddressFormView in edit mode
    Get.toNamed(
      Routes.ADDRESS_FORM,
      arguments: {'isEdit': true, 'address': addressData},
    )?.then((result) {
      // Refresh address when coming back from edit
      if (result == true) {
        controller.refreshAddress();

        // Also refresh the address list controller to ensure data is in sync
        if (Get.isRegistered<AddressListController>()) {
          final addressController = Get.find<AddressListController>();
          addressController.refreshAddresses();
        }

        Get.snackbar(
          "Success",
          "Address updated successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Theme.of(context).colorScheme.primary,
          colorText: Theme.of(context).colorScheme.onPrimary,
          duration: Duration(seconds: 2),
        );
      }
    });
  }

  // ── Payment Methods Section (integrated from second design) ──────────────
  Widget _buildPaymentMethodsSection(
      double width, double height, BuildContext context) {
    return Container(
      width: width * 0.92,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: width * 0.36,
            child: Text(
              "Payment Method",
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: height * 0.02,
                fontWeight: FontWeight.w700,
                height: 1.75,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(height: height * 0.015),

          // Payment Options List (dynamic from controller)
          // CRITICAL: Wrap the entire payment options in Obx
          Obx(() {
            // Force a rebuild by accessing the observable
            final currentIndex = controller.selectedIndex.value;

            return controller.paymentOptions.isEmpty
                ? _buildPaymentMethodShimmer(width, height, context)
                : ListView.separated(
                    separatorBuilder: (_, __) =>
                        SizedBox(height: height * 0.012),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: controller.paymentOptions.length,
                    itemBuilder: (context, index) {
                      // Pass currentIndex to force comparison
                      return _buildPaymentTile(
                        index,
                        width,
                        height,
                        currentIndex, // Pass current index for comparison
                        context,
                      );
                    },
                  );
          }),
        ],
      ),
    );
  }

  // ── Individual Payment Tile (styling from first design, logic from second) ──
  Widget _buildPaymentTile(int index, double width, double height,
      int currentSelectedIndex, BuildContext context) {
    final option = controller.paymentOptions[index];
    // Use the passed currentSelectedIndex instead of accessing controller directly
    final isSelected = currentSelectedIndex == index;

    // Check if this is the credit card section (expanded view)
    if (option['method'] == "Credit Card" && isSelected) {
      return _buildCreditCardExpandedSection(width, height, context);
    }
    return GestureDetector(
      onTap: () {
        print('Tapped: ${option['method']} at index $index');
        controller.selectedIndex.value = index;
        controller.deliveryOption.value = option;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: width * 0.92,
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.03,
          vertical: height * 0.018,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height * 0.015),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.5),
            width: isSelected ? 1.5 : 1,
          ),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            // Payment method icon
            if (option['image'] != null)
              option['image']!.contains('.svg')
                  ? SvgPicture.asset(
                      option['image']!,
                      width: height * 0.03,
                      height: height * 0.03,
                      colorFilter: isSelected
                          ? ColorFilter.mode(
                              Theme.of(context).colorScheme.primary,
                              BlendMode.srcIn)
                          : null,
                    )
                  : Image.asset(
                      option['image']!,
                      width: height * 0.03,
                      height: height * 0.03,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
            SizedBox(width: width * 0.025),
            Expanded(
              child: Text(
                option['method'].toString(),
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: height * 0.017,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  height: 1.4,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            // Radio button with animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: height * 0.022,
              height: height * 0.022,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeInOut,
                        width: height * 0.012,
                        height: height * 0.012,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── Credit Card Expanded Section (from first design) ─────────────────────
  Widget _buildCreditCardExpandedSection(
      double width, double height, BuildContext context) {
    return Container(
      width: width * 0.92,
      padding: EdgeInsets.all(width * 0.03),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height * 0.015),
        border: Border.all(
            color: Theme.of(context).colorScheme.primary, width: 1.5),
      ),
      child: Column(
        children: [
          // Header row with Credit Card and chevron
          Row(
            children: [
              Image.asset(
                "assets/icon/Credit Card.png",
                width: height * 0.03,
                height: height * 0.03,
              ),
              SizedBox(width: width * 0.03),
              Expanded(
                child: Text(
                  "Credit Card",
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: height * 0.018,
                    fontWeight: FontWeight.w500,
                    height: 1.85,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: height * 0.03,
              ),
            ],
          ),
          SizedBox(height: height * 0.015),

          // Saved cards list (from controller)
          // Obx(() => ListView.separated(
          //       shrinkWrap: true,
          //       physics: const NeverScrollableScrollPhysics(),
          //       itemCount: controller.savedCards.length,
          //       separatorBuilder: (_, __) => SizedBox(height: height * 0.015),
          //       itemBuilder: (context, cardIndex) {
          //         return _buildSavedCardTile(cardIndex, width, height);
          //       },
          //     )),

          SizedBox(height: height * 0.015),

          // Add new card button
          _buildAddNewCardButton(width, height, context),
        ],
      ),
    );
  }

  // // ── Saved Card Tile ──────────────────────────────────────────────────────
  // Widget _buildSavedCardTile(int cardIndex, double width, double height) {
  //   final card = controller.savedCards[cardIndex];
  //   final isSelected = controller.selectedCardIndex.value == cardIndex;

  //   return GestureDetector(
  //     onTap: () => controller.selectedCardIndex.value = cardIndex,
  //     child: Container(
  //       width: width * 0.86,
  //       padding: EdgeInsets.all(width * 0.03),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(height * 0.015),
  //         border: Border.all(
  //           color: isSelected
  //               ? DefaultThemeColors.secondarymain
  //               : const Color(0xFFF0F0F0),
  //         ),
  //       ),
  //       child: Row(
  //         children: [
  //           Image.asset(
  //             card['icon'] ?? "assets/images/card.png",
  //             width: height * 0.035,
  //             height: height * 0.035,
  //           ),
  //           SizedBox(width: width * 0.03),
  //           Expanded(
  //             child: Text(
  //               card['number'] ?? "•••• 7658",
  //               style: TextStyle(
  //                 fontFamily: 'Plus Jakarta Sans',
  //                 fontSize: height * 0.018,
  //                 fontWeight: FontWeight.w500,
  //                 height: 1.85,
  //                 color: const Color(0xFF666666),
  //               ),
  //             ),
  //           ),
  //           Container(
  //             width: height * 0.025,
  //             height: height * 0.025,
  //             decoration: BoxDecoration(
  //               shape: BoxShape.circle,
  //               color: isSelected
  //                   ? DefaultThemeColors.secondarymain
  //                   : Colors.transparent,
  //               border: Border.all(
  //                 color: isSelected
  //                     ? DefaultThemeColors.secondarymain
  //                     : const Color(0xFFE0E0E0),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // ── Add New Card Button ──────────────────────────────────────────────────
  Widget _buildAddNewCardButton(
      double width, double height, BuildContext context) {
    return GestureDetector(
      onTap: () => controller.addNewCard(),
      child: Container(
        width: width * 0.86,
        height: height * 0.062,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height * 0.015),
          border: Border.all(color: Theme.of(context).colorScheme.primary),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: height * 0.025,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: width * 0.02),
            Text(
              "Add new card",
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: height * 0.018,
                fontWeight: FontWeight.w500,
                height: 1.85,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shimmer Loader for Payment Methods (from second design) ──────────────
  Widget _buildPaymentMethodShimmer(
      double width, double height, BuildContext context) {
    return Shimmer.fromColors(
      enabled: true,
      direction: ShimmerDirection.ltr,
      loop: 0,
      period: const Duration(seconds: 1),
      baseColor: Theme.of(context).colorScheme.surfaceVariant,
      highlightColor:
          Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.1),
      child: Column(
        children: [
          _buildShimmerTile(width, height, context),
          SizedBox(height: height * 0.015),
          _buildShimmerTile(width, height, context),
        ],
      ),
    );
  }

  Widget _buildShimmerTile(double width, double height, BuildContext context) {
    return Container(
      width: width * 0.92,
      height: height * 0.065,
      padding: EdgeInsets.all(width * 0.03),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height * 0.015),
        border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: height * 0.035,
            height: height * 0.035,
            color: Colors.white,
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Container(
              height: height * 0.018,
              color: Colors.white,
            ),
          ),
          Container(
            width: height * 0.025,
            height: height * 0.025,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Order Summary Section (integrated from second design) ────────────────
  Widget _buildOrderSummary(double width, double height, BuildContext context) {
    final textTheme = txtTheme();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Summary',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Obx(() => _buildSummaryRow(
              'Subtotal',
              '₹${cartController.subTotal.value.toStringAsFixed(2)}',
              textTheme,
              width,
              height,
            )),
        const SizedBox(height: 8),
        Obx(() => cartController.savings > 0
            ? _buildSummaryRow(
                'You Save',
                '-₹${cartController.savings.toStringAsFixed(2)}',
                textTheme,
                width,
                height,
                valueColor: Theme.of(context)
                    .colorScheme
                    .primary, // Using primary for savings if it's "good"
              )
            : const SizedBox.shrink()),
        const SizedBox(height: 8),
        _buildSummaryRow('Delivery', '₹0.00', textTheme, width, height),
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
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            )),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    TextTheme textTheme,
    double width,
    double height, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.bodyMedium),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // ── Bottom Navigation Bar (from first design, integrated with order summary) ──
  // ── Bottom Navigation Bar (from first design, integrated with order summary) ──
  Widget _buildBottomBar(double width, double height, BuildContext context) {
    return Container(
      width: width,
      // Remove fixed height constraint - let content determine height
      padding: EdgeInsets.all(width * 0.05),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Important: let Column size to minimum
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Summary inside bottom bar
          _buildOrderSummary(width, height, context),

          SizedBox(height: height * 0.015),

          // Pay Now Button
          SizedBox(
            width: width * 0.90,
            height: height * 0.075,
            child: PrimaryActionButton(
              text: "Pay Now",
              onPressed: () {
                // Remove the immediate success dialog
                // The success dialog should only show after payment is successful
                controller.processOrder();

                // ❌ REMOVE THIS - it's causing the issue
                // DialogHelper.showSuccessDialog(
                //   title: "Payment Successfully Processed",
                //   description:
                //       "Thank you for your purchase! Your payment has been successfully processed. Sit back, relax, and enjoy your new items.",
                //   imagePath: "assets/images/success.png",
                //   buttonText: "Continue",
                //   onPressed: () {
                //     Get.back();
                //   },
                // );
              },
            ),
          ),
        ],
      ),
    );
  }
}
