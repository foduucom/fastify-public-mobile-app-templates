// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '/app/modules/Profie/orders/controller/orders_controller.dart';
import '../controllers/ordersucess_controller.dart';
import '/app/routes/app_pages.dart';
import '/components/buttons/bottombutton.dart';
import '/components/oderdetail.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';
import '/constants/theme.dart';
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
              iconTheme: IconThemeData(
                color: Theme.of(context).colorScheme.onSurface,
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
                                            width: double.infinity,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    '${controller.address['name'] ?? ''}',
                                                    style: TextStyle(
                                                        fontFamily: 'lato',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                Text(
                                                    '${controller.address['address'] ?? ''}',
                                                    style: TextStyle(
                                                      fontFamily: 'lato',
                                                      fontSize: 14,
                                                    )),
                                                Text(
                                                    '${controller.address['city'] is Map ? controller.address['city']['name'] : ''}, ${controller.address['state'] is Map ? controller.address['state']['name'] : ''}, ${controller.address['country'] is Map ? controller.address['country']['name'] : ''}',
                                                    style: TextStyle(
                                                      fontFamily: 'lato',
                                                      fontSize: 14,
                                                    )),
                                                Text(
                                                    '${controller.address['pincode'] ?? ''}',
                                                    style: TextStyle(
                                                      fontFamily: 'lato',
                                                      fontSize: 14,
                                                    )),
                                                Text(
                                                    'Mobile: ${controller.address['mobile'] ?? ''}',
                                                    style: TextStyle(
                                                      fontFamily: 'lato',
                                                      fontSize: 14,
                                                    )),
                                              ],
                                            )),
                                        SizedBox(height: 20),
                                        const Text('Payment Method',
                                            style: TextStyle(
                                                fontFamily: 'lato',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600)),
                                        Text(
                                            controller.item['payment_method']
                                                .toString()
                                                .toUpperCase(),
                                            style: TextStyle(
                                              fontFamily: 'lato',
                                              fontSize: 14,
                                            )),
                                        SizedBox(height: 20),
                                      ]),
                                ),
                                Divider(
                                  thickness: 10,
                                ),
                                Padding(
                                  padding: pageSurroundingPadding,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10),
                                      Obx(
                                        () => orderDetial(
                                          isShowBagSaving: false,
                                          couponPrefix: '',
                                          price: controller.item['subtotal']
                                              .toString(),
                                          cuponValue:
                                              '${controller.item['currency'] ?? '₹'}${controller.item['discount'].toString()}',
                                          deliveryStatus:
                                              '${controller.item['currency'] ?? '₹'}${controller.item['shipping_charges'].toString()}',
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
