import 'package:intl/intl.dart';
import 'package:zouhi/constants/constants.dart';

class CouponProductItem {
  final String id;
  final String name;
  final String slug;

  CouponProductItem({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory CouponProductItem.fromJson(Map<String, dynamic> json) {
    return CouponProductItem(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
    );
  }
}

class CouponModel {
  final String id;
  final String code;
  final String rawCouponType;
  final String rawDiscountType;
  final double discountValue;
  final double minAmount;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isPersonal;
  final bool allowMultipleUse;
  final List<CouponProductItem> productIds;
  final int productCount;

  CouponModel({
    required this.id,
    required this.code,
    required this.rawCouponType,
    required this.rawDiscountType,
    required this.discountValue,
    required this.minAmount,
    this.startDate,
    this.endDate,
    required this.isPersonal,
    required this.allowMultipleUse,
    required this.productIds,
    required this.productCount,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic dateVal) {
      if (dateVal == null) return null;
      try {
        return DateTime.parse(dateVal.toString());
      } catch (_) {
        return null;
      }
    }

    final rawProducts = json['product_ids'];
    List<CouponProductItem> products = [];
    if (rawProducts is List) {
      products = rawProducts
          .map((item) {
            if (item is Map) {
              return CouponProductItem.fromJson(Map<String, dynamic>.from(item));
            }
            return null;
          })
          .whereType<CouponProductItem>()
          .toList();
    }

    return CouponModel(
      id: json['_id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      rawCouponType: json['coupon_type']?.toString() ?? 'AMOUNT_OFF_PRODUCTS',
      rawDiscountType: json['discount_type']?.toString() ?? 'FLAT',
      discountValue: (json['discount_value'] as num?)?.toDouble() ?? 0.0,
      minAmount: (json['min_amount'] as num?)?.toDouble() ?? 0.0,
      startDate: parseDate(json['start_date']),
      endDate: parseDate(json['end_date']),
      isPersonal: json['is_personal'] == true,
      allowMultipleUse: json['allow_multiple_use_per_customer'] == true,
      productIds: products,
      productCount: (json['product_count'] as num?)?.toInt() ?? products.length,
    );
  }

  /// Currency symbol with fallback
  String get _curr => currency.isNotEmpty ? currency : '\$';

  /// "Product Discount", "Order Discount", etc.
  String get displayCouponType {
    switch (rawCouponType.toUpperCase()) {
      case 'AMOUNT_OFF_PRODUCTS':
      case 'PERCENT_OFF_PRODUCTS':
        return 'Product Discount';
      case 'AMOUNT_OFF_ORDER':
      case 'PERCENT_OFF_ORDER':
        return 'Order Discount';
      default:
        return rawCouponType
            .replaceAll('_', ' ')
            .toLowerCase()
            .split(' ')
            .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
            .join(' ');
    }
  }

  /// Badge text for top-right banner: "PRODUCT DISCOUNT"
  String get badgeText => displayCouponType.toUpperCase();

  /// "Flat Amount" or "Percentage"
  String get displayDiscountType {
    if (rawDiscountType.toUpperCase() == 'PERCENTAGE') {
      return 'Percentage';
    }
    return 'Flat Amount';
  }

  bool get isPercentage => rawDiscountType.toUpperCase() == 'PERCENTAGE';

  /// Formatted discount, e.g. "$10.00 OFF" or "15% OFF"
  String get displayDiscountOff {
    if (isPercentage) {
      return '${discountValue.toStringAsFixed(0)}% OFF';
    }
    return '$_curr${discountValue.toStringAsFixed(2)} OFF';
  }

  /// Headline: "Save $10.00 on this order!"
  String get savingsHeadline {
    if (isPercentage) {
      return 'Save ${discountValue.toStringAsFixed(0)}% on this order!';
    }
    return 'Save $_curr${discountValue.toStringAsFixed(2)} on this order!';
  }

  /// Subtitle: "Get $10.00 Off on orders above $10.00"
  String get orderConditionSubtitle {
    final discountStr = isPercentage
        ? '${discountValue.toStringAsFixed(0)}%'
        : '$_curr${discountValue.toStringAsFixed(2)}';

    if (minAmount > 0) {
      return 'Get $discountStr Off on orders above $_curr${minAmount.toStringAsFixed(2)}';
    }
    return 'Get $discountStr Off with no minimum order';
  }

  /// Formatted minimum order: "$10.00" or "None"
  String get displayMinOrder {
    if (minAmount > 0) {
      return '$_curr${minAmount.toStringAsFixed(2)}';
    }
    return 'None';
  }

  /// Formatted valid from date: "Oct 15, 2026"
  String get displayValidFrom {
    if (startDate != null) {
      return DateFormat('MMM dd, yyyy').format(startDate!);
    }
    return 'Available Now';
  }

  /// Formatted valid until date: "No Expiry" or "Nov 30, 2026"
  String get displayValidUntil {
    if (endDate != null) {
      return DateFormat('MMM dd, yyyy').format(endDate!);
    }
    return 'No Expiry';
  }

  /// Whether restricted to specific products
  bool get hasProductRestrictions => productIds.isNotEmpty || productCount > 0;

  /// Specific Products Scope label
  String get scopeBadgeLabel {
    if (hasProductRestrictions) {
      return 'Specific Products';
    }
    return 'All Products';
  }
}
