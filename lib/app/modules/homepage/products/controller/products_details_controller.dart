import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/constants/constants.dart';

class ProductDetailsController extends GetxController with BaseController {

  final RxBool isLoading       = true.obs;
  final RxBool hasError        = false.obs;
  final RxBool isWishlisted    = false.obs;
  final RxBool wishlistLoading = false.obs;
  final RxInt  selectedVariantIndex = 0.obs;
  final RxInt  selectedImageIndex   = 0.obs;

  final Rx<Map<String, dynamic>> product = Rx<Map<String, dynamic>>({});

  // ✅ FIXED: removed 'uploads/'
  static String get _imgBase => assetURL;

  @override
  void onInit() {
    super.onInit();
    final id = Get.arguments?.toString() ?? '';
    if (id.isNotEmpty) fetchProduct(id);
  }

  // ── Fetch Product ─────────────────────────────────────────────
  Future<void> fetchProduct(String id) async {
    isLoading(true);
    hasError(false);
    try {
      final response = await BasicProvider('products/$id')
          .getRequest()
          .catchError(handleError);

      if (response != null) {
        final data = response is Map && response['data'] != null
            ? response['data'] as Map
            : response as Map;
        product.value = Map<String, dynamic>.from(data);
        debugPrint('✅ Product loaded: ${product.value['name']}');
        debugPrint('🖼️ Product image: ${allImages.isNotEmpty ? allImages[0] : "none"}');
      } else {
        hasError(true);
      }
    } catch (e) {
      debugPrint('ProductDetailsController error: $e');
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  // ── Toggle Wishlist ───────────────────────────────────────────
  Future<void> toggleWishlist() async {
    if (wishlistLoading.value) return;

    final productId = product.value['_id']?.toString() ?? '';
    final variantId = selectedVariantId;

    if (productId.isEmpty) {
      Get.snackbar('Error', 'Product not found',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16));
      return;
    }

    wishlistLoading(true);
    try {
      final body = <String, dynamic>{
        'product_id': productId,
        if (variantId.isNotEmpty) 'variant_id': variantId,
      };

      debugPrint('❤️ Wishlist body: $body');

      final response = await BasicProvider('wishlist/add').postRequest(body);

      if (response != null) {
        isWishlisted.toggle();
        Get.snackbar(
          isWishlisted.value ? '❤️ Added'    : '🤍 Removed',
          isWishlisted.value
              ? 'Added to your wishlist'
              : 'Removed from wishlist',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF1A1A1A),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      debugPrint('Wishlist error: $e');
      Get.snackbar('Error', 'Could not update wishlist',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16));
    } finally {
      wishlistLoading(false);
    }
  }

  // ── Getters ───────────────────────────────────────────────────
  String get name =>
      product.value['name']?.toString() ?? '';

  String get description {
    final raw = product.value['content']?.toString() ?? '';
    return raw.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  List<Map<String, dynamic>> get variants {
    final v = product.value['variants'];
    if (v is List) {
      return v.map<Map<String, dynamic>>(
            (e) => Map<String, dynamic>.from(e as Map),
      ).toList();
    }
    return [];
  }

  Map<String, dynamic> get selectedVariant {
    final v = variants;
    if (v.isEmpty) return {};
    final i = selectedVariantIndex.value.clamp(0, v.length - 1);
    return v[i];
  }

  String get selectedVariantId {
    final v = variants;
    if (v.isEmpty) return '';
    final i = selectedVariantIndex.value.clamp(0, v.length - 1);
    return v[i]['_id']?.toString() ?? '';
  }

  String get selectedVariantSlug {
    final v = variants;
    if (v.isEmpty) return '';
    final i = selectedVariantIndex.value.clamp(0, v.length - 1);
    return v[i]['slug']?.toString() ?? '';
  }

  double get price {
    final v = selectedVariant;
    if (v.isNotEmpty) {
      final sale = double.tryParse(v['sale_price']?.toString() ?? '') ?? 0.0;
      final orig = double.tryParse(v['price']?.toString()      ?? '') ?? 0.0;
      if (sale > 0) return sale;
      if (orig > 0) return orig;
    }
    final raw = product.value['sale_price'] ?? product.value['price'] ?? 0;
    return double.tryParse(raw.toString()) ?? 0.0;
  }

  double get originalPrice {
    final v = selectedVariant;
    if (v.isNotEmpty) {
      return double.tryParse(v['price']?.toString() ?? '') ?? 0.0;
    }
    return 0.0;
  }

  bool get hasDiscount => originalPrice > price && price > 0;

  // ✅ FIXED: download_url first, fallback to filepath for all image sources
  List<String> get allImages {
    final imgs = <String>[];

    // 1. product featured_image
    final fi = product.value['featured_image'];
    if (fi is Map) {
      final du = fi['download_url']?.toString() ?? '';
      final fp = fi['filepath']?.toString() ?? '';
      final url = du.isNotEmpty ? du : (fp.isNotEmpty ? '$_imgBase$fp' : '');
      if (url.isNotEmpty && !imgs.contains(url)) imgs.add(url);
    }

    // 2. product gallery
    final gallery = product.value['gallery'];
    if (gallery is List) {
      for (final g in gallery) {
        if (g is Map) {
          final du = g['download_url']?.toString() ?? '';
          final fp = g['filepath']?.toString() ?? '';
          final url = du.isNotEmpty ? du : (fp.isNotEmpty ? '$_imgBase$fp' : '');
          if (url.isNotEmpty && !imgs.contains(url)) imgs.add(url);
        }
      }
    }

    // 3. selected variant gallery
    final vGallery = selectedVariant['gallery'];
    if (vGallery is List) {
      for (final g in vGallery) {
        if (g is Map) {
          final du = g['download_url']?.toString() ?? '';
          final fp = g['filepath']?.toString() ?? '';
          final url = du.isNotEmpty ? du : (fp.isNotEmpty ? '$_imgBase$fp' : '');
          if (url.isNotEmpty && !imgs.contains(url)) imgs.add(url);
        }
      }
    }

    return imgs;
  }

  String variantLabel(Map<String, dynamic> v) {
    final attrs = v['attributes'];
    if (attrs is Map && attrs.isNotEmpty) {
      return attrs.entries
          .map((e) => '${_capitalize(e.key)}: ${_capitalize(e.value.toString())}')
          .join(' · ');
    }
    return v['name']?.toString() ?? '';
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  // ── Actions ───────────────────────────────────────────────────
  void selectVariant(int index) {
    selectedVariantIndex.value = index;
    selectedImageIndex.value   = 0;
  }

  void onAddToCart() {
    final item = Map<String, dynamic>.from(product.value);
    item['_selected_variant'] = selectedVariant;
    Get.snackbar(
      'Added to Cart', '$name added!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF1A1A1A),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  void goBack() => Get.back();
}
