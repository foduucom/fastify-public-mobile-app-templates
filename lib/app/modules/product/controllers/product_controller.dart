import "package:share_plus/share_plus.dart";
import "package:foduu_ecommerce/constants/constants.dart";
import "package:foduu_ecommerce/constants/helper_functions.dart";
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/constants/product_helper.dart';
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
  late final TextEditingController pinCodeController;
  var box = GetStorage();
  var productGallery = List.empty().obs;
  late final PageController pageController;
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
  dynamic productVariantOption = <dynamic>[];

  // var pinCodeController;
  final count = 1.obs;
  final checkController = TextEditingController();
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  bool _animationInitialized = false;

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
    if (isClosed) return;

    if (productDetials.containsKey('categories') &&
        productDetials['categories'] != null) {
      categoriesId.addAll(productDetials['categories']);
    }

    for (final element in categoriesId) {
      if (element is Map) {
        final id = element['_id'] ?? element['id'];
        if (id != null && id.toString().isNotEmpty) {
          cateogries.add(id.toString());
        }
      }
    }

    getSimilarProduct(cateogries);
    extractAttributes();
    // ✅ ADD THIS: Initialize selectors after extracting attributes
    initializeSelectors();
    getVariantDetails();
    getProductReview(productId);
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animationInitialized = true;
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
    final attributes = productDetials['attributes'];
    if (attributes is! List) return;
    for (final attribute in attributes.whereType<Map>()) {
      final name = (attribute['name'] ?? '').toString().trim().toLowerCase();
      final values = _stringValues(attribute['values']);
      if (name.contains('size') && values.isNotEmpty) {
        sizes.assignAll(values);
      } else if (name.contains('color') && values.isNotEmpty) {
        colors.assignAll(values);
      }
    }
  }

  void updateSelectedVariant() {
    if (productDetials['variants'] == null ||
        productDetials['variants'] is! List) {
      selectedVariantIndex.value = -1;
      return;
    }

    List variants = productDetials['variants'];
    int variantIndex = -1;

    final targetSize =
        selectedSizeIndex.value >= 0 && selectedSizeIndex.value < sizes.length
            ? sizes[selectedSizeIndex.value].trim().toLowerCase()
            : null;
    final targetColor = selectedColorIndex.value >= 0 &&
            selectedColorIndex.value < colors.length
        ? colors[selectedColorIndex.value].trim().toLowerCase()
        : null;
    selectedVariantIndex.value = -1;

    for (int i = 0; i < variants.length; i++) {
      var variant = variants[i];
      if (variant is! Map) continue;
      final rawAttributes = variant['attributes'];
      final variantAttributes = <String, String>{};
      if (rawAttributes is Map) {
        for (final entry in rawAttributes.entries) {
          variantAttributes[entry.key.toString().trim().toLowerCase()] =
              entry.value.toString().trim().toLowerCase();
        }
      }

      if (variantAttributes.isNotEmpty) {
        // Match by attributes
        bool isMatch = true;
        if (targetSize != null && variantAttributes['size'] != targetSize) {
          isMatch = false;
        }
        if (targetColor != null && variantAttributes['color'] != targetColor) {
          isMatch = false;
        }

        if (isMatch) {
          variantIndex = i;
          break;
        }
      } else {
        // Fallback to name matching
        final variantName = (variant['variant_name'] ?? variant['name'] ?? '')
            .toString()
            .trim()
            .toLowerCase();

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
    }
  }

  Future<void> getSimilarProduct(List category) async {
    try {
      similarProduct.clear();
      var response =
          await BasicProvider("public/product/categorywise").postRequest(
        {"categories": category},
      ).catchError((e) {
        print("⚠️ Similar products endpoint not available: $e");
        return null;
      });
      final products = response is List
          ? response
          : response is Map
              ? response['data'] ?? response['products'] ?? response['product']
              : null;
      if (products is! List) return;
      similarProduct.assignAll(products);
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
    final reviews = response is List
        ? response
        : response is Map
            ? response['data'] ?? response['reviews']
            : null;
    if (reviews is List) productReview.assignAll(reviews);
  }

  void getProductReview(String productId) async {
    var response = await BasicProvider("public/reviews/product-wise/$productId")
        .getRequest()
        .catchError((e) {
      print("⚠️ Product reviews endpoint not available: $e");
      return null;
    });
    final reviews = response is List
        ? response
        : response is Map
            ? response['data'] ?? response['reviews']
            : null;
    if (reviews is List) productReview.assignAll(reviews);
  }

  Future<void> getProductDetials({required String id}) async {
    isLoading.value = true;
    try {
      final response = await BasicProvider("products/$id")
          .getRequest()
          .catchError(handleError);
      if (isClosed) return;
      if (response is! Map) return;

      final payload = response['data'] is Map ? response['data'] : response;
      if (payload is! Map) return;
      productDetials.assignAll(Map<String, dynamic>.from(payload));

      final gallery = productDetials['gallery'];
      productGallery.assignAll(gallery is List ? gallery : const []);
      sizes.clear();
      colors.clear();

      final attributes = productDetials['attributes'];
      if (attributes is List) {
        for (final attribute in attributes.whereType<Map>()) {
          final name = (attribute['name'] ?? '').toString().toLowerCase();
          final values = _stringValues(attribute['values']);
          if (name.contains('color')) colors.assignAll(values);
          if (name.contains('size')) sizes.assignAll(values);
        }
      }

      final variants = productDetials['variants'];
      if (variants is List && (sizes.isEmpty || colors.isEmpty)) {
        final foundSizes = <String>{...sizes};
        final foundColors = <String>{...colors};
        const knownColors = {
          'red',
          'blue',
          'green',
          'black',
          'white',
          'yellow',
          'purple',
          'pink',
          'brown',
          'gray',
          'grey',
          'orange',
          'beige',
          'navy',
          'silver',
          'gold',
          'cream',
          'maroon',
          'teal',
          'tan',
        };
        for (final variant in variants.whereType<Map>()) {
          final variantAttributes = variant['attributes'];
          if (variantAttributes is Map) {
            for (final entry in variantAttributes.entries) {
              final key = entry.key.toString().toLowerCase();
              final value = entry.value.toString().trim();
              if (value.isEmpty) continue;
              if (key.contains('size') && sizes.isEmpty) foundSizes.add(value);
              if (key.contains('color') && colors.isEmpty)
                foundColors.add(value);
            }
          } else {
            final name =
                (variant['variant_name'] ?? variant['name'] ?? '').toString();
            for (final part in name
                .split(RegExp(r'\s*[/,|]\s*'))
                .map((value) => value.trim())
                .where((value) => value.isNotEmpty)) {
              final normalized = part.toLowerCase();
              if (sizes.isEmpty &&
                  RegExp(r'^(xxxs|xxs|xs|s|m|l|xl|xxl|xxxl|\d+)$')
                      .hasMatch(normalized)) {
                foundSizes.add(part.toUpperCase());
              } else if (colors.isEmpty && knownColors.contains(normalized)) {
                foundColors.add(part);
              }
            }
          }
        }
        if (sizes.isEmpty) sizes.assignAll(foundSizes);
        if (colors.isEmpty) colors.assignAll(foundColors);
      }
      initializeSelectors();
    } catch (error) {
      debugPrint('Product details load failed: $error');
    } finally {
      isLoading.value = false;
    }
  }

  List<String> _stringValues(dynamic values) => values is List
      ? values.map((value) => value.toString()).toList(growable: false)
      : const [];

  void getVariantDetails() {
    if (productDetials['type'] == 'variable' ||
        productDetials['type'] == 'variant') {
      if (productDetials['variant_options'] != null) {
        var options = productDetials['variant_options'];
        if (options is String) {
          try {
            productVariantOption = json.decode(options);
          } catch (error) {
            debugPrint('Invalid product variant options: $error');
            productVariantOption = const [];
          }
        } else {
          productVariantOption = options;
        }
        if (productVariantOption is! List) {
          productVariantOption = const [];
          return;
        }
        labels.clear();
        labelVariant.clear();
        selectedVariant.clear();

        List<String> selectedVariantList = [];
        for (final item in productVariantOption) {
          if (item is! Map || item['variants'] is! List) continue;
          labels.add(item['label']);
          labelVariant.add(item['variants']);
          if ((item['variants'] as List).isNotEmpty) {
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
    final variantIds = productDetials['variant_ids'];
    if (variantIds is! List) {
      selectedVariantIndex.value = -1;
      return;
    }
    selectedVariantIndex.value = -1;
    for (int i = 0; i < variantIds.length; i++) {
      final item = variantIds[i];
      final variants = productDetials['variants'];
      if (item is Map &&
          joinedVariants.value == item['variant']?.toString() &&
          (variants is! List || i < variants.length)) {
        selectedVariantIndex.value = i;
        return;
      }
    }
  }

  bool containsExactSize(String variants, String target) {
    // Split the string into parts based on the delimiter
    List<String> parts = variants.split('/');
    // Check if any part matches the target size
    return parts.contains(target);
  }

  Future<bool> addToCart() async {
    final variants = productDetials['variants'];
    if (variants is! List || variants.isEmpty) {
      HelperFunctions().showSnackBarError('This product is unavailable.');
      return false;
    }
    final index = selectedVariantIndex.value;
    if (index < 0 || index >= variants.length || variants[index] is! Map) {
      HelperFunctions().showSnackBarError(
          'Please select an available product option before adding to cart.');
      return false;
    }
    final variantId =
        (variants[index]['_id'] ?? variants[index]['id'])?.toString() ?? '';
    if (variantId.isEmpty || productId == null) {
      HelperFunctions()
          .showSnackBarError('This product cannot be added right now.');
      return false;
    }
    if (!ProductHelper.isInStock(
      Map<String, dynamic>.from(productDetials),
      variantIndex: index,
    )) {
      HelperFunctions().showSnackBarError('This option is out of stock.');
      return false;
    }

    isLoading.value = true;
    try {
      await CartService.to.manageCart(
          productId: productId,
          variantId: variantId,
          quantity: count.value,
          product: Map<String, dynamic>.from(productDetials));
      return true;
    } finally {
      isLoading.value = false;
    }
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
  void onClose() {
    pageController.dispose();
    pinCodeController.dispose();
    reviewTextController.dispose();
    checkController.dispose();
    if (_animationInitialized) controller.dispose();
    super.onClose();
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

  static String productShareUrl(String slug) =>
      '${url}product/${Uri.encodeComponent(slug.trim())}';

  void shareContent(BuildContext context) {
    final slug = (productDetials['slug'] ?? '').toString().trim();
    if (slug.isEmpty) {
      HelperFunctions().showSnackBarError('Product link is not available yet');
      return;
    }

    final name = (productDetials['name'] ?? '').toString().trim();
    final urlToShare = productShareUrl(slug);
    final text = name.isEmpty
        ? 'Check this out on $appName\n$urlToShare'
        : 'Check out $name on $appName\n$urlToShare';

    final renderBox = context.findRenderObject() as RenderBox?;
    final origin = renderBox != null
        ? renderBox.localToGlobal(Offset.zero) & renderBox.size
        : null;

    Share.share(
      text,
      subject: name.isEmpty ? appName : name,
      sharePositionOrigin: origin,
    );
  }
}
