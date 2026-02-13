import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:foduu_ecommerce/components/oderdetail.dart';
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
  VoidCallback keypressEvent;

  @override
  State<bottomButton> createState() => _bottomButtonState();
}

class _bottomButtonState extends State<bottomButton> {
  CartController cartController = Get.find<CartController>();
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
                      Get.bottomSheet(
                        // Scaffold(
                        //   body:
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(15))),
                          padding: pageSurroundingPadding,
                          child: Column(
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
                                couponPrefix:
                                    cartController.viewCouponPrefix.value,
                                price: cartController.viewprice.value,
                                savedPrice: cartController.viewsavedPrice.value,
                                cuponValue:
                                    cartController.viewCouponAmount.value,
                                deliveryStatus:
                                    widget.deliveryAmount.toString(),
                                totalAmount: '${widget.totalAmount}',
                              ),
                              const SizedBox(height: 10),
                              // Container(
                              //   height: 40,
                              //   decoration: BoxDecoration(
                              //       borderRadius: BorderRadius.circular(3),
                              //       color: themegreyColor),
                              //   child: Padding(
                              //     padding: const EdgeInsets.symmetric(
                              //         horizontal: 10),
                              //     child: Row(
                              //       children: [
                              //         SvgPicture.asset(
                              //             'assets/icon/dilevery.svg',
                              //             color: themetitleColor),
                              //         const SizedBox(width: 10),
                              //         Text(
                              //             'No Delivery Charges applied on this order ',
                              //             style: txtTheme()
                              //                 .titleLarge!
                              //                 .copyWith(
                              //                     color: themetitleColor)),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                              // const SizedBox(height: 15)
                            ],
                          ),
                        ),
                        // ),
                        // Get.dialog(
                        //   Scaffold(
                        //     extendBody: true,
                        //     body:
                        //   ),
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
