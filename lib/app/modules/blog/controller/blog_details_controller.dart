import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:get/get.dart';

class BlogDetailsController extends GetxController with BaseController {
  var blogDetails = {}.obs;
  var isLoading = false.obs;
  var recentBlogs = [].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map && args.containsKey('id')) {
      loadBlogAndRecent(args['id'].toString());
    } else if (args != null && args is String) {
      loadBlogAndRecent(args);
    }
  }

  Future<void> loadBlogAndRecent(String id) async {
    await getBlogById(id: id);
    await getRecentBlogs(excludeId: id);
  }

  Future<void> getBlogById({required String id}) async {
    try {
      isLoading.value = true;
      var response =
          await BasicProvider("blogs/$id").getRequest().catchError(handleError);
      if (response == null) return;
      if (response is Map) {
        blogDetails.assignAll(Map<String, dynamic>.from(response));
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getRecentBlogs({String? excludeId}) async {
    try {
      var response = await BasicProvider("blogs").getRequest(
        queryParams: {'page': '1', 'count': '6'},
      ).catchError(handleError);

      if (response == null) return;
      List list = [];
      if (response is Map && response.containsKey('data')) {
        list = response['data'] as List;
      } else if (response is List) {
        list = response;
      }

      if (excludeId != null && excludeId.isNotEmpty) {
        list = list.where((item) => item['_id']?.toString() != excludeId).toList();
      }
      recentBlogs.assignAll(list);
    } catch (_) {
    }
  }
}
