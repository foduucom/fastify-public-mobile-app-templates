import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:shimmer/shimmer.dart';

// class orderDetial extends StatelessWidget {
//   orderDetial({
//     required this.price,
//     this.savedPrice,
//     required this.cuponValue,
//     required this.deliveryStatus,
//     required this.totalAmount,
//     required this.couponPrefix,
//     this.isLoading = false,
//     this.isShowBagSaving = true,
//     Key? key,
//   }) : super(key: key);
//   String price;
//   String? savedPrice;
//   String cuponValue;
//   String deliveryStatus;
//   String totalAmount;
//   String couponPrefix;
//   bool isLoading;
//   bool? isShowBagSaving = true;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             const Expanded(
//                 child: Text('Bag total',
//                     style: TextStyle(
//                       fontFamily: 'lato',
//                     ))),
//             isLoading
//                 ? TextShimmer()
//                 : Text("\u{20B9}$price",
//                     style: const TextStyle(
//                       fontFamily: 'lato',
//                     ))
//           ],
//         ),
//         isShowBagSaving! ? const SizedBox(height: 06) : Container(),
//         isShowBagSaving!
//             ? Row(
//                 children: [
//                   const Expanded(
//                       child: Text('You Save',
//                           style: TextStyle(
//                             fontFamily: 'lato',
//                           ))),
//                   isLoading
//                       ? TextShimmer()
//                       : Text("-\u{20B9}$savedPrice",
//                           style: const TextStyle(
//                             fontFamily: 'lato',
//                             color: Colors.green,
//                           ))
//                 ],
//               )
//             : Container(),
//         const SizedBox(height: 06),
//         // !AuthDetails.isUserLogin()
//         //     ? Container()
//         //     : Row(
//         //         children: [
//         //           Expanded(
//         //               child: Text('Coupon Discount $couponPrefix',
//         //                   style: const TextStyle(
//         //                     fontFamily: 'lato',
//         //                   ))),
//         //           isLoading
//         //               ? TextShimmer()
//         //               : Text("$cuponValue",
//         //                   style: TextStyle(
//         //                     fontFamily: 'lato',
//         //                   ))
//         //         ],
//         //       ),
//         // const SizedBox(height: 06),
//         // Row(
//         //   children: [
//         //     const Expanded(
//         //         child: Text('Delivery',
//         //             style: TextStyle(
//         //               fontFamily: 'lato',
//         //             ))),
//         //     isLoading
//         //         ? TextShimmer()
//         //         : Text('$deliveryStatus',
//         //             style: const TextStyle(
//         //               fontFamily: 'lato',
//         //             ))
//         //   ],
//         // ),
//         // const SizedBox(height: 5.0),
//         const Divider(
//           thickness: 0.7,
//         ),
//         const SizedBox(height: 5.0),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'Total Amount:',
//               style: TextStyle(fontFamily: 'Lato', fontWeight: FontWeight.w600),
//             ),
//             isLoading
//                 ? TextShimmer()
//                 : Text(
//                     "\u{20B9}$totalAmount",
//                     style: const TextStyle(
//                         fontFamily: 'Lato', fontWeight: FontWeight.w600),
//                   ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class TextShimmer extends StatelessWidget {
//   const TextShimmer({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Shimmer.fromColors(
//         enabled: true,
//         direction: ShimmerDirection.ltr,
//         baseColor: Colors.grey,
//         loop: 0,
//         period: Duration(seconds: 1),
//         // baseColor: themegreyColor,
//         highlightColor: Color.fromARGB(255, 197, 197, 197),
//         child: Container(
//           height: 12,
//           width: 60,
//           decoration: BoxDecoration(
//               color: Colors.grey, borderRadius: BorderRadius.circular(10)),
//         ));
//   }
// }

class orderDetial extends StatelessWidget {
  orderDetial({
    required this.price,
    this.savedPrice,
    this.subtotal,
    required this.cuponValue,
    this.deliveryStatus,
    required this.totalAmount,
    required this.couponPrefix,
    this.tax = 0.0,
    this.tax_percentage = 0.0,
    this.taxBreakdown,
    this.isLoading = false,
    this.isShowBagSaving = true,
    Key? key,
  }) : super(key: key);
  String price;
  String? savedPrice;
  String? subtotal;
  String cuponValue;
  String? deliveryStatus;
  String totalAmount;
  String couponPrefix;

  double tax;
  double tax_percentage;
  List<dynamic>? taxBreakdown;

  bool isLoading;
  bool? isShowBagSaving = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeSecondrytext = colorScheme.onSurfaceVariant;
    final themegreyColor = colorScheme.outline;
    final themeGreenColor = Colors.green;
    final themeRedColor = Colors.red;

    final userData = AuthDetails.getUserDetails();
    double discountPercentage = 0.0;
    if (userData != null && userData['saap_discountPercentage'] != null) {
      discountPercentage =
          double.tryParse(userData['saap_discountPercentage'].toString()) ??
              0.0;
    }
    bool isShowDiscount = userData != null &&
        userData['saap_code'] != null &&
        userData['saap_code'] != '';
    String discountAmount =
        (double.parse(totalAmount) * (discountPercentage / 100))
            .toStringAsFixed(2);

    totalAmount = isShowDiscount
        ? (double.parse(totalAmount) - double.parse(discountAmount))
            .toStringAsFixed(2)
        : totalAmount;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Bag total',
                style: TextStyle(fontFamily: 'lato', color: themeSecondrytext),
              ),
            ),
            isLoading
                ? const TextShimmer()
                : Text(
                    "\u{20B9}$price",
                    style: TextStyle(
                      fontFamily: 'lato',
                      color: themeSecondrytext,
                    ),
                  ),
          ],
        ),
        isShowBagSaving! ? const SizedBox(height: 06) : Container(),
        isShowBagSaving!
            ? Row(
                children: [
                  Expanded(
                    child: Text(
                      'You Save',
                      style: TextStyle(
                        fontFamily: 'lato',
                        color: themeSecondrytext,
                      ),
                    ),
                  ),
                  isLoading
                      ? const TextShimmer()
                      : Text(
                          "-\u{20B9}$savedPrice",
                          style: TextStyle(
                            fontFamily: 'lato',
                            color: themeGreenColor,
                          ),
                        ),
                ],
              )
            : Container(),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                'Subtotal',
                style: TextStyle(fontFamily: 'lato', color: themeSecondrytext),
              ),
            ),
            isLoading
                ? const TextShimmer()
                : Text(
                    "\u{20B9}${subtotal ?? (double.parse(price) - double.parse(savedPrice ?? '0')).toStringAsFixed(2)}",
                    style: TextStyle(
                      fontFamily: 'lato',
                      color: themeSecondrytext,
                    ),
                  ),
          ],
        ),
        const SizedBox(height: 5),
        // (!AuthDetails.isUserLogin() ||
        //         cuponValue == 'Apply Coupon' ||
        //         cuponValue.isEmpty ||
        //         cuponValue == '0.00')
        //     ? const SizedBox()
        //     : Row(
        //         children: [
        //           Expanded(
        //             child: Text(
        //               'Coupon Discount $couponPrefix',
        //               style: const TextStyle(
        //                   fontFamily: 'lato', color: themeSecondrytext),
        //             ),
        //           ),
        //           isLoading
        //               ? const TextShimmer()
        //               : Text(
        //                   cuponValue,
        //                   style: const TextStyle(
        //                       fontFamily: 'lato', color: themeGreenColor),
        //                 )
        //         ],
        //       ),
        // if (cuponValue != 'Apply Coupon' &&
        //     cuponValue.isNotEmpty &&
        //     cuponValue != '0.00') ...[
        //   const SizedBox(height: 6),
        //   Row(
        //     children: [
        //       const Expanded(
        //           child: Text('Subtotal after coupon',
        //               style: TextStyle(
        //                   fontFamily: 'lato', color: themeSecondrytext))),
        //       isLoading
        //           ? const TextShimmer()
        //           : Text(
        //               "\u{20B9}${((double.tryParse(subtotal ?? '0') ?? 0) - (double.tryParse(cuponValue.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0)).toStringAsFixed(2)}",
        //               style: const TextStyle(
        //                   fontFamily: 'lato', color: themeSecondrytext))
        //     ],
        //   ),
        // ],
        // const SizedBox(height: 06),
        // isShowDiscount
        //     ? Row(
        //         children: [
        //           Expanded(
        //             child: Text(
        //               'Discount ($discountPercentage%)',
        //               style: const TextStyle(
        //                   fontFamily: 'lato', color: themeSecondrytext),
        //             ),
        //           ),
        //           isLoading
        //               ? const TextShimmer()
        //               : Text(
        //                   '-$currency$discountAmount',
        //                   style: const TextStyle(
        //                     fontFamily: 'lato',
        //                     color: themeRedColor,
        //                   ),
        //                 ),
        //         ],
        //       )
        //     : Container(),
        // isShowDiscount ? const SizedBox(height: 5.0) : Container(),
        // Row(
        //   children: [
        //     const Expanded(
        //         child: Text('Delivery',
        //             style: TextStyle(
        //                 fontFamily: 'lato', color: themeSecondrytext))),
        //     isLoading
        //         ? const TextShimmer()
        //         : Text(deliveryStatus,
        //             style: const TextStyle(fontFamily: 'lato', color: Colors.green))
        //   ],
        // ),
        // if (taxBreakdown != null && taxBreakdown!.isNotEmpty)
        //   ...taxBreakdown!.map((breakdown) {
        //     double rate =
        //         double.tryParse(breakdown['percentage']?.toString() ?? '0') ??
        //             0.0;
        //     double taxable = double.tryParse(
        //             breakdown['taxableAmount']?.toString() ?? '0') ??
        //         0.0;
        //     double amt =
        //         double.tryParse(breakdown['taxAmount']?.toString() ?? '0') ??
        //             0.0;
        //     if (amt <= 0) return const SizedBox();
        //     return Padding(
        //       padding: const EdgeInsets.only(top: 5.0),
        //       child: Row(
        //         children: [
        //           Expanded(
        //             child: Text(
        //               'Tax (${rate.toStringAsFixed(0)}% on \u{20B9}${taxable.toStringAsFixed(2)})',
        //               style: const TextStyle(
        //                   fontFamily: 'lato', color: themeSecondrytext),
        //             ),
        //           ),
        //           isLoading
        //               ? const TextShimmer()
        //               : Text(
        //                   "\u{20B9}${amt.toStringAsFixed(2)}",
        //                   style: const TextStyle(
        //                       fontFamily: 'lato', color: themeSecondrytext),
        //                 ),
        //         ],
        //       ),
        //     );
        //   }).toList()
        // else
        //   tax > 0
        //       ? Row(
        //           children: [
        //             Expanded(
        //               child: Text(
        //                 tax_percentage > 0
        //                     ? 'Tax (${tax_percentage.toStringAsFixed(0)}%)'
        //                     : 'Tax',
        //                 style: const TextStyle(
        //                     fontFamily: 'lato', color: themeSecondrytext),
        //               ),
        //             ),
        //             isLoading
        //                 ? const TextShimmer()
        //                 : Text(
        //                     "\u{20B9}${tax.toStringAsFixed(2)}",
        //                     style: const TextStyle(
        //                         fontFamily: 'lato', color: themeSecondrytext),
        //                   ),
        //           ],
        //         )
        //       : const SizedBox(),
        // const SizedBox(height: 5.0),
        Divider(thickness: 0.7, color: themegreyColor),
        const SizedBox(height: 5.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Amount:',
              style: TextStyle(fontFamily: 'Lato', fontWeight: FontWeight.w600),
            ),
            isLoading
                ? const TextShimmer()
                : Text(
                    "\u{20B9}${double.parse(totalAmount).toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ],
        ),
      ],
    );
  }
}

class TextShimmer extends StatelessWidget {
  const TextShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final themegreyColor = Theme.of(context).colorScheme.outline;
    return Shimmer.fromColors(
      enabled: true,
      direction: ShimmerDirection.ltr,
      loop: 0,
      period: const Duration(seconds: 1),
      baseColor: themegreyColor,
      highlightColor: const Color.fromARGB(255, 197, 197, 197),
      child: Container(
        height: 12,
        width: 60,
        decoration: BoxDecoration(
          color: themegreyColor,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class ItemTaxBreakdown {
  final String name;
  final String? variantName;
  final double taxPercent;
  final double taxAmount;

  ItemTaxBreakdown({
    required this.name,
    this.variantName,
    required this.taxPercent,
    required this.taxAmount,
  });
}

class PriceBreakdownWidget extends StatefulWidget {
  final double originalBagTotal;
  final double itemSavings;
  final String couponCode;
  final String couponDiscountPrefix;
  final double couponDiscountAmount;
  final double taxableValue;
  final double totalTaxAmount;
  final List<ItemTaxBreakdown> itemTaxBreakdown;
  final double finalTotal;
  final double shippingCharges;
  final bool isLoading;

  const PriceBreakdownWidget({
    Key? key,
    required this.originalBagTotal,
    required this.itemSavings,
    required this.couponCode,
    required this.couponDiscountPrefix,
    required this.couponDiscountAmount,
    required this.taxableValue,
    required this.totalTaxAmount,
    required this.itemTaxBreakdown,
    required this.finalTotal,
    this.shippingCharges = 0.0,
    this.isLoading = false,
    this.currencySymbol,
  }) : super(key: key);

  final String? currencySymbol;

  @override
  State<PriceBreakdownWidget> createState() => _PriceBreakdownWidgetState();
}

class _PriceBreakdownWidgetState extends State<PriceBreakdownWidget> {
  bool _isTaxExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeSecondrytext = colorScheme.onSurfaceVariant;
    final themegreyColor = colorScheme.outline;
    final themeGreenColor = Colors.green;
    final themeRedColor = Colors.red;

    final symbol = widget.currencySymbol ?? '₹';
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRow(
            'Items total',
            widget.originalBagTotal,
            isLoading: widget.isLoading,
          ),
          if (widget.itemSavings > 0) ...[
            const SizedBox(height: 6),
            _buildRow(
              'You save (on items)',
              -widget.itemSavings,
              isDiscount: true,
              isLoading: widget.isLoading,
            ),
          ],
          if (widget.couponDiscountAmount > 0) ...[
            const SizedBox(height: 6),
            _buildRow(
              'Coupon (${widget.couponCode}${widget.couponDiscountPrefix.isNotEmpty ? ' · ${widget.couponDiscountPrefix}' : ''})',
              -widget.couponDiscountAmount,
              isDiscount: true,
              isLoading: widget.isLoading,
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(thickness: 1, color: themegreyColor),
          ),
          _buildRow(
            'Taxable value',
            widget.taxableValue,
            isLoading: widget.isLoading,
          ),
          const SizedBox(height: 6),
          if (widget.totalTaxAmount > 0) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'Tax (as per items)',
                        style: TextStyle(
                          fontFamily: 'lato',
                          color: themeSecondrytext,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Tooltip(
                        message:
                            'Tax is calculated per item on post-discount price',
                        triggerMode: TooltipTriggerMode.tap,
                        child: Icon(
                          Icons.info_outline,
                          size: 14,
                          color: themeSecondrytext.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                widget.isLoading
                    ? const TextShimmer()
                    : Text(
                        '+$symbol ${widget.totalTaxAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: 'lato',
                          color: themeSecondrytext,
                        ),
                      ),
              ],
            ),
            if (widget.itemTaxBreakdown.isNotEmpty)
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState:
                    (widget.itemTaxBreakdown.length > 3 && !_isTaxExpanded)
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                firstChild: _buildTaxBreakdownList(
                  widget.itemTaxBreakdown.take(3).toList(),
                  true,
                ),
                secondChild: _buildTaxBreakdownList(
                  widget.itemTaxBreakdown,
                  false,
                ),
              ),
          ],
          if (widget.shippingCharges > 0) ...[
            const SizedBox(height: 6),
            _buildRow(
              'Delivery charges',
              widget.shippingCharges,
              isLoading: widget.isLoading,
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(thickness: 1, color: themegreyColor),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'You pay',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              widget.isLoading
                  ? const TextShimmer()
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        "$symbol ${widget.finalTotal.toStringAsFixed(2)}",
                        key: ValueKey(widget.finalTotal),
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaxBreakdownList(
    List<ItemTaxBreakdown> breakdown,
    bool hasMore,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeSecondrytext = colorScheme.onSurfaceVariant;

    final symbol = widget.currencySymbol ?? '₹';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...breakdown
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                child: Row(
                  children: [
                    Text(
                      '↳ ',
                      style: TextStyle(color: themeSecondrytext, fontSize: 12),
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: item.name,
                              style: TextStyle(
                                fontFamily: 'lato',
                                color: themeSecondrytext,
                                fontSize: 12,
                              ),
                            ),
                            if (item.variantName != null &&
                                item.variantName!.isNotEmpty)
                              TextSpan(
                                text: ' (${item.variantName})',
                                style: TextStyle(
                                  fontFamily: 'lato',
                                  color: themeSecondrytext.withOpacity(0.7),
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '$symbol ${item.taxAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontFamily: 'lato',
                        color: themeSecondrytext,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
        if (hasMore)
          GestureDetector(
            onTap: () {
              setState(() {
                _isTaxExpanded = true;
              });
            },
            child: const Padding(
              padding: EdgeInsets.only(top: 4.0, left: 24.0),
              child: Text(
                'View more...',
                style: TextStyle(
                  fontFamily: 'lato',
                  color: Colors.blue,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        if (!hasMore && widget.itemTaxBreakdown.length > 3)
          GestureDetector(
            onTap: () {
              setState(() {
                _isTaxExpanded = false;
              });
            },
            child: const Padding(
              padding: EdgeInsets.only(top: 4.0, left: 24.0),
              child: Text(
                'Show less',
                style: TextStyle(
                  fontFamily: 'lato',
                  color: Colors.blue,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRow(
    String title,
    double amount, {
    bool isDiscount = false,
    bool isLoading = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeSecondrytext = colorScheme.onSurfaceVariant;
    final themeGreenColor = Colors.green;

    final symbol = widget.currencySymbol ?? '₹';
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'lato',
              color: themeSecondrytext,
            ),
          ),
        ),
        isLoading
            ? const TextShimmer()
            : Text(
                "${amount < 0 ? '-' : ''}$symbol ${amount.abs().toStringAsFixed(2)}",
                style: TextStyle(
                  fontFamily: 'lato',
                  color: isDiscount ? themeGreenColor : themeSecondrytext,
                ),
              ),
      ],
    );
  }
}
