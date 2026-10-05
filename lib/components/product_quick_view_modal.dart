import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/product_helper.dart';
import 'package:foduu_ecommerce/core/services/cartServcie.dart';
import 'package:get/get.dart';

class ProductQuickViewModal extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductQuickViewModal({Key? key, required this.product})
      : super(key: key);

  static void show(BuildContext context, Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductQuickViewModal(product: product),
    );
  }

  @override
  State<ProductQuickViewModal> createState() => _ProductQuickViewModalState();
}

class _ProductQuickViewModalState extends State<ProductQuickViewModal> {
  int _quantity = 1;
  int _selectedVariantIndex = 0;
  bool _isAddingToCart = false;

  Map<String, dynamic> get product => widget.product;
  List get variants => (product['variants'] is List) ? product['variants'] : [];
  bool get hasVariants => variants.isNotEmpty;

  String get _productId => ProductHelper.getProductId(product);

  String get _currentVariantId {
    if (hasVariants && _selectedVariantIndex < variants.length) {
      final v = variants[_selectedVariantIndex];
      return (v['_id'] ?? v['id'] ?? '').toString();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final priceInfo = ProductHelper.calculatePriceInfo(
      product,
      variantIndex: hasVariants ? _selectedVariantIndex : null,
    );

    final imageUrl = ProductHelper.getProductImage(product);
    final productName = ProductHelper.getProductName(product);
    final inStock = ProductHelper.isInStock(
      product,
      variantIndex: hasVariants ? _selectedVariantIndex : null,
    );

    final priceStr = priceInfo['productPrice']?.toString() ?? '0';
    final regularPriceStr = priceInfo['salePrice']?.toString() ?? '';
    final hasDiscount = priceInfo['discountRate'] != null &&
        priceInfo['discountRate'].toString().trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle & close button row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.outlineColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded,
                      color: context.onSurfaceVariantColor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Product Hero Image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    progressIndicatorBuilder: (_, __, ___) =>
                        HelperFunctions().loadingIndicator(),
                    errorWidget: (_, __, ___) => Container(
                      color: context.surfaceVariantColor,
                      child: Icon(Icons.image_outlined,
                          size: 48, color: context.onSurfaceVariantColor),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Rating Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => const Icon(
                  Icons.star_rounded,
                  size: 18,
                  color: DefaultThemeColors.alertWarninglight,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Product Title
            Text(
              productName,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.onSurfaceColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),

            // Price Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ProductHelper.formatPrice(priceStr),
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                if (hasDiscount && regularPriceStr.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    ProductHelper.formatPrice(regularPriceStr),
                    style: textTheme.bodyMedium?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: context.onSurfaceVariantColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      priceInfo['discountRate'].toString().trim(),
                      style: TextStyle(
                        color: colorScheme.error,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),

            // Stock status
            Center(
              child: Text(
                inStock ? 'In Stock' : 'Out of Stock',
                style: TextStyle(
                  color: inStock
                      ? DefaultThemeColors.alertSuccessLight
                      : colorScheme.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Variant Selector (if variable)
            if (hasVariants) ...[
              Text(
                'Select Option:',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.onSurfaceColor,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(variants.length, (idx) {
                  final v = variants[idx];
                  final label = (v['title'] ?? v['name'] ?? 'Option ${idx + 1}')
                      .toString();
                  final isSelected = _selectedVariantIndex == idx;
                  return ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedVariantIndex = idx);
                      }
                    },
                    selectedColor: colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : context.onSurfaceColor,
                      fontSize: 12,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
            ],

            // Quantity & Add to Cart Row
            Row(
              children: [
                // Quantity Stepper
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: context.outlineColor.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                      ),
                      Text(
                        '$_quantity',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: inStock
                            ? () => setState(() => _quantity++)
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Add to Cart Button
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: inStock && !_isAddingToCart
                          ? () => _addToCart(context)
                          : null,
                      icon: _isAddingToCart
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.shopping_bag_outlined, size: 20),
                      label: Text(
                        _isAddingToCart ? 'Adding...' : 'Add to Cart',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // View Details Text Button
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.toNamed(
                    Routes.PRODUCTDETAILS,
                    arguments: {'productId': _productId},
                  );
                },
                child: Text(
                  'View Full Product Details →',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToCart(BuildContext context) async {
    setState(() => _isAddingToCart = true);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final nav = Navigator.of(context);

    try {
      final variantId = _currentVariantId;
      await CartService.to.manageCart(
        productId: _productId,
        variantId: variantId,
        quantity: _quantity,
        product: product,
      );

      if (mounted) {
        nav.pop();
        Get.snackbar(
          'Added to Cart',
          '${ProductHelper.getProductName(product)} added to your cart',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: primaryColor,
          colorText: onPrimaryColor,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      debugPrint('Quick view add to cart error: $e');
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }
}
