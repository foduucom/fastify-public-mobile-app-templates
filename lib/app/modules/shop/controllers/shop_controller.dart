// // ignore_for_file: prefer_const_constructors
//
// import 'package:flutter/material.dart';
// import '/core/foduuStudio/foduu_studio_layout_mixin.dart';
// import '/app/controllers/api_exception_handle_controller.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
//
// class ShopController extends GetxController
//     with BaseController, GetTickerProviderStateMixin, FoduuStudioLayoutMixin {
//   var allProductList = List<dynamic>.empty().obs;
//   var getCurrentvalue = 0.obs;
//   late ScrollController scrollController;
//
//   final count = 0.obs;
//   var isLoading = true.obs;
//   var currentPage = 1.obs;
//   var maxPage = 1.obs;
//   var discountedValue = "".obs;
//   var box = GetStorage();
//   var arguments = {}.obs;
//   var collectionName;
//   var categoryId = [];
//   var source;
//   var isFilter = false.obs;
//
//   late AnimationController controller;
//   late Animation<double> scaleAnimation;
//
//   @override
//   Future<void> onInit() async {
//     // scrollController = ScrollController();
//
//     fetchLayout('product-listing');
//     // arguments.addAll(Get.arguments);
//
//     // source = arguments['source'];
//     // if (source == 'offerCorner') {
//     //   offerConrnerPrice = arguments['price'];
//     //   collectionName = arguments['name'];
//     //   // getOfferConrnerProducts(offerConrnerPrice);
//     // } else if (source == 'dashboard') {
//     //   productId = arguments['productId'];
//     //   collectionName = arguments['name'];
//     //   producttype = arguments['productype'];
//     //   // getProducts(productType: producttype);
//     // } else if (source == 'category') {
//     //   productId = arguments['productId'];
//     //   collectionName = arguments['name'];
//     //   // getCategoryWiseProduct(productId);
//     // }
//
//     // // await fetchProductOnScroll();
//     // currentRangeValues.value.start.val(filterMaxPrice.toString());
//
//     // controller = AnimationController(
//     //   vsync: this,
//     //   duration: Duration(milliseconds: 300),
//     // );
//     // scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
//     //   CurvedAnimation(parent: controller, curve: Curves.easeInOut),
//     // );
//   }
//
//   // Future<void> onPullTorefresh() async {
//   //   currentPage.value = 1;
//   //   maxPage.value = 10;
//   //   allProductList.clear();
//   //   if (isFilter.value == true) {
//   //     // filterProducts();
//   //   } else {
//   //     if (source == 'offerCorner') {
//   //       offerConrnerPrice = arguments['price'];
//   //       collectionName = arguments['name'];
//
//   //       // getOfferConrnerProducts(offerConrnerPrice);
//   //     } else if (source == 'dashboard') {
//   //       productId = arguments['productId'];
//   //       collectionName = arguments['name'];
//   //       producttype = arguments['productype'];
//   //       // getProducts(productType: producttype);
//   //       // categoryId.addAll(productId);
//   //     } else if (source == 'category') {
//   //       productId = arguments['productId'];
//   //       collectionName = arguments['name'];
//   //       // getCategoryWiseProduct(productId);
//   //     }
//   //   }
//   // }
//
//   // Future<void> getProducts({required String productType}) async {
//   //   try {
//   //     isLoading(true);
//
//   //     var response;
//   //     if (productType == 'random_category') {
//   //       response = await BasicProvider(
//   //               "mobile/public/product/random?count=10&page=$currentPage")
//   //           .getRequest()
//   //           .catchError(handleError);
//   //     } else if (productType == 'specific_category') {
//   //       response = await BasicProvider(
//   //               "mobile/public/product/specific?count=10&page=$currentPage")
//   //           .postRequest({'categories': productId}).catchError(handleError);
//   //     } else if (productType == 'popular_products') {
//   //       response = await BasicProvider(
//   //               "mobile/public/product/popular?count=10&page=$currentPage")
//   //           .getRequest()
//   //           .catchError(handleError);
//   //     } else if (productType == 'discounted_products') {
//   //       response = await BasicProvider(
//   //               "mobile/public/product/discounted?count=10&page=$currentPage")
//   //           .getRequest()
//   //           .catchError(handleError);
//   //     }
//
//   //     if (productType == 'random_category') {
//   //       allProductList.addAll(response);
//   //     } else {
//   //       allProductList.addAll(response['data']);
//   //     }
//   //     maxPage(response["last_page"]);
//   //     print('max page ${maxPage.value}');
//   //     isLoading(false);
//   //   } catch (e) {
//   //     print('trending error $e');
//   //     isLoading(false);
//   //   }
//   // }
//
//   @override
//   void onClose() {
//     scrollController.dispose();
//   }
//
//   List color = [
//     const Color(0xFFE6E6FA),
//     const Color(0xFFF5F5F5),
//     const Color(0xFFB0C4DE),
//     const Color(0xFFEBACA2),
//     const Color(0xFFFFC0CB),
//     const Color(0xFFADD8E6),
//     const Color(0xFFBED3C3),
//     const Color(0xFF9FD9F2),
//     const Color(0xFFF5DEB3),
//     const Color(0xFFFFE4E1),
//     const Color(0xFFE6E6FA)
//   ];
//
//   // Define a list of color details: name, color object, and hexadecimal code
//   final List<Map<String, dynamic>> colorList = [
//     {'name': 'Red', 'color': Colors.red, 'code': '0xFFFF0000'},
//     {'name': 'Blue', 'color': Colors.blue, 'code': '0xFF0000FF'},
//     {'name': 'Pink', 'color': Colors.pink, 'code': '0xFFFFC0CB'},
//     {'name': 'Green', 'color': Colors.green, 'code': '0xFF008000'},
//     {'name': 'Yellow', 'color': Colors.yellow, 'code': '0xFFFFFF00'},
//     {'name': 'Purple', 'color': Colors.purple, 'code': '0xFF800080'},
//     {'name': 'Grey', 'color': Colors.grey, 'code': '0xFF808080'},
//     {'name': 'Teal', 'color': Colors.teal, 'code': '0xFF008080'},
//     {'name': 'Orange', 'color': Colors.orange, 'code': '0xFFFFA500'},
//     {'name': 'Cyan', 'color': Colors.cyan, 'code': '0xFF00FFFF'},
//   ];
//
//   List brads = [
//     {"brandname": "Here & Now"},
//     {"brandname": "Zara"},
//     {"brandname": "Mast & harbour"},
//     {"brandname": "Tokyo talkies"},
//     {"brandname": "Vogue"},
//     {"brandname": "Gucci"},
//   ];
//
//   List size = [
//     {"size": "S"},
//     {"size": "M"},
//     {"size": "L"},
//     {"size": "XL"},
//     {"size": "2XL"}
//   ];
//
//   // void updateSlider(RangeValues values) {
//   //   currentRangeValues.value = RangeValues(values.start, values.end);
//   // }
// }
import 'package:flutter/material.dart';
import '/constants/constants.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import 'package:get/get.dart';

class ShopController extends GetxController with BaseController {
  // ─── STATE VARIABLES ──────────────────────────────────────────
  var products = [].obs;
  var isLoading = true.obs;
  var isFetchingMore = false.obs;
  var totalProducts = 0.obs;

  late ScrollController scrollController;
  int currentPage = 1;
  bool hasNextPage = false;

  // ─── ACTIVE FILTERS & SORTING ─────────────────────────────────
  var collectionName = "All Products".obs;

  // Sorting
  var sortBy = "created_at".obs;
  var sortOrder = "desc".obs;

  // Booleans
  var isFeatured = false.obs;
  var isHot = false.obs;

  // Price Range
  var currentPriceRange = const RangeValues(0, 10000).obs;
  var minPrice = 0.0.obs;
  var maxPrice = 10000.0.obs;

  // Arrays for multi-select (Using Sets to prevent duplicates)
  var selectedCategories = <String>{}.obs;
  var selectedBrands = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);

    _parseArguments();
    fetchProducts(isRefresh: true);
  }

  void _parseArguments() {
    if (Get.arguments != null) {
      final args = Get.arguments as Map;
      collectionName.value = args['name'] ?? "Shop";

      // If we arrived here from a specific category or brand banner
      if (args['source'] == 'category' && args['categoryId'] != null) {
        selectedCategories.add(args['categoryId']);
      } else if (args['source'] == 'brand' && args['brandId'] != null) {
        selectedBrands.add(args['brandId']);
      }
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (!isFetchingMore.value && hasNextPage) {
        fetchProducts(isRefresh: false);
      }
    }
  }

  // ─── THE CORE API FETCH ───────────────────────────────────────
  Future<void> fetchProducts({required bool isRefresh}) async {
    try {
      if (isRefresh) {
        isLoading.value = true;
        currentPage = 1;
        products.clear();
      } else {
        isFetchingMore.value = true;
        currentPage++;
      }

      // 1. Build Query Parameters based on your exact API Docs
      Map<String, dynamic> queryParams = {
        'page': currentPage.toString(),
        'count': '10',
        'sort_by': sortBy.value,
        'sort_order': sortOrder.value,
      };

      if (isFeatured.value) queryParams['featured'] = 'true';
      if (isHot.value) queryParams['hot'] = 'true';

      // Only apply price filter if they moved the sliders from default
      if (minPrice.value > 0) queryParams['min_price'] = minPrice.value.toString();
      if (maxPrice.value < 10000) queryParams['max_price'] = maxPrice.value.toString();

      // Dio automatically handles List<String> by passing multiple parameters
      // e.g., ?category=electronics&category=phones
      if (selectedCategories.isNotEmpty) {
        queryParams['category'] = selectedCategories.toList();
      }
      if (selectedBrands.isNotEmpty) {
        queryParams['brand'] = selectedBrands.toList();
      }

      // 2. Fetch Data
      var response = await BasicProvider("products")
          .getRequest(queryParams: queryParams)
          .catchError(handleError);

      // 3. Parse Response
      if (response != null && response is Map) {
        final List newProducts = (response['data'] is List) ? response['data'] : [];

        if (isRefresh) {
          products.assignAll(newProducts);
        } else {
          products.addAll(newProducts);
        }

        totalProducts.value = response['total'] is int
            ? response['total']
            : int.tryParse(response['total']?.toString() ?? '') ?? products.length;

        hasNextPage = response['hasNextPage'] == true;
      }
    } catch (e) {
      debugPrint('❌ Fetch Products Error: $e');
      if (!isRefresh) currentPage--;
    } finally {
      isLoading.value = false;
      isFetchingMore.value = false;
    }
  }

  // ─── FILTER CONTROLS ──────────────────────────────────────────
  void applySort(String by, String order) {
    sortBy.value = by;
    sortOrder.value = order;
    fetchProducts(isRefresh: true);
  }

  void toggleCategory(String slug) {
    if (selectedCategories.contains(slug)) {
      selectedCategories.remove(slug);
    } else {
      selectedCategories.add(slug);
    }
  }

  void toggleBrand(String slug) {
    if (selectedBrands.contains(slug)) {
      selectedBrands.remove(slug);
    } else {
      selectedBrands.add(slug);
    }
  }

  void clearAllFilters() {
    isFeatured.value = false;
    isHot.value = false;
    selectedCategories.clear();
    selectedBrands.clear();
    minPrice.value = 0.0;
    maxPrice.value = 10000.0;
    currentPriceRange.value = const RangeValues(0, 10000);
    sortBy.value = "created_at";
    sortOrder.value = "desc";
    fetchProducts(isRefresh: true);
  }
}