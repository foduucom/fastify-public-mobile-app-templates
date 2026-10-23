import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/controllers/currency_controller.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:zouhi/components/product_image_placeholder.dart';

import '../constants/constants.dart';

class ProductCard extends StatefulWidget {
  ProductCard({
    Key? key,
    required this.assetImage,
    required this.productName,
    required this.productPrice,
    required this.discountPrice,
    required this.discountRate,
    required this.onLike,
    required this.averageRating,
    required this.like,
    required this.productType,
    required this.highestPrice,
    required this.lowestPrice,
  }) : super(key: key);

  final String? assetImage;
  final String productType;

  final String highestPrice;
  final String lowestPrice;
  final String productName;
  final String productPrice;
  final String discountPrice;
  final double averageRating;
  final String discountRate;
  final VoidCallback onLike;
  final Widget like;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  String get _currencySymbol {
    if (Get.isRegistered<CurrencyController>()) {
      return Get.find<CurrencyController>().selectedCurrency['symbol']?.toString() ?? currency;
    }
    return currency;
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: SizedBox(
                  height: 150,
                  width: 150,
                  child: (widget.assetImage != null &&
                          widget.assetImage!.isNotEmpty &&
                          widget.assetImage != HelperFunctions.getNoImage())
                      ? CachedNetworkImage(
                          imageUrl: widget.assetImage!,
                          height: 150,
                          width: 150,
                          errorWidget: (context, url, error) =>
                              const ProductImagePlaceholder(radius: 5),
                          progressIndicatorBuilder: (context, url, progress) {
                            return HelperFunctions().loadingIndicator();
                          },
                          fit: BoxFit.contain,
                        )
                      : const ProductImagePlaceholder(radius: 5),
                ),
              ),
              // Positioned(
              //   left: 3,
              //   top: 3,
              //   child: GestureDetector(
              //     onTap: () {
              //       widget.onLike();
              //       _controller
              //           .forward(
              //             from: 0.0,
              //           )
              //           .then((value) => _controller.reverse());
              //     },
              //     child: AnimatedBuilder(
              //       animation: _controller,
              //       builder: (context, child) {
              //         return Transform.scale(
              //           scale: _scaleAnimation.value,
              //           child: Container(
              //             decoration: BoxDecoration(
              //               borderRadius: BorderRadius.circular(50),
              //               color: Colors.white,
              //             ),
              //             padding: const EdgeInsets.all(6.0),
              //             child: widget.like,
              //           ),
              //         );
              //       },
              //     ),
              //   ),
              // )
            ],
          ),
          const SizedBox(height: 11),
          SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                RatingBarIndicator(
                  rating: widget.averageRating,
                  itemBuilder: (context, index) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 15.0,
                  direction: Axis.horizontal,
                ),
                Text('', style: txtTheme().titleMedium),
              ],
            ),
          ),
          const SizedBox(height: 4.6),
          Text(
            widget.productName,
            overflow: TextOverflow.ellipsis,
            style: txtTheme().headlineSmall,
          ),
          const SizedBox(height: 6.0),
          widget.productType == 'variant'
              ? Row(
                  children: [
                    Text(
                      '$_currencySymbol${widget.lowestPrice.toString()} - $_currencySymbol${widget.highestPrice.toString()}',
                      style: txtTheme()
                          .headlineSmall!
                          .copyWith(fontSize: 12, color: context.themeTextColor),
                    ),
                  ],
                )
              : RichText(
                  text: TextSpan(
                      text: '$_currencySymbol${widget.productPrice} ',
                      style: txtTheme().headlineSmall!.copyWith(fontSize: 12),
                      children: [
                        if (widget.discountPrice != '')
                          TextSpan(
                              text: '$_currencySymbol${widget.discountPrice}',
                              style: txtTheme().headlineSmall!.copyWith(
                                  color: context.themeSecondrytext,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 12)),
                        const TextSpan(text: ' '),
                        if (widget.discountPrice != '')
                          TextSpan(
                              text: '(${widget.discountRate})',
                              style: txtTheme().headlineSmall!.copyWith(
                                  color: themeRedColor, fontSize: 12)),
                      ]),
                ),
          // : RichText(
          //     text: TextSpan(
          //       text: '\u{20B9}${widget.productPrice} ',
          //       style: txtTheme()
          //           .headlineSmall!
          //           .copyWith(fontSize: 12, color: themeTextColor),
          //       children: [
          //         TextSpan(
          //             text: '\u{20B9}${widget.discountPrice}',
          //             style: txtTheme().headlineSmall!.copyWith(
          //                 color: themeSecondrytext,
          //                 fontSize: 12,
          //                 decoration: TextDecoration.lineThrough)),
          //         TextSpan(
          //             text: ' ${widget.discountRate}',
          //             style: const TextStyle(color: Color(0xFFDD4B39)))
          //       ],
          //     ),
          //   )
        ],
      ),
    );
  }
}
