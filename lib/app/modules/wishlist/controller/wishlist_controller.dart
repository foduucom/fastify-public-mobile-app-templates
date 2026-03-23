import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/constants/constants.dart';

class WishlistController extends GetxController with BaseController {

  final RxBool isLoading = true.obs;
  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;

  // ✅ FIXED: removed 'uploads/'
  static String get _imgBase => assetURL;

  @override
  void onInit() {
    super.onInit();
    fetchWishlist();
  }

  // ── GET /api/wishlist/list ────────────────────────────────────
  Future<void> fetchWishlist() async {
    isLoading(true);
    try {
      final response = await BasicProvider('wishlist/list').getRequest();
      if (response is List) {
        items.assignAll(
          response.map<Map<String, dynamic>>(
                (e) => Map<String, dynamic>.from(e as Map),
          ).toList(),
        );
      } else {
        items.clear();
      }
      debugPrint('✅ Wishlist loaded: ${items.length} items');
    } catch (e) {
      debugPrint('Wishlist fetch error: $e');
    } finally {
      isLoading(false);
    }
  }

// ── POST /api/wishlist/remove ─────────────────────────────────
  Future<void> removeItem(Map<String, dynamic> item) async {
    final pId = productId(item);
    final vId = variantId(item);

    if (pId.isEmpty) {
      debugPrint('❌ product_id missing — cannot remove');
      return;
    }

    // Optimistic remove
    final wId = wishlistId(item);
    items.removeWhere((i) => i['_id']?.toString() == wId);

    try {
      final body = {
        'product_id': pId,
        if (vId.isNotEmpty) 'variant_id': vId,
      };
      debugPrint('🗑️ Removing wishlist: $body');

      final response = await BasicProvider('wishlist/remove').postRequest(body);

      if (response != null) {
        Get.snackbar(
          '🗑️ Removed', 'Item removed from wishlist',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF1A1A1A),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 2),
        );
      } else {
        await fetchWishlist(); // revert if failed
      }
    } catch (e) {
      debugPrint('Remove wishlist error: $e');
      await fetchWishlist(); // revert
    }
  }

  String _fixUrl(String url) {
    if (url.isEmpty) return url;
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    if (uri.path.startsWith('/images/')) {
      return '$_imgBase${uri.path.substring(8)}'; // ✅ strip '/images/' prefix
    }
    return url;
  }

  // ── Helpers ───────────────────────────────────────────────────
  String itemImage(Map<String, dynamic> item) {
    // 1. variant gallery first
    final variant = item['variant_id'];
    if (variant is Map) {
      final gallery = variant['gallery'];
      if (gallery is List && gallery.isNotEmpty) {
        final du = gallery[0]['download_url']?.toString() ?? '';
        if (du.isNotEmpty) return _fixUrl(du); // ✅
        final fp = gallery[0]['filepath']?.toString() ?? '';
        if (fp.isNotEmpty) return '$_imgBase$fp';
      }
    }
    // 2. product featured_image
    final product = item['product_id'];
    if (product is Map) {
      final fi = product['featured_image'];
      if (fi is Map) {
        final du = fi['download_url']?.toString() ?? '';
        if (du.isNotEmpty) return _fixUrl(du); // ✅
        final fp = fi['filepath']?.toString() ?? '';
        if (fp.isNotEmpty) return '$_imgBase$fp';
      }
    }
    return '';
  }

  String itemName(Map<String, dynamic> item) {
    final product = item['product_id'];
    if (product is Map) return product['name']?.toString() ?? '';
    return '';
  }

  String variantName(Map<String, dynamic> item) {
    final variant = item['variant_id'];
    if (variant is Map) {
      final name = variant['name']?.toString() ?? '';
      final productName = itemName(item);
      if (name == productName) return '';
      return name;
    }
    return '';
  }

  double itemPrice(Map<String, dynamic> item) {
    final variant = item['variant_id'];
    if (variant is Map) {
      final sale = double.tryParse(
          variant['sale_price']?.toString() ?? '') ?? 0.0;
      final orig = double.tryParse(
          variant['price']?.toString() ?? '') ?? 0.0;
      if (sale > 0) return sale;
      if (orig > 0) return orig;
    }
    return 0.0;
  }

  double originalPrice(Map<String, dynamic> item) {
    final variant = item['variant_id'];
    if (variant is Map) {
      return double.tryParse(
          variant['price']?.toString() ?? '') ?? 0.0;
    }
    return 0.0;
  }

  bool hasDiscount(Map<String, dynamic> item) {
    final orig = originalPrice(item);
    final sale = itemPrice(item);
    return orig > sale && sale > 0;
  }

  String wishlistId(Map<String, dynamic> item) =>
      item['_id']?.toString() ?? '';

  String productId(Map<String, dynamic> item) {
    final product = item['product_id'];
    if (product is Map) return product['_id']?.toString() ?? '';
    return '';
  }

  String variantId(Map<String, dynamic> item) {
    final variant = item['variant_id'];
    if (variant is Map) return variant['_id']?.toString() ?? '';
    return variant?.toString() ?? '';
  }

}
