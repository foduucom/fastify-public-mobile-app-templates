import 'package:flutter/material.dart';
import 'package:zouhi/app/modules/auth/auth_details.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zouhi/constants/theme_ext.dart';

class orderSuccessDetials extends StatelessWidget {
  orderSuccessDetials({
    required this.price,
    this.savedPrice,
    this.subtotal,
    required this.cuponValue,
    //required this.deliveryStatus,
    required this.totalAmount,
    required this.couponPrefix,
    required this.tax,
    required this.tax_percentage,
    this.taxBreakdown,
    required this.isShowDiscount,
    required this.discountPercentage,
    required this.discountAmount,
    this.isLoading = false,
    this.isShowBagSaving = true,
    this.currencySymbol,
    Key? key,
  }) : super(key: key);
  String price;
  String? savedPrice;
  String? subtotal;
  String cuponValue;
  //String deliveryStatus;
  String totalAmount;
  String couponPrefix;
  bool isShowDiscount;
  String? discountPercentage;
  String? discountAmount;
  double tax;
  double tax_percentage;
  List<dynamic>? taxBreakdown;
  String? currencySymbol;

  bool isLoading;
  bool? isShowBagSaving = true;

  @override
  Widget build(BuildContext context) {
    final symbol = currencySymbol ?? (currency.isNotEmpty && currency != '₹' ? currency : r'$');
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: Text('Bag total',
                    style: TextStyle(
                        fontFamily: 'Poppins', color: context.themeSecondrytext))),
            isLoading
                ? const TextShimmer()
                : Text("$symbol$price",
                    style: TextStyle(
                        fontFamily: 'Poppins', color: context.themeSecondrytext))
          ],
        ),
        isShowBagSaving! ? const SizedBox(height: 06) : Container(),
        isShowBagSaving!
            ? Row(
                children: [
                  Expanded(
                      child: Text('You Save',
                          style: TextStyle(
                              fontFamily: 'Poppins', color: context.themeSecondrytext))),
                  isLoading
                      ? const TextShimmer()
                      : Text("-$symbol$savedPrice",
                          style: const TextStyle(
                              fontFamily: 'Poppins', color: themeGreenColor))
                ],
              )
            : Container(),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
                child: Text('Subtotal',
                    style: TextStyle(
                        fontFamily: 'Poppins', color: context.themeSecondrytext))),
            isLoading
                ? const TextShimmer()
                : Text(
                    "$symbol${subtotal ?? ((double.tryParse(price) ?? 0.0) - (double.tryParse(savedPrice ?? '0') ?? 0.0)).toStringAsFixed(2)}",
                    style: TextStyle(
                        fontFamily: 'Poppins', color: context.themeSecondrytext))
          ],
        ),
        const SizedBox(height: 5),
        !AuthDetails.isUserLogin() || cuponValue.isEmpty
            ? Container()
            : Row(
                children: [
                  Expanded(
                      child: Text('Coupon Discount $couponPrefix',
                          style: TextStyle(
                              fontFamily: 'Poppins', color: context.themeSecondrytext))),
                  isLoading
                      ? const TextShimmer()
                      : Text(cuponValue,
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: cuponValue == 'Apply Coupon'
                                  ? themeRedColor
                                  : themeGreenColor))
                ],
              ),
        const SizedBox(height: 06),

        isShowDiscount
            ? Row(
                children: [
                  Expanded(
                    child: Text(
                      'Discount ($discountPercentage%)',
                      style: TextStyle(
                          fontFamily: 'Poppins', color: context.themeSecondrytext),
                    ),
                  ),
                  isLoading
                      ? const TextShimmer()
                      : Text(
                          '-$symbol$discountAmount',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: themeRedColor,
                          ),
                        ),
                ],
              )
            : Container(),
        isShowDiscount ? const SizedBox(height: 5.0) : Container(),
        if (taxBreakdown != null && taxBreakdown!.isNotEmpty)
          ...taxBreakdown!.map((breakdown) {
            double rate =
                double.tryParse(breakdown['percentage']?.toString() ?? '0') ??
                    0.0;
            double taxable = double.tryParse(
                    breakdown['taxableAmount']?.toString() ?? '0') ??
                0.0;
            double amt =
                double.tryParse(breakdown['taxAmount']?.toString() ?? '0') ??
                    0.0;
            if (amt <= 0) return const SizedBox();
            return Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tax (${rate.toStringAsFixed(0)}% on $symbol${taxable.toStringAsFixed(2)})',
                      style: TextStyle(
                          fontFamily: 'Poppins', color: context.themeSecondrytext),
                    ),
                  ),
                  isLoading
                      ? const TextShimmer()
                      : Text(
                          "$symbol${amt.toStringAsFixed(2)}",
                          style: TextStyle(
                              fontFamily: 'Poppins', color: context.themeSecondrytext),
                        ),
                ],
              ),
            );
          }).toList()
        else
          tax > 0
              ? Row(
                  children: [
                    Expanded(
                      child: Text(
                        tax_percentage > 0
                            ? 'Tax (${tax_percentage.toStringAsFixed(0)}%)'
                            : 'Tax',
                        style: TextStyle(
                            fontFamily: 'Poppins', color: context.themeSecondrytext),
                      ),
                    ),
                    isLoading
                        ? const TextShimmer()
                        : Text(
                            "$symbol${tax.toStringAsFixed(2)}",
                            style: TextStyle(
                                fontFamily: 'Poppins', color: context.themeSecondrytext),
                          ),
                  ],
                )
              : const SizedBox(),
        const SizedBox(height: 5.0),
        Divider(thickness: 0.7, color: context.themeBorderColor),
        const SizedBox(height: 5.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Amount:',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: context.themeTextColor),
            ),
            isLoading
                ? const TextShimmer()
                : Text(
                    "$symbol$totalAmount",
                    style: TextStyle(
                        fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: context.themeTextColor),
                  ),
          ],
        ),
      ],
    );
  }
}

class TextShimmer extends StatelessWidget {
  const TextShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        enabled: true,
        direction: ShimmerDirection.ltr,
        loop: 0,
        period: const Duration(seconds: 1),
        baseColor: context.isDark ? Colors.grey[800]! : context.themegreyColor,
        highlightColor: context.isDark ? Colors.grey[700]! : const Color.fromARGB(255, 197, 197, 197),
        child: Container(
          height: 12,
          width: 60,
          decoration: BoxDecoration(
              color: context.themegreyColor, borderRadius: BorderRadius.circular(10)),
        ));
  }
}

