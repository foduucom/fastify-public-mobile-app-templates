import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foduu_ecommerce/app/modules/product/views/product_view.dart';
import 'package:foduu_ecommerce/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:foduu_ecommerce/components/commonWidgets/simple_price_text.dart';
import 'package:foduu_ecommerce/components/commonWidgets/variable_price_text.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/product_helper.dart';
import 'package:get/get.dart';

/// Reusable Product Card Widget
/// Displays a product with image, name, price, and wishlist functionality
class ProductCard extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistToggle;
  final double? width;
  final double? imageHeight;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onWishlistToggle,
    this.width = 160,
    this.imageHeight = 180,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final WishlistController _wishlistController = Get.find<WishlistController>();

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

  void _handleWishlistTap() async {
    final productId = ProductHelper.getProductId(widget.product);
    await _wishlistController.addProductToWishlist(productid: productId);
    await _wishlistController.getwishlist();

    _controller.forward(from: 0.0).then((value) => _controller.reverse());

    if (widget.onWishlistToggle != null) {
      widget.onWishlistToggle!();
    }
  }

  void _handleProductTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      // Default behavior: navigate to product detail
      final productId = ProductHelper.getProductId(widget.product);
      Get.to(
        () => ProductView(),
        preventDuplicates: false,
        arguments: {'productId': productId},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Get product information using helper
    final productName = ProductHelper.getProductName(widget.product);
    final productId = ProductHelper.getProductId(widget.product);
    final imageUrl = ProductHelper.getProductImage(widget.product);
    final priceInfo = ProductHelper.calculatePriceInfo(widget.product);
    final productType = priceInfo['productType'];

    return GestureDetector(
      onTap: _handleProductTap,
      child: SizedBox(
        width: widget.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Wishlist Icon
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: widget.imageHeight,
                    width: widget.width,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (context, url, progress) =>
                        HelperFunctions().loadingIndicator(),
                    errorWidget: (context, url, error) {
                      return Container(
                        color: colorScheme.surfaceVariant,
                        child: Icon(
                          Icons.error,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                ),
                // Wishlist Button
                Positioned(
                  left: 3,
                  top: 3,
                  child: GestureDetector(
                    onTap: _handleWishlistTap,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: colorScheme.surface,
                            ),
                            padding: const EdgeInsets.all(6.0),
                            child: GetBuilder<WishlistController>(
                              builder: (controller) {
                                final isInWishlist = controller
                                    .wishlistProductIds
                                    .contains(productId);
                                return SvgPicture.asset(
                                  isInWishlist
                                      ? 'assets/icon/like.svg'
                                      : 'assets/icon/unlike.svg',
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Product Name
            Text(
              productName,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            // Product Price
            if (productType == 'variable')
              VariablePriceText(
                lowestPrice: priceInfo['lowestPrice'],
                highestPrice: priceInfo['highestPrice'],
              )
            else
              SimplePriceText(
                price: priceInfo['productPrice'],
                originalPrice: priceInfo['discountPrice'],
                discountLabel: priceInfo['discountRate'],
              )
          ],
        ),
      ),
    );
  }
}
