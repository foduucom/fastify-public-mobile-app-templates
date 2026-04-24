import 'package:flutter/cupertino.dart';
import '/core/services/cartServcie.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/constants/constants.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class ProductController extends GetxController with BaseController, GetTickerProviderStateMixin {
  var isLoading = false.obs;
  var productDetials = {}.obs;
  var box = GetStorage();
  var pageController = PageController();
  var selectedPageIndex = 0.obs;
  var currentImageIndex = 0.obs; // Added to track gallery index

  var productId;

  var labelVariant = [].obs;
  var labels = [].obs;
  var variantString = ''.obs;
  var joinedVariants = ''.obs;
  Map<String, String> selectedVariants = {};
  var selectedVariantIndex = 0.obs;
  var selectedVariant = {}.obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final count = 1.obs;
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  Future<void> onInit() async {
    super.onInit();
    selectedVariantIndex.value = 0;
    pageController = PageController(initialPage: 0, viewportFraction: 1.0, keepPage: true);

    try {
      var argument = Get.arguments;
      if (argument != null) {
        productId = argument['productId'];
        box.write('tempProductId', productId);
      } else {
        productId = box.read('tempProductId');
      }
    } catch (e) {
      debugPrint('product details init error $e');
    }

    await getProductDetials(id: productId);
    getVariantDetails();

    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  // ─── Robust URL Extractor ───
  List<String> get galleryUrls {
    if (productDetials.isEmpty) return [];
    List<String> urls = [];

    void extractAndAdd(dynamic imgData) {
      if (imgData == null || imgData is! Map) return;

      String dUrl = imgData['download_url']?.toString() ?? '';
      String path = imgData['filepath']?.toString() ?? '';

      if (dUrl.isNotEmpty) {
        urls.add(dUrl);
      } else if (path.isNotEmpty) {
        final cleanPath = path.startsWith('/') ? path.substring(1) : path;
        urls.add('$imageBase$cleanPath');
      }
    }

    // Prioritize variant images if a variant is selected
    if (productDetials['variants'] != null && (productDetials['variants'] as List).isNotEmpty) {
      final variants = productDetials['variants'] as List;
      if(selectedVariantIndex.value < variants.length) {
        final currentVariant = variants[selectedVariantIndex.value];
        extractAndAdd(currentVariant['front_image']);
        extractAndAdd(currentVariant['back_image']);
      }
    }

    // Fallback to main product images
    extractAndAdd(productDetials['featured_image']);
    extractAndAdd(productDetials['front_image']);
    extractAndAdd(productDetials['back_image']);

    final gallery = productDetials['gallery'];
    if (gallery != null && gallery is List) {
      for (var item in gallery) {
        extractAndAdd(item);
      }
    }

    return urls.toSet().toList();
  }

  String getDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return DateFormat("dd MMM, yyyy").format(dateTime);
  }

  Future<void> getProductDetials({required String id}) async {
    isLoading.value = true;
    var response = await BasicProvider("products/$id").getRequest().catchError(handleError);
    if (response == null) {
      isLoading.value = false;
      return;
    }
    productDetials.value = response;
    isLoading.value = false;
  }

  void getVariantDetails() {
    if (productDetials['type'] == 'variable' || productDetials['type'] == 'variant') {
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
          selectedVariant.forEach((key, value) {
            if (variantAttrs[key] != value) isMatch = false;
          });
          if (isMatch) {
            selectedVariantIndex.value = i;
            return;
          }
        }
      }
    }
  }

  Future<void> addToCart() async {
    final variants = productDetials['variants'];
    if (variants == null || (variants as List).isEmpty) return;

    await CartService.to.manageCart(
        productId: productId,
        variantId: variants[selectedVariantIndex.value]['_id'],
        quantity: count.value,
        product: Map<String, dynamic>.from(productDetials));

    Get.until((route) => !Get.isDialogOpen!);
  }

  void increment() {
    if (count.value != 10) count.value++;
  }

  void decrement() {
    if (count.value != 1) count.value--;
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}