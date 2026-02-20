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
  var collectionName = ''.obs;
  var categoryId = [];
  var source;
  var isFilter = false.obs;
  var filterMaxPrice;
  var filterMinPrice;

  var offerConrnerPrice;

  late AnimationController controller;
  late Animation<double> scaleAnimation;

  // Add these to your ShopController
  var categoryStructure = {}.obs;
  var subCategories = <dynamic>[].obs;
  var deepCategories = <dynamic>[].obs;
  var _selectedSubCategoryIndex = 0.obs;

  int get selectedSubCategoryIndex => _selectedSubCategoryIndex.value;

  set selectedSubCategoryIndex(int value) {
    _selectedSubCategoryIndex.value = value;
    update(); // Force update
    print("🎯 Index set to: $value");
  }

  var selectedDeepCategoryIndex = 0.obs;
  var selectedSubCategoryId = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize animation FIRST
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );

    scrollController = ScrollController();

    // DON'T assign arguments here
    // arguments.addAll(Get.arguments); // REMOVE THIS LINE

    // Other non-reactive initializations
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  @override
  void onReady() {
    super.onReady();

    // Move ALL reactive updates and API calls here
    arguments.addAll(Get.arguments);
    source = arguments['source'];

    if (source == 'offerCorner') {
      offerConrnerPrice = arguments['price'];
      collectionName.value = arguments['name'];
      getOfferConrnerProducts(offerConrnerPrice);
    } else if (source == 'dashboard') {
      productId = arguments['productId'];
      collectionName.value = arguments['name'];
      producttype = arguments['productype'];
      dashBoardproducts(productType: producttype);
    } else if (source == 'category') {
      productId = arguments['productId'];
      collectionName.value = arguments['name'];

      // Fetch category structure
      Future.microtask(() {
        fetchCategoryStructure();
      });
    }

    fetchProductOnScroll();
    Future.microtask(() {
      getMaxMinPriceFilter();
    });
    currentRangeValues.value.start.val(filterMaxPrice.toString());
  }

  Future<void> getMaxMinPriceFilter() async {
    try {
      // Use the existing category structure API to get price range
      var response = await BasicProvider(
              'category/get-first-parent/products?pagination=false')
          .getRequest()
          .catchError(handleError);

      filterMaxPrice = 100000; // Default fallback
      filterMinPrice = 0; // Default fallback

      if (response == null || response['data'] == null) return;

      // Extract price range from all products in the category structure
      List<dynamic> allCategories = response['data'];
      num maxPrice = 0;
      num minPrice = double.infinity;

      // Function to recursively extract products and find prices
      void extractPricesFromCategories(List<dynamic> categories) {
        for (var category in categories) {
          // Check if category has products array (depends on your API structure)
          if (category['products'] != null && category['products'] is List) {
            for (var product in category['products']) {
              // Handle variable products with variants
              if (product['type'] == 'variable' &&
                  product['variants'] != null) {
                for (var variant in product['variants']) {
                  num price =
                      variant['discounted_price'] ?? variant['price'] ?? 0;
                  if (price > maxPrice) maxPrice = price;
                  if (price < minPrice && price > 0) minPrice = price;
                }
              }
              // Handle simple products
              else {
                num price = product['sale_price'] ?? product['price'] ?? 0;
                if (price > maxPrice) maxPrice = price;
                if (price < minPrice && price > 0) minPrice = price;
              }
            }
          }

          // Recursively check children categories
          if (category['children'] != null && category['children'].isNotEmpty) {
            extractPricesFromCategories(category['children']);
          }
        }
      }

      extractPricesFromCategories(allCategories);

      // Set the filter values
      filterMaxPrice = maxPrice > 0 ? maxPrice.toInt() : 100000;
      filterMinPrice = minPrice != double.infinity ? minPrice.toInt() : 0;

      print(
          '✅ Price range extracted: Min=$filterMinPrice, Max=$filterMaxPrice');
    } catch (e) {
      print('❌ Error in getMaxMinPriceFilter: $e');
      filterMaxPrice = 100000;
      filterMinPrice = 0;
    }
  }

  getProductsForCategory(String categoryId) async {
    isLoading(true);

    try {
      print("🔍 Fetching products for category: ${categoryId}");

      var response = await BasicProvider("products?category=$categoryId")
          .getRequest()
          .catchError(handleError);

      if (response == null) {
        isLoading(false);
        return;
      }

      print("📦 Response type: ${response.runtimeType}");
      print(
          "📦 Response keys: ${response is Map ? response.keys : 'Not a Map'}");

      allProductList.clear();

      // FIX: Check the actual response structure
      if (response is Map) {
        // If response has 'data' key and it's a List
        if (response['data'] != null && response['data'] is List) {
          allProductList.addAll(List.from(response['data']));
          print(
              "✅ Added ${response['data'].length} products from response['data']");
        }
        // If response has 'products' key and it's a List
        else if (response['products'] != null && response['products'] is List) {
          allProductList.addAll(List.from(response['products']));
          print(
              "✅ Added ${response['products'].length} products from response['products']");
        }
        // If response has 'data' that contains another 'data' (like nested)
        else if (response['data'] != null &&
            response['data'] is Map &&
            response['data']['data'] != null &&
            response['data']['data'] is List) {
          allProductList.addAll(List.from(response['data']['data']));
          print(
              "✅ Added ${response['data']['data'].length} products from response['data']['data']");
        }
        // Try to find any list in the response
        else {
          bool foundList = false;
          response.forEach((key, value) {
            if (!foundList && value is List && value.isNotEmpty) {
              print("🔍 Found list in key: $key with ${value.length} items");
              allProductList.addAll(List.from(value));
              foundList = true;
            }
          });

          if (!foundList) {
            print("⚠️ No product list found in response");
          }
        }
      }
      // If response is directly a List
      else if (response is List) {
        allProductList.addAll(List.from(response));
        print("✅ Added ${response.length} products from direct list");
      }

      // Calculate max page based on your pagination
      if (response is Map) {
        if (response['total'] != null) {
          if (response['total'] is int) {
            maxPage.value = (response['total'] / 10).ceil();
          } else if (response['total'] is String) {
            maxPage.value = (int.parse(response['total']) / 10).ceil();
          }
        } else if (response['last_page'] != null) {
          if (response['last_page'] is int) {
            maxPage.value = response['last_page'];
          } else if (response['last_page'] is String) {
            maxPage.value = int.parse(response['last_page']);
          }
        } else {
          maxPage.value = (allProductList.length / 10).ceil();
        }
      } else {
        maxPage.value = (allProductList.length / 10).ceil();
      }

      print("✅ Final product count: ${allProductList.length}");
      print("✅ Max page: ${maxPage.value}");

      // Print first product as sample if available
      if (allProductList.isNotEmpty) {
        print("📦 Sample product: ${allProductList.first['name']}");
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching products: $e');
      print('📚 Stack trace: $stackTrace');
    }

    isLoading(false);
    update();
  }

  Future<void> fetchCategoryStructure() async {
    try {
      isLoading(true);
      print('🟡 fetchCategoryStructure STARTED for productId: $productId');

      var response = await BasicProvider(
              'category/get-first-parent/products?pagination=false')
          .getRequest()
          .catchError(handleError);

      if (response == null) {
        print('❌ Response is null');
        return;
      }

      print('🟢 Category structure fetched successfully');
      categoryStructure.value = response;

      // RECURSIVE SEARCH FUNCTION
      dynamic findCategoryById(List<dynamic> categories, String targetId) {
        for (var category in categories) {
          if (category['_id'] == targetId) {
            return category;
          }
          if (category['children'] != null && category['children'].isNotEmpty) {
            final found = findCategoryById(category['children'], targetId);
            if (found != null) return found;
          }
        }
        return null;
      }

      final selectedCategory =
          findCategoryById(response['data'] ?? [], productId);

      if (selectedCategory != null) {
        print(
            '✅ Selected category found: ${selectedCategory['name']} (${selectedCategory['_id']})');
        // FIX: Update collectionName with the actual category name
        collectionName.value = selectedCategory['name'];

        print('📝 Updated collectionName to: $collectionName');

        // Extract subcategories
        if (selectedCategory['children'] != null) {
          subCategories.value = List.from(selectedCategory['children']);
          print(
              '📂 Found ${subCategories.length} subcategories: ${subCategories.map((c) => c['name']).toList()}');
        }

        // Fetch products for this category
        if (subCategories.isNotEmpty) {
          print(
              '🟢 Calling getProductsForCategory for first subcategory: ${subCategories.first['name']} (${subCategories.first['slug']})');
          //selectedSubCategoryId.value = subCategories.first['_id'];
          selectedSubCategoryId.value = selectedCategory['name'];
          await getProductsForCategory(selectedSubCategoryId.value);
        } else {
          print(
              '🟢 Calling getProductsForCategory for main category: $productId');
          await getProductsForCategory(productId);
        }
        //await getProductsForCategory(productId);
      } else {
        print('❌ No category found with ID: $productId');
      }

      isLoading(false);
    } catch (e) {
      print('❌ Error in fetchCategoryStructure: $e');
      isLoading(false);
    }
  }

  // This will recursively find all subcategory IDs including nested ones
  List<String> getAllSubCategoryIds(dynamic category) {
    List<String> ids = [];

    if (category['_id'] != null) {
      ids.add(category['_id']);
    }

    if (category['children'] != null && category['children'].isNotEmpty) {
      for (var child in category['children']) {
        ids.addAll(getAllSubCategoryIds(child));
      }
    }

    return ids;
  }

// Modified method to fetch products from main category and all subcategories
  Future<void> fetchProductsForCategoryAndSubcategories(
      String categoryId) async {
    isLoading(true);

    // Find the category from our stored structure
    final allCategories = categoryStructure['data'] as List? ?? [];
    dynamic targetCategory;

    for (var cat in allCategories) {
      if (cat['_id'] == categoryId) {
        targetCategory = cat;
        break;
      }
    }

    if (targetCategory == null) return;

    // Get all category IDs (main + all nested children)
    List<String> allCategoryIds = getAllSubCategoryIds(targetCategory);

    print('📦 Fetching products for categories: $allCategoryIds');

    // Now fetch products using these IDs
    var response = await BasicProvider(
            'public/product/categorywise/?count=10&page=$currentPage')
        .postRequest({
      "categories": allCategoryIds, // Send ALL category IDs
    }).catchError(handleError);

    if (response == null) return;

    allProductList.addAll(response['data']);
    maxPage(response["last_page"]);

    // Right after allProductList.addAll(), add:
    print('📦 First product keys: ${allProductList.first.keys}');
    print('📦 Product type: ${allProductList.first['type']}');
    print('📦 Has variants? ${allProductList.first.containsKey('variants')}');
    if (allProductList.first.containsKey('variants')) {
      print('📦 Variants length: ${allProductList.first['variants']?.length}');
    }
    isLoading(false);
    update();
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
        //getCategoryWiseProduct(productId);
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

  // Future<void> getCategoryWiseProduct(var categories) async {
  //   isLoading(true);
  //   var response = await BasicProvider(
  //           'public/product/categorywise/?count=10&page=$currentPage')
  //       .postRequest(
  //     {
  //       "categories": categories,
  //     },
  //   ).catchError(handleError);
  //   if (response == null) return;
  //   allProductList.addAll(response['data']);
  //   maxPage(response["last_page"]);
  //   isLoading(false);
  //   update();
  // }

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
              // await getCategoryWiseProduct(productId);
            }
          }
        }
      }
    });
  }
  // Future<void> fetchProductOnScroll() async {
  //   scrollController.addListener(() async {
  //     if (scrollController.position.pixels ==
  //         scrollController.position.minScrollExtent) {

  //     }

  //     if (scrollController.position.pixels >=
  //         scrollController.position.maxScrollExtent - 50.0) {
  //       if (currentPage.value < maxPage.value) {
  //         currentPage(currentPage.value + 1);
  //         print('Fetching next page');
  //         if (isFilter.value == true) {
  //           filterProducts();
  //         } else {
  //           if (source == 'offerCorner') {
  //             await getOfferConrnerProducts(offerConrnerPrice);
  //           } else if (source == 'dashboard') {
  //             await dashBoardproducts(productType: producttype);
  //           } else if (source == 'category') {
  //             await getCategoryWiseProduct(productId);
  //           }
  //         }
  //       }
  //     }
  //   });
  // }

  void gotProductDetails(item) {
    // if (allProductList[item]['type'] == "simple") {
    // Get.to(() => ProductdetailView(),
    //     binding: ShopBinding(),
    //     arguments: {'productId': allProductList[item]['_id']});
    // }
    // Get.to(() => ProductdetailView(),
    //     arguments: {'productId': allProductList[item]['_id']});
    // if (allProductList[item]['type'] == "variant") {
    //   Get.to(() => ProductvariantView(),
    //       binding: ShopBinding(), arguments: allProductList[item]);
    // }
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
