import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/app/modules/auth/auth_details.dart';
import 'package:zouhi/app/modules/cart/controllers/cart_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:zouhi/app/modules/shop/views/productdetail_view.dart';
import 'package:zouhi/constants/constants.dart';

import 'package:share_plus/share_plus.dart';
import 'package:zouhi/app/controllers/currency_controller.dart';
import 'package:zouhi/app/modules/shop/models/registry_form_model.dart';
import 'package:zouhi/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:zouhi/constants/helper_functions.dart';

class ProductdetialController extends GetxController
    with BaseController, GetTickerProviderStateMixin {
  var isLoading = false.obs;
  var offerCode = 'FODUUKART10';
  var relatedProducts = [].obs;
  var isRelatedLoading = false.obs;
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
  var reviewSummary = {}.obs;
  var categoriesId = [];
  List<String> cateogries = [];
  var reviewTextController = TextEditingController();

  var productId;

  var labels = <String>[].obs;
  var selectedVariant = <String, String>{}.obs;
  var productAttributes = <dynamic>[].obs;
  var productVariants = <dynamic>[].obs;
  var selectedVariantIndex = 0.obs;
  final variantQuantities = <String, int>{}.obs;

  String get currentVariantKey =>
      currentVariantId.isNotEmpty ? currentVariantId : productId.toString();
  var currencySymbol = currency.obs;
  var isRegistry = false.obs;
  var registryForm = Rx<RegistryForm?>(null);
  var isSubmittingQuote = false.obs;
  var isContentExpanded = false.obs;
  var isLongContentExpanded = false.obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // var pinCodeController;
  final count = 1.obs;
  final checkController = TextEditingController();
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  Future<void> onInit() async {
    super.onInit();

    // Listen to global currency updates
    if (Get.isRegistered<CurrencyController>()) {
      final currencyCtrl = Get.find<CurrencyController>();
      currencySymbol.value =
          currencyCtrl.selectedCurrency['symbol']?.toString() ?? currency;
      ever(currencyCtrl.selectedCurrency, (curr) {
        if (curr is Map) {
          currencySymbol.value = curr['symbol']?.toString() ?? currency;
        }
      });
    }

    selectedVariantIndex.value = 0;
    pageController = PageController(
        initialPage: _currentPage, viewportFraction: 1.0, keepPage: true);
    pinCodeController = TextEditingController();
    String? id;
    String? slug;
    try {
      if (Get.parameters['slug'] != null) {
        slug = Get.parameters['slug'];
      }
      var argument = Get.arguments;
      if (argument != null) {
        if (argument is Map) {
          id = argument['productId']?.toString();
          slug ??= argument['slug']?.toString();
        } else if (argument is String) {
          id = argument;
        }
      }
      if (id == null && slug == null) {
        id = box.read('tempProductId');
        slug = box.read('tempProductSlug');
      } else {
        if (id != null) box.write('tempProductId', id);
        if (slug != null) box.write('tempProductSlug', slug);
      }
    } catch (e) {
      print('product details init error $e');
    }

    productId = id;
    await getProductDetials(id: productId, slug: slug);

    // categoriesId.addAll(productDetials['categories']);

    checkIsAlreadyInCart();

    categoriesId.forEach((element) {
      cateogries.add("${element['_id']}");
    });

    getSimilarProduct(cateogries);

    getVariantDetails();
    if (productId != null) {
      getProductReview(productId);
    }
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
    if (AuthDetails.isUserLogin()) {
      Get.find<WishlistController>().getwishlist();
    }

    ever(selectedVariantIndex, (_) {
      _onVariantChanged();
    });

    ever(count, (qty) {
      variantQuantities[currentVariantKey] = qty;
    });
  }

  Future<void> getSimilarProduct(List category) async {
    try {
      similarProduct.clear();
      if (category.isEmpty) return;
      var response =
          await BasicProvider("public/product/categorywise").postRequest(
        {"categories": category},
      );
      if (response == null) return;
      similarProduct.clear();
      if (response is List) {
        similarProduct.addAll(response);
      } else if (response is Map && response['data'] != null) {
        similarProduct.addAll(response['data']);
      }
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

  String getDate(dynamic dateString) {
    if (dateString == null ||
        dateString == "null" ||
        dateString.toString().trim().isEmpty) {
      return "";
    }
    try {
      DateTime dateTime = DateTime.parse(dateString.toString());
      DateFormat dateFormat = DateFormat("MMM d, yyyy");
      String formattedDate = dateFormat.format(dateTime);
      return formattedDate;
    } catch (e) {
      return "";
    }
  }

  Future<void> submitQuoteRequest(Map<String, dynamic> formData) async {
    isSubmittingQuote.value = true;
    try {
      final form = registryForm.value!;
      var response = await BasicProvider(form.submitEndpoint)
          .postRequest(formData)
          .catchError(handleError);
      if (response != null) {
        Get.back();
        HelperFunctions.defaultdialogbox(
            'Quote submitted successfully!', themeGreenColor);
      }
    } catch (e) {
      HelperFunctions.defaultdialogbox(
          'Submission failed. Please try again.', themeRedColor);
    } finally {
      isSubmittingQuote.value = false;
    }
  }

  void postReview({required String summary, required int rating}) async {
    var form = {
      'product_id': productId,
      'rating': rating,
      'comment': summary,
    };
    var response = await BasicProvider("review/create")
        .postRequest(form)
        .catchError(handleError);
    if (response == null) return;
    // productReview.clear();
    // productReview.addAll(response);
    getProductReview(productId);
  }

  void getProductReview(String productId) async {
    try {
      var response =
          await BasicProvider("review/product/$productId").getRequest();

      print('project dreviereeee $response');
      if (response == null) return;
      productReview.clear();
      reviewSummary.clear();

      List? docsList;
      if (response is Map) {
        if (response['summary'] is Map) {
          reviewSummary.addAll(Map<String, dynamic>.from(response['summary']));
        }
        if (response['reviews'] is Map && response['reviews']['docs'] is List) {
          docsList = response['reviews']['docs'];
        } else if (response['reviews'] is List) {
          docsList = response['reviews'];
        } else if (response['data'] is List) {
          docsList = response['data'];
        } else if (response['data'] is Map) {
          if (response['data']['summary'] is Map) {
            reviewSummary.addAll(Map<String, dynamic>.from(response['data']['summary']));
          }
          if (response['data']['reviews']?['docs'] is List) {
            docsList = response['data']['reviews']['docs'];
          } else if (response['data']['reviews'] is List) {
            docsList = response['data']['reviews'];
          }
        }
      } else if (response is List) {
        docsList = response;
      }

      if (docsList != null && docsList.isNotEmpty) {
        productReview.addAll(docsList);
      }
    } catch (e) {
      print('product review error $e');
    }
  }

  Future<void> getProductDetials({String? id, String? slug}) async {
    isLoading.value = true;
    isContentExpanded.value = false;
    isLongContentExpanded.value = false;
    variantQuantities.clear();
    var endpoint =
        (id != null && id.isNotEmpty) ? "products/$id" : "productdetail/$slug";
    var response =
        await BasicProvider(endpoint).getRequest().catchError(handleError);
    if (response == null) {
      isLoading.value = false;
      return;
    }
    isLoading.value = false;

    if (response is Map) {
      productId = response['_id']?.toString() ?? id;
      if (productId != null) {
        box.write('tempProductId', productId);
      }
      productDetials.value = response;

      try {
        if (response['is_registry'] == true &&
            response['registry_form_id'] is Map) {
          final parsedForm = RegistryForm.fromJson(
              Map<String, dynamic>.from(response['registry_form_id']));
          registryForm.value = parsedForm;
          isRegistry.value = true;
        } else {
          isRegistry.value = false;
          registryForm.value = null;
        }
      } catch (e) {
        print('registry form parse error: $e');
        isRegistry.value = false;
        registryForm.value = null;
      }

      productAttributes.value = response['attributes'] ?? [];
      productVariants.value = response['variants'] ?? [];
      if (Get.isRegistered<CurrencyController>()) {
        currencySymbol.value = Get.find<CurrencyController>()
                .selectedCurrency['symbol']
                ?.toString() ??
            currency;
      } else {
        currencySymbol.value = response['currencySymbol'] ?? currency;
      }

      if (productDetials['gallery'] != null &&
          productDetials['gallery'] is List) {
        productGallery.value = productDetials['gallery'];
      }

      // Initialize selected attributes with first available values
      if (productAttributes.isNotEmpty) {
        for (var attr in productAttributes) {
          if (attr['values'] != null && (attr['values'] as List).isNotEmpty) {
            selectedVariant[attr['name']] = attr['values'][0].toString();
          }
        }
      }

      _updateMatchedVariant();
      bool variantSelected = false;
      // If a variant ID was passed in arguments, select that variant
      var arg = Get.arguments;
      if (arg is Map && arg['variantId'] != null) {
        String targetVariantId = arg['variantId'].toString();
        int matchedIdx = productVariants.indexWhere((v) {
          if (v is! Map) return false;
          var vid = v['_id'] ?? v['id'];
          return vid?.toString() == targetVariantId;
        });
        if (matchedIdx != -1) {
          selectVariantByIndex(matchedIdx);
          variantSelected = true;
        }
      }

      if (!variantSelected && productVariants.isNotEmpty) {
        // If initial selected variant is out of stock, auto-select first in-stock variant
        if (!isVariantInStock(0)) {
          int firstInStockIdx = -1;
          for (int i = 0; i < productVariants.length; i++) {
            if (isVariantInStock(i)) {
              firstInStockIdx = i;
              break;
            }
          }
          if (firstInStockIdx != -1) {
            selectVariantByIndex(firstInStockIdx);
          }
        }
      }
      checkIsAlreadyInCart();
      _onVariantChanged();
      if (productDetials['slug'] != null) {
        getRelatedProducts(productDetials['slug'].toString());
      }
      if (productId != null) {
        getProductReview(productId);
      }
    } else {
      print('Product details response is not a map: $response');
    }

    print("====== productDetials[tags] ${productDetials['tags']}");
    print("====== productDetials[status] ${productDetials['status']}");
    print("========= productDetials[variants] ${productDetials['variants']}");
    print("========= productDetials[brand] ${productDetials['brand']}");
  }

  Future<void> getRelatedProducts(String slug) async {
    isRelatedLoading.value = true;
    try {
      relatedProducts.clear();
      var response = await BasicProvider("products/related/$slug").getRequest();
      if (response != null && response is Map && response['data'] != null) {
        relatedProducts.addAll(response['data']);
      }
    } catch (e) {
      print('related product error $e');
    } finally {
      isRelatedLoading.value = false;
    }
  }

  String? _getMatchedAttributeName(String key) {
    for (var attr in productAttributes) {
      String attrName = attr['name'] ?? '';
      if (attrName.toLowerCase() == key.toLowerCase()) {
        return attrName;
      }
    }
    return null;
  }

  dynamic _getValueFromMapCaseInsensitive(Map map, String targetKey) {
    for (var entry in map.entries) {
      if (entry.key.toString().toLowerCase() == targetKey.toLowerCase()) {
        return entry.value;
      }
    }
    return null;
  }

  void checkIsAlreadyInCart() {
    var cartController = Get.find<CartController>();
    dynamic matchedItem;
    if (AuthDetails.isUserLogin()) {
      if (productVariants.isNotEmpty) {
        String selectedVid = currentVariantId;
        matchedItem = cartController.cartItems.firstWhereOrNull((element) {
          var elementProductId = element['product']?['_id']?.toString();
          var elementVariantId = '';
          var variantObj = element['variant'];
          if (variantObj is Map) {
            elementVariantId = variantObj['_id']?.toString() ?? '';
          } else if (element['variant_id'] != null) {
            elementVariantId = element['variant_id'].toString();
          }
          return elementProductId == productId.toString() &&
              elementVariantId == selectedVid;
        });
      } else {
        matchedItem = cartController.cartItems.firstWhereOrNull((element) {
          var elementProductId = element['product']?['_id']?.toString();
          return elementProductId == productId.toString();
        });
      }
    } else {
      if (productVariants.isNotEmpty) {
        String selectedVid = currentVariantId;
        matchedItem =
            cartController.guestUserCartList.firstWhereOrNull((element) {
          var elementProductId = element['_id']?.toString();
          var elementVariantName = element['variant_name']?.toString();
          return elementProductId == productId.toString() &&
              (elementVariantName == selectedVid ||
                  (elementVariantName == null && selectedVid.isEmpty));
        });
      } else {
        matchedItem =
            cartController.guestUserCartList.firstWhereOrNull((element) {
          var elementProductId = element['_id']?.toString();
          return elementProductId == productId.toString();
        });
      }
    }

    isAlreadyInCart.value = matchedItem != null;

    int newQty = 1;
    if (matchedItem != null) {
      newQty = int.tryParse(matchedItem['quantity']?.toString() ?? '') ?? 1;
    }
    count.value = newQty;
    variantQuantities[currentVariantKey] = newQty;
  }

  void getVariantDetails() {
    // This is now handled within getProductDetials and _updateMatchedVariant
    _updateMatchedVariant();
  }

  void onSelectVariant(String label, String value) {
    String matchedKey = _getMatchedAttributeName(label) ?? label;
    selectedVariant[matchedKey] = value;
    _updateMatchedVariant();
    checkIsAlreadyInCart();
  }

  void selectVariantByIndex(int index) {
    if (index < 0 || index >= productVariants.length) return;
    selectedVariantIndex.value = index;
    var variant = productVariants[index];
    var vAttrs = variant['attributes'];
    if (vAttrs is Map) {
      vAttrs.forEach((key, value) {
        String matchedKey =
            _getMatchedAttributeName(key.toString()) ?? key.toString();
        selectedVariant[matchedKey] = value.toString();
      });
    }
    checkIsAlreadyInCart();
  }

  void _updateMatchedVariant() {
    if (productVariants.isEmpty) return;

    for (int i = 0; i < productVariants.length; i++) {
      var variant = productVariants[i];
      var vAttrs = variant['attributes'];
      if (vAttrs is Map) {
        bool match = true;
        selectedVariant.forEach((key, value) {
          var vValue = _getValueFromMapCaseInsensitive(vAttrs, key);
          if (vValue == null ||
              vValue.toString().toLowerCase() !=
                  value.toString().toLowerCase()) {
            match = false;
          }
        });
        if (match) {
          selectedVariantIndex.value = i;
          return;
        }
      }
    }
  }

  // --- Tax and Price Getters ---
  double get effectivePrice {
    var variant = productVariants.isNotEmpty &&
            selectedVariantIndex.value < productVariants.length
        ? productVariants[selectedVariantIndex.value]
        : productDetials;
    double price = double.tryParse(variant['price']?.toString() ?? '0') ?? 0.0;
    double salePrice =
        double.tryParse(variant['sale_price']?.toString() ?? '0') ?? 0.0;
    return (salePrice > 0) ? salePrice : price;
  }

  double get taxAmount {
    if (productDetials.isEmpty) return 0.0;
    bool isTaxable = productDetials['isTaxable'] == true ||
        productDetials['isTaxable'] == 'true';
    double taxPercentage =
        double.tryParse(productDetials['tax']?.toString() ?? '0') ?? 0.0;
    if (isTaxable && taxPercentage > 0) {
      return (effectivePrice * taxPercentage) / 100;
    }
    return 0.0;
  }

  double get finalPrice {
    return effectivePrice + taxAmount;
  }

  bool containsExactSize(String variants, String target) {
    // Split the string into parts based on the delimiter
    List<String> parts = variants.split('/');
    // Check if any part matches the target size
    return parts.contains(target);
  }

  String get currentVariantId {
    try {
      // 1. Try to get variant from productVariants first (which contains the full populated maps)
      if (productVariants.isNotEmpty &&
          selectedVariantIndex.value < productVariants.length) {
        var variant = productVariants[selectedVariantIndex.value];
        if (variant is Map) {
          var vid = variant['_id'] ?? variant['id'];
          if (vid != null &&
              vid.toString().isNotEmpty &&
              vid.toString() != productId.toString()) {
            return vid.toString();
          }
        }
      }

      // 2. Check for variants in all common keys
      final dynamic variantsData = productDetials['variant_ids'] ??
          productDetials['variants'] ??
          productDetials['product_variants'];

      final variantList = variantsData is List ? variantsData : null;
      final type = productDetials['type']?.toString().toLowerCase();

      if (type == 'variant' ||
          type == 'variable' ||
          (variantList != null && variantList.isNotEmpty)) {
        if (variantList != null &&
            variantList.length > selectedVariantIndex.value) {
          var item = variantList[selectedVariantIndex.value];
          var vid;
          if (item is Map) {
            vid = item['_id'] ?? item['id'];
          } else {
            vid = item;
          }
          if (vid != null &&
              vid.toString().isNotEmpty &&
              vid.toString() != productId.toString()) {
            return vid.toString();
          }
        }
      }

      // 3. For simple products or as a fallback for variable products,
      // try to get the first available variant ID
      if (variantList != null && variantList.isNotEmpty) {
        for (var v in variantList) {
          var vid;
          if (v is Map) {
            vid = v['_id'] ?? v['id'];
          } else {
            vid = v;
          }
          if (vid != null &&
              vid.toString().isNotEmpty &&
              vid.toString() != productId.toString()) {
            return vid.toString();
          }
        }
      }

      // 3. Check for a direct variant ID field in the product object
      var directVid = productDetials['variant_id'] ??
          productDetials['default_variant_id'] ??
          productDetials['product_variant_id'];
      if (directVid != null &&
          directVid.toString().isNotEmpty &&
          directVid.toString() != productId.toString()) {
        return directVid.toString();
      }
    } catch (e) {
      print('Error in currentVariantId getter: $e');
    }

    // FINAL FALLBACK: If we truly can't find a variant ID that is different from productId,
    // we send an empty string. The backend accepts "" (results in 0 price temporarily)
    // but REJECTS productId (results in 404).
    print(
        '⚠️ currentVariantId: No distinct variant ID found for $productId, sending empty string');
    return '';
  }

  Future<void> addToCart() async {
    isLoading.value = true;
    try {
      await Get.find<CartController>().addToCart(
          productId: productId,
          quantity: count.value,
          variantId: currentVariantId,
          productType: productDetials['type']);
      checkIsAlreadyInCart();
    } catch (e) {
      debugPrint('addToCart error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  bool isVariantInStock(int index) {
    if (index < 0 || index >= productVariants.length) return false;
    final v = productVariants[index];
    if (v is! Map) return false;
    final vStatus = v['stock_status']
        ?.toString()
        .toLowerCase()
        .replaceAll('_', '')
        .replaceAll(' ', '');
    if (vStatus == 'outofstock') return false;

    final qty = v['quantity'] ?? v['stock'] ?? v['stock_quantity'];
    if (qty != null) {
      final parsedQty = int.tryParse(qty.toString());
      if (parsedQty != null && parsedQty <= 0) return false;
    }
    return true;
  }

  /// Returns the available stock for the currently selected variant/product.
  /// Returns null if stock is unlimited (quantity field not set).
  int? get availableStock {
    dynamic qty;
    // Check variant stock first
    if (productVariants.isNotEmpty &&
        selectedVariantIndex.value < productVariants.length) {
      final selectedV = productVariants[selectedVariantIndex.value];
      if (selectedV is Map) {
        qty = selectedV['quantity'] ??
            selectedV['stock'] ??
            selectedV['stock_quantity'];
      }
    }
    // Fallback to main product stock
    qty ??= productDetials['quantity'] ??
        productDetials['stock'] ??
        productDetials['stock_quantity'];
    if (qty == null) return null; // unlimited stock
    return int.tryParse(qty.toString());
  }

  bool get isOutOfStock {
    if (productVariants.isNotEmpty &&
        selectedVariantIndex.value < productVariants.length) {
      final selectedV = productVariants[selectedVariantIndex.value];
      if (selectedV is Map) {
        final vStatus = selectedV['stock_status']
            ?.toString()
            .toLowerCase()
            .replaceAll('_', '')
            .replaceAll(' ', '');
        if (vStatus == 'outofstock') return true;
      }
    }

    final status = productDetials['status'] ?? productDetials['stock_status'];
    if (status != null && status is String) {
      final s = status.toLowerCase().replaceAll('_', '').replaceAll(' ', '');
      if (s == 'outofstock') return true;
    }

    final stock = availableStock;
    return stock != null && stock <= 0;
  }

  void increment() {
    final stock = availableStock;
    if (stock != null && count.value >= stock) {
      Get.snackbar(
        'Stock Limit',
        'Only $stock items available in stock',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    count.value++;
    variantQuantities[currentVariantKey] = count.value;
    if (isAlreadyInCart.value) {
      Get.find<CartController>().updateCartQuantity(
        productId: productId,
        variantId: currentVariantId,
        delta: 1,
      );
    }
  }

  void decrement() {
    if (count.value > 1) {
      count.value--;
      variantQuantities[currentVariantKey] = count.value;
      if (isAlreadyInCart.value) {
        Get.find<CartController>().updateCartQuantity(
          productId: productId,
          variantId: currentVariantId,
          delta: -1,
        );
      }
    }
  }

  void _onVariantChanged() {
    final key = currentVariantKey;
    int savedQty = variantQuantities[key] ?? 1;

    final stock = availableStock;
    if (stock != null) {
      if (stock <= 0) {
        savedQty = 1;
      } else if (savedQty > stock) {
        savedQty = stock;
      }
    }

    if (count.value != savedQty) {
      count.value = savedQty;
    }
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  /// Public web URL of a product, e.g. https://vision.vbought.com/product/fire-rated-cable
  static String productShareUrl(String slug) =>
      '${url}product/${Uri.encodeComponent(slug.trim())}';

  void shareContent(BuildContext context) {
    final slug = (productDetials['slug'] ?? '').toString().trim();
    if (slug.isEmpty) {
      Get.snackbar('Share', 'Product link is not available yet');
      return;
    }

    final name = (productDetials['name'] ?? '').toString().trim();
    final urlToShare = productShareUrl(slug);
    final text = name.isEmpty
        ? 'Check this out on $appName\n$urlToShare'
        : 'Check out $name on $appName\n$urlToShare';

    // iPad requires an anchor rect for the share popover.
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
