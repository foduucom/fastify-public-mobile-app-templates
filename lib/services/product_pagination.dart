class ProductPagination {
  const ProductPagination._();

  static bool hasMore(
    Map data, {
    required int itemCount,
    required int pageSize,
  }) {
    final rawHasNext =
        data['hasNextPage'] ?? data['has_next'] ?? data['has_next_page'];
    if (rawHasNext is bool) return rawHasNext;
    if (rawHasNext != null) {
      final value = rawHasNext.toString().toLowerCase();
      if (value == 'true' || value == '1') return true;
      if (value == 'false' || value == '0') return false;
    }

    final currentPage = _integer(data['current_page'] ?? data['currentPage']);
    final lastPage = _integer(data['last_page'] ?? data['lastPage']);
    if (currentPage != null && lastPage != null) {
      return currentPage < lastPage;
    }
    return itemCount >= pageSize;
  }

  static int nextPage(Map data, {int defaultPage = 1}) {
    final explicitNext = _integer(data['next'] ?? data['next_page']);
    if (explicitNext != null && explicitNext > 0) return explicitNext;

    final currentPage = _integer(data['current_page'] ?? data['currentPage']);
    return currentPage == null ? defaultPage : currentPage + 1;
  }

  static int? _integer(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static List<dynamic> uniquePage(
    Iterable<dynamic> existing,
    Iterable<dynamic> incoming,
  ) {
    final seenIds = <String>{};
    for (final product in existing) {
      final id = _productId(product);
      if (id.isNotEmpty) seenIds.add(id);
    }

    return incoming.where((product) {
      final id = _productId(product);
      return id.isEmpty || seenIds.add(id);
    }).toList();
  }

  static String _productId(dynamic product) {
    if (product is! Map) return '';
    final productId = product['product_id'];
    final id = product['_id'] ??
        product['id'] ??
        (productId is Map ? productId['_id'] ?? productId['id'] : productId);
    return id?.toString() ?? '';
  }
}
