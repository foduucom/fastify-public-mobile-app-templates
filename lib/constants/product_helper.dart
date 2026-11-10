import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '/constants/helper_functions.dart';

/// Helper class for product-related calculations and utilities
class ProductHelper {
  static double _number(dynamic value) => HelperFunctions.parseAmount(value);

  /// Formats a price value as a string with optional currency symbol.
  /// Used by product cards, quick view modals, and shop views.
  static String formatPrice(dynamic price, {String symbol = '₹'}) {
    if (price == null) return '${symbol}0';
    if (price is String) {
      final trimmed = price.trim();
      if (trimmed.isEmpty) return '${symbol}0';
      if (trimmed.contains('-')) {
        final parts = trimmed.split('-');
        if (parts.length == 2) {
          final p1 = double.tryParse(parts[0].replaceAll(RegExp(r'[^\d.]'), '').trim());
          final p2 = double.tryParse(parts[1].replaceAll(RegExp(r'[^\d.]'), '').trim());
          if (p1 != null && p2 != null) {
            if (p1 == p2) {
              return formatPrice(p1, symbol: symbol);
            }
            return '${formatPrice(p1, symbol: symbol)} - ${formatPrice(p2, symbol: symbol)}';
          }
        }
      }
    }
    final double value = (price is String)
        ? double.tryParse(price.toString().replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0
        : (price as num).toDouble();
    // Remove trailing zeros for whole numbers
    if (value == value.truncate()) {
      return '$symbol${value.toInt()}';
    }
    return '$symbol${value.toStringAsFixed(2)}';
  }

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
    final salePrice = _number(variant['sale_price'] ?? variant['price']);
    final regularPrice = _number(variant['price']);

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
      final price = _number(variant['price']);
      final salePrice = _number(variant['sale_price']);

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

    final salePrice = _number(source['sale_price']);
    final regularPrice = _number(source['price']);

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

    // Fallback to featured_image or front_image
    final featuredImage = product['featured_image'];
    if (featuredImage != null && featuredImage.toString().isNotEmpty) {
      return [featuredImage]; // return as list
    }
    final frontImage = product['front_image'];
    if (frontImage != null && frontImage.toString().isNotEmpty) {
      return [frontImage];
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
          final img = HelperFunctions().getImage(
            firstImage,
            isLog: false,
            moduleName: 'ProductHelper',
          );
          if (img.isNotEmpty && img != HelperFunctions.getNoImage()) {
            return img;
          }
        }
      }
    }

    final featuredImage = product['featured_image'];
    if (featuredImage != null && featuredImage.toString().isNotEmpty) {
      final img = HelperFunctions().getImage(
        featuredImage,
        isLog: false,
        moduleName: 'ProductHelper',
      );
      if (img.isNotEmpty && img != HelperFunctions.getNoImage()) {
        return img;
      }
    }

    final frontImage = product['front_image'];
    if (frontImage != null && frontImage.toString().isNotEmpty) {
      final img = HelperFunctions().getImage(
        frontImage,
        isLog: false,
        moduleName: 'ProductHelper',
      );
      if (img.isNotEmpty && img != HelperFunctions.getNoImage()) {
        return img;
      }
    }

    // Comprehensive fallback via resolveProductImage
    final resolved = HelperFunctions.resolveProductImage(product);
    if (resolved.isNotEmpty) {
      return resolved;
    }

    return HelperFunctions.getNoImage();
  }

  /// Check if product is in stock
  static bool isInStock(Map<String, dynamic> product, {int? variantIndex}) {
    bool isItemInStock(dynamic item) {
      if (item is! Map) return true;

      final status =
          (item['stock_status'] ?? '').toString().toLowerCase().trim();
      if (status == 'out_of_stock' || status == 'outofstock') {
        return false;
      }

      final qty = item['quantity'];
      if (qty == null) return true;
      return HelperFunctions.parseAmount(qty) > 0;
    }

    final productType = product['type'] ?? 'simple';
    final variants = product['variants'];
    final hasVariants = variants is List && variants.isNotEmpty;

    if (productType == 'variable' || hasVariants) {
      final List variantList = hasVariants ? variants : [];
      if (variantIndex != null && variantIndex < variantList.length) {
        return isItemInStock(variantList[variantIndex]);
      }
      for (var variant in variantList) {
        if (isItemInStock(variant)) return true;
      }
      return false;
    }

    return isItemInStock(product);
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
}
