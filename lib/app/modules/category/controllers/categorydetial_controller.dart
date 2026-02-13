import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CategeorydetaiController extends GetxController with BaseController {
  var productCategoryList = List<dynamic>.empty().obs;
  var isLoading = true.obs;
  var box = GetStorage();
  var arguments = {}.obs;
  var subcategory = [].obs;
  var parentCategor = [].obs;
  var banner = {}.obs;

  RxInt expandedindex = RxInt(-1);

  void toggleExpansion(int index) {
    if (expandedindex.value == index) {
      expandedindex.value = -1;
    } else {
      expandedindex.value = index;
    }
    update();
  }

  @override
  Future<void> onInit() async {
    super.onInit();

    // if (Get.arguments != null) {
    //   arguments.value = Get.arguments;
    // }

    arguments.addAll(Get.arguments);

    print('argument $arguments');

    banner.addAll(arguments['bannerData']);
    parentCategor.addAll(arguments['children']);
    // await getCategoryLeaf(arguments['']);
  }

  // Future<void> getCategoryLeaf(String id) async {
  //   isLoading(true);

  //   var response = await BasicProvider('public/categories/leaf-node/$id')
  //       .getRequest()
  //       .catchError(handleError);
  //   if (response == null) return;

  //   productCategoryList.addAll(response);
  //   isLoading(false);
  // }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}
}
