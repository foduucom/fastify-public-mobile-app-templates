import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';

/// Helper class for product-related calculations and utilities
class ProductHelper {
  /// Calculate price information for a product
  /// Returns a map with productPrice, discountPrice, discountRate, lowestPrice, highestPrice
  static Map<String, dynamic> calculatePriceInfo(Map<String, dynamic> product) {
    final productType = product['type'] ?? 'simple';

    if (productType == 'variable') {
      return _calculateVariableProductPrice(product);
    } else {
      return _calculateSimpleProductPrice(product);
    }
  }

  /// Calculate prices for variable products with variants
  static Map<String, dynamic> _calculateVariableProductPrice(
      Map<String, dynamic> product) {
    final variants = product['variants'] ?? [];

    if (variants.isEmpty) {
      return {
        'productType': 'variable',
        'lowestPrice': 0,
        'highestPrice': 0,
        'productPrice': 0,
        'discountPrice': 0,
        'discountRate': '',
        'hasValidVariants': false,
      };
    }

    // Calculate lowest and highest prices from variants
    num minPrice = variants.first['sale_price'] ?? variants.first['price'] ?? 0;

    num maxPrice = minPrice;

    for (var variant in variants) {
      final variantPrice = variant['sale_price'] ?? variant['price'] ?? 0;
      if (variantPrice < minPrice && variantPrice > 0) minPrice = variantPrice;
      if (variantPrice > maxPrice) maxPrice = variantPrice;
    }

    return {
      'productType': 'variable',
      'lowestPrice': minPrice,
      'highestPrice': maxPrice,
      'productPrice': '0',
      'discountPrice': '0',
      'discountRate': '',
      'hasValidVariants': true,
    };
  }

  /// Calculate prices for simple products
  static Map<String, dynamic> _calculateSimpleProductPrice(
      Map<String, dynamic> product) {
    // Robust price extraction with multiple fallbacks
    num salePrice = _parseNum(product['sale_price'] ??
        product['discount_price'] ??
        product['discounted_price']);

    num regularPrice = _parseNum(
        product['price'] ?? product['regular_price'] ?? product['mrp']);

    // BI-99: Fallback to variants if top-level prices are 0 (e.g., "pajama" product)
    if (salePrice == 0 && regularPrice == 0) {
      final variants = product['variants'];
      if (variants is List && variants.isNotEmpty) {
        final defaultVariant = variants.firstWhere(
            (v) => v['is_default'] == true,
            orElse: () => variants.first);
        if (defaultVariant != null) {
          salePrice = _parseNum(defaultVariant['sale_price']);
          regularPrice = _parseNum(defaultVariant['price']);
        }
      }
    }

    num productPrice = (salePrice > 0) ? salePrice : regularPrice;
    num discountPrice =
        (salePrice > 0 && regularPrice > salePrice) ? regularPrice : 0;
    String discountRate = "";

    if (salePrice > 0 && regularPrice > salePrice) {
      final discount = (100 - (salePrice * 100 / regularPrice)).round();
      if (discount > 0) discountRate = " $discount% off";
    }

    return {
      'productType': 'simple',
      'productPrice': productPrice,
      'discountPrice': discountPrice,
      'discountRate': discountRate,
      'lowestPrice': '0',
      'highestPrice': '0',
      'hasValidVariants': true,
    };
  }

  static num _parseNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }

  /// Get product image URL
  /// Handles both featured_image and variant images
  static String getProductImage(Map<String, dynamic> product) {
    final featuredImage = product['featured_image'];

    // Try using HelperFunctions.getImage first
    if (featuredImage != null) {
      return HelperFunctions().getImage(
        featuredImage,
        isLog: false,
        moduleName: 'ProductHelper',
      );
    }

    // Fallback: try to get from variants if variable product
    if (product['type'] == 'variable') {
      final variants = product['variants'];
      if (variants is List && variants.isNotEmpty) {
        final images = variants.first['images'];
        if (images is List && images.isNotEmpty) {
          final firstImage = images.first;
          if (firstImage['filepath'] != null) {
            return url + 'images/' + firstImage['filepath'];
          }
        }
      }
    }

    return HelperFunctions.getNoImage();
  }

  /// Check if product is in stock
  static bool isInStock(Map<String, dynamic> product) {
    final productType = product['type'] ?? 'simple';

    if (productType == 'variable') {
      final variants = product['variants'] ?? [];
      for (var variant in variants) {
        final quantity = variant['quantity'] ?? 0;
        if (quantity > 0) return true;
      }
      return false;
    } else {
      final quantity = product['quantity'] ?? 0;
      return quantity > 0;
    }
  }

  /// Get product name
  static String getProductName(Map<String, dynamic> product) {
    return product['name'] ?? '';
  }

  /// Get product ID
  static String getProductId(Map<String, dynamic> product) {
    return product['_id'] ?? '';
  }
}
