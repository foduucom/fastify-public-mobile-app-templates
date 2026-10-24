import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zouhi/app/data/category_index_service.dart';
import 'package:zouhi/app/data/models/category_products_page.dart';
import 'package:zouhi/app/data/models/home_cms.dart';
import 'package:zouhi/app/data/services/category_product_service.dart';
import 'package:zouhi/app/data/services/home_cms_service.dart';
import 'package:zouhi/constants/api_sanitizer.dart';
import 'package:zouhi/constants/home_config.dart';

class HomepageController extends GetxController with BaseController {
  var selectcategory = 0.obs;
  var sliderImage = List<dynamic>.empty().obs;
  var productCategoryList = List<dynamic>.empty().obs;
  var isLoading = true.obs;
  var isCategoryLoading = false.obs;
  var isShopByMaterialUsed = false.obs;
  var isSliderLoading = false.obs;
  var isTrendingLoading = false.obs;
  var isEditorsChoiceLoading = false.obs;
  var isTrendingProductsLoading = false.obs;

  var sliderImageList = [].obs;
  var solutionSliderList = [].obs;
  var trendingProductList = [].obs;
  var editorsChoiceList = [].obs;
  var trendingProductsList = [].obs;
  var categoryTreeList = [].obs;
  var isCategoryTreeLoading = false.obs;

  var box = GetStorage();
  final isLogin = false.obs;
  var widgetList = [].obs;
  List offerCornerList = [].obs;
  var trendingList = [].obs;
  var blogList = [].obs;
  var notificatoinCount = 0.obs;
  var categoryName = '';
  var shopbyMaterialUsed = [].obs;

  var abc = Get.arguments ?? 'fashion';

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  // ── Parent-site (vision.vbought.com/home) sections ──────────────────────
  final cms = Rxn<HomeCms>();
  // ── Top Categories Of The Month (Hero Feature) ─────────────────────────
  final selectedTopCategoryIndex = 0.obs;
  final topCategoryProducts = <String, List<CategoryProduct>>{}.obs;
  final isTopCategoryProductsLoading = false.obs;

  final specialOffers = <CategoryProduct>[].obs;
  final specialOffersLoading = false.obs;
  final specialItems = <String, List<CategoryProduct>>{}.obs;
  final specialLoading = <String, bool>{}.obs;
  final bestSellers = <CategoryProduct>[].obs;
  final latestProducts = <CategoryProduct>[].obs;
  final isBestLoading = true.obs;
  final isLatestLoading = true.obs;
  final brandsList = [].obs;
  final isBrandsLoading = false.obs;
  final DateTime startedAt = DateTime.now();
  final _cmsService = HomeCmsService();
  final _productService = CategoryProductService();

  final Map<String, Future<void>> _categoryInFlight = {};

  Future<void> selectTopCategory(int index, dynamic category) async {
    selectedTopCategoryIndex.value = index;
    if (category == null || category is! Map) return;

    final id = (category['_id'] ?? category['id'] ?? '').toString();
    final slug = (category['slug'] ?? '').toString().toLowerCase();
    final key = id.isNotEmpty ? id : slug;

    if (key.isEmpty) return;

    // Cable Assemblies & MTP Solution are dedicated form configurators, not product catalogs
    if (slug == 'cable-assemblies' ||
        slug == 'mtp-solution' ||
        key == 'cable-assemblies' ||
        key == 'mtp-solution') {
      topCategoryProducts[key] = [];
      return;
    }

    if (topCategoryProducts.containsKey(key)) {
      return;
    }

    if (_categoryInFlight.containsKey(key)) {
      return _categoryInFlight[key];
    }

    final future = _loadCategoryProducts(key, id, slug);
    _categoryInFlight[key] = future;
    try {
      await future;
    } finally {
      _categoryInFlight.remove(key);
    }
  }

  Future<void> _loadCategoryProducts(String key, String id, String slug) async {
    isTopCategoryProductsLoading.value = true;
    try {
      final res = await _productService.fetchByParentCategory(
        id.isNotEmpty ? id : slug,
        categorySlug: slug,
        count: 12,
      );
      if (res != null && res.items.isNotEmpty) {
        topCategoryProducts[key] = res.items;
      } else {
        topCategoryProducts[key] = [];
      }
    } catch (e) {
      debugPrint('selectTopCategory error: $e');
      topCategoryProducts[key] = [];
    } finally {
      isTopCategoryProductsLoading.value = false;
    }
  }

  Future<void>? _refreshInFlight;
  Timer? _connectivityDebounce;

  @override
  Future<void> onInit() async {
    super.onInit();
    loadCachedData();
    refreshAllData();
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        // We are back online! Sync fresh data (debounced: the plugin can emit
        // several events in a row while the network settles).
        _connectivityDebounce?.cancel();
        _connectivityDebounce =
            Timer(const Duration(seconds: 2), () => refreshAllData());
      }
    });
  }

  void loadCachedData() {
    try {
      cms.value = _cmsService.cached() ?? HomeCms.fallback();

      final cachedSliders = box.read('home_slider_images');
      if (cachedSliders != null && cachedSliders is List) {
        final filteredSliders = cachedSliders.where((item) {
          if (item is Map) {
            final heading = (item['heading'] ?? '').toString().toLowerCase();
            return !heading.contains('not sure which solution');
          }
          return true;
        }).toList();
        sliderImageList.assignAll(filteredSliders);
      }

      final cachedSolutionSliders = box.read('solution_slider_images');
      if (cachedSolutionSliders != null && cachedSolutionSliders is List) {
        solutionSliderList.assignAll(cachedSolutionSliders);
      }

      final cachedCategories = box.read('home_product_categories');
      if (cachedCategories != null && cachedCategories is List) {
        productCategoryList.assignAll(cachedCategories);
      }

      final cachedBlogs = box.read('home_blogs');
      if (cachedBlogs != null && cachedBlogs is List) {
        blogList.assignAll(cachedBlogs);
      }

      final cachedShopMaterial = box.read('home_shop_by_material');
      if (cachedShopMaterial != null && cachedShopMaterial is List) {
        shopbyMaterialUsed.assignAll(cachedShopMaterial);
      }

      final cachedPopular = box.read('home_trending_popular');
      if (cachedPopular != null && cachedPopular is List) {
        trendingProductList.assignAll(cachedPopular);
      }

      final cachedEditors = box.read('home_trending_editors_choice');
      if (cachedEditors != null && cachedEditors is List) {
        editorsChoiceList.assignAll(cachedEditors);
      }

      final cachedTrending = box.read('home_trending_products');
      if (cachedTrending != null && cachedTrending is List) {
        trendingProductsList.assignAll(cachedTrending);
      }

      final cachedTree = box.read('home_category_tree');
      if (cachedTree != null && cachedTree is List) {
        categoryTreeList.assignAll(cachedTree);
      }

      final cachedBrands = box.read('home_brands');
      if (cachedBrands != null && cachedBrands is List) {
        brandsList.assignAll(cachedBrands);
      }

      // If we have cached content, immediately disable primary loading shimmer
      if (sliderImageList.isNotEmpty || productCategoryList.isNotEmpty) {
        isLoading.value = false;
      }
    } catch (e) {
      debugPrint("Error loading homepage cache: $e");
    }
  }

  /// Concurrent callers (init, pull-to-refresh, connectivity) share one run
  /// instead of firing every endpoint again.
  Future<void> refreshAllData() {
    return _refreshInFlight ??= _refreshAllData().whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<void> _refreshAllData() async {
    // Only show primary loader if there's no cached data to show
    if (sliderImageList.isEmpty && productCategoryList.isEmpty) {
      isLoading.value = true;
    }
    
    try {
      // Phase 1: High Priority (Above-the-fold content: Banners, Main Categories, Top Highlights)
      await Future.wait([
        getSliderData(),
        loadCms(),
        getProductCategoryHome(),
      ]);
    } catch (e) {
      debugPrint("Error in Phase 1 home loading: $e");
    } finally {
      // Immediately display rendered content to user
      isLoading.value = false;
    }

    try {
      // Phase 2: Medium Priority (Best Sellers, Latest Products)
      await Future.wait([
        loadBestSellers(),
        loadLatestProducts(),
      ]);
    } catch (e) {
      debugPrint("Error in Phase 2 home loading: $e");
    }

    // Phase 3: Background / Low Priority (Blogs, Material Tree, Category Trees, Brands)
    _loadBackgroundData();
  }

  Future<void> _loadBackgroundData() async {
    try {
      await Future.wait([
        getFeatureBlog(),
        getCategoryTreeData(),
        CategoryIndexService().ensureLoaded(forceRefresh: true),
      ]);
    } catch (e) {
      debugPrint("Error in Phase 3 background data loading: $e");
    }
  }

  Future<void> loadBrands() async {
    isBrandsLoading.value = true;
    try {
      final resBrands =
          await BasicProvider('brands', showSnackBar: false).getRequest();
      if (resBrands != null && resBrands is Map && resBrands['data'] is List) {
        final list = resBrands['data'] as List;
        brandsList.assignAll(list);
        box.write('home_brands', list);
      }
    } catch (e) {
      debugPrint("home brands error: $e");
    } finally {
      isBrandsLoading.value = false;
    }
  }

  Future<void> loadCms() async {
    try {
      final fresh = await _cmsService.fetch();
      if (fresh != null) cms.value = fresh;
    } catch (e) {
      debugPrint('home cms error $e');
    }
  }

  int get _itemsPerTab =>
      cms.value?.byType('index_product-tabs')?.integer('items_per_tab', 6) ?? 6;

  /// "Special Offers! Up to 50% OFF" rail: the 4 newest products, as on the
  /// parent site.
  Future<void> _loadSpecialOfferRail() async {
    specialOffersLoading.value = true;
    try {
      final page = await _productService.fetchProducts(
          sortBy: 'created_at', count: 4);
      if (page != null) specialOffers.assignAll(page.items.take(4));
    } catch (e) {
      debugPrint('special offer rail error $e');
    }
    specialOffersLoading.value = false;
  }

  void _hydrateUnpricedItems(String tabId, List<CategoryProduct> items) {
    final unpriced = items.where((p) => p.effectivePrice <= 0).toList();
    if (unpriced.isEmpty) return;

    Future(() async {
      var updated = false;
      final currentList = specialItems[tabId]?.toList() ?? items.toList();
      for (final p in unpriced) {
        try {
          final res = await BasicProvider('products/${p.id}').getRequest();
          if (res != null && res is Map && res['data'] is Map) {
            final data = Map<String, dynamic>.from(res['data']);
            final full = CategoryProduct.fromJson(data);
            if (full.effectivePrice > 0) {
              final idx = currentList.indexWhere((e) => e.id == p.id);
              if (idx != -1) {
                currentList[idx] = currentList[idx].copyWith(
                  price: full.price,
                  salePrice: full.salePrice,
                  variantId:
                      full.variantId.isNotEmpty ? full.variantId : null,
                );
                updated = true;
              }
            }
          }
        } catch (_) {}
      }
      if (updated) {
        specialItems[tabId] = currentList;
      }
    });
  }

  /// Category tabs under the offers rail: first tab first so it paints before
  /// the others.
  Future<void> loadSpecialOffers() async {
    unawaited(_loadSpecialOfferRail());
    Future<void> one(String id) async {
      specialLoading[id] = true;
      try {
        final page = await _productService.fetchByParentCategory(id,
            count: _itemsPerTab);
        if (page != null) {
          specialItems[id] = page.items;
          _hydrateUnpricedItems(id, page.items);
        }
      } catch (e) {
        debugPrint('special offers $id error $e');
      } finally {
        specialLoading[id] = false;
      }
    }

    final ids = HomeConfig.specialOfferTabs.map((t) => t.id).toList();
    if (ids.isEmpty) return;
    await one(ids.first);
    await Future.wait(ids.skip(1).map(one));
  }

  Future<void> loadBestSellers() async {
    isBestLoading.value = true;
    try {
      final count = cms.value
              ?.byType('index_seller-products')
              ?.integer('items_per_page', 12) ??
          12;
      // Over-fetch: unpriced (₹0) catalogue entries are not sellable, so they
      // are skipped rather than leading the "Best Seller" rail.
      final page = await _productService.fetchProducts(
          sortBy: 'total_sales', count: count * 2);
      if (page != null) {
        bestSellers.assignAll(
            page.items.where((p) => p.effectivePrice > 0).take(count));
      }
    } catch (e) {
      debugPrint('best sellers error $e');
    }
    isBestLoading.value = false;
  }

  Future<void> loadLatestProducts() async {
    isLatestLoading.value = true;
    try {
      final count = cms.value
              ?.byType('index_products-section')
              ?.integer('items_per_page', 12) ??
          12;
      final page = await _productService.fetchProducts(
          sortBy: 'created_at', count: count);
      if (page != null) latestProducts.assignAll(page.items);
    } catch (e) {
      debugPrint('latest products error $e');
    }
    isLatestLoading.value = false;
  }

  Future<void> getSliderData() async {
    try {
      isSliderLoading.value = true;
      var response =
          await BasicProvider("slider").getRequest().catchError(handleError);

      if (response != null) {
        List slidersList = [];
        if (response is List) {
          slidersList = response;
        } else if (response is Map) {
          if (response['data'] is List) {
            slidersList = response['data'];
          } else if (response['data'] is Map &&
              response['data']['data'] is List) {
            slidersList = response['data']['data'];
          }
        }
        // 1. Extract home-slider items specifically for homepage hero
        dynamic homeSlider;
        dynamic solutionSlider;

        for (var slider in slidersList) {
          if (slider is Map) {
            final slug = (slider['slug'] ?? slider['name'] ?? '').toString().toLowerCase();
            if (slug == 'home-slider') {
              homeSlider = slider;
            } else if (slug == 'solution') {
              solutionSlider = slider;
            }
          }
        }

        // Fallback: if 'home-slider' slug not found, find first non-solution slider with content
        if (homeSlider == null) {
          for (var slider in slidersList) {
            if (slider is Map) {
              final slug = (slider['slug'] ?? slider['name'] ?? '').toString().toLowerCase();
              if (slug != 'solution' &&
                  slider['content'] != null &&
                  slider['content'] is List &&
                  (slider['content'] as List).isNotEmpty) {
                homeSlider = slider;
                break;
              }
            }
          }
        }

        if (homeSlider != null &&
            homeSlider['content'] != null &&
            homeSlider['content'] is List) {
          final List homeImages = List.from(homeSlider['content']);
          // Sort slides by 'order' ascending if available
          homeImages.sort((a, b) {
            final int orderA = (a is Map && a['order'] is num) ? (a['order'] as num).toInt() : 0;
            final int orderB = (b is Map && b['order'] is num) ? (b['order'] as num).toInt() : 0;
            return orderA.compareTo(orderB);
          });
          sliderImageList.assignAll(homeImages);
          box.write('home_slider_images', homeImages);
        }

        // 2. Extract and preserve solution slider separately
        if (solutionSlider != null &&
            solutionSlider['content'] != null &&
            solutionSlider['content'] is List) {
          final List solutionImages = List.from(solutionSlider['content']);
          solutionSliderList.assignAll(solutionImages);
          box.write('solution_slider_images', solutionImages);
        }
      }
      isSliderLoading.value = false;
    } catch (e) {
      isSliderLoading.value = false;
      debugPrint('app slider error $e');
    }
  }

  Future<void> getTrendingProducts(String productType) async {
    try {
      if (productType == 'popular_products') {
        isTrendingLoading.value = true;
      } else if (productType == 'trending') {
        isTrendingProductsLoading.value = true;
      } else {
        isEditorsChoiceLoading.value = true;
      }

      var response;
      if (productType == 'editors-choice') {
        response = await BasicProvider("products?todays_top_pick=true")
            .getRequest()
            .catchError(handleError);
      } else if (productType == 'popular_products') {
        response = await BasicProvider("products?weekly_top_highlights=true")
            .getRequest()
            .catchError(handleError);
      } else if (productType == 'trending') {
        response = await BasicProvider("products?trending=true")
            .getRequest()
            .catchError(handleError);
      }

      if (response != null) {
        List products = [];
        if (response is List) {
          products = response;
        } else if (response is Map) {
          if (response['data'] is List) {
            products = response['data'];
          } else if (response['data'] is Map &&
              response['data']['data'] is List) {
            products = response['data']['data'];
          } else if (response['products'] is List) {
            products = response['products'];
          }
        }

        products = stripHeavyList(products);
        if (productType == 'popular_products') {
          trendingProductList.assignAll(products);
          box.write('home_trending_popular', products);
        } else if (productType == 'trending') {
          trendingProductsList.assignAll(products);
          box.write('home_trending_products', products);
        } else {
          editorsChoiceList.assignAll(products);
          box.write('home_trending_editors_choice', products);
        }
      }

      if (productType == 'popular_products') {
        isTrendingLoading.value = false;
      } else if (productType == 'trending') {
        isTrendingProductsLoading.value = false;
      } else {
        isEditorsChoiceLoading.value = false;
      }
    } catch (e) {
      isTrendingLoading.value = false;
      isEditorsChoiceLoading.value = false;
      isTrendingProductsLoading.value = false;
      debugPrint('trending error $e');
    }
  }

  Future<void> getFeatureBlog() async {
    try {
      isCategoryLoading.value = true;
      var response =
          await BasicProvider('blogs').getRequest().catchError(handleError);

      if (response != null) {
        List data = [];
        if (response is List) {
          data = response;
        } else if (response is Map) {
          if (response['data'] is List) {
            data = response['data'];
          } else if (response['data'] is Map &&
              response['data']['data'] is List) {
            data = response['data']['data'];
          }
        }
        if (data.isNotEmpty) {
          data = stripHeavyList(data);
          blogList.assignAll(data);
          box.write('home_blogs', data);
        }
      }
      isCategoryLoading.value = false;
    } catch (e) {
      isCategoryLoading.value = false;
      print('feature blog error $e');
    }
  }

  Future<void> getProductCategoryHome() async {
    try {
      isCategoryLoading.value = true;
      var response = await BasicProvider("category/featured")
          .getRequest()
          .catchError(handleError);

      if (response != null) {
        List data = [];
        if (response is List) {
          data = response;
        } else if (response is Map && response['data'] != null) {
          data = response['data'] is List ? response['data'] : [];
        }
        data = stripHeavyList(data);
        productCategoryList.assignAll(data);
        box.write('home_product_categories', data);
      }
      isCategoryLoading.value = false;
    } catch (e) {
      isCategoryLoading.value = false;
      print('category home error $e');
    }
  }

  Future<void> getshopbyMaterialUsed() async {
    try {
      isShopByMaterialUsed.value = true;
      var response = await BasicProvider("category?parentCategory=true")
          .getRequest()
          .catchError(handleError);

      if (response != null) {
        List data = [];
        if (response is List) {
          data = response;
        } else if (response is Map && response['data'] != null) {
          data = response['data'] is List ? response['data'] : [];
        }
        shopbyMaterialUsed.assignAll(stripHeavyList(data));
        box.write('home_shop_by_material', shopbyMaterialUsed.toList());
      }
      isShopByMaterialUsed.value = false;
    } catch (e) {
      isShopByMaterialUsed.value = false;
      print('category home error $e');
    }
  }

  Future<void> getEditorChoice() async {
    try {
      isShopByMaterialUsed.value = true;
      var response = await BasicProvider("category/get-tree/material")
          .getRequest()
          .catchError(handleError);

      if (response != null) {
        List data = [];
        if (response is List) {
          data = response;
        } else if (response is Map && response['data'] != null) {
          data = response['data'] is List ? response['data'] : [];
        }
        // Append additional materials, skipping ones already present
        final known = shopbyMaterialUsed
            .map((e) => e is Map ? e['_id'] ?? e['id'] : e)
            .toSet();
        shopbyMaterialUsed.addAll(stripHeavyList(data).where(
            (e) => !known.contains(e is Map ? e['_id'] ?? e['id'] : e)));
        box.write('home_shop_by_material', shopbyMaterialUsed.toList());
      }
      isShopByMaterialUsed.value = false;
    } catch (e) {
      isShopByMaterialUsed.value = false;
      print('category home error $e');
    }
  }

  Future<void>? _treeInFlight;

  Future<void> getCategoryTreeData() {
    return _treeInFlight ??= _fetchCategoryTree().whenComplete(() {
      _treeInFlight = null;
    });
  }

  Future<void> _fetchCategoryTree() async {
    try {
      isCategoryTreeLoading.value = true;
      var response = await BasicProvider("category/get-tree/product")
          .getRequest()
          .catchError(handleError);
      if (response != null) {
        List data = [];
        if (response is List) {
          data = response;
        } else if (response is Map) {
          if (response['data'] is List) {
            data = response['data'] as List;
          } else if (response['data'] is Map &&
              response['data']['data'] is List) {
            data = response['data']['data'] as List;
          }
        }
        if (data.isNotEmpty) {
          data = stripHeavyList(data);
          categoryTreeList.assignAll(data);
          box.write('home_category_tree', data);
        }
      }
      isCategoryTreeLoading.value = false;
    } catch (e) {
      isCategoryTreeLoading.value = false;
      debugPrint("Error fetching category tree in controller: $e");
    }
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    _connectivityDebounce?.cancel();
    super.onClose();
  }
}
