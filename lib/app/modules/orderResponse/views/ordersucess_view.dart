// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/Profie/orders/controller/orders_controller.dart';
import '../controllers/ordersucess_controller.dart';
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
                                                controller.item['payment_status'] ==
                                                            'paid' ||
                                                        controller.item[
                                                                'payment_method'] ==
                                                            'cod'
                                                    ? 'assets/lotti/order-success.json'
                                                    : 'assets/lotti/emptyanimation.json',
                                                fit: BoxFit.cover,
                                                height: 180)),
                                        Center(
                                            child: Text(
                                                controller.item['payment_status'] ==
                                                            'paid' ||
                                                        controller.item[
                                                                'payment_method'] ==
                                                            'cod'
                                                    ? 'Order Placed successfully!'
                                                    : 'Order Placement Failed!',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'lato',
                                                    color: controller.item[
                                                                    'payment_status'] ==
                                                                'paid' ||
                                                            controller.item[
                                                                    'payment_method'] ==
                                                                'cod'
                                                        ? Colors.black
                                                        : Colors.black54,
                                                    fontSize: 22))),
                                        SizedBox(height: 20),
                                        Center(
                                          child: Text(
                                              controller.item['payment_status'] ==
                                                          'paid' ||
                                                      controller.item[
                                                              'payment_method'] ==
                                                          'cod'
                                                  ? 'Payment is successfully processed and your Order is on the way.'
                                                  : 'Payment was not completed. Your order is pending payment.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: 'lato',
                                                fontSize: 16,
                                              )),
                                        ),
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
                    deliveryAmount:
                        controller.item['shipping']?.toString() ?? '0',
                    buttonText: controller.item['payment_status'] == 'paid' ||
                            controller.item['payment_method'] == 'cod'
                        ? 'Continue Shopping'
                        : 'View My Orders',
                    priceText: controller.item['total']?.toString() ?? '0',
                    keypressEvent: () {
                      if (controller.item['payment_status'] == 'paid' ||
                          controller.item['payment_method'] == 'cod') {
                        Get.offAllNamed(Routes.BOTTOMBAR);
                      } else {
                        // Navigate to orders section if payment failed
                        Get.offAllNamed(Routes.BOTTOMBAR);
                        // Optional: trigger navigation to the orders tab if possible
                      }
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
