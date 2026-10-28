import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/models/page_model.dart';
import 'package:zouhi/app/data/models/privacy_sections.dart';
import 'package:zouhi/app/data/models/terms_sections.dart';
import 'package:zouhi/app/data/services/page_api_service.dart';
import 'package:zouhi/core/foduuStudio/foduu_studio_layout_mixin.dart';

class PolicyController extends GetxController
    with BaseController, FoduuStudioLayoutMixin {
  final PageApiService _apiService = PageApiService();
  final _storage = GetStorage();

  final isLoading = false.obs;
  final pageData = Rxn<PageResponse>();
  final termsData = Rxn<TermsPageData>();
  final privacyData = Rxn<PrivacyPageData>();
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

    if (policyType == 'terms') {
      // Pre-seed canonical defaults for instant render (zero blank screen)
      termsData.value = TermsPageData.canonical();
    } else if (policyType == 'privacy') {
      privacyData.value = PrivacyPageData.canonical();
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

  /// Intercepts both initial fetch and live WebSocket broadcasts from Fastify Studio
  @override
  void buildLayout(List sections) {
    super.buildLayout(sections);
    if (policyType == 'terms' && sections.isNotEmpty) {
      termsData.value = TermsPageData.fromSections(sections);
    } else if (policyType == 'privacy' && sections.isNotEmpty) {
      privacyData.value = PrivacyPageData.fromSections(sections);
    }
  }

  Future<void> fetchPolicy(String type, {bool forceRefresh = false}) async {
    policyType = type;
    isLoading(true);
    error('');
    isOfflineMode(false);

    if (type == 'terms') {
      await _fetchTerms(forceRefresh: forceRefresh);
    } else if (type == 'privacy') {
      await _fetchPrivacy(forceRefresh: forceRefresh);
    } else {
      await _fetchLegacyPolicy(type, forceRefresh: forceRefresh);
    }
  }

  /// Multi-tier fetching strategy for Privacy Policy matching fastify CMS broadcasting
  Future<void> _fetchPrivacy({bool forceRefresh = false}) async {
    // 1. Check local cache first if not force refreshing
    if (!forceRefresh) {
      final cachedJson = _storage.read(_cacheKey);
      if (cachedJson != null && cachedJson is Map) {
        try {
          final sections = cachedJson['sections'] ??
              (cachedJson['data'] is Map ? cachedJson['data']['sections'] : null);
          if (sections is List && sections.isNotEmpty) {
            privacyData.value = PrivacyPageData.fromSections(sections);
            isLoading(false);
            _checkAndFetchPrivacyInBackground();
            return;
          }
        } catch (e) {
          debugPrint("PolicyController: Error reading cached privacy: $e");
        }
      }
    }

    // 2. Connectivity check
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        isOfflineMode(true);
        if (privacyData.value == null) {
          privacyData.value = PrivacyPageData.canonical();
        }
        isLoading(false);
        return;
      }

      // Tier 1: Fastify CMS Broadcasting endpoint (GET /api/mobile-app/privacy-policy)
      try {
        final response = await fetchLayout('privacy-policy');
        if (response != null && response is Map) {
          final list = response['sections'] ??
              (response['data'] is Map ? response['data']['sections'] : null);
          if (list is List && list.isNotEmpty) {
            privacyData.value = PrivacyPageData.fromSections(list);
            await _storage.write(_cacheKey, response);
            isLoading(false);
            return;
          }
        }
      } catch (cmsError) {
        debugPrint("PolicyController: CMS fetchLayout('privacy-policy') failed: $cmsError");
      }

      // Tier 2: Legacy Page API Fallback (/pages?type=privacy)
      try {
        final legacyResponse = await _fetchFromApi('privacy');
        if (legacyResponse.status == 'success' && legacyResponse.data != null) {
          pageData(legacyResponse);
          await _storage.write(_cacheKey, legacyResponse.toJson());
          isLoading(false);
          return;
        }
      } catch (legacyError) {
        debugPrint("PolicyController: Legacy page API fallback failed: $legacyError");
      }

      // Tier 3: Website Canonical Defaults (guaranteed zero blank screen)
      if (privacyData.value == null) {
        privacyData.value = PrivacyPageData.canonical();
      }
    } catch (e) {
      debugPrint("PolicyController: Network error in _fetchPrivacy: $e");
      isOfflineMode(true);
      if (privacyData.value == null) {
        privacyData.value = PrivacyPageData.canonical();
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> _checkAndFetchPrivacyInBackground() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      try {
        final response = await fetchLayout('privacy-policy', silent: true);
        if (response != null && response is Map) {
          final list = response['sections'] ??
              (response['data'] is Map ? response['data']['sections'] : null);
          if (list is List && list.isNotEmpty) {
            privacyData.value = PrivacyPageData.fromSections(list);
            await _storage.write(_cacheKey, response);
          }
        }
      } catch (e) {
        debugPrint("PolicyController: Background privacy sync error: $e");
      }
    }
  }

  /// Multi-tier fetching strategy for Terms & Conditions matching fastify CMS broadcasting
  Future<void> _fetchTerms({bool forceRefresh = false}) async {
    // 1. Check local cache first if not force refreshing
    if (!forceRefresh) {
      final cachedJson = _storage.read(_cacheKey);
      if (cachedJson != null && cachedJson is Map) {
        try {
          final sections = cachedJson['sections'] ?? (cachedJson['data'] is Map ? cachedJson['data']['sections'] : null);
          if (sections is List && sections.isNotEmpty) {
            termsData.value = TermsPageData.fromSections(sections);
            isLoading(false);
            _checkAndFetchTermsInBackground();
            return;
          }
        } catch (e) {
          debugPrint("PolicyController: Error reading cached terms: $e");
        }
      }
    }

    // 2. Connectivity check
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        isOfflineMode(true);
        if (termsData.value == null) {
          termsData.value = TermsPageData.canonical();
        }
        isLoading(false);
        return;
      }

      // Tier 1: Fastify CMS Broadcasting endpoint (GET /api/mobile-app/terms-and-conditions)
      try {
        final response = await fetchLayout('terms-and-conditions');
        if (response != null && response is Map) {
          final list = response['sections'] ?? (response['data'] is Map ? response['data']['sections'] : null);
          if (list is List && list.isNotEmpty) {
            termsData.value = TermsPageData.fromSections(list);
            await _storage.write(_cacheKey, response);
            isLoading(false);
            return;
          }
        }
      } catch (cmsError) {
        debugPrint("PolicyController: CMS fetchLayout('terms-and-conditions') failed: $cmsError");
      }

      // Tier 2: Legacy Page API Fallback (/pages/terms-conditions)
      try {
        final legacyResponse = await _fetchFromApi('terms');
        if (legacyResponse.status == 'success' && legacyResponse.data != null) {
          pageData(legacyResponse);
          await _storage.write(_cacheKey, legacyResponse.toJson());
          isLoading(false);
          return;
        }
      } catch (legacyError) {
        debugPrint("PolicyController: Legacy page API fallback failed: $legacyError");
      }

      // Tier 3: Website Canonical Defaults (guaranteed zero blank screen)
      if (termsData.value == null) {
        termsData.value = TermsPageData.canonical();
      }
    } catch (e) {
      debugPrint("PolicyController: Network error in _fetchTerms: $e");
      isOfflineMode(true);
      if (termsData.value == null) {
        termsData.value = TermsPageData.canonical();
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> _checkAndFetchTermsInBackground() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      try {
        final response = await fetchLayout('terms-and-conditions', silent: true);
        if (response != null && response is Map) {
          final list = response['sections'] ?? (response['data'] is Map ? response['data']['sections'] : null);
          if (list is List && list.isNotEmpty) {
            termsData.value = TermsPageData.fromSections(list);
            await _storage.write(_cacheKey, response);
          }
        }
      } catch (e) {
        debugPrint("PolicyController: Background terms sync error: $e");
      }
    }
  }

  /// Legacy policy fetching logic preserved for Privacy, Refund, and other CMS pages
  Future<void> _fetchLegacyPolicy(String type, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedJson = _storage.read(_cacheKey);
      if (cachedJson != null) {
        try {
          final parsed = PageResponse.fromJson(Map<String, dynamic>.from(cachedJson));
          if (parsed.data != null) {
            pageData(parsed);
            isLoading(false);
            _checkAndFetchInBackground(type);
            return;
          }
        } catch (e) {
          debugPrint("Error reading cached policy: $e");
        }
      }
    }

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception("No internet connection available.");
      }

      final response = await _fetchFromApi(type);
      if (response.status == 'success' && response.data != null) {
        pageData(response);
        await _storage.write(_cacheKey, response.toJson());
      } else {
        throw Exception("API returned unsuccessful status: ${response.status}");
      }
    } catch (e) {
      debugPrint("Error fetching policy from network: $e");
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
          debugPrint("Error parsing fallback cached policy: $cacheEx");
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
        debugPrint("Background fetch failed: $e");
      }
    }
  }

  /// Launch external URL, email, or telephone link with scheme normalization
  Future<void> openUrl(String rawUrl) async {
    try {
      String formattedUrl = rawUrl.trim();
      if (formattedUrl.contains('@') && !formattedUrl.startsWith('mailto:')) {
        formattedUrl = 'mailto:$formattedUrl';
      } else if (!formattedUrl.startsWith('http://') &&
          !formattedUrl.startsWith('https://') &&
          !formattedUrl.startsWith('mailto:') &&
          !formattedUrl.startsWith('tel:')) {
        formattedUrl = 'https://$formattedUrl';
      }
      final uri = Uri.parse(formattedUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint("Could not launch url $rawUrl: $e");
    }
  }
}
