import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class ProductdetialController extends GetxController
    with BaseController, GetTickerProviderStateMixin {
  var isLoading = false.obs;
  var offerCode = 'FODUUKART10';
  var isCopied = false.obs;
  var productDetials = {}.obs;
  var pinCodeController;
  var box = GetStorage();
  var productGallery = List.empty().obs;
  var pageController = PageController();
  int _currentPage = 0;
  var similarProduct = [].obs;
  var selectedPageIndex = 0.obs;
  var isAlreadyInCart = false.obs;
  var getYourSize = "S".obs;
  var productReview = [].obs;
  var categoriesId = [];
  List<String> cateogries = [];
  var reviewTextController = TextEditingController();

  var productId;

  var labelVariant = [].obs;
  var labels = [].obs;
  var variantString = ''.obs;
  var joinedVariants = ''.obs;
  Map<String, String> selectedVariants = {};
  var selectedVariantIndex = 0.obs;
  var selectedVariant = {}.obs;
  var productVariantOption = List<dynamic>.empty();

  // var pinCodeController;
  final count = 1.obs;
  final checkController = TextEditingController();
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  Future<void> onInit() async {
    super.onInit();
    selectedVariantIndex.value = 0;
    pageController = PageController(
        initialPage: _currentPage, viewportFraction: 0.8, keepPage: true);
    pinCodeController = TextEditingController();
    try {
      var argument = Get.arguments;
      if (argument != null) {
        productId = argument['productId'];
        box.write('tempProductId', productId);
      } else {
        productId = box.read('tempProductId');
      }
    } catch (e) {
      print('product details init error $e');
    }

    await getProductDetials(id: productId);

    categoriesId.addAll(productDetials['categories']);

    // if (AuthDetails.isUserLogin()) {
    //   isAlreadyInCart.value = Get.find<CartController>()
    //       .cartProducts
    //       .any((element) => element['productId'] == productId);
    // } else {
    //   isAlreadyInCart.value = Get.find<CartController>()
    //       .cartProducts
    //       .any((element) => element['_id'] == productId);
    // }

    categoriesId.forEach((element) {
      cateogries.add("${element['_id']}");
    });

    getSimilarProduct(cateogries);

    getVariantDetails();
    getProductReview(productId);
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  Future<void> getSimilarProduct(List category) async {
    try {
      similarProduct.clear();
      var response =
          await BasicProvider("public/product/categorywise").postRequest(
        {"categories": category},
      ).catchError(handleError);
      if (response == null) return;
      similarProduct.clear();
      similarProduct.addAll(response['data']);
    } catch (e) {
      print('similar product error $e');
    }
  }

  dynamic validCheck() {
    if (checkController.text.isEmpty) {
      return 'Please enter a PIN code';
    } else if (checkController.text.length < 6) {
      return 'PIN code must be at least 6 characters';
    }
    return null;
  }

  List color = [
    const Color(0xFFE6E6FA),
    const Color(0xFFF5F5F5),
    const Color(0xFFB0C4DE),
  ];

  String getDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);

    DateFormat dateFormat = DateFormat("dd MMM, yyyy");
    String formattedDate = dateFormat.format(dateTime);
    return formattedDate;
  }

  void postReview({required String summary, required int rating}) async {
    var form = {
      'product': productId,
      'rating': rating,
      'summary': summary,
    };
    var response = await BasicProvider("public/reviews/product")
        .postRequest(form)
        .catchError(handleError);
    if (response == null) return;
    productReview.clear();

    productReview.addAll(response);
  }

  void getProductReview(String productId) async {
    var response = await BasicProvider("public/reviews/product-wise/$productId")
        .getRequest()
        .catchError(handleError);
    if (response == null) return;
    // productReview.addAll(response['data']);
    productReview.clear();
    productReview.addAll(response['data']);
  }

  Future<void> getProductDetials({required String id}) async {
    isLoading.value = true;
    var response = await BasicProvider("public/product/show/$id")
        .getRequest()
        .catchError(handleError);
    if (response == null) return;
    isLoading.value = false;

    productDetials.value = response;
    if (productDetials['gallery'] != null) {
      productGallery.value = productDetials['gallery'];
    }
  }

  // void getVariantDetails() {
  //   if (productDetials['type'] == 'variant') {
  //     if (productDetials['variant_options'] != null) {
  //       productVariantOption = jsonDecode(productDetials['variant_options']);
  //     }
  //     print("=-----------------");
  //     print(productVariantOption);
  //     List<String> labels = [];

  //     for (var option in productVariantOption) {
  //       labels.add(option['label']);
  //     }
  //     for (var i = 0; i < productVariantOption.length; i++) {
  //       if (labels.contains(productVariantOption[i]['label'])) {
  //         variantOption.add({
  //           productVariantOption[i]['label']: productVariantOption[i]
  //               ['variants']
  //         });
  //         print('################ ${variantOption}');
  //       }
  //       if (productVariantOption[i]['label'] == 'colour') {
  //         colorList = productVariantOption[i]['variants'];
  //       }
  //       if (productVariantOption[i]['label'] == 'size') {
  //         sizeList = productVariantOption[i]['variants'];
  //       }
  //     }

  //     print(variantOption);

  //     selectedColor.value = colorList.isNotEmpty ? colorList[0] : '-1';
  //     selectedSize.value = sizeList.isNotEmpty ? sizeList[0] : '-1';
  //   }
  // }String joinedVariants

  void getVariantDetails() {
    if (productDetials['type'] == 'variant') {
      if (productDetials['variant_options'] != null) {
        productVariantOption = json.decode(productDetials['variant_options']);
        List<String> selectedVariants = [];
        for (var item in productVariantOption) {
          labels.add(item['label']);
          labelVariant.add(item['variants']);
          if (labelVariant.isNotEmpty) {
            selectedVariants.add(item['variants'][0].toString());
            selectedVariant
                .addAll({item['label']: item['variants'][0].toString()});
          }
        }
        joinedVariants.value = selectedVariants.join('/');

        // selectedColor.value = colorList.isNotEmpty ? colorList[0] : '-1';
        // selectedSize.value = sizeList.isNotEmpty ? sizeList[0] : '-1';
      }
    }
  }

  void onSelectVariant(String label, String variant) {
    selectedVariant[label] = variant;
    updateJoinedVariants();
  }

  void updateJoinedVariants() {
    List<String> variantList = [];
    for (var label in selectedVariant.keys) {
      variantList.add(selectedVariant[label]!);
    }
    joinedVariants.value = variantList.join('/');
    print('joingt+++++ $joinedVariants');
    updateVariantIndex();
  }

  void updateVariantIndex() {
    for (int i = 0; i < productDetials['variant_ids'].length; i++) {
      if (joinedVariants.value == productDetials['variant_ids'][i]['variant']) {
        // selectedVariant.addAll(variantsProduct[i]);
        selectedVariantIndex.value = i;
      }
    }
  }

  bool containsExactSize(String variants, String target) {
    // Split the string into parts based on the delimiter
    List<String> parts = variants.split('/');
    // Check if any part matches the target size
    return parts.contains(target);
  }

  Future<void> addToCart() async {
    // Get.find<BottombarController>().addToCart(productDetials);
    // Get.put(CartController()).
    isLoading.value = true;

    // await Get.find<CartController>()
    //     .addToCart(
    //         productId: productId,
    //         quantity: count.value,
    //         variantName: joinedVariants.value,
    //         productType: productDetials['type'])
    //     .then((value) {
    //   isLoading.value = false;
    //   return;
    // });
    // Get.find<BottombarController>().currentPageIndex.value = 2;
    // Get.find<BottombarController>().pageController.jumpToPage(2);
  }

  @override
  void onReady() {
    super.onReady();
  }

  void increment() {
    if (count.value != 10) {
      count.value++;
    }
  }

  void decrement() {
    if (count.value != 1) {
      count.value--;
    }
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  List size = [
    {
      "size": "S",
    },
    {
      "size": "M",
    },
    {
      "size": "L",
    },
    {
      "size": "XL",
    },
  ];
}
