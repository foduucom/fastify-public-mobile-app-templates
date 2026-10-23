import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/app/data/models/page_model.dart';

class PageApiService {
  /// Candidate CMS slugs per page type, tried in order until one returns content.
  /// The first entry is the slug used by the website (vision.vbought.com).
  static const Map<String, List<String>> pageSlugs = {
    'privacy': ['privacy-policy'],
    'terms': ['terms-conditions', 'terms-and-conditions', 'terms-of-service'],
    'refund': ['return-and-refund', 'refund-policy', 'return-policy'],
    'about': ['about'],
    'contact': ['contact'],
    'solution': ['solution', 'solutions'],
    'services': ['services'],
  };

  Future<PageResponse> getPageByType(String type) async {
    final slugs = pageSlugs[type];
    if (slugs == null) {
      throw Exception("Unknown page type: $type");
    }
    Object? lastError;
    for (final slug in slugs) {
      try {
        final response = await getPage(slug);
        if (response.status == 'success' &&
            response.data != null &&
            response.data!.content.isNotEmpty) {
          return response;
        }
      } catch (e) {
        lastError = e;
        print("PageApiService: slug '$slug' failed: $e");
      }
    }
    if (lastError != null) throw lastError;
    return PageResponse(status: "error", data: null);
  }

  Future<PageResponse> getPage(String slug) async {
    final data = await getPageData("pages/$slug");
    return _buildPageResponse(data);
  }

  Future<PageResponse> getPrivacyPolicy() => getPageByType('privacy');

  Future<PageResponse> getTermsConditions() => getPageByType('terms');

  Future<PageResponse> getReturnRefundPolicy() => getPageByType('refund');

  Future<PageResponse> getSolutionsPage() => getPageByType('solution');

  Future<PageResponse> getServicesPage() => getPageByType('services');

  Future<Map<String, dynamic>?> getPageData(String endpoint) async {
    try {
      final response = await BasicProvider(endpoint).getRequest();
      if (response == null) return null;
      if (response is Map) {
        return Map<String, dynamic>.from(response);
      }
      return null;
    } catch (e) {
      print("Error in PageApiService.getPageData ($endpoint): $e");
      rethrow;
    }
  }

  PageResponse _buildPageResponse(Map<String, dynamic>? data) {
    if (data == null) {
      return PageResponse(status: "error", data: null);
    }
    // BasicProvider's processResponse returns the inner 'data' block directly
    if (data.containsKey('slug') || data.containsKey('_id') || data.containsKey('content')) {
      return PageResponse(
        status: "success",
        data: PageData.fromJson(data),
      );
    }
    return PageResponse.fromJson(data);
  }
}
