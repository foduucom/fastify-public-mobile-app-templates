import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';

class BlogController extends GetxController with BaseController {
  var allnews = [].obs;
  late ScrollController scrollController;
  var isLoading = false.obs;

  var currentPage = 1.obs;
  var hasNextPage = true.obs;

  var searchQuery = ''.obs;
  late TextEditingController searchController;

  List get displayedBlogs {
    if (searchQuery.value.trim().isEmpty) {
      return allnews;
    }
    final query = searchQuery.value.toLowerCase().trim();
    return allnews.where((blog) {
      final name = (blog['name'] ?? '').toString().toLowerCase();
      final content = (blog['content'] ?? '').toString().toLowerCase();
      return name.contains(query) || content.contains(query);
    }).toList();
  }

  @override
  void onInit() async {
    scrollController = ScrollController();
    searchController = TextEditingController();
    super.onInit();
    getAllBlogs();
    _attachScrollListener();
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  void onRefresh() {
    currentPage.value = 1;
    hasNextPage.value = true;
    allnews.clear();
    clearSearch();
    getAllBlogs();
  }

  Future<void> getAllBlogs() async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      var response = await BasicProvider("blogs").getRequest(
        queryParams: {
          'page': currentPage.value.toString(),
          'count': '10',
        },
      ).catchError(handleError);

      if (response == null) return;

      if (response is Map && response.containsKey('data')) {
        allnews.addAll(response['data'] as List);
        hasNextPage.value = response['hasNextPage'] ?? false;
        if (hasNextPage.value) currentPage.value++;
      } else if (response is List) {
        allnews.addAll(response);
        hasNextPage.value = false;
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void _attachScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200.0 &&
          !isLoading.value &&
          hasNextPage.value) {
        getAllBlogs();
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
