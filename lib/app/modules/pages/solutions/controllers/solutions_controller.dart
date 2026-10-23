import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/models/page_model.dart';
import 'package:zouhi/app/data/services/page_api_service.dart';

class SolutionsController extends GetxController with BaseController {
  final PageApiService _apiService = PageApiService();
  final GetStorage _box = GetStorage();
  static const _cacheKey = 'cms_page_solution_content';

  final isLoading = false.obs;
  final error = ''.obs;
  final components = <PageComponent>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCached();
    fetchSolutions();
  }

  void loadCached() {
    try {
      final cached = _box.read(_cacheKey);
      if (cached != null && cached is List) {
        final list = cached
            .map((e) => PageComponent.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        if (list.isNotEmpty) {
          components.assignAll(list);
        }
      }
    } catch (_) {}
  }

  Future<void> fetchSolutions() async {
    if (components.isEmpty) {
      isLoading(true);
    }
    error('');
    try {
      final response = await _apiService.getSolutionsPage();
      final content = response.data?.content ?? [];
      if (content.isEmpty && components.isEmpty) {
        error('No content available.');
      } else if (content.isNotEmpty) {
        components.assignAll(content);
        _box.write(_cacheKey, content.map((c) => c.toJson()).toList());
      }
    } catch (e) {
      if (components.isEmpty) {
        error(e.toString());
      }
    } finally {
      isLoading(false);
    }
  }
}
