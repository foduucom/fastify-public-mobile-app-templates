import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:new_fastify_template/constants/constants.dart';
import '/app/data/basic_provider.dart';
import '/app/controllers/api_exception_handle_controller.dart';

class HomeController extends GetxController with BaseController {
  final isLoading = false.obs;
  final products = [].obs;
  final featuredProducts = [].obs; // popular store
  final hotProducts = [].obs;
  final trendingProducts = [].obs;
  final currentBanner = 0.obs;

  final PageController bannerPageController = PageController();
  Timer? _bannerTimer;

  // ── Static banners (all images from assets) ──────────────────────
  final List<Map<String, String>> banners = [
    {
      'asset': 'assets/images/banner_1.png',
      'tag': 'Delivery within',
      'highlight': 'in 25 min',
      'title': 'Get free shipping\nand 25% discount\nfor today only',
    },
    {
      'asset': 'assets/images/banner_2.png',
      'tag': 'Fresh arrivals',
      'highlight': 'every day',
      'title': 'Farm fresh produce\ndelivered straight\nto your door',
    },
    {
      'asset': 'assets/images/banner_3.png',
      'tag': 'Weekend special',
      'highlight': 'Save 30%',
      'title': 'Stock up on all\nyour weekly\ngrocery needs',
    },
  ];

  // ── Static categories ─────────────────────────────────────────────
  final List<Map<String, String>> categories = [
    {'name': 'Fruits', 'asset': 'assets/images/cat_fruits.png'},
    {'name': 'Seafood', 'asset': 'assets/images/cat_seafood.png'},
    {'name': 'Pastry', 'asset': 'assets/images/cat_pastry.png'},
    {'name': 'Meat', 'asset': 'assets/images/cat_meat.png'},
    {'name': 'Cheese', 'asset': 'assets/images/cat_cheese.png'},
    {'name': 'Cola', 'asset': 'assets/images/cat_cola.png'},
    {'name': 'Egg', 'asset': 'assets/images/cat_egg.png'},
    {'name': 'Spice', 'asset': 'assets/images/cat_spice.png'},
  ];

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    _startBannerTimer();
  }

  @override
  void onClose() {
    _bannerTimer?.cancel();
    bannerPageController.dispose();
    super.onClose();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      final next = (currentBanner.value + 1) % banners.length;
      if (bannerPageController.hasClients) {
        bannerPageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
      currentBanner.value = next;
    });
  }

  Future<void> fetchProducts() async {
    try {
      isLoading(true);
      final response =
          await BasicProvider('products').getRequest().catchError(handleError);
      if (response != null) {
        final data = response['data'];
        final list = (data is Map ? data['data'] : data) as List? ?? [];
        products.assignAll(list);
        featuredProducts
            .assignAll(list.where((p) => p['featured'] == true).toList());
        hotProducts.assignAll(list.where((p) => p['hot'] == true).toList());
        trendingProducts
            .assignAll(list.where((p) => p['trending'] == true).toList());
      }
    } catch (e) {
      debugPrint('home products error: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> onRefresh() => fetchProducts();

  String getImageUrl(Map product) {
    final fi = product['featured_image'];
    if (fi is Map) {
      final path = fi['filepath']?.toString() ?? '';
      if (path.isNotEmpty) return '$assetURL$path';
    }
    return '';
  }

  double getPrice(Map product) {
    final variants = product['variants'];
    if (variants is List && variants.isNotEmpty) {
      return double.tryParse(variants[0]['price']?.toString() ?? '0') ?? 0.0;
    }
    return 0.0;
  }

  double getSalePrice(Map product) {
    final variants = product['variants'];
    if (variants is List && variants.isNotEmpty) {
      return double.tryParse(variants[0]['sale_price']?.toString() ?? '0') ??
          0.0;
    }
    return 0.0;
  }
}
