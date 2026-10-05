import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/blog/controller/blog_controller.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/models/blog_model.dart';
import 'package:get/get.dart';

class BlogDetailsController extends GetxController with BaseController {
  final Rx<BlogModel?> currentBlog = Rx<BlogModel?>(null);
  final RxList<BlogModel> latestBlogs = <BlogModel>[].obs;
  final Rx<BlogModel?> previousBlog = Rx<BlogModel?>(null);
  final Rx<BlogModel?> nextBlog = Rx<BlogModel?>(null);

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _resolveBlogFromArguments();
  }

  void _resolveBlogFromArguments() {
    final args = Get.arguments;
    if (args is Map) {
      if (args['blog'] is BlogModel) {
        currentBlog.value = args['blog'] as BlogModel;
        _populateAdjacentAndLatestBlogs();
      } else if (args['id'] != null) {
        fetchBlogById(args['id'].toString());
      }
    } else if (args is BlogModel) {
      currentBlog.value = args;
      _populateAdjacentAndLatestBlogs();
    }
  }

  Future<void> fetchBlogById(String id) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final response = await BasicProvider('blogs/$id')
          .getRequest()
          .catchError(handleError);

      if (response == null) {
        hasError.value = true;
        errorMessage.value = 'Blog post not found.';
        return;
      }

      Map<String, dynamic>? dataMap;
      if (response is Map<String, dynamic>) {
        if (response['data'] is Map<String, dynamic>) {
          dataMap = response['data'] as Map<String, dynamic>;
        } else {
          dataMap = response;
        }
      }

      if (dataMap != null) {
        currentBlog.value = BlogModel.fromJson(dataMap);
        _populateAdjacentAndLatestBlogs();
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to parse blog details.';
      }
    } catch (e) {
      debugPrint('Error loading blog detail: $e');
      hasError.value = true;
      errorMessage.value = 'Unable to load article.';
    } finally {
      isLoading.value = false;
    }
  }

  void _populateAdjacentAndLatestBlogs() {
    // If BlogController is registered, extract adjacent and latest posts from its list
    if (Get.isRegistered<BlogController>()) {
      final blogCtrl = Get.find<BlogController>();
      final list = blogCtrl.allBlogs;
      final curId = currentBlog.value?.id;

      if (list.isNotEmpty && curId != null) {
        final index = list.indexWhere((b) => b.id == curId);
        if (index != -1) {
          if (index > 0) {
            previousBlog.value = list[index - 1];
          } else {
            previousBlog.value = null;
          }

          if (index < list.length - 1) {
            nextBlog.value = list[index + 1];
          } else {
            nextBlog.value = null;
          }
        }

        // Latest blogs (excluding current)
        final recents = list.where((b) => b.id != curId).take(3).toList();
        latestBlogs.assignAll(recents);
      }
    }
  }

  /// Navigate to another blog post (for prev/next or latest post taps)
  void openBlog(BlogModel blog) {
    currentBlog.value = blog;
    _populateAdjacentAndLatestBlogs();
  }

  /// Share blog article link
  void shareBlog() {
    final blog = currentBlog.value;
    if (blog == null) return;

    final blogUrl = blog.slug.isNotEmpty
        ? '${url}blog/${blog.slug}'
        : '${url}blog';

    FlutterClipboard.copy(blogUrl).then((_) {
      Fluttertoast.showToast(
        msg: 'Article link copied to clipboard!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    });
  }
}
