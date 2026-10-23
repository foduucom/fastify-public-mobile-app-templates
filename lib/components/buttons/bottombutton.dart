import 'package:flutter/material.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/modules/cart/controllers/cart_controller.dart';
import 'package:zouhi/app/modules/payment/controllers/ordersucess_controller.dart';
import 'package:zouhi/components/oderdetail.dart';
import 'package:zouhi/components/orderSuccessOrderDetails.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:get/get.dart';
import '../../constants/constants.dart';

class bottomButton extends StatefulWidget {
  bottomButton({
    required this.buttonText,
    required this.priceText,
    required this.keypressEvent,
    required this.otherText,
    required this.opacity,
    //required this.deliveryAmount,
    this.isLoading = false,
    this.totalAmount,
    this.isShowOrderSuccessDetails = false,
    this.currencySymbol,
    this.exchangeRate = 1.0,
    Key? key,
  }) : super(key: key);
  String buttonText;
  String? priceText;
  double opacity;
  String? totalAmount;
  String otherText;
  //String deliveryAmount;
  bool isLoading;
  VoidCallback? keypressEvent;
  bool isShowOrderSuccessDetails = false;
  String? currencySymbol;
  double exchangeRate;

  @override
  State<bottomButton> createState() => _bottomButtonState();
}

class _bottomButtonState extends State<bottomButton> {
  CartController cartController = Get.put(CartController());

  var bottomBarController = Get.put(BottombarController());

  @override
  Widget build(BuildContext context) {
    double discountPercentage =
        bottomBarController.saap_discountPercentage.value;

    bool isShowDiscount = bottomBarController.userData['saap_code'] == null ||
            bottomBarController.userData['saap_code'] == ''
        ? false
        : true;

    double discountAmount =
        double.parse(widget.priceText!) * (discountPercentage / 100);

    // totalAmount = (double.parse(totalAmount) - double.parse(discountAmount))
    //     .toStringAsFixed(2);
    return Positioned(
        bottom: 0,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                  color: themePrimaryColor,
                  spreadRadius: 0,
                  blurRadius: 1.5),
            ],
            color: context.themeWhiteColor,
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
                              color: context.themegreyColor,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15))),
                          padding: pageSurroundingPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 15),
                              const Text(
                                'Order Details:',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 20),
                              (() {
                                if (widget.isShowOrderSuccessDetails &&
                                    Get.isRegistered<
                                        OrderSuccessController>()) {
                                  final orderSuccessController =
                                      Get.find<OrderSuccessController>();
                                  final orderData = orderSuccessController.item
                                          .containsKey('data')
                                      ? orderSuccessController.item['data']
                                      : orderSuccessController.item;

                                  if (orderData != null &&
                                      orderData.isNotEmpty) {
                                    double parseDouble(dynamic value) {
                                      if (value == null) return 0.0;
                                      return double.tryParse(
                                              value.toString()) ??
                                          0.0;
                                    }

                                    final currencyObj = orderData['currency'];
                                    final double exchangeRate =
                                        currencyObj is Map
                                            ? (double.tryParse(
                                                    currencyObj['exchange_rate']
                                                            ?.toString() ??
                                                        '') ??
                                                1.0)
                                            : 1.0;

                                    double getUnitPrice(Map p) {
                                      double up = parseDouble(p['unit_price']);
                                      if (up > 0) return up;
                                      up = parseDouble(p['price']);
                                      if (up > 0) return up;
                                      final prodId = p['product_id'];
                                      if (prodId is Map) {
                                        up = parseDouble(prodId['price']) *
                                            exchangeRate;
                                      }
                                      return up;
                                    }

                                    double getOriginalPrice(
                                        Map p, double resolvedUnitPrice) {
                                      double op = parseDouble(p['price']);
                                      if (op > 0) return op;

                                      final variant = p['variant'];
                                      if (variant is Map) {
                                        op = parseDouble(variant['price']) *
                                            exchangeRate;
                                      }
                                      if (op > 0) return op;

                                      final prodId = p['product_id'];
                                      if (prodId is Map) {
                                        op = parseDouble(prodId['price']) *
                                            exchangeRate;
                                      }
                                      if (op > 0) return op;

                                      if (resolvedUnitPrice > 0)
                                        return resolvedUnitPrice;

                                      return 0.0;
                                    }

                                    double originalBagTotal = 0.0;
                                    double actualBagTotal = 0.0;
                                    final products =
                                        orderData['products'] as List? ?? [];
                                    List<ItemTaxBreakdown> breakdown = [];

                                    for (var p in products) {
                                      if (p is Map) {
                                        double qty = double.tryParse(
                                                p['quantity']?.toString() ??
                                                    p['qty']?.toString() ??
                                                    '1') ??
                                            1.0;
                                        double unitPrice = getUnitPrice(p);
                                        double originalPrice =
                                            getOriginalPrice(p, unitPrice);

                                        originalBagTotal += originalPrice * qty;
                                        actualBagTotal += unitPrice * qty;

                                        double taxPercent = double.tryParse(
                                                p['tax']?.toString() ?? '0') ??
                                            0.0;
                                        double itemTax =
                                            ((unitPrice * qty) * taxPercent) /
                                                100;
                                        if (itemTax > 0) {
                                          breakdown.add(ItemTaxBreakdown(
                                            name: p['name']?.toString() ??
                                                'Product',
                                            taxPercent: taxPercent,
                                            taxAmount: itemTax,
                                          ));
                                        }
                                      }
                                    }

                                    double itemSavings =
                                        originalBagTotal - actualBagTotal;
                                    if (itemSavings < 0) itemSavings = 0.0;

                                    final coupon = orderData['coupon'];
                                    final isCouponValid = coupon != null &&
                                        coupon is Map &&
                                        coupon.isNotEmpty;

                                    String couponCode = '';
                                    String couponDiscountPrefix = '';
                                    double couponDiscountAmount = 0.0;

                                    if (isCouponValid) {
                                      couponCode =
                                          coupon['code']?.toString() ?? '';
                                      couponDiscountPrefix =
                                          coupon['discount_type'] == 'fixAmount'
                                              ? ''
                                              : '(${coupon['type_value']}%)';
                                      couponDiscountAmount = double.tryParse(
                                              coupon['discount']?.toString() ??
                                                  '') ??
                                          0.0;
                                    }

                                    double subTotal =
                                        originalBagTotal - itemSavings;
                                    double taxableValue =
                                        subTotal - couponDiscountAmount;

                                    double totalTaxAmount = double.tryParse(
                                            orderData['tax']?.toString() ??
                                                orderData['tax_amount']
                                                    ?.toString() ??
                                                '') ??
                                        0.0;

                                    double shippingCharges = double.tryParse(
                                            orderData['shipping_charges']
                                                    ?.toString() ??
                                                '') ??
                                        0.0;

                                    double finalTotal =
                                        double.tryParse(widget.priceText!) ??
                                            (double.tryParse(orderData['total']
                                                        ?.toString() ??
                                                    '') ??
                                                0.0);

                                    return PriceBreakdownWidget(
                                      originalBagTotal: originalBagTotal,
                                      itemSavings: itemSavings,
                                      couponCode: couponCode,
                                      couponDiscountPrefix:
                                          couponDiscountPrefix,
                                      couponDiscountAmount:
                                          couponDiscountAmount,
                                      taxableValue: taxableValue,
                                      totalTaxAmount: totalTaxAmount,
                                      itemTaxBreakdown: breakdown,
                                      finalTotal: finalTotal,
                                      shippingCharges: shippingCharges,
                                      currencySymbol: widget.currencySymbol,
                                    );
                                  }
                                }

                                double originalBagTotal = (double.tryParse(
                                            cartController.viewPrice.value) ??
                                        0.0) *
                                    widget.exchangeRate;
                                double itemSavings = (double.tryParse(
                                            cartController
                                                .viewSavedPrice.value) ??
                                        0.0) *
                                    widget.exchangeRate;
                                double couponDiscountAmount = (double.tryParse(
                                            cartController
                                                .couponDiscountAmount.value) ??
                                        0.0) *
                                    widget.exchangeRate;
                                double subTotal = (double.tryParse(
                                            cartController
                                                .viewSubTotalAmount.value) ??
                                        0.0) *
                                    widget.exchangeRate;
                                double taxableValue =
                                    subTotal - couponDiscountAmount;
                                double totalTaxAmount =
                                    cartController.tax.value *
                                        widget.exchangeRate;
                                double finalTotal = (double.tryParse(widget
                                                .isShowOrderSuccessDetails
                                            ? widget.priceText!
                                            : (widget.totalAmount ?? '0')) ??
                                        0.0) *
                                    (widget.isShowOrderSuccessDetails
                                        ? 1.0
                                        : widget.exchangeRate);

                                List<ItemTaxBreakdown> breakdown =
                                    cartController.taxBreakdownList.map((e) {
                                  double itemTaxAmount = (double.tryParse(
                                              e['tax_amount']?.toString() ??
                                                  '0') ??
                                          0.0) *
                                      widget.exchangeRate;
                                  return ItemTaxBreakdown(
                                    name: e['name']?.toString() ?? 'Product',
                                    taxPercent: double.tryParse(
                                            e['tax_percent']?.toString() ??
                                                '0') ??
                                        0.0,
                                    taxAmount: itemTaxAmount,
                                  );
                                }).toList();

                                return PriceBreakdownWidget(
                                  originalBagTotal: originalBagTotal,
                                  itemSavings: itemSavings,
                                  couponCode:
                                      cartController.viewCouponCode.value ==
                                              'Apply Coupon'
                                          ? ''
                                          : cartController.viewCouponCode.value,
                                  couponDiscountPrefix:
                                      cartController.viewCouponPrefix.value,
                                  couponDiscountAmount: couponDiscountAmount,
                                  taxableValue: taxableValue,
                                  totalTaxAmount: totalTaxAmount,
                                  itemTaxBreakdown: breakdown,
                                  finalTotal: finalTotal,
                                  currencySymbol: widget.currencySymbol,
                                );
                              })(),
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
                              //                 .headlineSmall!
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
                        (() {
                          final priceVal =
                              double.tryParse(widget.priceText ?? '0') ?? 0.0;
                          final priceStr = priceVal
                              .toStringAsFixed(priceVal % 1 == 0 ? 0 : 2);
                          return Text(
                              widget.isShowOrderSuccessDetails
                                  ? '${widget.currencySymbol ?? currency} $priceStr'
                                  : "${widget.currencySymbol ?? currency} $priceStr ",
                              style: txtTheme()
                                  .headlineSmall!
                                  .copyWith(color: context.themeTextColor));
                        })(),
                        const SizedBox(height: 2.0),
                        Text(widget.otherText,
                            style: txtTheme()
                                .headlineSmall!
                                .copyWith(color: context.themeRedColor))
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
                          padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(horizontal: 5))),
                      child: widget.isLoading
                          ? HelperFunctions().loadingIndicator()
                          : Text(widget.buttonText.toUpperCase(),
                              style: TextStyle(
                                  color: context.colors.onPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins')),
                    ),
                  ),
                ))
              ],
            ),
          ),
        ));
  }
}
