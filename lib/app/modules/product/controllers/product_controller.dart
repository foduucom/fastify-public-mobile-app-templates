import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/core/services/cartServcie.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class ProductController extends GetxController
    with BaseController, GetTickerProviderStateMixin {
  RxList<String> sizes = <String>[].obs;
  var activeIndex = 0.obs;
  var isDescriptionExpanded = false.obs;

  void toggleDescription() {
    isDescriptionExpanded.value = !isDescriptionExpanded.value;
  }

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

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // var pinCodeController;
  final count = 1.obs;
  final checkController = TextEditingController();
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  // Add these to your controller
  RxList<String> colors = <String>[].obs;
  var selectedSizeIndex =
      0.obs; // ✅ CHANGE: from activeIndex to selectedSizeIndex
  RxInt selectedColorIndex = 0.obs;
  var selectedImageIndex = 0.obs;

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

    if (productDetials.containsKey('categories') &&
        productDetials['categories'] != null) {
      categoriesId.addAll(productDetials['categories']);
    }

    if (AuthDetails.isUserLogin()) {
      isAlreadyInCart.value = Get.find<CartController>()
          .cartProducts
          .any((element) => element['productId'] == productId);
    } else {
      isAlreadyInCart.value = Get.find<CartController>()
          .cartProducts
          .any((element) => element['_id'] == productId);
    }

    categoriesId.forEach((element) {
      cateogries.add("${element['_id']}");
    });

    //getSimilarProduct(cateogries);
    extractAttributes();
    // ✅ ADD THIS: Initialize selectors after extracting attributes
    initializeSelectors();
    getVariantDetails();
    //getProductReview(productId);
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  // Add this method to initialize selectors
  void initializeSelectors() {
    // Initialize color selector
    if (colors.isNotEmpty) {
      selectedColorIndex.value = 0;
    }

    // Initialize size selector
    if (sizes.isNotEmpty) {
      selectedSizeIndex.value = 0;
    }

    // Update variant with initial selections
    updateSelectedVariant();
  }

  // Call this after getProductDetials()
  void extractAttributes() {
    if (productDetials['attributes'] != null) {
      for (var attribute in productDetials['attributes']) {
        if (attribute['name'] == 'size') {
          sizes.value = List<String>.from(attribute['values']);
        }
        if (attribute['name'] == 'color') {
          colors.value = List<String>.from(attribute['values']);
        }
      }
    }
  }

  void updateSelectedVariant() {
    if (productDetials['variants'] == null ||
        productDetials['variants'] is! List) return;

    List variants = productDetials['variants'];
    int variantIndex = -1;

    String? targetSize =
        sizes.isNotEmpty ? sizes[selectedSizeIndex.value].toLowerCase() : null;
    String? targetColor = colors.isNotEmpty
        ? colors[selectedColorIndex.value].toLowerCase()
        : null;

    print("Target Attributes - Size: $targetSize, Color: $targetColor");

    for (int i = 0; i < variants.length; i++) {
      var variant = variants[i];
      var variantAttributes = variant['attributes'];

      if (variantAttributes != null && variantAttributes is Map) {
        // Match by attributes
        bool isMatch = true;
        if (targetSize != null &&
            variantAttributes['size']?.toString().toLowerCase() != targetSize) {
          isMatch = false;
        }
        if (targetColor != null &&
            variantAttributes['color']?.toString().toLowerCase() !=
                targetColor) {
          isMatch = false;
        }

        if (isMatch) {
          variantIndex = i;
          break;
        }
      } else {
        // Fallback to name matching
        String variantName =
            variant['variant_name']?.toString().toLowerCase() ??
                variant['name']?.toString().toLowerCase() ??
                '';

        if (targetSize != null && targetColor != null) {
          List<String> formats = [
            '$targetColor / $targetSize',
            '$targetColor/$targetSize',
            '$targetSize / $targetColor',
            '$targetSize/$targetColor',
          ];
          if (formats.any((f) => variantName == f)) {
            variantIndex = i;
            break;
          }
        } else if (targetSize != null && variantName == targetSize) {
          variantIndex = i;
          break;
        } else if (targetColor != null && variantName == targetColor) {
          variantIndex = i;
          break;
        }
      }
    }

    if (variantIndex != -1) {
      selectedVariantIndex.value = variantIndex;
      selectedImageIndex.value = 0;
      print(
          "Matched variant at index $variantIndex: ${variants[variantIndex]}");
    } else {
      print("No variant matched for attributes.");
    }
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

  // dynamic validCheck() {
  //   if (checkController.text.isEmpty) {
  //     return 'Please enter a PIN code';
  //   } else if (checkController.text.length < 6) {
  //     return 'PIN code must be at least 6 characters';
  //   }
  //   return null;
  // }

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
    var response = await BasicProvider("products/$id")
        .getRequest()
        .catchError(handleError);
    if (response == null) {
      isLoading.value = false;
      return;
    }
    isLoading.value = false;

    productDetials.value = response;

    if (productDetials['gallery'] != null) {
      productGallery.value = productDetials['gallery'];
    }

    // First try to extract from attributes (more reliable)
    if (productDetials['attributes'] != null &&
        productDetials['attributes'].isNotEmpty) {
      var attributes = productDetials['attributes'];

      for (var attr in attributes) {
        String attrName = attr['name']?.toString().toLowerCase() ?? '';

        if (attrName.contains('color')) {
          // Extract colors from attributes
          List<String> colorValues = List<String>.from(attr['values'] ?? []);
          colors.assignAll(colorValues);
          print("Extracted colors from attributes: $colors");
        } else if (attrName.contains('size')) {
          // Extract sizes from attributes
          List<String> sizeValues = List<String>.from(attr['values'] ?? []);
          sizes.assignAll(sizeValues);
          print("Extracted sizes from attributes: $sizes");
        }
      }
    }

    // If attributes didn't have data, extract from variants
    if (sizes.isEmpty && colors.isEmpty) {
      if (productDetials['variants'] != null) {
        List<dynamic> variants = productDetials['variants'];

        Set<String> uniqueSizes = {};
        Set<String> uniqueColors = {};

        for (var variant in variants) {
          String variantName =
              variant['variant_name']?.toString().toLowerCase() ?? '';

          // Check if it's a size
          if (variantName.contains('s') ||
              variantName.contains('m') ||
              variantName.contains('l') ||
              variantName.contains('xl') ||
              variantName.contains('xxl') ||
              variantName.contains('xs')) {
            uniqueSizes.add(variantName.toUpperCase());
          }
          // Check if it's a color (common color names)
          else if (variantName.isNotEmpty &&
              (variantName.contains('red') ||
                  variantName.contains('blue') ||
                  variantName.contains('green') ||
                  variantName.contains('black') ||
                  variantName.contains('white') ||
                  variantName.contains('yellow') ||
                  variantName.contains('purple') ||
                  variantName.contains('pink') ||
                  variantName.contains('brown') ||
                  variantName.contains('gray') ||
                  variantName.contains('grey'))) {
            uniqueColors
                .add(variantName[0].toUpperCase() + variantName.substring(1));
          }
          // If it's not clearly a size or color, check the variant's attributes if available
          else if (variantName.isNotEmpty && variant['attributes'] != null) {
            // You can add logic here to check variant-specific attributes
            // For now, just add to colors
            uniqueColors
                .add(variantName[0].toUpperCase() + variantName.substring(1));
          }
        }

        sizes.assignAll(uniqueSizes.toList());
        colors.assignAll(uniqueColors.toList());

        print("Extracted sizes from variants: $sizes");
        print("Extracted colors from variants: $colors");
      }
    }

    // Initialize selectors with the extracted data
    initializeSelectors();
  }

  void getVariantDetails() {
    if (productDetials['type'] == 'variable' ||
        productDetials['type'] == 'variant') {
      if (productDetials['variant_options'] != null) {
        var options = productDetials['variant_options'];
        if (options is String) {
          productVariantOption = json.decode(options);
        } else {
          productVariantOption = options;
        }

        List<String> selectedVariantList = [];
        for (var item in productVariantOption) {
          labels.add(item['label']);
          labelVariant.add(item['variants']);
          if (item['variants'] != null && item['variants'].isNotEmpty) {
            String initialVariant = item['variants'][0].toString();
            selectedVariantList.add(initialVariant);
            selectedVariant[item['label']] = initialVariant;
          }
        }
        joinedVariants.value = selectedVariantList.join('/');
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
    final variants = productDetials['variants'];
    if (variants == null || (variants as List).isEmpty) return;

    await CartService.to.manageCart(
        productId: productId,
        variantId: variants[selectedVariantIndex.value]['_id'],
        quantity: count.value,
        product: Map<String, dynamic>.from(productDetials));
    isLoading.value = false;
    Get.until((route) => !Get.isDialogOpen!);
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
