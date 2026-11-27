// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import '/app/data/basic_provider.dart';
import '/constants/app_exceptions.dart';
import '/constants/resilience_strings.dart';
import '/services/api_health_service.dart';
import '/helpers/socket_helper.dart';
import 'package:get/get.dart';

import 'widget_registry.dart';

/// Mixin that gives any GetxController dynamic-layout capabilities.
///
/// Usage:
/// ```dart
/// class MyPageController extends GetxController
///     with BaseController, DynamicLayoutMixin {
///   @override
///   void onInit() {
///     super.onInit();
///     fetchLayout('my-page-slug');
///   }
/// }
/// ```
///
/// Provides:
/// - [widgetList] — observable list of built widgets for the view.
/// - [isLayoutLoading] — observable loading flag.
/// - [fetchLayout] — fetches sections JSON from API and builds widgets.
/// - [buildLayout] — converts a raw `List<Map>` of sections into widgets.
/// - [enableSocketUpdates] / [disableSocketUpdates] — live layout updates.
mixin FoduuStudioLayoutMixin on GetxController {
  static final Map<String, String> categoryNameMap = {};

  // ─── Observable state ────────────────────────────────────────
  final widgetList = <Widget>[].obs;
  final isLayoutLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = "".obs;
  final layoutError = ''.obs;

  /// True while the sections on screen came from the local cache because the
  /// backend could not be reached.
  final isStale = false.obs;

  /// Section `type`s to skip when building the layout, e.g. `['search']`.
  List<String> excludeSectionTypes = const [];

  /// `type`s seen in the most recently built section list, before
  /// [excludeSectionTypes] filtering.
  final sectionTypes = <String>{}.obs;
  final rawSections = <Map<String, dynamic>>[].obs;

  // ─── Internal state ──────────────────────────────────────────
  List _initialComponents = [];
  List _lastSocketSections = [];
  int _layoutRequestId = 0;

  final SocketHelper _layoutSocketHelper = SocketHelper();
  final WidgetRegistry _registry = WidgetRegistry();

  String? _lastFetchSlug;
  dynamic _lastFetchBody;
  Worker? _recoveryWorker;

  String? _currentDomain;
  String? _currentSlug;

  // ─── Static registry: slug → mixin instance ─────────────────
  // Keeps one socket listener per event name.  When the event fires
  // it broadcasts to ALL registered controllers instead of only the
  // last one that called enableSocketUpdates().
  static final Map<String, FoduuStudioLayoutMixin> _slugHandlers = {};
  static String? _registeredEventName;

  // ─── Static block types that can be updated without API call ─
  static const _localUpdateOnlyTypes = [
    'spacer',
    'divider',
    'text_block',
    'rich_text',
  ];

  // ═══════════════════════════════════════════════════════════════
  //  PUBLIC API
  // ═══════════════════════════════════════════════════════════════

  /// Build the [widgetList] from a raw list of section maps.
  void buildLayout(List sections) {
    final normalized = sections
        .whereType<Map>()
        .map((section) => Map<String, dynamic>.from(section))
        .toList(growable: false);
    _initialComponents = normalized;
    rawSections.assignAll(normalized);
    _updateCategoryNameMap(normalized);
    sectionTypes.assignAll(normalized
        .map(
            (section) => section['type']?.toString().trim().toLowerCase() ?? '')
        .where((type) => type.isNotEmpty));

    // The products section builds its category tabs from the categories
    // section of the same page, so hand the category list over to it.
    List? tabCategories;
    for (var section in normalized) {
      if (section['type']?.toString().trim().toLowerCase() == 'categories') {
        final rawContent = section['content_json'] ?? section['contentJson'];
        final content = rawContent is Map ? rawContent : section['data'];
        final cats = content is Map ? content['categories'] : null;
        if (cats is List && cats.isNotEmpty) tabCategories = cats;
        break;
      }
    }

    var tabsInjected = false;
    final nextWidgets = <Widget>[];
    for (var section in normalized) {
      try {
        if (section['visible'] == false ||
            excludeSectionTypes.contains(section['type'])) {
          continue;
        }
        var toBuild = section;
        if (tabCategories != null &&
            !tabsInjected &&
            section['type']?.toString().trim().toLowerCase() == 'products') {
          tabsInjected = true;
          final rawProductContent =
              section['content_json'] ?? section['contentJson'];
          final productContent = rawProductContent is Map
              ? Map<String, dynamic>.from(rawProductContent)
              : <String, dynamic>{};
          toBuild = {
            ...section,
            'content_json': {
              ...productContent,
              'tab_categories': tabCategories,
            },
          };
        }
        final widget = _registry.build(toBuild);
        if (widget != null) nextWidgets.add(widget);
      } catch (error) {
        debugPrint('Studio section build failed (${section['type']}): $error');
      }
    }
    widgetList.assignAll(nextWidgets);
  }

  /// Build widgets for the last-fetched sections, skipping [excludeTypes].
  /// Not reactive — recomputed on every call.
  List<Widget> buildWidgetsExcluding(List<String> excludeTypes) {
    final result = <Widget>[];
    for (var section in _initialComponents) {
      if (section is Map) {
        if (excludeTypes.contains(section['type'])) continue;
        if (section['visible'] == false) continue;
        try {
          final widget = _registry.build(Map<String, dynamic>.from(section));
          if (widget != null) result.add(widget);
        } catch (error) {
          debugPrint(
              'Studio section build failed (${section['type']}): $error');
        }
      }
    }
    return result;
  }

  /// `content_json` of the first section of [type] in the last-fetched
  /// layout, or null when the page has no such section.
  Map<String, dynamic>? contentJsonFor(String type) {
    for (final section in _initialComponents) {
      if (section is Map &&
          section['type']?.toString().trim().toLowerCase() ==
              type.trim().toLowerCase()) {
        final cj = section['content_json'] ??
            section['contentJson'] ??
            section['data'];
        if (cj is Map) return Map<String, dynamic>.from(cj);
        return Map<String, dynamic>.from(section);
      }
    }
    return null;
  }

  void _updateCategoryNameMap(List<Map<String, dynamic>> sections) {
    for (final section in sections) {
      if (section['type']?.toString().trim().toLowerCase() != 'categories') {
        continue;
      }
      dynamic content = section['content_json'] ??
          section['contentJson'] ??
          section['data'] ??
          section;
      if (content is String) {
        try {
          content = json.decode(content);
        } catch (_) {
          continue;
        }
      }
      if (content is Map && content['categories'] is List) {
        _populateCategoryMap(content['categories'] as List);
      }
    }
  }

  void _populateCategoryMap(List categories) {
    for (final category in categories) {
      if (category is! Map) continue;
      final id = (category['_id'] ?? category['id'])?.toString();
      final name = (category['name'] ?? category['title'])?.toString();
      if (id != null &&
          id.isNotEmpty &&
          name != null &&
          name.trim().isNotEmpty) {
        categoryNameMap[id] = name.trim();
      }
      if (category['children'] is List) {
        _populateCategoryMap(category['children'] as List);
      }
    }
  }

  /// Fetch layout JSON from the API and build widgets.
  ///
  /// - [slug] — the page slug, e.g. `'home'`, `'category'`, etc.
  /// - [requestBody] — if provided, uses POST `mobile-app/by-json` instead of GET.
  ///
  /// With [silent] the current content stays on screen (no loading state);
  /// used to refresh quietly once the backend recovers.
  Future<dynamic> fetchLayout(String slug,
      {dynamic requestBody, bool silent = false}) async {
    final requestId = ++_layoutRequestId;
    _lastFetchSlug = slug;
    _lastFetchBody = requestBody;
    _watchBackendRecovery();
    try {
      if (!silent) {
        isLayoutLoading.value = true;
        hasError.value = false;
        errorMessage.value = "";
        layoutError.value = '';
      }
      dynamic response;

      // Ensure socket is connected and listener is enabled on web
      if (kIsWeb) {
        if (!_layoutSocketHelper.isConnected) {
          _layoutSocketHelper.connect();
        }
        enableSocketUpdates(domain: websiteDomain, slug: slug);
      }

      if (requestBody != null) {
        response = await BasicProvider("mobile-app/by-json")
            .postRequest(requestBody)
            .catchError((e, stackTrace) => _handleApiError(e, stackTrace));
        isStale.value = false;
      } else {
        final provider = BasicProvider("mobile-app/$slug");
        response = await provider
            .getRequest()
            .catchError((e, stackTrace) => _handleApiError(e, stackTrace));
        isStale.value = provider.servedFromCache;
      }
      if (requestId != _layoutRequestId || isClosed) return response;

      final sections = _extractSections(response);
      if (sections == null) {
        hasError.value = true;
        layoutError.value = response == null
            ? 'Could not load this content. Check your connection and try again.'
            : 'The CMS response did not contain a valid sections list.';
        errorMessage.value = _friendlyMessage(response == null
            ? layoutError.value
            : StateError(layoutError.value));
      } else {
        final themeData = _extractThemeColor(response);
        if (themeData is Map) {
          DynamicThemeManager()
              .updateFromApi(Map<String, dynamic>.from(themeData));
          if (Get.isRegistered<ThemeController>()) {
            Get.find<ThemeController>().refreshTheme();
          }
        }
        hasError.value = false;
        layoutError.value =
            sections.isEmpty ? 'No CMS sections are configured.' : '';
        errorMessage.value = layoutError.value;
        _initialComponents = sections;
        _lastSocketSections = List<Map<String, dynamic>>.from(sections);
        buildLayout(sections);
      }

      return response;
    } catch (e) {
      if (requestId == _layoutRequestId && !isClosed) {
        debugPrint('DynamicLayoutMixin fetchLayout error: $e');
        hasError.value = true;
        layoutError.value = _friendlyMessage(e);
        errorMessage.value = layoutError.value;
      }
    } finally {
      if (requestId == _layoutRequestId && !isClosed) {
        isLayoutLoading.value = false;
      }
    }
  }

  /// Once the backend is reachable again, quietly reload a layout that is
  /// either stale (cache) or failed, without flashing a loading state.
  void _watchBackendRecovery() {
    if (_recoveryWorker != null) return;
    final health = ApiHealthService.maybe;
    if (health == null) return;
    _recoveryWorker = ever(health.recoveryTick, (_) {
      final slug = _lastFetchSlug;
      if (slug != null && (isStale.value || hasError.value)) {
        fetchLayout(slug, requestBody: _lastFetchBody, silent: true);
      }
    });
  }

  @override
  void onClose() {
    _recoveryWorker?.dispose();
    final slug = _currentSlug;
    if (slug != null) {
      disableSocketUpdates(_currentDomain ?? websiteDomain, slug);
    }
    super.onClose();
  }

  List<Map<String, dynamic>>? _extractSections(dynamic response) {
    dynamic value = response;
    for (var depth = 0; depth < 5; depth++) {
      if (value is String) {
        try {
          value = json.decode(value);
        } catch (_) {
          return null;
        }
      }
      if (value is List) {
        return value
            .whereType<Map>()
            .map((section) => Map<String, dynamic>.from(section))
            .toList(growable: false);
      }
      if (value is! Map) return null;
      if (value['sections'] is List) {
        value = value['sections'];
        continue;
      }
      final next = value['data'] ??
          value['content_json'] ??
          value['contentJson'] ??
          value['content'];
      if (next == null) return null;
      value = next;
    }
    return null;
  }

  dynamic _extractThemeColor(dynamic response) {
    dynamic value = response;
    for (var depth = 0; depth < 5; depth++) {
      if (value is String) {
        try {
          value = json.decode(value);
        } catch (_) {
          return null;
        }
      }
      if (value is! Map) return null;
      final theme = value['theme_color'] ?? value['app_theme_color'];
      if (theme != null) return theme;
      value = value['data'] ?? value['content_json'] ?? value['contentJson'];
      if (value == null) return null;
    }
    return null;
  }

  String _friendlyMessage(dynamic e) => e is ServiceUnavailableException
      ? ResilienceStrings.unavailableMessage
      : 'Something went wrong. Please try again.';

  /// Enable real-time socket-driven layout updates.
  ///
  /// Registers this controller for socket events. Multiple controllers
  /// can coexist — the socket listener is registered ONCE. When a socket
  /// event fires, the `slug` in the data payload determines which
  /// controller handles it.
  void enableSocketUpdates({
    required String domain,
    required String slug,
  }) {
    try {
      if (_currentDomain == domain && _currentSlug == slug) return;

      _currentDomain = domain;
      _currentSlug = slug;

      // Register this controller for the given slug
      _slugHandlers[slug] = this;

      final eventName = '${domain}:mobileapp';

      // Only set up the socket listener ONCE across all controllers
      if (_registeredEventName != eventName) {
        if (_registeredEventName != null) {
          _layoutSocketHelper.off(_registeredEventName!);
        }

        print(
            '🟢 DynamicLayout: Setting up SHARED socket listener for: $eventName');
        _layoutSocketHelper.on(eventName, (data) {
          _dispatchSocketEvent(data);
        });

        _registeredEventName = eventName;
      } else {
        print(
            '🟢 DynamicLayout: Registered slug "$slug" on existing listener ($eventName)');
      }
    } catch (e) {
      print('❌ DynamicLayout: enableSocketUpdates error: $e');
    }
  }

  /// Stop listening for socket updates for this controller's slug.
  void disableSocketUpdates(String domain, String slug) {
    if (identical(_slugHandlers[slug], this)) _slugHandlers.remove(slug);
    final normalizedSlug = slug.toLowerCase().replaceFirst(RegExp(r'^/'), '');
    if (identical(_slugHandlers[normalizedSlug], this)) {
      _slugHandlers.remove(normalizedSlug);
    }
    print(
        '🔴 DynamicLayout: Unregistered slug "$slug" (${_slugHandlers.length} remaining)');

    // If no more handlers, remove the socket listener entirely
    if (_slugHandlers.isEmpty && _registeredEventName != null) {
      _layoutSocketHelper.off(_registeredEventName!);
      _registeredEventName = null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  SOCKET INTERNALS
  // ═══════════════════════════════════════════════════════════════

  /// Central dispatch — parses the slug from the socket data and routes
  /// the event ONLY to the controller registered for that slug.
  static void _dispatchSocketEvent(dynamic data) {
    if (data == null) {
      print('⚠️ DynamicLayout: Socket data is null');
      return;
    }

    dynamic decodedData;
    if (data is String) {
      decodedData = json.decode(data);
    } else {
      decodedData = data;
    }

    // ── Resolve the content payload ──
    // Format 1 (new): slug, theme_color, sections at root level
    // Format 2 (legacy): nested inside decodedData['content_json']
    dynamic contentPayload;
    if (decodedData.containsKey('content_json')) {
      contentPayload = decodedData['content_json'];
      if (contentPayload is String) {
        contentPayload = json.decode(contentPayload);
      }
    } else {
      contentPayload = decodedData;
    }

    // ── Extract slug from data ──
    // slug can be at root level or inside content_json
    final String? dataSlug =
        decodedData['slug']?.toString() ?? contentPayload['slug']?.toString();

    print('📩 DynamicLayout: Socket event received for slug: "$dataSlug"');
    print('   Registered slugs: ${_slugHandlers.keys.toList()}');

    // ── Handle Theme Update (applies globally) ──
    var themeData = contentPayload['theme_color'];
    if (themeData != null) {
      print('🎨 DynamicLayout: Theme update detected');
      DynamicThemeManager().updateFromApi(themeData);

      if (Get.isRegistered<ThemeController>()) {
        Get.find<ThemeController>().refreshTheme();
      }
    }

    // ── Handle Section Update (slug-specific) ──
    var newSections = contentPayload['sections'];
    if (newSections != null && newSections is List && dataSlug != null) {
      final handler = _slugHandlers[dataSlug];
      if (handler != null) {
        print('   ✅ Dispatching sections to slug: "$dataSlug"');
        handler._handleSectionUpdate(newSections, dataSlug);
      } else {
        print(
            '   ⚠️ No controller registered for slug: "$dataSlug" — ignoring sections');
      }
    }
  }

  void _handleSectionUpdate(List newSections, String slug) {
    print('🧩 DynamicLayout: Sections received: ${newSections.length}');

    // First socket event → store and fetch from API
    if (_lastSocketSections.isEmpty) {
      print('🔄 First socket event. Fetching from API...');
      _lastSocketSections =
          List.from(newSections.map((e) => json.decode(json.encode(e))));
      fetchLayout(slug, requestBody: newSections);
      return;
    }

    // Structural change: blocks added or removed
    if (_lastSocketSections.length != newSections.length) {
      print(
          '⚠️ Section count changed: ${_lastSocketSections.length} → ${newSections.length}');
      _lastSocketSections =
          List.from(newSections.map((e) => json.decode(json.encode(e))));
      fetchLayout(slug, requestBody: newSections);
      return;
    }

    // Check for block type changes
    bool hasTypeChange = false;
    for (int i = 0; i < _lastSocketSections.length; i++) {
      if (_lastSocketSections[i]['type'] != newSections[i]['type']) {
        print(
            '⚠️ Block type changed at $i: ${_lastSocketSections[i]['type']} → ${newSections[i]['type']}');
        hasTypeChange = true;
        break;
      }
    }
    if (hasTypeChange) {
      _lastSocketSections =
          List.from(newSections.map((e) => json.decode(json.encode(e))));
      fetchLayout(slug, requestBody: newSections);
      return;
    }

    // Compare against last socket config
    bool hasDynamicChange = false;
    bool hasStaticChange = false;
    List<int> staticChangedIndices = [];

    for (int i = 0; i < _lastSocketSections.length; i++) {
      var oldItem = _lastSocketSections[i];
      var newItem = newSections[i];

      if (json.encode(oldItem) == json.encode(newItem)) continue;

      if (_localUpdateOnlyTypes.contains(newItem['type'])) {
        print(
            '✏️ Static block updated at $i (${newItem['type']}), updating locally');
        staticChangedIndices.add(i);
        hasStaticChange = true;
      } else {
        print(
            '⚠️ Dynamic block changed at $i (${newItem['type']}), API call needed');
        hasDynamicChange = true;
      }
    }

    _lastSocketSections =
        List.from(newSections.map((e) => json.decode(json.encode(e))));

    if (hasDynamicChange) {
      print('🚀 Dynamic changes detected. Fetching from API...');
      fetchLayout(slug, requestBody: newSections);
    } else if (hasStaticChange) {
      print('✅ Only static changes. Updating UI directly...');
      for (int idx in staticChangedIndices) {
        _initialComponents[idx] = newSections[idx];
      }
      buildLayout(_initialComponents);
    } else {
      print('ℹ️ No changes detected.');
    }
  }

  // ─── Error handling (delegates to BaseController if available) ─
  dynamic _handleApiError(dynamic error, StackTrace stackTrace) {
    print('DynamicLayoutMixin API error: $error');
    // Surface the failure to the view instead of leaving a blank screen.
    hasError.value = true;
    errorMessage.value = _friendlyMessage(error);
    return null;
  }
}
