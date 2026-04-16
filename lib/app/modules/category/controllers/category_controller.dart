import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:new_fastify_template/core/foduuStudio/foduu_studio_layout_mixin.dart';
import '/app/data/basic_provider.dart';
import '/app/controllers/api_exception_handle_controller.dart';

class CategoryController extends GetxController with BaseController, FoduuStudioLayoutMixin {
  final isLoading   = false.obs;
  final products    = [].obs;

  // ADDED FOR CATEGORY
  var categoryList = List<dynamic>.empty().obs;
  late ScrollController scrollController;
  var currentPage = 1.obs;
  var maxPage = 1.obs;
  var pageSlug = 'category';

  static const String _baseImageUrl = 'https://mywatch.vbought.com/images/';

  // ── Static Categories (assets) ─────────────────────────────────────
  final List<Map<String, String>> categories = [
    {'name': 'Fruits',   'asset': 'assets/images/cat_fruits.png'},
    {'name': 'Seafood',  'asset': 'assets/images/cat_seafood.png'},
    {'name': 'Pastry',   'asset': 'assets/images/cat_pastry.png'},
    {'name': 'Meat',     'asset': 'assets/images/cat_meat.png'},
    {'name': 'Cheese',   'asset': 'assets/images/cat_cheese.png'},
    {'name': 'Cola',     'asset': 'assets/images/cat_cola.png'},
    {'name': 'Egg',      'asset': 'assets/images/cat_egg.png'},
    {'name': 'Spice',    'asset': 'assets/images/cat_spice.png'},
  ];

  @override
  void onInit() async {
    super.onInit();
    scrollController = ScrollController();

    await fetchLayout(pageSlug);
    //fetchProducts();
  }

  Future<void> onPullTorefresh() async {
    currentPage.value = 1;
    maxPage.value = 1;
    categoryList.clear();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading(true);
      final response = await BasicProvider('products')
          .getRequest()
          .catchError(handleError);
      if (response != null) {
        final data = response['data'];
        if (data is List) {
          products.assignAll(data);
        } else if (data is Map && data['data'] is List) {
          products.assignAll(data['data'] as List);
        }
      }
    } catch (e) {
      debugPrint('category products error: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> onRefresh() => fetchProducts();

  // ── Resolve image URL from filepath ───────────────────────────────
  String getImageUrl(Map product) {
    final fi = product['featured_image'];
    if (fi is Map) {
      final url = fi['download_url']?.toString() ?? '';
      if (url.isNotEmpty) return url;
      final path = fi['filepath']?.toString() ?? '';
      if (path.isNotEmpty) {
        return '$_baseImageUrl$path';
      }
    }
    return '';
  }

  // ── Get price from first variant ──────────────────────────────────
  double getPrice(Map product) {
    final variants = product['variants'];
    if (variants is List && variants.isNotEmpty) {
      return double.tryParse(
          variants[0]['price']?.toString() ?? '0') ?? 0.0;
    }
    return double.tryParse(product['price']?.toString() ?? '0') ?? 0.0;
  }

  double getSalePrice(Map product) {
    final variants = product['variants'];
    if (variants is List && variants.isNotEmpty) {
      return double.tryParse(
          variants[0]['sale_price']?.toString() ?? '0') ?? 0.0;
    }
    return double.tryParse(
        product['sale_price']?.toString() ?? '0') ?? 0.0;
  }
}