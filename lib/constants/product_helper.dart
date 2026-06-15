import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';

/// Helper class for product-related calculations and utilities
class ProductHelper {
  /// Calculate price information for a product
  /// Returns a map with productPrice, discountPrice, discountRate, lowestPrice, highestPrice
  static Map<String, dynamic> calculatePriceInfo(Map<String, dynamic> product,
      {int? variantIndex}) {
    final productType = product['type'] ?? 'simple';

    if (productType == 'variable') {
      if (variantIndex != null) {
        return _calculateVariantPrice(product, variantIndex);
      }
      return _calculateVariableProductPrice(product);
    } else {
      return _calculateSimpleProductPrice(product);
    }
  }

  /// Calculate prices for a specific variant
  static Map<String, dynamic> _calculateVariantPrice(
      Map<String, dynamic> product, int variantIndex) {
    final variants = product['variants'] ?? [];
    if (variants.isEmpty || variantIndex >= variants.length) {
      return _calculateSimpleProductPrice(product);
    }

    final variant = variants[variantIndex];
    final salePrice =
        HelperFunctions.parseAmount(variant['sale_price'] ?? variant['price']);
    final regularPrice = HelperFunctions.parseAmount(variant['price']);

    String productPrice = salePrice.toString();
    String discountPrice = regularPrice.toString();
    String discountRate = '';

    if (regularPrice > salePrice && salePrice > 0) {
      final discount = (100 - (salePrice * 100 / regularPrice)).round();
      discountRate = " $discount% off";
    }

    return {
      'productType': 'variable',
      'productPrice': productPrice,
      'salePrice': discountPrice,
      'discountRate': discountRate,
      'lowestPrice': '0',
      'highestPrice': '0',
      'hasValidVariants': true,
    };
  }

  /// Calculate prices for variable products (range)
  static Map<String, dynamic> _calculateVariableProductPrice(
      Map<String, dynamic> product) {
    final List variants = product['variants'] ?? [];

    if (variants.isEmpty) {
      return {
        'productType': 'variable',
        'lowestPrice': '0',
        'highestPrice': '0',
        'productPrice': '0',
        'salePrice': '0',
        'discountRate': '',
        'hasValidVariants': false,
      };
    }

    double minPrice = double.infinity;
    double maxPrice = 0;
    double minOriginalPrice = double.infinity;

    for (var variant in variants) {
      double price = HelperFunctions.parseAmount(variant['price']);
      double salePrice = HelperFunctions.parseAmount(variant['sale_price']);

      // Use sale price only if > 0
      double effectivePrice =
          (salePrice > 0 && salePrice < price) ? salePrice : price;

      if (effectivePrice > 0 && effectivePrice < minPrice) {
        minPrice = effectivePrice;
      }

      if (effectivePrice > maxPrice) {
        maxPrice = effectivePrice;
      }

      if (price > 0 && price < minOriginalPrice) {
        minOriginalPrice = price;
      }
    }

    if (minPrice == double.infinity) minPrice = 0;
    if (minOriginalPrice == double.infinity) minOriginalPrice = minPrice;

    // Calculate discount if applicable
    String discountRate = '';
    if (minOriginalPrice > minPrice) {
      double discount =
          ((minOriginalPrice - minPrice) / minOriginalPrice) * 100;
      discountRate = "${discount.toStringAsFixed(0)}% off";
    }

    return {
      'productType': 'variable',
      'lowestPrice': minPrice.toStringAsFixed(0),
      'highestPrice': maxPrice.toStringAsFixed(0),
      'productPrice': minPrice.toStringAsFixed(0),
      'salePrice': minPrice < minOriginalPrice
          ? minOriginalPrice.toStringAsFixed(0)
          : '0',
      'discountRate': discountRate,
      'hasValidVariants': true,
    };
  }

  /// Calculate prices for simple products
  static Map<String, dynamic> _calculateSimpleProductPrice(
      Map<String, dynamic> product) {
    var source = product;

    // If variants exist, prioritize the first variant for pricing
    if (product['variants'] != null &&
        (product['variants'] as List).isNotEmpty) {
      source = product['variants'][0];
    }

    final salePrice = HelperFunctions.parseAmount(source['sale_price']);
    final regularPrice = HelperFunctions.parseAmount(source['price']);

    String productPrice = (salePrice > 0 && salePrice < regularPrice)
        ? salePrice.toString()
        : regularPrice.toString();
    String discountPrice = (salePrice > 0 && salePrice < regularPrice)
        ? regularPrice.toString()
        : "";
    String discountRate = '';

    if (salePrice > 0 && regularPrice > salePrice) {
      final discount = (100 - (salePrice * 100 / regularPrice)).round();
      discountRate = " $discount% off";
    }

    return {
      'productType': 'simple',
      'productPrice': productPrice,
      'salePrice': discountPrice,
      'discountRate': discountRate,
      'lowestPrice': '0',
      'highestPrice': '0',
      'hasValidVariants': true,
    };
  }

  /// Get product images based on variant
  static List<dynamic> getProductGallery(Map<String, dynamic> product,
      {int? variantIndex}) {
    if (product['type'] == 'variable' && variantIndex != null) {
      final variants = product['variants'];
      if (variants is List &&
          variantIndex >= 0 &&
          variantIndex < variants.length) {
        final variantImages = variants[variantIndex]['gallery'];
        if (variantImages is List && variantImages.isNotEmpty) {
          return variantImages;
        }
      }
    }
    // return product['gallery'] ?? [];
    final gallery = product['gallery'];

    if (gallery is List && gallery.isNotEmpty) {
      return gallery;
    }

    // Fallback to featured_image
    final featuredImage = product['featured_image'];
    if (featuredImage != null && featuredImage.toString().isNotEmpty) {
      return [featuredImage]; // return as list
    }

    return [];
  }

  /// Get product image URL
  /// Handles both featured_image and variant images
  static String getProductImage(Map<String, dynamic> product,
      {int? variantIndex}) {
    if (variantIndex != null) {
      final gallery = getProductGallery(product, variantIndex: variantIndex);
      if (gallery.isNotEmpty) {
        final firstImage = gallery.first;
        if (firstImage is Map) {
          return HelperFunctions().getImage(
            firstImage,
            isLog: false,
            moduleName: 'ProductHelper',
          );
        }
      }
    }

    final featuredImage = product['featured_image'];
    if (featuredImage != null) {
      return HelperFunctions().getImage(
        featuredImage,
        isLog: false,
        moduleName: 'ProductHelper',
      );
    }

    return HelperFunctions.getNoImage();
  }

  /// Check if product is in stock
  static bool isInStock(Map<String, dynamic> product, {int? variantIndex}) {
    bool qtyInStock(dynamic qty) {
      if (qty == null) return true;
      return HelperFunctions.parseAmount(qty) > 0;
    }

    final productType = product['type'] ?? 'simple';
    final variants = product['variants'];
    final hasVariants = variants is List && variants.isNotEmpty;

    if (productType == 'variable' || hasVariants) {
      final List variantList = hasVariants ? variants : [];
      if (variantIndex != null && variantIndex < variantList.length) {
        return qtyInStock(variantList[variantIndex]['quantity']);
      }
      for (var variant in variantList) {
        if (qtyInStock(variant['quantity'])) return true;
      }
      return false;
    }

    return qtyInStock(product['quantity']);
  }

  /// Get product name
  static String getProductName(Map<String, dynamic> product) {
    return product['name'] ?? '';
  }

  /// Get product ID
  static String getProductId(Map<String, dynamic> product) {
    return product['_id'] ?? product['id'] ?? '';
  }

  static Widget buildPriceWidget(
      {required var product, required BuildContext context}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    var priceInfo = calculatePriceInfo(product);

    if (product['type'] == 'variable') {
      _buildVariablePrice(priceInfo, textTheme, colorScheme);
    } else {
      _buildSimplePrice(priceInfo, textTheme, colorScheme);
    }

    return SizedBox();
  }

  static Widget _buildVariablePrice(
    Map<String, dynamic> priceInfo,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Text(
      '₹${priceInfo['lowestPrice']} - ₹${priceInfo['highestPrice']}',
      style: textTheme.bodyMedium!.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.primary,
      ),
    );
  }

  static Widget _buildSimplePrice(
    Map<String, dynamic> priceInfo,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return RichText(
      text: TextSpan(
        text: '₹${priceInfo['productPrice']}',
        style: textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
        children: [
          if (priceInfo['discountRate'].isNotEmpty) ...[
            const TextSpan(text: '  '),
            TextSpan(
              text: '₹${priceInfo['discountPrice']}',
              style: textTheme.bodySmall!.copyWith(
                decoration: TextDecoration.lineThrough,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: priceInfo['discountRate'],
              style: textTheme.bodySmall!.copyWith(
                color: colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build rating stars and review count widget
  static Widget buildRatingWidget(Map<String, dynamic> product,
      TextTheme textTheme, ColorScheme colorScheme,
      {double starSize = 12.0}) {
    final rawRating = product['average_rating'];
    final rawCount = product['rating_count'];
    final double rating = double.tryParse(rawRating?.toString() ?? '0') ?? 0.0;
    final int count = int.tryParse(rawCount?.toString() ?? '0') ?? 0;

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(5, (index) {
              IconData icon;
              if (index < rating.floor()) {
                icon = Icons.star;
              } else if (index < rating && rating - index >= 0.5) {
                icon = Icons.star_half;
              } else {
                icon = Icons.star_border;
              }
              return Icon(
                icon,
                color: const Color(0xFFFFBA49),
                size: starSize,
              );
            }),
          ),
          const SizedBox(width: 4),
          Text(
            '($count)',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              fontSize: starSize - 2 > 8 ? starSize - 2 : 9,
            ),
          ),
        ],
      ),
    );
  }
}
