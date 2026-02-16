import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/theme.dart';
import '../constants/constants.dart';

class gridProductCart extends StatefulWidget {
  gridProductCart({
    Key? key,
    required this.assetimage,
    required this.productname,
    required this.productprice,
    required this.discountprice,
    required this.discountrate,
    required this.keypressEvent,
    required this.quantity,
    required this.width,
    this.animationController, // Make it optional
    this.scaoleAnimation, // Make it optional
    required this.liked,
    required this.lowestPrice,
    required this.highestPrice,
    required this.onLiked,
    required this.height,
    required this.productType,
    required this.rating,
    this.storeName = '',
  }) : super(key: key);

  final String assetimage;
  final String productname;
  final String productprice;
  final String lowestPrice;
  final String highestPrice;
  final String productType;
  final String discountprice;
  final String discountrate;
  final VoidCallback keypressEvent;
  final AnimationController? animationController; // Made optional
  final Animation<double>? scaoleAnimation; // Made optional
  final String quantity;
  final double width;
  final double height;
  final double rating;
  final Widget liked;
  final VoidCallback onLiked;
  final String storeName;

  @override
  State<gridProductCart> createState() => _gridProductCartState();
}

class _gridProductCartState extends State<gridProductCart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: widget.keypressEvent,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: DefaultThemeColors.darklight,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with Like Button
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      height: widget.height,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      imageUrl: widget.assetimage,
                      errorWidget: (context, url, error) => Container(
                        height: widget.height,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(Icons.error, size: 30),
                        ),
                      ),
                      progressIndicatorBuilder: (context, url, progress) =>
                          Container(
                        height: widget.height,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: SizedBox(
                            height: 40,
                            width: 40,
                            child: CircularProgressIndicator(
                              value: progress.progress,
                              strokeWidth: 2,
                              color: DefaultThemeColors.mainprimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Like Button with Animation
                  Positioned(
                    left: 8,
                    top: 8,
                    child: GestureDetector(
                      onTap: () {
                        _controller
                            .forward(from: 0.0)
                            .then((value) => _controller.reverse());
                        widget.onLiked();
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
                              padding: const EdgeInsets.all(8),
                              child: widget.liked,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Rating Bar
              Row(
                children: [
                  RatingBarIndicator(
                    rating: widget.rating,
                    itemBuilder: (context, index) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 16,
                    direction: Axis.horizontal,
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Product Title
              Text(
                widget.productname,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 15,
                  color: Color.fromRGBO(34, 34, 34, 1),
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 2),

              // Store Name
              if (widget.storeName.isNotEmpty)
                Text(
                  widget.storeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: DefaultThemeColors.darklighter,
                  ),
                ),

              const SizedBox(height: 4),

              // Price Section
              widget.productType == 'variant'
                  ? Row(
                      children: [
                        Icon(
                          Icons.sell_outlined,
                          size: 16,
                          color: DefaultThemeColors.mainprimary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '\u{20B9}${widget.lowestPrice} - \u{20B9}${widget.highestPrice}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Lato',
                              color: Color.fromRGBO(34, 34, 34, 1),
                            ),
                          ),
                        ),
                      ],
                    )
                  : RichText(
                      text: TextSpan(
                        text: '\u{20B9}${widget.productprice}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Lato',
                          color: Color.fromRGBO(34, 34, 34, 1),
                        ),
                        children: [
                          if (widget.discountrate.isNotEmpty) ...[
                            const TextSpan(text: '  '),
                            TextSpan(
                              text: '\u{20B9}${widget.discountprice}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                            const TextSpan(text: ' '),
                            TextSpan(
                              text: widget.discountrate,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
