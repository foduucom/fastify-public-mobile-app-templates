import 'package:flutter/cupertino.dart';
import 'package:foduu_ecommerce/core/services/cartServcie.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class ProductController extends GetxController
    with BaseController, GetTickerProviderStateMixin {
  var isLoading = false.obs;
  var productDetials = {}.obs;
  var box = GetStorage();
  var pageController = PageController();
  int _currentPage = 0;
  var selectedPageIndex = 0.obs;

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
  final count = 1.obs;
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  Future<void> onInit() async {
    super.onInit();
    selectedVariantIndex.value = 0;
    pageController = PageController(
        initialPage: _currentPage, viewportFraction: 0.8, keepPage: true);
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

    getVariantDetails();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  String getDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);

    DateFormat dateFormat = DateFormat("dd MMM, yyyy");
    String formattedDate = dateFormat.format(dateTime);
    return formattedDate;
  }

  Future<void> getProductDetials({required String id}) async {
    isLoading.value = true;
    var response = await BasicProvider("products/$id")
        .getRequest()
        .catchError(handleError);
    if (response == null) return;

    printInfo(info: 'response ----->>>>>>> ${response.toString()}');
    isLoading.value = false;

    productDetials.value = response;
  }

  void getVariantDetails() {
    if (productDetials['type'] == 'variable' ||
        productDetials['type'] == 'variant') {
      labels.clear();
      labelVariant.clear();
      selectedVariant.clear();
      List<String> selectedVariantValues = [];

      var attributes = productDetials['attributes'];
      if (attributes != null && attributes is List) {
        for (var item in attributes) {
          labels.add(item['name']);
          labelVariant.add(item['values']);
          if (item['values'].isNotEmpty) {
            String initialValue = item['values'][0].toString();
            selectedVariantValues.add(initialValue);
            selectedVariant[item['name'].toString()] = initialValue;
          }
        }
      }
      joinedVariants.value = selectedVariantValues.join(' / ');
      updateVariantIndex();
    }
  }

  void onSelectVariant(String label, String variant) {
    selectedVariant[label] = variant;
    updateJoinedVariants();
  }

  void updateJoinedVariants() {
    List<String> variantList = [];
    for (var label in labels) {
      variantList.add(selectedVariant[label] ?? '');
    }
    joinedVariants.value = variantList.join(' / ');
    updateVariantIndex();
  }

  void updateVariantIndex() {
    var variants = productDetials['variants'];
    if (variants != null && variants is List) {
      for (int i = 0; i < variants.length; i++) {
        var variantAttrs = variants[i]['attributes'];
        if (variantAttrs != null && variantAttrs is Map) {
          bool isMatch = true;
          // Check if all selected attributes match this variant
          selectedVariant.forEach((key, value) {
            if (variantAttrs[key] != value) {
              isMatch = false;
            }
          });

          if (isMatch) {
            selectedVariantIndex.value = i;
            return;
          }
        }
      }
    }
  }

  bool containsExactSize(String variants, String target) {
    List<String> parts = variants.split(' / ');
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
}
