import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants/dynamic_theme.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/constants/constants.dart';
import '/helpers/socket_helper.dart';


class HomeController extends GetxController with BaseController {
  final RxInt selectedCategory = 0.obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString addingToCartId = ''.obs;

  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> featuredProducts =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> newCollections =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;

  static String get _imgBase => assetURL;

  final _socketHelper = SocketHelper();
  final _themeController = Get.find<ThemeController>();

  get isDrawerNavigationLoading => null;

  get drawernavigationItems => null;

  @override
  void onInit() {
    super.onInit();
    _initApp();
  }

  Future<void> _initApp() async {
    if (!DynamicThemeManager().lightColors.primary.value.toString().isNotEmpty) {
      await DynamicThemeManager().init();
    }

    if (!_socketHelper.isConnected) {
      _socketHelper.connect();
    }

    _listenThemeUpdates();
    await fetchHomeData();
  }

  void _listenThemeUpdates() {
    _socketHelper.off('theme_update');
    _socketHelper.on('theme_update', (data) {
      try {
        final decoded = data is String ? Map<String, dynamic>.from(jsonDecode(data)) : Map<String, dynamic>.from(data as Map);
        if (decoded['light'] != null || decoded['dark'] != null) {
          DynamicThemeManager().updateFromApi(decoded);
          _themeController.refreshTheme();
          debugPrint('✅ Theme updated from socket');
        }
      } catch (e) {
        debugPrint('❌ Theme socket parse error: $e');
      }
    });
  }

  Future<void> fetchHomeData() async {
    isLoading(true);
    hasError(false);
    try {
      final response = await BasicProvider('mobile-app/69a934c9511d9bae478fd641')
          .getRequest()
          .catchError(handleError);

      if (response != null) {
        _parseHomeData(response);

        final themeColor = response['data']?['theme_color'] ?? response['theme_color'];
        if (themeColor != null && themeColor is Map) {
          DynamicThemeManager().updateFromApi(Map<String, dynamic>.from(themeColor));
          _themeController.refreshTheme();
        }
      } else {
        hasError(true);
      }
    } catch (e) {
      debugPrint('HomeController error: $e');
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  void _parseHomeData(dynamic response) {
    final data = response is Map && response['data'] != null
        ? response['data'] as Map
        : response as Map;

    debugPrint('🔍 HOME TOP KEYS: ${data.keys.toList()}');

    final sections = data['sections'];
    if (sections == null || sections is! List) {
      debugPrint('❌ No sections found');
      hasError(true);
      return;
    }

    categories.clear();
    featuredProducts.clear();
    newCollections.clear();

    for (final section in sections) {
      if (section is! Map) continue;

      final type = section['type']?.toString() ?? '';
      final contentJson = section['content_json'];
      if (contentJson == null || contentJson is! Map) continue;

      switch (type) {
        case 'categories':
          final rawCats = contentJson['categories'];
          if (rawCats is List) {
            categories.assignAll(
              rawCats.map<Map<String, dynamic>>(
                    (c) => Map<String, dynamic>.from(c as Map),
              ).toList(),
            );
          }
          break;

        case 'products':
          final rawWrapper = contentJson['products'];
          List<dynamic> rawList = [];

          if (rawWrapper is Map) {
            rawList = rawWrapper['data'] is List ? rawWrapper['data'] as List : [];
          } else if (rawWrapper is List) {
            rawList = rawWrapper;
          }

          final parsed = rawList
              .map<Map<String, dynamic>>(
                (p) => Map<String, dynamic>.from(p as Map),
          )
              .toList();

          if (featuredProducts.isEmpty) {
            featuredProducts.assignAll(parsed);
          } else {
            newCollections.assignAll(parsed);
          }
          break;
      }
    }

    if (newCollections.isEmpty && featuredProducts.isNotEmpty) {
      newCollections.assignAll(featuredProducts);
    }

    debugPrint(
      '✅ categories:${categories.length} featured:${featuredProducts.length} collections:${newCollections.length}',
    );

    if (featuredProducts.isNotEmpty) {
      debugPrint('🖼️ First product image: ${itemImage(featuredProducts[0])}');
    }
    if (categories.isNotEmpty) {
      debugPrint('🖼️ First category image: ${catImage(categories[0])}');
    }
  }

  static String itemId(Map item) =>
      item['_id']?.toString() ?? item['id']?.toString() ?? '';

  static String itemName(Map item) =>
      item['name']?.toString() ?? item['title']?.toString() ?? '';

  static double itemPrice(Map item) {
    final variants = item['variants'];
    if (variants is List && variants.isNotEmpty) {
      final v = variants[0] as Map;
      final salePrice =
          double.tryParse(v['sale_price']?.toString() ?? '') ?? 0.0;
      final price = double.tryParse(v['price']?.toString() ?? '') ?? 0.0;
      if (salePrice > 0) return salePrice;
      if (price > 0) return price;
    }
    final raw = item['sale_price'] ?? item['price'] ?? 0;
    return double.tryParse(raw.toString()) ?? 0.0;
  }

  static String _resolveImageUrl(Map? imageMap) {
    if (imageMap == null) return '';
    final du = imageMap['download_url']?.toString() ?? '';
    if (du.isNotEmpty) return du;
    final fp = imageMap['filepath']?.toString() ?? '';
    if (fp.isNotEmpty) return '$_imgBase$fp';
    return '';
  }

  static String itemImage(Map item) {
    final fi = item['featured_image'];
    if (fi is Map) {
      final url = _resolveImageUrl(fi);
      if (url.isNotEmpty) return url;
    }

    final gallery = item['gallery'];
    if (gallery is List && gallery.isNotEmpty && gallery[0] is Map) {
      final url = _resolveImageUrl(gallery[0] as Map);
      if (url.isNotEmpty) return url;
    }

    final variants = item['variants'];
    if (variants is List && variants.isNotEmpty) {
      final v = variants[0] as Map;

      final frontImg = v['front_image'];
      if (frontImg is Map) {
        final url = _resolveImageUrl(frontImg);
        if (url.isNotEmpty) return url;
      }

      final vGallery = v['gallery'];
      if (vGallery is List && vGallery.isNotEmpty && vGallery[0] is Map) {
        final url = _resolveImageUrl(vGallery[0] as Map);
        if (url.isNotEmpty) return url;
      }
    }
    return '';
  }

  static String catImage(Map cat) {
    final fi = cat['featured_image'];
    if (fi is Map) return _resolveImageUrl(fi);
    return '';
  }

  static String catName(Map cat) => cat['name']?.toString() ?? '';

  static String itemVariantId(Map item) {
    final variants = item['variants'];
    if (variants is List && variants.isNotEmpty) {
      final v = variants[0] as Map;
      return v['_id']?.toString() ?? v['id']?.toString() ?? '';
    }
    return '';
  }

  Future<void> onAddToCart(Map<String, dynamic> item) async {
    final productId = itemId(item);
    final variantId = itemVariantId(item);
    final name = itemName(item);

    if (productId.isEmpty) {
      Get.snackbar('Error', 'Invalid product',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12);
      return;
    }

    addingToCartId.value = productId;
    try {
      final response = await BasicProvider('cart/manage').postRequest({
        'items': [
          {
            'product_id': productId,
            if (variantId.isNotEmpty) 'variant_id': variantId,
            'quantity': 1,
          }
        ],
      }).catchError(handleError);

      if (response != null) {
        cartItems.add(item);
        Get.snackbar(
          '🛒 Added to Cart',
          '$name added successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF1A1A1A),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      debugPrint('Add to cart error: $e');
      Get.snackbar('Failed', 'Could not add to cart.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12);
    } finally {
      addingToCartId.value = '';
    }
  }

  void onCategoryTap(int index) => selectedCategory.value = index;
  void onNotificationTap() => Get.toNamed('/notification');
  void onCartTap() => Get.toNamed('/cart');
  void onSeeAllTap() => Get.toNamed('/productlistview');
  void onProductTap(String id) => Get.toNamed('/productdetails', arguments: id);

  @override
  void onClose() {
    _socketHelper.off('theme_update');
    super.onClose();
  }
}
