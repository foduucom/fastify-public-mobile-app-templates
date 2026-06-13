class Product {
  final String id;
  final String name;
  final double price;
  final double? salePrice;
  final String description;
  final List<String> images;
  final bool isTaxable;
  final double tax;
  final List<String> tags;
  final DateTime? publishedAt;
  final List<ProductAttribute> attributes;
  final List<ProductVariant> variants;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.salePrice,
    required this.description,
    required this.images,
    required this.isTaxable,
    required this.tax,
    required this.tags,
    this.publishedAt,
    required this.attributes,
    required this.variants,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      salePrice: (json['sale_price'] as num?)?.toDouble(),
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      isTaxable: json['isTaxable'] ?? false,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      tags: List<String>.from(json['tags'] ?? []),
      publishedAt: json['published_at'] != null ? DateTime.tryParse(json['published_at']) : null,
      attributes: (json['attributes'] as List? ?? [])
          .map((e) => ProductAttribute.fromJson(e))
          .toList(),
      variants: (json['variants'] as List? ?? [])
          .map((e) => ProductVariant.fromJson(e))
          .toList(),
    );
  }
}

class ProductAttribute {
  final String name;
  final List<String> values;

  ProductAttribute({required this.name, required this.values});

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(
      name: json['name'] ?? '',
      values: List<String>.from(json['values'] ?? []),
    );
  }
}

class ProductVariant {
  final String id;
  final String sku;
  final int quantity;
  final Map<String, String> attributes;

  ProductVariant({
    required this.id,
    required this.sku,
    required this.quantity,
    required this.attributes,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['_id'] ?? json['id'] ?? '',
      sku: json['sku'] ?? '',
      quantity: json['quantity'] ?? 0,
      attributes: Map<String, String>.from(json['attributes'] ?? {}),
    );
  }
}
