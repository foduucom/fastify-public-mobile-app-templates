import 'package:get/get.dart';

class ChooseCategoryController extends GetxController {
  final selectedCategory = ''.obs;
  List<String> categoryList = [
    'Women',
    'Men',
    'Accessories',
    'Kids',
    'Bags',
    'Shoes',
    'Kids',
    'Workwear',
    'Plus Size',
    'Formalwear',
    'Streetwear',
    'Vintage',
    'Outerwear',
    'Sustainable',
  ].obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
