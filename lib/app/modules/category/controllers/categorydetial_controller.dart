import '/app/data/basic_provider.dart';
import '/core/foduuStudio/foduu_studio_layout_mixin.dart';

import '/app/controllers/api_exception_handle_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '/app/routes/app_pages.dart';

class CategeorydetaiController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  var productCategoryList = List<dynamic>.empty().obs;
  var isLoading = true.obs;
  var box = GetStorage();
  var arguments = {}.obs;
  var subcategory = [].obs;
  var parentCategor = [].obs;
  var mainCategoryId = ''.obs;
  var banner = {}.obs;

  RxInt expandedindex = RxInt(-1);
  var isSubcategoryLoading = false.obs;

  void toggleExpansion(int index) {
    if (expandedindex.value == index) {
      expandedindex.value = -1;
    } else {
      expandedindex.value = index;
    }
    update();
  }

  Future<void> fetchSubcategoriesAndToggle(
      int index, String parentId, String parentName, String parentSlug) async {
    if (expandedindex.value == index) {
      // Just collapse
      expandedindex.value = -1;
      update();
      return;
    }

    isSubcategoryLoading(true);
    subcategory.clear();
    expandedindex.value = index; // Expand immediately to show loading
    update();

    var response = await BasicProvider('category').getRequest(
        queryParams: {'childrenOfParent': parentId}).catchError(handleError);

    isSubcategoryLoading(false);

    if (response == null) {
      expandedindex.value = -1;
      update();
      return;
    }

    List fetchedChildren = [];
    if (response is Map<String, dynamic> && response.containsKey('docs')) {
      fetchedChildren = response['docs'];
    } else if (response is List) {
      fetchedChildren = response;
    }

    if (fetchedChildren.isEmpty) {
      expandedindex.value = -1;
      Get.toNamed(Routes.SHOPPRODUCTLISTVIEW, arguments: {
        'productId': parentId,
        'categorySlug': parentSlug,
        'name': parentName,
        'source': 'category'
      });
    } else {
      subcategory.assignAll(fetchedChildren);
    }
    update();
  }

  @override
  Future<void> onInit() async {
    super.onInit();

    arguments.addAll(Get.arguments);

    print('argument $arguments');

    banner.addAll(arguments['bannerData']);
    mainCategoryId.value = arguments['id'];
    print('main category idd id id id id id id id id ${mainCategoryId.value}');

    if (arguments['children'] != null) {
      parentCategor.addAll(arguments['children']);
    }

    getChildrenCategories(mainCategoryId.value);
  }

  Future<void> getChildrenCategories(String parentId) async {
    isLoading(true);
    var response = await BasicProvider('category').getRequest(
        queryParams: {'childrenOfParent': parentId}).catchError(handleError);

    if (response == null) {
      isLoading(false);
      return;
    }

    if (response is Map<String, dynamic> && response.containsKey('docs')) {
      parentCategor.assignAll(response['docs']);
    } else if (response is List) {
      parentCategor.assignAll(response);
    }

    update();
    isLoading(false);
  }

  Future<void> getCategoryLeaf(String id) async {
    isLoading(true);

    var response = await BasicProvider('public/categories/leaf-node/$id')
        .getRequest()
        .catchError(handleError);
    if (response == null) return;

    productCategoryList.addAll(response);
    isLoading(false);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}
}
