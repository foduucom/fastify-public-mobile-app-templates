import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Adds brand-search/attribute-filter/price-bounds state to [ShopController],
/// kept separate from [ShopCategoryFilterMixin] to avoid one controller file
/// accumulating every new field.
mixin ShopAttributeFilterMixin on GetxController {
  final contextBrands = <dynamic>[].obs;
  final brandSearchController = TextEditingController();
  final brandSearchQuery = ''.obs;
  final isBrandsDropdownExpanded = false.obs;

  final expandedAttributes = <String, bool>{}.obs;
  final visibleAttributeCount = <String, int>{}.obs;
  final filterDataProductFilters = <dynamic>[].obs;
  final isAttributesLoading = false.obs;
  final selectedAttributes = <String, Set<String>>{}.obs;

  final absoluteMinPrice = 0.0.obs;
  final absoluteMaxPrice = 10000.0.obs;
  final minPriceTextController = TextEditingController();
  final maxPriceTextController = TextEditingController();

  void toggleAttribute(String attributeName, String value) {
    final current = selectedAttributes[attributeName] ?? <String>{};
    if (current.contains(value)) {
      current.remove(value);
    } else {
      current.add(value);
    }
    selectedAttributes[attributeName] = current;
    selectedAttributes.refresh();
  }

  void disposeAttributeFilterControllers() {
    brandSearchController.dispose();
    minPriceTextController.dispose();
    maxPriceTextController.dispose();
  }
}
