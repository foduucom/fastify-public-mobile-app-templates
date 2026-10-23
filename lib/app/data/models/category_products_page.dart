import 'package:zouhi/app/data/models/product_model.dart' show CatalogMode;

/// Light-weight models for `GET products/by-parent-category/{id}`.
///
/// The backend embeds the full `owner_id` user object in every product; it is
/// deliberately never read here so it can't leak into memory or storage.
class CategoryProduct {
  final String id;
  final String name;
  final String slug;
  final String description;
  final dynamic image;
  final double price;
  final double? salePrice;
  final double? averageRating;
  final int ratingCount;
  final String type;

  /// `_id` of the variant whose price is shown; the cart API requires it for
  /// variable products.
  final String variantId;
  final CatalogMode catalogMode;

  const CategoryProduct({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.image,
    required this.price,
    this.salePrice,
    this.averageRating,
    this.ratingCount = 0,
    this.type = 'simple',
    this.variantId = '',
    this.catalogMode = const CatalogMode(),
  });

  /// Sale price when it is a real discount, otherwise the regular price.
  double get effectivePrice =>
      (salePrice != null && salePrice! > 0 && salePrice! < price)
          ? salePrice!
          : price;

  bool get isCatalogMode =>
      catalogMode.isEnabled || effectivePrice <= 0 || price <= 0;

  String get catalogButtonText => catalogMode.buttonText;
  String get catalogContactUrl => catalogMode.contactUrl;

  bool get hasDiscount => !isCatalogMode && effectivePrice < price;

  int get discountPercent => hasDiscount && price > 0
      ? (((price - effectivePrice) / price) * 100).round()
      : 0;

  bool get hasRating =>
      averageRating != null && averageRating! > 0 && ratingCount > 0;

  /// Mongo decimals arrive as `{"$numberDecimal": "155.77"}`.
  static double? _num(dynamic v) {
    if (v == null) return null;
    if (v is Map) return _num(v['\$numberDecimal']);
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static dynamic _pickImage(Map<String, dynamic> json) {
    final featured = json['featured_image'];
    if (featured != null && featured.toString().isNotEmpty) return featured;
    final external = json['external_image_url'];
    if (external is String && external.trim().isNotEmpty) return external;
    final gallery = json['gallery'];
    if (gallery is List && gallery.isNotEmpty) return gallery.first;
    return null;
  }

  /// Variable products carry 0/null at the top level; the real price lives on
  /// the default (else first priced) variant, as on the parent site.
  static Map<String, dynamic>? _pickVariant(dynamic variants) {
    if (variants is! List) return null;
    final list = variants
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    for (final v in list) {
      final p = _num(v['price']) ?? 0;
      final sp = _num(v['sale_price']) ?? 0;
      if (v['is_default'] == true && (p > 0 || sp > 0)) return v;
    }
    for (final v in list) {
      final p = _num(v['price']) ?? 0;
      final sp = _num(v['sale_price']) ?? 0;
      if (p > 0 || sp > 0) return v;
    }
    return list.isNotEmpty ? list.first : null;
  }

  factory CategoryProduct.fromJson(Map<String, dynamic> json) {
    var price = _num(json['price']) ?? 0;
    var salePrice = _num(json['sale_price']);
    final pickedVariant =
        _pickVariant(json['variants'] ?? json['variant_ids']);

    if (pickedVariant != null) {
      final vp = _num(pickedVariant['price']) ?? 0;
      final vsp = _num(pickedVariant['sale_price']);
      final vcp = _num(pickedVariant['compare_price']) ??
          _num(pickedVariant['regular_price']) ??
          _num(pickedVariant['mrp']);

      if (vcp != null && vcp > 0 && (vp > 0 || (vsp != null && vsp > 0))) {
        price = vcp;
        salePrice = (vsp != null && vsp > 0) ? vsp : vp;
      } else if (vp > 0 && vsp != null && vsp > 0 && vsp < vp) {
        price = vp;
        salePrice = vsp;
      } else if (price <= 0) {
        price = vp > 0 ? vp : (vsp ?? 0);
        salePrice = vsp;
      }
    }

    final cp = _num(json['compare_price']) ??
        _num(json['regular_price']) ??
        _num(json['mrp']);
    if (cp != null &&
        cp > price &&
        price > 0 &&
        (salePrice == null || salePrice <= 0)) {
      salePrice = price;
      price = cp;
    }

    if (price <= 0 && salePrice != null && salePrice > 0) {
      price = salePrice;
      salePrice = null;
    }
    return CategoryProduct(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      description: (json['content'] ??
              json['description'] ??
              json['short_description'] ??
              '')
          .toString(),
      image: _pickImage(json),
      price: price,
      salePrice: salePrice,
      averageRating: _num(json['average_rating']),
      ratingCount: _num(json['rating_count'])?.toInt() ?? 0,
      type: (json['type'] ?? 'simple').toString(),
      variantId: (pickedVariant?['_id'] ?? '').toString(),
      catalogMode: CatalogMode.fromJson(json['catalog_mode']),
    );
  }

  CategoryProduct copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    dynamic image,
    double? price,
    double? salePrice,
    double? averageRating,
    int? ratingCount,
    String? type,
    String? variantId,
    CatalogMode? catalogMode,
  }) {
    return CategoryProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      image: image ?? this.image,
      price: price ?? this.price,
      salePrice: salePrice ?? this.salePrice,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
      type: type ?? this.type,
      variantId: variantId ?? this.variantId,
      catalogMode: catalogMode ?? this.catalogMode,
    );
  }
}

class PageInfo {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasNext;

  const PageInfo({
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 20,
    this.total = 0,
    this.hasNext = false,
  });

  static int _int(dynamic v, int fallback) =>
      v == null ? fallback : (int.tryParse(v.toString()) ?? fallback);

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    final nested = json['pagination'];
    final p = nested is Map ? Map<String, dynamic>.from(nested) : json;
    final current = _int(p['current_page'], 1);
    final last = _int(p['last_page'], 1);
    final next = p['has_next'] ?? p['hasNextPage'];
    return PageInfo(
      currentPage: current,
      lastPage: last,
      perPage: _int(p['per_page'], 20),
      total: _int(p['total'], 0),
      hasNext: next is bool ? next : current < last,
    );
  }
}

class CategoryProductsPage {
  final List<CategoryProduct> items;
  final PageInfo pageInfo;

  const CategoryProductsPage({required this.items, required this.pageInfo});

  /// Accepts the unwrapped `data` map (`{data: [...], pagination: {...}}`)
  /// and also the still-wrapped `{status, data: {...}}` or a bare list.
  factory CategoryProductsPage.fromResponse(dynamic response) {
    dynamic body = response;
    if (body is Map && body['data'] is Map) {
      body = body['data'];
    }

    List raw = const [];
    Map<String, dynamic> meta = const {};
    if (body is List) {
      raw = body;
    } else if (body is Map) {
      meta = Map<String, dynamic>.from(body);
      if (body['data'] is List) raw = body['data'] as List;
    }

    final items = <CategoryProduct>[];
    for (final e in raw) {
      if (e is Map) {
        items.add(CategoryProduct.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    return CategoryProductsPage(items: items, pageInfo: PageInfo.fromJson(meta));
  }
}
