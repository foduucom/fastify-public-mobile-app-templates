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

  late AnimationController controller;
  late Animation<double> scaleAnimation;

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
      // categoryId.addAll(productId);
    } else if (source == 'category') {
      productId = arguments['productId'];
      collectionName = arguments['name'];
      getCategoryWiseProduct(productId);
    }

    // if (producttype != null) {
    // } else {
    //   categoryId.add(productId);

    //   await getCategoryWiseProduct(categoryId);
    // }

    await fetchProductOnScroll();
    await getMaxMinPriceFilter();
    currentRangeValues.value.start.val(filterMaxPrice.toString());

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

  Future<void> getCategoryWiseProduct(var categories) async {
    isLoading(true);
    var response = await BasicProvider(
            'public/product/categorywise/?count=10&page=$currentPage')
        .postRequest(
      {
        "categories": categories,
      },
    ).catchError(handleError);
    if (response == null) return;
    allProductList.addAll(response['data']);
    maxPage(response["last_page"]);
    isLoading(false);
    update();
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
