// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/Profie/orders/controller/orders_controller.dart';
import 'package:foduu_ecommerce/app/modules/payment/controllers/ordersucess_controller.dart';
import 'package:foduu_ecommerce/app/modules/payment/controllers/payment_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/bottombutton.dart';
import 'package:foduu_ecommerce/components/oderdetail.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/theme.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class OrdersucessView extends GetView<OrderSuccessController> {
  OrdersucessView({Key? key}) : super(key: key);
  var controller = Get.put(OrderSuccessController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed(Routes.BOTTOMBAR);
        return false;
      },
      child: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text('Order Placed',
                  style: txtTheme().titleLarge!.copyWith(
                      fontWeight: FontWeight.bold, fontFamily: 'Lato')),
              iconTheme: const IconThemeData(
                color: Colors.black,
              ),
              // backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  bottom: 0,
                  child: SingleChildScrollView(
                    child: Obx(
                      () => controller.isLoading.value
                          ? HelperFunctions().loadingIndicator()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: pageSurroundingPadding,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                            child: LottieBuilder.asset(
                                                'assets/lotti/order-success.json',
                                                fit: BoxFit.cover,
                                                height: 180)),
                                        Center(
                                            child: Text('Order successfully!',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'lato',
                                                    // color: themeRedColor,
                                                    fontSize: 22))),
                                        SizedBox(height: 20),
                                        Text(
                                            'Payment is successfully processsed and your Order is on the way.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: 'lato',
                                              fontSize: 16,
                                              // color: themeTextColor
                                            )),
                                        SizedBox(height: 20),
                                        const Text(
                                          'Order Details:',
                                          style: TextStyle(
                                              fontFamily: 'Lato',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                            'Your order # is: ${controller.item['order_no']}',
                                            style: TextStyle(
                                                fontFamily: 'lato',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600)),
                                        const Text(
                                            'An email receipt including the details about your order has been sent to your email ID.',
                                            style: TextStyle(
                                              fontFamily: 'lato',
                                              fontSize: 14,
                                              // color: themeSecondrytext
                                            )),
                                        SizedBox(height: 20),
                                        const Text(
                                            'This order will be shipped to:',
                                            style: TextStyle(
                                                fontFamily: 'lato',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600)),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.50,
                                            child:
                                                // Obx(
                                                //   () =>
                                                Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    '${controller.address['house_no']} , ${controller.address['landmark']} ',
                                                    style: TextStyle(
                                                      fontFamily: 'lato',
                                                      fontSize: 14,
                                                      // color:
                                                      //     themeSecondrytext
                                                    )),
                                                Text(
                                                    '${controller.address['city']['name']} ,${controller.address['state']['name']} , ${controller.address['country']['name']}',
                                                    style: TextStyle(
                                                      fontFamily: 'lato',
                                                      fontSize: 14,
                                                      // color:
                                                      //     themeSecondrytext
                                                    )),
                                                Text(
                                                    '${controller.address['pincode']} ',
                                                    style: TextStyle(
                                                      fontFamily: 'lato',
                                                      fontSize: 14,
                                                      // color:
                                                      //     themeSecondrytext
                                                    )),
                                              ],
                                              // ),
                                            )),
                                        SizedBox(height: 20),
                                        const Text('Payment Method',
                                            style: TextStyle(
                                                fontFamily: 'lato',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600)),
                                        Text(
                                            controller.item['payment_method']
                                                .toString(),
                                            style: TextStyle(
                                              fontFamily: 'lato',
                                              fontSize: 14,
                                              // color: themeSecondrytext
                                            )),
                                        SizedBox(height: 20),
                                      ]),
                                ),
                                Divider(
                                  thickness: 10,
                                  // color: themegreyColor,
                                ),
                                Padding(
                                  padding: pageSurroundingPadding,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // const Text(
                                      //   'Order Summery',
                                      //   style: TextStyle(
                                      //       fontFamily: 'Lato',
                                      //       fontSize: 16,
                                      //       fontWeight: FontWeight.w600),
                                      // ),
                                      // SizedBox(height: 20),
                                      // ListView.separated(
                                      //     shrinkWrap: true,
                                      //     physics:
                                      //         const NeverScrollableScrollPhysics(),
                                      //     separatorBuilder: (context, index) =>
                                      //         const Divider(
                                      //           thickness: 0.9,
                                      //           color: themegreyColor,
                                      //         ),
                                      //     itemCount: 2,
                                      //     itemBuilder: ((context, index) {
                                      //       return deliveryCartProducts(
                                      //         assetImage:
                                      //             'assets/images/shopkart2.png',
                                      //         productName: 'Straight Kurta',
                                      //         deliveryDate: '25',
                                      //       );
                                      //     })),
                                      SizedBox(height: 10),
                                      Obx(
                                        () => orderDetial(
                                          isShowBagSaving: false,
                                          couponPrefix: '',
                                          price: controller.item['subtotal']
                                              .toString(),
                                          cuponValue:
                                              '\u{20B9}${controller.item['discount'].toString()}',
                                          deliveryStatus:
                                              '\u{20B9}${controller.item['shipping'].toString()}',
                                          totalAmount: controller.item['total']
                                              .toString(),
                                        ),
                                      ),
                                      SizedBox(height: 60),
                                    ],
                                  ),
                                )
                              ],
                            ),
                    ),
                  ),
                ),
                Obx(
                  () => bottomButton(
                    opacity: 1,
                    deliveryAmount: controller.item['shipping'].toString(),
                    buttonText: 'Continue Shopping',
                    priceText: controller.item['total'].toString(),
                    keypressEvent: () {
                      Get.offAllNamed(Routes.BOTTOMBAR);
                    },
                    otherText: 'View details',
                  ),
                )
              ],
            )),
      ),
    );
  }
}
