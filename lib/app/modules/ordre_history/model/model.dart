class OrderModel {
  final String id;
  final String orderNo;
  final double total;
  final double subtotal;
  final double discount;
  final double shippingCharges;
  final String paymentStatus;  // "unpaid" | "paid"
  final String paymentMethod;  // "COD" | "stripe"
  final String currency;
  final String status;         // status ObjectId or label
  final String notes;
  final OrderAddress address;
  final List<OrderProduct> products;

  const OrderModel({
    required this.id,
    required this.orderNo,
    required this.total,
    required this.subtotal,
    required this.discount,
    required this.shippingCharges,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.currency,
    required this.status,
    required this.notes,
    required this.address,
    required this.products,
  });

  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
    id:              j['_id']?.toString()             ?? '',
    orderNo:         j['order_no']?.toString()         ?? '',
    total:           (j['total']  as num?)?.toDouble() ?? 0,
    subtotal:        (j['subtotal'] as num?)?.toDouble() ?? 0,
    discount:        (j['discount_amount'] as num?)?.toDouble() ?? 0,
    shippingCharges: (j['shipping_charges'] as num?)?.toDouble() ?? 0,
    paymentStatus:   j['payment_status']?.toString() ?? 'unpaid',
    paymentMethod:   j['payment_method']?.toString() ?? '',
    currency:        j['currency']?.toString()        ?? '₹',
    status:          j['status']?.toString()           ?? '',
    notes:           j['notes']?.toString()            ?? '',
    address: j['address'] != null
        ? OrderAddress.fromJson(
        Map<String, dynamic>.from(j['address'] as Map))
        : const OrderAddress.empty(),
    products: (j['products'] as List? ?? [])
        .map((e) => OrderProduct.fromJson(
        Map<String, dynamic>.from(e as Map)))
        .toList(),
  );

  // ── Helpers ────────────────────────────────────────────────
  bool get isPaid       => paymentStatus == 'paid';
  bool get isCompleted  => isPaid;

  // First product image for card thumbnail
  String get thumbnailUrl =>
      products.isNotEmpty ? products.first.imageUrl : '';

  // First product name for card
  String get firstProductName =>
      products.isNotEmpty ? products.first.name : 'Order';
}

// ── Order Address ─────────────────────────────────────────────────
class OrderAddress {
  final String name;
  final String email;
  final String mobile;
  final String address;
  final String pincode;
  final String addressType;

  const OrderAddress({
    required this.name,
    required this.email,
    required this.mobile,
    required this.address,
    required this.pincode,
    required this.addressType,
  });

  const OrderAddress.empty()
      : name        = '',
        email       = '',
        mobile      = '',
        address     = '',
        pincode     = '',
        addressType = '';

  factory OrderAddress.fromJson(Map<String, dynamic> j) =>
      OrderAddress(
        name:        j['name']?.toString()         ?? '',
        email:       j['email']?.toString()        ?? '',
        mobile:      j['mobile']?.toString()       ?? '',
        address:     j['address']?.toString()      ?? '',
        pincode:     j['pincode']?.toString()       ?? '',
        addressType: j['address_type']?.toString() ?? '',
      );
}

// ── Order Product ─────────────────────────────────────────────────
class OrderProduct {
  final String name;
  final int    qty;
  final double unitPrice;
  final double total;
  final String imageUrl;
  final String variantName;

  const OrderProduct({
    required this.name,
    required this.qty,
    required this.unitPrice,
    required this.total,
    required this.imageUrl,
    required this.variantName,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> j) {
    // ── Extract image from nested product_id.featured_image ──
    String img = '';
    final prod = j['product_id'];
    if (prod is Map) {
      final fi = prod['featured_image'];
      if (fi is Map) {
        final url = fi['download_url']?.toString() ?? '';
        final path = fi['filepath']?.toString() ?? '';
        img = url.isNotEmpty
            ? url
            : path.isNotEmpty
            ? 'https://shoponline.vbought.com/images/$path'
            : '';
      }
    }

    // ── Variant name ─────────────────────────────────────────
    final variant = j['variant'];
    final varName = variant is Map
        ? (variant['name']?.toString() ?? '')
        : '';

    return OrderProduct(
      name:        j['name']?.toString()               ?? '',
      qty:         (j['qty'] as num?)?.toInt()          ?? 1,
      unitPrice:   (j['unit_price'] as num?)?.toDouble() ?? 0,
      total:       (j['total'] as num?)?.toDouble()      ?? 0,
      imageUrl:    img,
      variantName: varName,
    );
  }
}
