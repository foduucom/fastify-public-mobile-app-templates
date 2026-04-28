import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_mixin.dart';

import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/wishlist/views/wishlist_view.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/product_helper.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:foduu_ecommerce/core/services/wishlistService.dart';

class WishlistController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  RxList<Map<String, dynamic>> get wishlistItems =>
      WishListService.to.wishListItems;
  var isLoading = false.obs;
  var scrollController = ScrollController();

  @override
  Future<void> onInit() async {
    super.onInit();
    fetchLayout('wishlist');
    if (AuthDetails.isUserLogin()) {
      await fetchWishlist();
    }
  }

  Future<void> fetchWishlist() async {
    isLoading.value = true;
    await WishListService.to.fetchWishList();
    isLoading.value = false;
  }

  Future<void> onRefresh() async {
    await fetchWishlist();
  }

  Map<String, dynamic> getProduct(int index) {
    return Map<String, dynamic>.from(wishlistItems[index]['product_id'] ?? {});
  }

  Map<String, dynamic> getVariant(int index) {
    final v = wishlistItems[index]['variant_id'];
    if (v is Map) return Map<String, dynamic>.from(v);
    return {};
  }

  int getQuantity(int index) {
    return wishlistItems[index]['quantity'] ?? 1;
  }

  String getVariantSlug(int index) {
    return wishlistItems[index]['variant_slug'] ?? '';
  }

  String getProductId(int index) {
    final product = wishlistItems[index]['product_id'];
    if (product is Map) {
      return product['_id'] ?? product['id'] ?? '';
    }
    return product?.toString() ?? '';
  }

  // ── Derived display helpers ───────────────────────────────

  /// Returns the price to show and whether a sale is active.
  /// Priority: variant.sale_price > variant.price > product fallback
  ({String finalPrice, String originalPrice, bool hasSale}) getPriceInfo(int index) {
    final variant = getVariant(index);
    final product = getProduct(index);

    double parse(dynamic v) =>
        v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;

    final variantSale = parse(variant['sale_price']);
    final variantPrice = parse(variant['price']);
    final productSale = parse(product['sale_price']);
    final productPrice = parse(product['price']);

    double original;
    double final_;
    if (variant.isNotEmpty) {
      original = variantPrice > 0 ? variantPrice : productPrice;
      if (variantSale > 0) {
        final_ = variantSale;
      } else {
        final_ = original;
      }
    } else {
      original = productPrice > 0 ? productPrice : productSale;
      if (productSale > 0 && productSale < productPrice) {
        final_ = productSale;
      } else {
        final_ = original;
      }
    }

    final hasSale = final_ > 0 && final_ < original;
    return (
      finalPrice: final_.toStringAsFixed(2),
      originalPrice: original.toStringAsFixed(2),
      hasSale: hasSale,
    );
  }

  /// Returns list of active badge labels: "featured", "hot", "trending", "recommended"
  List<String> getBadges(int index) {
    final product = getProduct(index);
    return ['featured', 'hot', 'trending', 'recommended']
        .where((key) => product[key] == true)
        .toList();
  }

  /// Returns brand map {id, name, slug} or null
  Map<String, String>? getBrand(int index) {
    final brand = getProduct(index)['brand'];
    if (brand is! Map) return null;
    final name = brand['name']?.toString();
    if (name == null || name.isEmpty) return null;
    return {
      'id': brand['_id']?.toString() ?? '',
      'name': name,
      'slug': brand['slug']?.toString() ?? '',
    };
  }

  /// Returns list of tag maps {id, name, slug}
  List<Map<String, String>> getTags(int index) {
    final tags = getProduct(index)['tags'];
    if (tags is! List) return [];
    return tags
        .whereType<Map>()
        .map((t) => {
              'id': t['_id']?.toString() ?? '',
              'name': t['name']?.toString() ?? '',
              'slug': t['slug']?.toString() ?? '',
            })
        .where((t) => t['name']!.isNotEmpty)
        .toList();
  }

  /// Returns best available image URL: variant gallery → product featured_image
  String getImageUrl(int index) {
    final variant = getVariant(index);
    final product = getProduct(index);

    // 1. Variant gallery (uses same HelperFunctions path logic as the rest of the app)
    final gallery = variant['gallery'];
    if (gallery is List && gallery.isNotEmpty) {
      final url = HelperFunctions().getImage(gallery.first, moduleName: 'WishlistController');
      if (url != HelperFunctions.getNoImage()) return url;
    }

    // 2. Delegate to ProductHelper which handles all featured_image formats correctly
    return ProductHelper.getProductImage(product);
  }
}
