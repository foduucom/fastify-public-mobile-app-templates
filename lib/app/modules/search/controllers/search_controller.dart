import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:get/get.dart'; 
import 'package:get_storage/get_storage.dart';

class SearchsController extends GetxController with BaseController {
  RxMap<dynamic, dynamic> serachData = {}.obs;
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
      var response =
          await BasicProvider('mobile/public/categories/specific/product')
              .getRequest()
              .catchError(handleError);
      trendingCategoryProduct.clear();

      trendingCategoryProduct.addAll(response);
    } catch (e) {
      print('search error $e');
    }
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
}
