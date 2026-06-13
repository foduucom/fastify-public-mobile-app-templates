import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:foduu_ecommerce/app/modules/payment/controllers/ordersucess_controller.dart';
import 'package:foduu_ecommerce/components/oderdetail.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/theme.dart';
import 'package:get/get.dart';
import '../../constants/constants.dart';

class bottomButton extends StatefulWidget {
  bottomButton({
    required this.buttonText,
    required this.priceText,
    required this.keypressEvent,
    required this.otherText,
    required this.opacity,
    required this.deliveryAmount,
    this.totalAmount,
    Key? key,
  }) : super(key: key);
  String buttonText;
  String priceText;
  double opacity;
  String? totalAmount;
  String otherText;
  String deliveryAmount;
  VoidCallback? keypressEvent;

  @override
  State<bottomButton> createState() => _bottomButtonState();
}

class _bottomButtonState extends State<bottomButton> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 0,
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Color.fromARGB(96, 168, 164, 164),
                  spreadRadius: 0,
                  blurRadius: 1.5),
            ],
            // color: themeWhiteColor,
          ),
          width: Get.width,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  width: Get.width * 0.38,
                  child: GestureDetector(
                    onTap: () {
                      final hasSuccess =
                          Get.isRegistered<OrderSuccessController>() &&
                              Get.find<OrderSuccessController>()
                                  .item
                                  .isNotEmpty;

                      final double subtotal;
                      final double savings;
                      final double couponDiscount;
                      final double delivery;
                      final double total;

                      if (hasSuccess) {
                        final success = Get.find<OrderSuccessController>();
                        subtotal = HelperFunctions.parseAmount(
                            success.item['subtotal'] ?? success.item['total']);
                        couponDiscount = HelperFunctions.parseAmount(
                            success.item['discount']);
                        delivery = HelperFunctions.parseAmount(
                            success.item['shipping_charges'] ??
                                success.item['shipping']);
                        total =
                            HelperFunctions.parseAmount(success.item['total']);
                        // savings = MRP bag total - sale price total
                        // total = subtotal - savings - couponDiscount + delivery
                        savings = subtotal - couponDiscount + delivery - total;
                      } else {
                        final hasCart = Get.isRegistered<CartController>() &&
                            Get.find<CartController>().cartItems.isNotEmpty;
                        if (hasCart) {
                          final cart = Get.find<CartController>();
                          subtotal = cart.subTotal.value;
                          savings = cart.savings;
                          couponDiscount = 0.0;
                          delivery = HelperFunctions.parseAmount(
                              widget.deliveryAmount);
                          total = cart.total.value;
                        } else {
                          total = HelperFunctions.parseAmount(widget.priceText);
                          delivery = HelperFunctions.parseAmount(
                              widget.deliveryAmount);
                          subtotal = total - delivery;
                          savings = 0.0;
                          couponDiscount = 0.0;
                        }
                      }

                      Get.bottomSheet(
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15))),
                          padding: pageSurroundingPadding,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 15),
                              const Text(
                                'Order Details:',
                                style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 20),
                              orderDetial(
                                isShowBagSaving: savings > 0,
                                couponPrefix: '',
                                price: subtotal.toStringAsFixed(2),
                                savedPrice: savings.toStringAsFixed(2),
                                cuponValue: couponDiscount.toStringAsFixed(2),
                                deliveryStatus: delivery.toStringAsFixed(2),
                                totalAmount: total.toStringAsFixed(2),
                              ),
                              const SizedBox(height: 15),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Text("\u{20B9}${widget.priceText}",
                            style: txtTheme().titleLarge),
                        const SizedBox(height: 2.0),
                        Text(widget.otherText,
                            style: txtTheme().titleLarge!.copyWith())
                      ],
                    ),
                  ),
                ),
                Expanded(
                    child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 42,
                  child: Opacity(
                    opacity: widget.opacity,
                    child: ElevatedButton(
                      onPressed: widget.keypressEvent,
                      style: themeButton.copyWith(
                          padding: MaterialStateProperty.all(
                              EdgeInsets.symmetric(horizontal: 5))),
                      child: Text(widget.buttonText.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Lato')),
                    ),
                  ),
                ))
              ],
            ),
          ),
        ));
  }
}
