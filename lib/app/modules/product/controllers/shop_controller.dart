// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ShopController extends GetxController
    with BaseController, GetTickerProviderStateMixin {
  var allProductList = List<dynamic>.empty().obs;
  var getCurrentvalue = 0.obs;
  late ScrollController scrollController;
  var selectBrand = 0.obs;
  var selectSize = 0.obs;
  final count = 0.obs;
  var isLoading = true.obs;
  var currentPage = 1.obs;
  var maxPage = 1.obs;
  var colorSelecte = 0.obs;
  var selectedColor = 0.obs;
  var discountedValue = "".obs;
  var currentRangeValues = RangeValues(0, 1500).obs;
  var box = GetStorage();
  var arguments = {}.obs;
  var producttype;
  var productId;
  var collectionName;
  var categoryId = [];
  var source;
  var isFilter = false.obs;
  var filterMaxPrice;
  var filterMinPrice;

  var offerConrnerPrice;

  // Add these variables to your ShopController
  var childCategories = <String>[].obs; // Store child category IDs
  var isLoadingCategories = false.obs;
  var parentCategoryName = ''.obs;

  late AnimationController controller;
  late Animation<double> scaleAnimation;

  // Update onInit method
  @override
  Future<void> onInit() async {
    scrollController = ScrollController();
    arguments.addAll(Get.arguments);
    source = arguments['source'];

    if (source == 'offerCorner') {
      offerConrnerPrice = arguments['price'];
      collectionName = arguments['name'];
      getOfferConrnerProducts(offerConrnerPrice);
    } else if (source == 'dashboard') {
      productId = arguments['productId'];
      collectionName = arguments['name'];
      producttype = arguments['productype'];
      dashBoardproducts(productType: producttype);
    } else if (source == 'category') {
      productId = arguments[
          'productId']; // This is "699d60029883b0f8f191f668" (T-shirts)
      collectionName = arguments['name']; // This is "T-shirts"

      // Extract children IDs first
      await fetchCategoryChildren(productId);
      // Then fetch products using the children IDs
      await getCategoryWiseProduct(productId);
    }

    await fetchProductOnScroll();
    await getMaxMinPriceFilter();

    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  Future<void> getMaxMinPriceFilter() async {
    var response =
        await BasicProvider('public/product/max-min-price').getRequest();
    filterMaxPrice = 100000;
    filterMinPrice = 0;
    if (response == null) return;
    filterMaxPrice = response[0]['maxPrice'];
    filterMinPrice = response[0]['minPrice'];
  }

  Future<void> filterProducts() async {
    isFilter.value = true;
    isLoading(true);
    var response =
        await BasicProvider("public/product/filter?count=10&page=$currentPage")
            .postRequest({
      'min_price': currentRangeValues.value.start,
      'max_price': currentRangeValues.value.end,
      'color': colorList[selectedColor.value]['name']
    }).catchError(handleError);
    if (response == null) return;

    allProductList.addAll(response['data']);
    maxPage(response["last_page"]);
    isLoading(false);
    update();
  }

  Future<void> onPullTorefresh() async {
    currentPage.value = 1;
    maxPage.value = 10;
    allProductList.clear();
    if (isFilter.value == true) {
      filterProducts();
    } else {
      if (source == 'offerCorner') {
        offerConrnerPrice = arguments['price'];
        collectionName = arguments['name'];

        getOfferConrnerProducts(offerConrnerPrice);
      } else if (source == 'dashboard') {
        productId = arguments['productId'];
        collectionName = arguments['name'];
        producttype = arguments['productype'];
        dashBoardproducts(productType: producttype);
        // categoryId.addAll(productId);
      } else if (source == 'category') {
        productId = arguments['productId'];
        collectionName = arguments['name'];
        getCategoryWiseProduct(productId);
      }
    }
  }

  Future<void> dashBoardproducts({required String productType}) async {
    try {
      isLoading(true);

      var response;
      if (productType == 'random_category') {
        response = await BasicProvider(
                "mobile/public/product/random?count=10&page=$currentPage")
            .getRequest()
            .catchError(handleError);
      } else if (productType == 'specific_category') {
        response = await BasicProvider(
                "mobile/public/product/specific?count=10&page=$currentPage")
            .postRequest({'categories': productId}).catchError(handleError);
      } else if (productType == 'popular_products') {
        response = await BasicProvider(
                "mobile/public/product/popular?count=10&page=$currentPage")
            .getRequest()
            .catchError(handleError);
      } else if (productType == 'discounted_products') {
        response = await BasicProvider(
                "mobile/public/product/discounted?count=10&page=$currentPage")
            .getRequest()
            .catchError(handleError);
      }

      if (productType == 'random_category') {
        allProductList.addAll(response);
      } else {
        allProductList.addAll(response['data']);
      }
      maxPage(response["last_page"]);
      print('max page ${maxPage.value}');
      isLoading(false);
    } catch (e) {
      print('trending error $e');
      isLoading(false);
    }
    // }
  }

  Future<void> getOfferConrnerProducts(String price) async {
    isLoading(true);
    var response = await BasicProvider(
            "mobile/public/product/below/$price?count=10&page=$currentPage")
        .getRequest()
        .catchError(handleError);
    if (response == null) return;
    allProductList.addAll(response['data']);
    maxPage(response["last_page"]);
    isLoading(false);
    update();
  }

// Add this method to fetch and extract children IDs - FIXED VERSION
  Future<void> fetchCategoryChildren(String targetCategoryId) async {
    try {
      isLoadingCategories(true);
      print(
          '🟡 fetchCategoryChildren STARTED for categoryId: $targetCategoryId');

      // Use the correct endpoint that returns the full category structure
      var response = await BasicProvider('mobile-app/category')
          .getRequest()
          .catchError(handleError);

      print('📦 Full API Response received');

      if (response == null) {
        print('❌ Response is null');
        return;
      }

      print('📦 Response keys: ${response.keys}');

      if (response['data'] == null) {
        print('❌ response["data"] is null');
        return;
      }

      // Parse the response to find the category and extract its children
      if (response['data']['sections'] != null) {
        print('✅ Found sections in response');

        for (var section in response['data']['sections']) {
          print('📂 Section type: ${section['type']}');

          if (section['type'] == 'categories' &&
              section['content_json'] != null) {
            print('✅ Found categories section');

            var contentJson = section['content_json'];
            print('📄 content_json keys: ${contentJson.keys}');

            if (contentJson['categories'] != null) {
              var categories = contentJson['categories'];
              print('📋 Total categories found: ${categories.length}');

              // Search through all categories recursively
              await _searchCategoryTree(categories, targetCategoryId);
            }
          }
        }
      } else {
        print('❌ No sections found in response');
      }

      if (childCategories.isEmpty) {
        print(
            '❌ No category found with ID: $targetCategoryId or it has no children');
        // Fallback: use the target ID itself
        childCategories.add(targetCategoryId);
      }

      print('✅ Final childCategories: $childCategories');
    } catch (e) {
      print('❌ Error in fetchCategoryChildren: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    } finally {
      isLoadingCategories(false);
    }
  }

// Helper method to recursively search through category tree
  Future<void> _searchCategoryTree(List categories, String targetId) async {
    for (var category in categories) {
      String currentId = category['_id'] ?? category['id'] ?? '';

      // Check if this is the category we're looking for
      if (currentId == targetId) {
        parentCategoryName.value = category['name'] ?? 'Unknown';
        print('✅ Found target category: ${parentCategoryName.value}');

        // EXTRACT CHILDREN IDs
        if (category['children'] != null && category['children'].isNotEmpty) {
          // Handle both formats: array of strings or array of objects
          if (category['children'].first is String) {
            // Children are stored as strings (IDs)
            childCategories.value = List<String>.from(category['children']);
          } else {
            // Children are stored as objects, extract their IDs
            childCategories.value = category['children'].map<String>((child) {
              return child['_id'] ?? child['id'] ?? '';
            }).toList();
          }
          print('📋 Extracted CHILDREN IDs: $childCategories');
        } else {
          print('ℹ️ No children found for this category');
        }
        return;
      }

      // If this category has children, search through them recursively
      if (category['children'] != null && category['children'].isNotEmpty) {
        await _searchCategoryTree(category['children'], targetId);
        if (childCategories.isNotEmpty) return; // Found it, stop searching
      }
    }
  }

// Modified getCategoryWiseProduct
  Future<void> getCategoryWiseProduct(var categories) async {
    isLoading(true);

    try {
      // First, fetch children for this category
      if (categories is String) {
        await fetchCategoryChildren(categories);
      }

      List<String> categoriesToFetch = [];

      // Use child categories if available
      if (childCategories.isNotEmpty) {
        categoriesToFetch = childCategories;
        print('📦 Using CHILDREN category IDs: $categoriesToFetch');
      } else {
        // Fallback to the original category
        categoriesToFetch = [categories is String ? categories : categories[0]];
        print('📦 Using parent category ID as fallback: $categoriesToFetch');
      }

      // Fetch products using the categories
      if (categoriesToFetch.isNotEmpty) {
        print('🚀 Fetching products for categories: $categoriesToFetch');

        var response = await BasicProvider(
                'public/product/categorywise/?count=10&page=$currentPage')
            .postRequest({
          "categories": categoriesToFetch,
        }).catchError(handleError);

        if (response == null) return;

        allProductList.addAll(response['data']);
        maxPage(response["last_page"]);
        print('✅ Loaded ${response['data'].length} products');
      }
    } catch (e) {
      print('❌ Error in getCategoryWiseProduct: $e');
    } finally {
      isLoading(false);
      update();
    }
  }

  Future<void> fetchProductOnScroll() async {
    scrollController.addListener(() async {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 50.0) {
        if (!isLoading.value && currentPage.value < maxPage.value) {
          currentPage(currentPage.value + 1);
          if (isFilter.value == true) {
            filterProducts();
          } else {
            if (source == 'offerCorner') {
              await getOfferConrnerProducts(offerConrnerPrice);
            } else if (source == 'dashboard') {
              await dashBoardproducts(productType: producttype);
            } else if (source == 'category') {
              await getCategoryWiseProduct(productId);
            }
          }
        }
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
  }

  List color = [
    const Color(0xFFE6E6FA),
    const Color(0xFFF5F5F5),
    const Color(0xFFB0C4DE),
    const Color(0xFFEBACA2),
    const Color(0xFFFFC0CB),
    const Color(0xFFADD8E6),
    const Color(0xFFBED3C3),
    const Color(0xFF9FD9F2),
    const Color(0xFFF5DEB3),
    const Color(0xFFFFE4E1),
    const Color(0xFFE6E6FA)
  ];

  // Define a list of color details: name, color object, and hexadecimal code
  final List<Map<String, dynamic>> colorList = [
    {'name': 'Red', 'color': Colors.red, 'code': '0xFFFF0000'},
    {'name': 'Blue', 'color': Colors.blue, 'code': '0xFF0000FF'},
    {'name': 'Pink', 'color': Colors.pink, 'code': '0xFFFFC0CB'},
    {'name': 'Green', 'color': Colors.green, 'code': '0xFF008000'},
    {'name': 'Yellow', 'color': Colors.yellow, 'code': '0xFFFFFF00'},
    {'name': 'Purple', 'color': Colors.purple, 'code': '0xFF800080'},
    {'name': 'Grey', 'color': Colors.grey, 'code': '0xFF808080'},
    {'name': 'Teal', 'color': Colors.teal, 'code': '0xFF008080'},
    {'name': 'Orange', 'color': Colors.orange, 'code': '0xFFFFA500'},
    {'name': 'Cyan', 'color': Colors.cyan, 'code': '0xFF00FFFF'},
  ];

  List brads = [
    {"brandname": "Here & Now"},
    {"brandname": "Zara"},
    {"brandname": "Mast & harbour"},
    {"brandname": "Tokyo talkies"},
    {"brandname": "Vogue"},
    {"brandname": "Gucci"},
  ];

  List size = [
    {"size": "S"},
    {"size": "M"},
    {"size": "L"},
    {"size": "XL"},
    {"size": "2XL"}
  ];

  void updateSlider(RangeValues values) {
    currentRangeValues.value = RangeValues(values.start, values.end);
  }
}
