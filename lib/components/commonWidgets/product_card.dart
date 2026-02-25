import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '/app/modules/product/views/product_view.dart';
import '/app/modules/wishlist/controllers/wishlist_controller.dart';
import '/constants/helper_functions.dart';
import '/constants/product_helper.dart';
import '/constants/dynamic_theme.dart';
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
    this.width,
    this.imageHeight,
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
    final height = Get.height;
    final width = widget.width ?? Get.width * 0.4;
    final imageHeight = widget.imageHeight ?? height * 0.18;

    // Get product information using helper
    final productName = ProductHelper.getProductName(widget.product);
    final productId = ProductHelper.getProductId(widget.product);
    final imageUrl = ProductHelper.getProductImage(widget.product);
    final priceInfo = ProductHelper.calculatePriceInfo(widget.product);
    final productType = priceInfo['productType'];

    // Get store name (you'll need to adjust this based on your data structure)
    final storeName = widget.product['storeName'] ?? 'Store Name';

    // Get rating (you'll need to adjust this based on your data structure)
    final rating = widget.product['rating'] ?? 4.5;

    // Get theme data explicitly to avoid extension conflicts
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(height * 0.015),
      onTap: _handleProductTap,
      child: Container(
        padding: EdgeInsets.all(width * 0.02),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height * 0.015),
          border: Border.all(
            color: colorScheme.outline, // Using colorScheme directly
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Wishlist Icon
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: imageHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(height * 0.012),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(height * 0.012),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
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
                                  colorFilter: ColorFilter.mode(
                                    isInWishlist
                                        ? colorScheme.error
                                        : colorScheme.onSurfaceVariant,
                                    BlendMode.srcIn,
                                  ),
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

            SizedBox(height: height * 0.01),

            // Product Title
            Text(
              productName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: height * 0.018,
                height: 1.4,
              ),
            ),

            SizedBox(height: height * 0.004),

            // Store Name
            Text(
              storeName,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: height * 0.015,
                height: 2,
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const Spacer(),

            // Price & Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price
                Row(
                  children: [
                    Icon(
                      Icons.sell_outlined,
                      size: height * 0.02,
                      color: colorScheme.primary,
                    ),
                    SizedBox(width: width * 0.005),
                    // Product Price based on type
                    if (productType == 'variable')
                      Text(
                        '₹${priceInfo['lowestPrice']} - ₹${priceInfo['highestPrice']}',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: height * 0.018,
                          color: colorScheme.primary,
                        ),
                      )
                    else
                      RichText(
                        text: TextSpan(
                          text: '₹${priceInfo['productPrice']}',
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: height * 0.018,
                            color: colorScheme.primary,
                          ),
                          children: [
                            if (priceInfo['discountRate'].isNotEmpty) ...[
                              const TextSpan(text: '  '),
                              TextSpan(
                                text: '₹${priceInfo['discountPrice']}',
                                style: textTheme.bodySmall?.copyWith(
                                  fontSize: height * 0.014,
                                  decoration: TextDecoration.lineThrough,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const TextSpan(text: ' '),
                              TextSpan(
                                text: priceInfo['discountRate'],
                                style: textTheme.bodySmall?.copyWith(
                                  fontSize: height * 0.014,
                                  color: colorScheme.error,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),

                // Rating
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: height * 0.02,
                      color: DefaultThemeColors.alertWarninglight,
                    ),
                    SizedBox(width: width * 0.005),
                    Text(
                      rating.toString(),
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: height * 0.018,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
