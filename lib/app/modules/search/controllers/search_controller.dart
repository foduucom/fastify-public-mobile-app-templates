import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SearchsController extends GetxController with BaseController {
  var serachData = {}.obs;
  var searchProduct = [].obs;
  var searchBlog = [].obs;
  var searchCategory = [].obs;
  var recentSearchList = [].obs;
  var box = GetStorage();
  var trendingCategoryProduct = [].obs;
  var searchTextController;
  @override
  void onInit() {
    getRecentSearch();
    super.onInit();
    searchTextController = TextEditingController();
    getTrandingCategory();
    searchBlog.clear();
    searchProduct.clear();
    serachData.clear();
  }

  void getRecentSearch() {
    var recent = box.read('recentSearch');
    if (recent != null) {
      recentSearchList.addAll(recent);
      // recentSearchList.addAll(recentSearchList.reversed);
      // recentSearchList.assignAll(recentSearchList);
    }
  }

  void getTrandingCategory() async {
    try {
      var response = await BasicProvider('products?featured=true').getRequest();

      trendingCategoryProduct.clear();

      // Handle different response types without using catchError
      if (response is Map) {
        if (response.containsKey('data') && response['data'] is List) {
          trendingCategoryProduct.addAll(response['data']);
        }
      } else if (response is List) {
        trendingCategoryProduct.addAll(response);
      }

      print('✅ Loaded ${trendingCategoryProduct.length} trending products');
      update();
    } catch (e) {
      print('search error $e');
    }
  }

  // Add this helper method in the Controller to build image URLs
  String getProductImage(dynamic product) {
    try {
      if (product == null) return HelperFunctions.getNoImage();

      final featuredImage = product['featured_image'];
      if (featuredImage != null && featuredImage is Map) {
        String filepath = featuredImage['filepath'] ?? '';
        if (filepath.isNotEmpty) {
          // Use the existing url constant from constants.dart
          print("We have Final Image Url ${url + filepath}");
          return url + filepath;
        }
      }
    } catch (e) {
      print('Error building image URL: $e');
    }
    return HelperFunctions.getNoImage();
  }

  void getSearchSuggestion({required String text}) async {
    try {
      var response = await BasicProvider('public/search/all')
          .getRequest(queryParams: {'search': text}).catchError(handleError);
      searchBlog.clear();
      searchProduct.clear();
      searchCategory.clear();
      serachData.addAll(response);
      searchProduct.addAll(response['product']);
      searchBlog.addAll(response['blog']);
      searchCategory.addAll(response['category']);
    } catch (e) {
      print('search error $e');
    }
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }
}
