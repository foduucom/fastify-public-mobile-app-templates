import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foduu_ecommerce/constants/theme.dart';
import '../constants/constants.dart';

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
      required this.width,
      required this.animationController,
      required this.scaoleAnimation,
      required this.liked,
      required this.lowestPrice,
      required this.highestPrice,
      required this.onLiked,
      required this.height,
      required this.productType,
      required this.rating})
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
  final double width;
  final double height;
  final double rating;
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: widget.keypressEvent,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CachedNetworkImage(
                    height: widget.height,
                    width: widget.width,
                    fit: BoxFit.cover,
                    imageUrl: widget.assetimage,
                    errorWidget: (context, url, error) => Container(
                      decoration: BoxDecoration(color: Colors.grey.shade300),
                      child: const Center(
                        child: Icon(Icons.error),
                      ),
                    ),
                    progressIndicatorBuilder: (context, url, progress) =>
                        Container(
                      decoration: BoxDecoration(color: Colors.grey.shade300),
                      height: 165,
                      child: const Center(
                        child: SizedBox(
                          height: 40,
                          width: 40,
                          // child: HelperFunctions().loadingIndicator(),
                        ),
                      ),
                    ),
                  ),
                ),
                // Positioned(
                //     right: 3,
                //     top: 3,
                //     child: GestureDetector(
                //       onTap: onLiked,
                //       child: Container(
                //         decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(50),
                //           color: themeWhiteColor,
                //         ),
                //         child: Padding(
                //           padding: const EdgeInsets.all(6.0),
                //           child: liked,
                //           //  Obx(
                //           //   () => SvgPicture.asset(
                //           //     likecontroller.isLiked == true
                //           //         ? 'assets/icon/appbarlike.svg'
                //           //         : 'assets/icon/like.svg',
                //           //     width: 15,
                //           //   ),
                //           // ),
                //         ),
                //       ),
                //     ))
                Positioned(
                  left: 3,
                  top: 3,
                  child: GestureDetector(
                    onTap: () {
                      controller
                          .forward(
                            from: 0.0,
                          )
                          .then((value) => controller.reverse());
                      widget.onLiked();
                    },
                    child: AnimatedBuilder(
                      animation: controller,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: scaleAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(6.0),
                            child: widget.liked,
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: widget.width,
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
                Text('', style: txtTheme().titleSmall),
              ],
            ),
          ),
          // const SizedBox(height: 1.6),
          Text(
              // 'Fit and Flare Dress',
              widget.productname,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 14,
                  color: Color.fromRGBO(34, 34, 34, 1),
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 2.6),
          widget.productType == 'variant'
              ? Row(
                  children: [
                    Text(
                      '\u{20B9}${widget.lowestPrice.toString()} - \u{20B9}${widget.highestPrice.toString()}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Lato',
                        // color: themeTextColor
                      ),
                    ),
                  ],
                )
              : RichText(
                  text: TextSpan(
                      text: '\u{20B9}${widget.productprice.toString()}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Lato',
                        // color: themeTextColor
                      ),
                      children: [
                      const TextSpan(
                        text: '  ',
                      ),
                      TextSpan(
                          text: widget.discountrate.isEmpty
                              ? ''
                              : '\u{20B9}${widget.discountprice.toString()}',
                          style: const TextStyle(
                            // color: themeSecondrytext,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.lineThrough,
                          )),
                      const TextSpan(
                        text: ' ',
                      ),
                      TextSpan(
                          text: widget.discountrate,
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w400)),
                    ])),
        ],
      ),
    );
  }
}
