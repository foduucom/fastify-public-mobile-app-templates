import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/theme.dart';

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

  final String assetImage;
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
                child: CachedNetworkImage(
                  imageUrl: widget.assetImage,
                  height: 150,
                  width: 150,
                  errorWidget: (context, url, error) => Container(
                    decoration: BoxDecoration(color: Colors.grey.shade300),
                    child: const Center(
                      child: Icon(Icons.error),
                    ),
                  ),
                  progressIndicatorBuilder: (context, url, progress) {
                    return HelperFunctions().loadingIndicator();
                  },
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                left: 3,
                top: 3,
                child: GestureDetector(
                  onTap: () {
                    widget.onLike();
                    _controller
                        .forward(
                          from: 0.0,
                        )
                        .then((value) => _controller.reverse());
                  },
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(6.0),
                          child: widget.like,
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 11),
          SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                RatingBarIndicator(
                  rating: 2,
                  itemBuilder: (context, index) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 15.0,
                  direction: Axis.horizontal,
                ),
                Text('', style: txtTheme().titleSmall),
              ],
            ),
          ),
          const SizedBox(height: 4.6),
          Text(
            widget.productName,
            overflow: TextOverflow.ellipsis,
            style: txtTheme().titleLarge,
          ),
          const SizedBox(height: 6.0),
          widget.productType == 'variant'
              ? Row(
                  children: [
                    Text(
                      '\u{20B9}${widget.lowestPrice.toString()} - \u{20B9}${widget.highestPrice.toString()}',
                      style: txtTheme().titleLarge!.copyWith(
                            fontSize: 12,
                          ),
                    ),
                  ],
                )
              : RichText(
                  text: TextSpan(
                      text: '\u{20B9}${widget.productPrice} ',
                      style: txtTheme().titleLarge!.copyWith(
                            fontSize: 12,
                          ),
                      children: [
                      TextSpan(
                          text: '\u{20B9}${widget.discountPrice}',
                          style: txtTheme().titleLarge!.copyWith(
                              // color: themeSecondrytext,
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough)),
                      TextSpan(
                          text: ' ${widget.discountRate}',
                          style: const TextStyle(color: Color(0xFFFF4C3B)))
                    ]))
        ],
      ),
    );
  }
}
