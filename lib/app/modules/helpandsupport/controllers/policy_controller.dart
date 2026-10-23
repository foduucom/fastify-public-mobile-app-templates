import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/models/page_model.dart';
import 'package:zouhi/app/data/services/page_api_service.dart';

class PolicyController extends GetxController with BaseController {
  final PageApiService _apiService = PageApiService();
  final _storage = GetStorage();

  final isLoading = false.obs;
  final pageData = Rxn<PageResponse>();
  final error = ''.obs;
  final isOfflineMode = false.obs;

  late String policyType; // 'privacy', 'terms', 'refund' (or a raw CMS slug)
  String? titleArg;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    policyType = 'privacy';
    if (args is Map) {
      titleArg = args['title']?.toString();
      final type = args['type']?.toString();
      final slug = args['slug']?.toString();
      if (type != null && type.isNotEmpty) {
        policyType = type;
      } else if (slug != null && slug.isNotEmpty) {
        policyType = _typeForSlug(slug);
      }
    }
    fetchPolicy(policyType);
  }

  /// Maps a CMS slug to a known policy type, or keeps the raw slug.
  String _typeForSlug(String slug) {
    for (final entry in PageApiService.pageSlugs.entries) {
      if (entry.value.contains(slug)) return entry.key;
    }
    return slug;
  }

  Future<PageResponse> _fetchFromApi(String type) {
    return PageApiService.pageSlugs.containsKey(type)
        ? _apiService.getPageByType(type)
        : _apiService.getPage(type);
  }

  String get _cacheKey => 'cached_policy_$policyType';

  Future<void> fetchPolicy(String type, {bool forceRefresh = false}) async {
    policyType = type;
    isLoading(true);
    error('');
    isOfflineMode(false);

    // Caching Strategy & Offline Support
    if (!forceRefresh) {
      final cachedJson = _storage.read(_cacheKey);
      if (cachedJson != null) {
        try {
          final parsed = PageResponse.fromJson(Map<String, dynamic>.from(cachedJson));
          if (parsed.data != null) {
            pageData(parsed);
            isLoading(false);
            
            // Check connectivity and fetch latest in background if online
            _checkAndFetchInBackground(type);
            return;
          }
        } catch (e) {
          print("Error reading cached policy: $e");
        }
      }
    }

    try {
      // Check connectivity first
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception("No internet connection available.");
      }

      final response = await _fetchFromApi(type);

      if (response.status == 'success' && response.data != null) {
        pageData(response);
        // Cache the parsed response
        await _storage.write(_cacheKey, response.toJson());
      } else {
        throw Exception("API returned unsuccessful status: ${response.status}");
      }
    } catch (e) {
      print("Error fetching policy from network: $e");
      
      // Fallback to cache if network call fails
      final cachedJson = _storage.read(_cacheKey);
      if (cachedJson != null) {
        try {
          final parsed = PageResponse.fromJson(Map<String, dynamic>.from(cachedJson));
          if (parsed.data != null) {
            pageData(parsed);
            isOfflineMode(true);
            Fluttertoast.showToast(
              msg: "Showing cached content (Offline)",
              toastLength: Toast.LENGTH_SHORT,
            );
            return;
          }
        } catch (cacheEx) {
          print("Error parsing fallback cached policy: $cacheEx");
        }
      }
      error(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> _checkAndFetchInBackground(String type) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      try {
        final response = await _fetchFromApi(type);

        if (response.status == 'success' && response.data != null) {
          pageData(response);
          await _storage.write(_cacheKey, response.toJson());
        }
      } catch (e) {
        print("Background fetch failed: $e");
      }
    }
  }
}
