import '/app/data/basic_provider.dart';
import '/constants/helper_functions.dart';

/// Resolves an order line's product image and coalesces duplicate lookups.
class OrderProductImageResolver {
  OrderProductImageResolver._();

  static final Map<String, String> _resolvedByProductId = {};
  static final Map<String, Future<String>> _inFlightByProductId = {};
  static final Map<String, DateTime> _unresolvedAt = {};
  static const _unresolvedCacheDuration = Duration(minutes: 2);

  static String immediate(dynamic orderLine) =>
      HelperFunctions.resolveProductImage(orderLine);

  static Future<String> resolve(dynamic orderLine) async {
    final directImage = immediate(orderLine);
    if (directImage != HelperFunctions.getNoImage()) return directImage;

    final productId = _productId(orderLine);
    if (productId.isEmpty) return HelperFunctions.getNoImage();

    final cached = _resolvedByProductId[productId];
    if (cached != null) return cached;
    final unresolvedAt = _unresolvedAt[productId];
    if (unresolvedAt != null &&
        DateTime.now().difference(unresolvedAt) < _unresolvedCacheDuration) {
      return HelperFunctions.getNoImage();
    }

    return _inFlightByProductId.putIfAbsent(productId, () async {
      try {
        final response =
            await BasicProvider('products/$productId').getRequest();
        final product = response is Map && response['data'] is Map
            ? response['data']
            : response;
        final image = HelperFunctions.resolveProductImage(product);
        if (image != HelperFunctions.getNoImage()) {
          _resolvedByProductId[productId] = image;
          _unresolvedAt.remove(productId);
        } else {
          _unresolvedAt[productId] = DateTime.now();
        }
        return image;
      } catch (_) {
        _unresolvedAt[productId] = DateTime.now();
        return HelperFunctions.getNoImage();
      } finally {
        _inFlightByProductId.remove(productId);
      }
    });
  }

  static String _productId(dynamic orderLine) {
    if (orderLine is! Map) return '';
    final rawProduct = orderLine['product_id'] ?? orderLine['product'];
    final id = rawProduct is Map
        ? (rawProduct['_id'] ?? rawProduct['id'])?.toString() ?? ''
        : rawProduct?.toString() ?? '';
    return RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(id) ? id : '';
  }
}
