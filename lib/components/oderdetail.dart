import 'package:flutter/material.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:shimmer/shimmer.dart';

import 'package:get/get.dart';

import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';

class orderDetial extends StatelessWidget {
  orderDetial({
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
  String? currencySymbol;

  double tax;
  double tax_percentage;
  List<dynamic>? taxBreakdown;

  bool isLoading;
  bool? isShowBagSaving = true;

  var bottomBarController = Get.put(BottombarController());

  @override
  Widget build(BuildContext context) {
    final symbol = currencySymbol ?? (currency.isNotEmpty && currency != '₹' ? currency : r'$');
    double discountPercentage =
        bottomBarController.saap_discountPercentage.value;
    bool isShowDiscount = bottomBarController.userData['saap_code'] == null ||
            bottomBarController.userData['saap_code'] == ''
        ? false
        : true;
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
                style:
                    TextStyle(fontFamily: 'Poppins', color: context.themeSecondrytext),
              ),
            ),
            isLoading
                ? const TextShimmer()
                : Text(
                    "$symbol$price",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: context.themeSecondrytext,
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
                        fontFamily: 'Poppins',
                        color: context.themeSecondrytext,
                      ),
                    ),
                  ),
                  isLoading
                      ? const TextShimmer()
                      : Text(
                          "-$symbol$savedPrice",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: context.themeGreenColor,
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
                style:
                    TextStyle(fontFamily: 'Poppins', color: context.themeSecondrytext),
              ),
            ),
            isLoading
                ? const TextShimmer()
                : Text(
                    "$symbol${subtotal ?? (double.parse(price) - double.parse(savedPrice ?? '0')).toStringAsFixed(2)}",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: context.themeSecondrytext,
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
        //                   fontFamily: 'Poppins', color: themeSecondrytext),
        //             ),
        //           ),
        //           isLoading
        //               ? const TextShimmer()
        //               : Text(
        //                   cuponValue,
        //                   style: const TextStyle(
        //                       fontFamily: 'Poppins', color: themeGreenColor),
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
        //                   fontFamily: 'Poppins', color: themeSecondrytext))),
        //       isLoading
        //           ? const TextShimmer()
        //           : Text(
        //               "\u{20B9}${((double.tryParse(subtotal ?? '0') ?? 0) - (double.tryParse(cuponValue.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0)).toStringAsFixed(2)}",
        //               style: const TextStyle(
        //                   fontFamily: 'Poppins', color: themeSecondrytext))
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
        //                   fontFamily: 'Poppins', color: themeSecondrytext),
        //             ),
        //           ),
        //           isLoading
        //               ? const TextShimmer()
        //               : Text(
        //                   '-$currency$discountAmount',
        //                   style: const TextStyle(
        //                     fontFamily: 'Poppins',
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
        //                 fontFamily: 'Poppins', color: themeSecondrytext))),
        //     isLoading
        //         ? const TextShimmer()
        //         : Text(deliveryStatus,
        //             style: const TextStyle(fontFamily: 'Poppins', color: Colors.green))
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
        //                   fontFamily: 'Poppins', color: themeSecondrytext),
        //             ),
        //           ),
        //           isLoading
        //               ? const TextShimmer()
        //               : Text(
        //                   "\u{20B9}${amt.toStringAsFixed(2)}",
        //                   style: const TextStyle(
        //                       fontFamily: 'Poppins', color: themeSecondrytext),
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
        //                     fontFamily: 'Poppins', color: themeSecondrytext),
        //               ),
        //             ),
        //             isLoading
        //                 ? const TextShimmer()
        //                 : Text(
        //                     "\u{20B9}${tax.toStringAsFixed(2)}",
        //                     style: const TextStyle(
        //                         fontFamily: 'Poppins', color: themeSecondrytext),
        //                   ),
        //           ],
        //         )
        //       : const SizedBox(),
        // const SizedBox(height: 5.0),
        Divider(thickness: 0.7, color: context.themegreyColor),
        const SizedBox(height: 5.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Amount:',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
            ),
            isLoading
                ? const TextShimmer()
                : Text(
                    "$symbol${double.parse(totalAmount).toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontFamily: 'Poppins',
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
    return Shimmer.fromColors(
      enabled: true,
      direction: ShimmerDirection.ltr,
      loop: 0,
      period: const Duration(seconds: 1),
      baseColor: context.themegreyColor,
      highlightColor: const Color.fromARGB(255, 197, 197, 197),
      child: Container(
        height: 12,
        width: 60,
        decoration: BoxDecoration(
          color: context.themegreyColor,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class ItemTaxBreakdown {
  final String name;
  final double taxPercent;
  final double taxAmount;

  ItemTaxBreakdown({
    required this.name,
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
    final symbol = widget.currencySymbol ??
        (currency.isNotEmpty && currency != '₹' ? currency : r'$');
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
            child: Divider(thickness: 1, color: context.themegreyColor),
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
                          fontFamily: 'Poppins',
                          color: context.themeSecondrytext,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          Get.dialog(
                            AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: const Text(
                                'Tax Breakdown',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ...widget.itemTaxBreakdown.map(
                                    (item) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${item.name} | GST (${item.taxPercent.toStringAsFixed(0)}%)',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                color: context.themeSecondrytext,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '$symbol ${item.taxAmount.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: context.themeSecondrytext,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total Tax',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '$symbol ${widget.totalTaxAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.info_outline,
                          size: 14,
                          color: context.themeSecondrytext.withOpacity(0.8),
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
                          fontFamily: 'Poppins',
                          color: context.themeSecondrytext,
                        ),
                      ),
              ],
            ),
            // if (widget.itemTaxBreakdown.isNotEmpty)
            //   AnimatedCrossFade(
            //     duration: const Duration(milliseconds: 300),
            //     crossFadeState:
            //         (widget.itemTaxBreakdown.length > 3 && !_isTaxExpanded)
            //         ? CrossFadeState.showFirst
            //         : CrossFadeState.showSecond,
            //     firstChild: _buildTaxBreakdownList(
            //       widget.itemTaxBreakdown.take(3).toList(),
            //       true,
            //     ),
            //     secondChild: _buildTaxBreakdownList(
            //       widget.itemTaxBreakdown,
            //       false,
            //     ),
            //   ),
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
            child: Divider(thickness: 1, color: context.themegreyColor),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'You pay',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: context.themeTextColor,
                ),
              ),
              widget.isLoading
                  ? const TextShimmer()
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        "$symbol ${widget.finalTotal.toStringAsFixed(2)}",
                        key: ValueKey(widget.finalTotal),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: context.themeTextColor,
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
    final symbol = widget.currencySymbol ?? currency;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...breakdown
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                child: Row(
                  children: [
                    const Text(
                      '↳ ',
                      style: TextStyle(color: themeSecondrytext, fontSize: 12),
                    ),
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: themeSecondrytext,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      '$symbol ${item.taxAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
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
                  fontFamily: 'Poppins',
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
                  fontFamily: 'Poppins',
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
    final symbol = widget.currencySymbol ?? currency;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: themeSecondrytext,
            ),
          ),
        ),
        isLoading
            ? const TextShimmer()
            : Text(
                "${amount < 0 ? '-' : ''}$symbol ${amount.abs().toStringAsFixed(2)}",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: isDiscount ? themeGreenColor : themeSecondrytext,
                ),
              ),
      ],
    );
  }
}
