import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/app/modules/auth/auth_details.dart';
import '/app/modules/cart/controllers/cart_controller.dart';
import '/constants/constants.dart';
import 'package:shimmer/shimmer.dart';

class orderDetial extends StatelessWidget {
  orderDetial({
    required this.price,
    this.savedPrice,
    required this.cuponValue,
    required this.deliveryStatus,
    required this.totalAmount,
    required this.couponPrefix,
    this.isLoading = false,
    this.isShowBagSaving = true,
    Key? key,
  }) : super(key: key);
  String price;
  String? savedPrice;
  String cuponValue;
  String deliveryStatus;
  String totalAmount;
  String couponPrefix;
  bool isLoading;
  bool? isShowBagSaving = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
                child: Text('Bag total',
                    style: TextStyle(
                      fontFamily: 'lato',
                    ))),
            isLoading
                ? TextShimmer()
                : Text("\u{20B9}$price",
                    style: const TextStyle(
                      fontFamily: 'lato',
                    ))
          ],
        ),
        isShowBagSaving! ? const SizedBox(height: 06) : Container(),
        isShowBagSaving!
            ? Row(
                children: [
                  const Expanded(
                      child: Text('Bag savings',
                          style: TextStyle(
                            fontFamily: 'lato',
                          ))),
                  isLoading
                      ? TextShimmer()
                      : Text("-\u{20B9}$savedPrice",
                          style: const TextStyle(
                            fontFamily: 'lato',
                          ))
                ],
              )
            : Container(),
        const SizedBox(height: 06),
        !AuthDetails.isUserLogin()
            ? Container()
            : Row(
                children: [
                  Expanded(
                      child: Text('Coupon Discount $couponPrefix',
                          style: const TextStyle(
                            fontFamily: 'lato',
                          ))),
                  isLoading
                      ? TextShimmer()
                      : Text("$cuponValue",
                          style: TextStyle(
                            fontFamily: 'lato',
                          ))
                ],
              ),
        const SizedBox(height: 06),
        Row(
          children: [
            const Expanded(
                child: Text('Delivery',
                    style: TextStyle(
                      fontFamily: 'lato',
                    ))),
            isLoading
                ? TextShimmer()
                : Text('$deliveryStatus',
                    style: const TextStyle(
                      fontFamily: 'lato',
                    ))
          ],
        ),
        const SizedBox(height: 5.0),
        const Divider(
          thickness: 0.7,
        ),
        const SizedBox(height: 5.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Amount:',
              style: TextStyle(fontFamily: 'Lato', fontWeight: FontWeight.w600),
            ),
            isLoading
                ? TextShimmer()
                : Text(
                    "\u{20B9}$totalAmount",
                    style: const TextStyle(
                        fontFamily: 'Lato', fontWeight: FontWeight.w600),
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
        baseColor: Colors.grey,
        loop: 0,
        period: Duration(seconds: 1),
        // baseColor: themegreyColor,
        highlightColor: Color.fromARGB(255, 197, 197, 197),
        child: Container(
          height: 12,
          width: 60,
          decoration: BoxDecoration(
              color: Colors.grey, borderRadius: BorderRadius.circular(10)),
        ));
  }
}
