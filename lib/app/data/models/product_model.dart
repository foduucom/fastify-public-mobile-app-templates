class Product {
  final String id;
  final String name;
  final dynamic featuredImage;
  final String rawPrice;
  final String rawSalePrice;
  final String type;
  final List<dynamic> variants;
  final List<Review> reviews;
  final dynamic quantity;
  final dynamic status;
  final bool isRegistry;
  final double? rawAverageRating;
  final int? rawRatingCount;
  final CatalogMode catalogMode;

  Product({
    required this.id,
    required this.name,
    required this.featuredImage,
    required this.rawPrice,
    required this.rawSalePrice,
    required this.type,
    required this.variants,
    required this.reviews,
    this.quantity,
    this.status,
    this.isRegistry = false,
    this.rawAverageRating,
    this.rawRatingCount,
    this.catalogMode = const CatalogMode(),
  });

  static String _parsePrice(dynamic price) {
    if (price == null) return '0';
    if (price is Map && price.containsKey(r'$numberDecimal')) {
      return price[r'$numberDecimal'].toString();
    }
    return price.toString();
  }

  static double? _parseRating(dynamic val) {
    if (val == null) return null;
    if (val is Map && val.containsKey(r'$numberDecimal')) {
      return double.tryParse(val[r'$numberDecimal']?.toString() ?? '');
    }
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString());
  }

  static int? _parseRatingCount(dynamic val) {
    if (val == null) return null;
    if (val is Map && val.containsKey(r'$numberDecimal')) {
      return int.tryParse(val[r'$numberDecimal']?.toString() ?? '');
    }
    if (val is num) return val.toInt();
    return int.tryParse(val.toString());
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    var reviewsList = json['reviews'] as List?;
    List<Review> parsedReviews = reviewsList != null
        ? reviewsList
            .map((r) => Review.fromJson(Map<String, dynamic>.from(r)))
            .toList()
        : [];

    final parsedRating = _parseRating(json['average_rating'] ?? json['rating']);
    final parsedRatingCount = _parseRatingCount(
        json['rating_count'] ?? json['review_count'] ?? json['reviews_count']);

    return Product(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      featuredImage: json['featured_image'] ?? json['image'],
      rawPrice: _parsePrice(json['price']),
      rawSalePrice: _parsePrice(json['sale_price']),
      type: json['type'] ?? 'simple',
      variants: (json['variants'] ?? json['variant_ids'] ?? []) as List,
      reviews: parsedReviews,
      quantity: json['quantity'] ?? json['stock'] ?? json['stock_quantity'],
      status: json['status'] ?? json['stock_status'],
      isRegistry: json['is_registry'] == true,
      rawAverageRating: parsedRating,
      rawRatingCount: parsedRatingCount,
      catalogMode: CatalogMode.fromJson(json['catalog_mode']),
    );
  }

  bool get isCatalogMode => catalogMode.isEnabled;
  String get catalogButtonText => catalogMode.buttonText;

  // Helper method for price calculations exactly mirroring trending_product_card.dart
  Map<String, dynamic> get _calculatedPrices {
    double? originalPrice;
    double? salePrice;
    String? variantId;

    bool isVariable = type == 'variable' || type == 'variant';

    bool isVariantInStock(Map v) {
      final vStatus = v['stock_status']
          ?.toString()
          .toLowerCase()
          .replaceAll('_', '')
          .replaceAll(' ', '');
      if (vStatus == 'outofstock') return false;

      final qty = v['quantity'] ?? v['stock'] ?? v['stock_quantity'];
      if (qty != null) {
        final parsedQty = int.tryParse(qty.toString());
        if (parsedQty != null && parsedQty <= 0) return false;
      }
      return true;
    }

    if (type == 'simple' || type == 'product') {
      // Find the default variant; fall back to first if none marked
      Map? defaultVariant;
      for (var v in variants) {
        if (v is Map && v['is_default'] == true) {
          defaultVariant = v;
          break;
        }
      }
      defaultVariant ??= (variants.isNotEmpty && variants.first is Map)
          ? variants.first as Map
          : null;

      if (defaultVariant != null) {
        variantId = defaultVariant['_id']?.toString();
        originalPrice =
            double.tryParse(defaultVariant['price']?.toString() ?? '');
        salePrice =
            double.tryParse(defaultVariant['sale_price']?.toString() ?? '');
      } else {
        // Absolute fallback to product-level fields
        originalPrice = double.tryParse(rawPrice);
        salePrice = double.tryParse(rawSalePrice);
      }
    } else if (isVariable) {
      // Find variant with lowest effective price (preferring in-stock variants)
      Map? lowestVariant;
      double? minEffective;

      for (var pass = 0; pass < 2; pass++) {
        // Pass 0: check in-stock variants only; Pass 1: fallback to all variants
        for (var v in variants) {
          if (v is! Map) continue;
          if (pass == 0 && !isVariantInStock(v)) continue;

          double vP = double.tryParse(v['price']?.toString() ?? '') ?? 0;
          double? vSP = double.tryParse(v['sale_price']?.toString() ?? '');
          double effective = (vSP != null && vSP > 0) ? vSP : vP;

          if (minEffective == null || effective < minEffective) {
            minEffective = effective;
            lowestVariant = v;
          }
        }
        if (lowestVariant != null) break;
      }

      if (lowestVariant != null) {
        variantId = lowestVariant['_id']?.toString();
        originalPrice =
            double.tryParse(lowestVariant['price']?.toString() ?? '');
        salePrice =
            double.tryParse(lowestVariant['sale_price']?.toString() ?? '');
      }
    }

    // Normalise: treat sale_price == 0 as no discount
    if (salePrice != null && salePrice <= 0) salePrice = null;

    return {
      'originalPrice': originalPrice,
      'salePrice': salePrice,
      'variantId': variantId,
    };
  }

  // Getter for the display regular/original price
  String get price {
    final prices = _calculatedPrices;
    final double? originalPrice = prices['originalPrice'];
    return originalPrice?.toStringAsFixed(2) ?? '0.00';
  }

  // Getter for the display sale price
  String get salePrice {
    final prices = _calculatedPrices;
    final double? salePrice = prices['salePrice'];
    return salePrice?.toStringAsFixed(2) ?? '0';
  }

  // Getter for the calculated default or lowest variant ID
  String? get defaultVariantId {
    final prices = _calculatedPrices;
    return prices['variantId'];
  }

  // Calculated fields (Computed Properties)
  double? get averageRating {
    if (reviews.isNotEmpty) {
      double total = 0.0;
      for (var review in reviews) {
        total += review.rating;
      }
      return reviews.isNotEmpty ? total / reviews.length : null;
    }
    if (rawAverageRating != null && rawAverageRating! > 0) {
      return rawAverageRating;
    }
    return null;
  }

  int? get reviewCount {
    if (reviews.isNotEmpty) {
      return reviews.length;
    }
    if (rawRatingCount != null && rawRatingCount! > 0) {
      return rawRatingCount;
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'featured_image': featuredImage,
      'price': price,
      'sale_price': salePrice,
      'type': type,
      'variants': variants,
      'reviews': reviews.map((r) => r.toJson()).toList(),
      'quantity': quantity,
      'status': status,
      'average_rating': averageRating,
      'rating_count': reviewCount,
    };
  }

  bool get isOutOfStock {
    // 1. Check explicit stock status / flags if present at product level
    if (status != null) {
      final s = status
          .toString()
          .toLowerCase()
          .replaceAll('_', '')
          .replaceAll(' ', '');
      if (s == 'outofstock') return true;
    }

    // 2. Check variant stock: parent product is in stock if at least one variant is available
    if (variants.isNotEmpty) {
      bool hasInStockVariant = false;
      bool checkedVariants = false;

      for (var v in variants) {
        if (v is Map) {
          checkedVariants = true;
          final vStatus = v['stock_status']
              ?.toString()
              .toLowerCase()
              .replaceAll('_', '')
              .replaceAll(' ', '');
          if (vStatus == 'outofstock') continue;

          final qty = v['quantity'] ?? v['stock'] ?? v['stock_quantity'];
          if (qty != null) {
            final parsedQty = int.tryParse(qty.toString());
            if (parsedQty != null && parsedQty <= 0) {
              continue;
            }
          }
          hasInStockVariant = true;
          break;
        }
      }

      if (checkedVariants) {
        return !hasInStockVariant;
      }
    }

    // 3. Fallback to product-level quantity
    if (quantity != null) {
      final parsedQty = int.tryParse(quantity.toString());
      return parsedQty != null && parsedQty <= 0;
    }
    return false;
  }
}

class Review {
  final String id;
  final double rating;
  final String comment;

  Review({
    required this.id,
    required this.rating,
    required this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id']?.toString() ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      comment: json['comment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'rating': rating,
      'comment': comment,
    };
  }
}

class CatalogMode {
  final bool isEnabled;
  final String buttonText;
  final String contactUrl;

  const CatalogMode({
    this.isEnabled = false,
    this.buttonText = 'Contact for Pricing',
    this.contactUrl = '/contact',
  });

  factory CatalogMode.fromJson(dynamic json) {
    if (json is! Map) return const CatalogMode();
    return CatalogMode(
      isEnabled: json['is_enabled'] == true,
      buttonText: json['button_text']?.toString() ?? 'Contact for Pricing',
      contactUrl: json['contact_url']?.toString() ?? '/contact',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_enabled': isEnabled,
      'button_text': buttonText,
      'contact_url': contactUrl,
    };
  }
}

