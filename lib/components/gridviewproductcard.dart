import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/controllers/currency_controller.dart';
import 'package:zouhi/constants/theme.dart';
import '../constants/constants.dart';
import '../constants/theme_ext.dart';
import 'package:zouhi/components/product_image_placeholder.dart';

class gridProductCart extends StatefulWidget {
  gridProductCart(
      {Key? key,
      required this.assetimage,
      required this.productname,
      required this.productprice,
      required this.discountprice,
      required this.discountrate,
      required this.keypressEvent,
      required this.quantity,
      this.width,
      required this.animationController,
      required this.scaoleAnimation,
      required this.liked,
      required this.lowestPrice,
      required this.highestPrice,
      required this.onLiked,
      required this.height,
      required this.productType,
      required this.rating,
      this.reviewCount = 0})
      : super(key: key);

  final String assetimage;
  final String productname;
  final String productprice;
  final String lowestPrice;
  final String highestPrice;
  final String productType;
  final String discountprice;
  final String discountrate;
  final VoidCallback keypressEvent;
  final AnimationController animationController;
  final Animation<double> scaoleAnimation;
  final String quantity;
  final double? width;
  final double height;
  final double rating;
  final int reviewCount;
  final Widget liked;
  final VoidCallback onLiked;

  @override
  State<gridProductCart> createState() => _gridProductCartState();
}

class _gridProductCartState extends State<gridProductCart>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  String get _currencySymbol {
    if (Get.isRegistered<CurrencyController>()) {
      return Get.find<CurrencyController>()
              .selectedCurrency['symbol']
              ?.toString() ??
          currency;
    }
    return currency;
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount = widget.discountrate.isNotEmpty &&
        widget.discountrate != '0' &&
        !widget.discountrate.startsWith('0%');
    final String discountText =
        widget.discountrate.replaceAll('off', 'OFF').trim();

    return Container(
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: widget.keypressEvent,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: widget.assetimage.isEmpty
                        ? const ProductImagePlaceholder(radius: 5)
                        : CachedNetworkImage(
                            height: double.infinity,
                            width: double.infinity,
                            fit: BoxFit.contain,
                            imageUrl: widget.assetimage,
                            errorWidget: (context, url, error) =>
                                const ProductImagePlaceholder(radius: 5),
                            progressIndicatorBuilder:
                                (context, url, progress) => Container(
                              decoration:
                                  BoxDecoration(color: Colors.grey.shade300),
                              height: 165,
                              child: const Center(
                                child: SizedBox(
                                  height: 40,
                                  width: 40,
                                ),
                              ),
                            ),
                          ),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.themeRedColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          discountText,
                          style: TextStyle(
                            color: context.colors.onPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                RatingBarIndicator(
                  rating: widget.rating,
                  itemBuilder: (context, index) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 15.0,
                  direction: Axis.horizontal,
                ),
                Text(
                  '(${widget.reviewCount})',
                  style: txtTheme().bodySmall!.copyWith(
                        fontSize: 10,
                        color: context.themeSecondrytext,
                      ),
                ),
              ],
            ),
          ),
          Text(widget.productname,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: context.themeTextColor,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 2.6),
          widget.productType == 'variant'
              ? Row(
                  children: [
                    Text(
                      '$_currencySymbol${widget.lowestPrice.toString()} - $_currencySymbol${widget.highestPrice.toString()}',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: context.themeRedColor),
                    ),
                  ],
                )
              : RichText(
                  text: TextSpan(
                    text: '$_currencySymbol${widget.productprice.toString()}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: themeRedColor),
                    children: [
                      const TextSpan(
                        text: '  ',
                      ),
                      TextSpan(
                          text: widget.discountrate.isEmpty ||
                                  widget.discountprice == '0' ||
                                  widget.discountprice == ''
                              ? ''
                              : '$_currencySymbol${widget.discountprice.toString()}',
                          style: const TextStyle(
                            color: themeSecondrytext,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.lineThrough,
                          )),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
