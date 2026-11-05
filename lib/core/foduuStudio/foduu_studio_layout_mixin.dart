// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import '/constants/constants.dart';
import '/constants/dynamic_theme.dart';
import '/app/data/basic_provider.dart';
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
  // ─── Static category lookup: id → name ──────────────────────
  static final Map<String, String> categoryNameMap = {};

  // ─── Observable state ────────────────────────────────────────
  final widgetList = <Widget>[].obs;
  final isLayoutLoading = true.obs;
  final layoutError = ''.obs;

  // ─── Internal state ──────────────────────────────────────────
  List _initialComponents = [];
  List _lastSocketSections = [];
  List<String> _excludedSectionTypes = const [];

  /// Section types present in the last fetched CMS layout.
  List<String> get sectionTypes => _initialComponents
      .whereType<Map>()
      .map((section) => section['type']?.toString() ?? '')
      .where((type) => type.isNotEmpty)
      .toList(growable: false);

  /// Excludes locally rendered sections from the widget tree.
  set excludeSectionTypes(List<String> types) {
    _excludedSectionTypes = List.unmodifiable(types);
    buildLayout(_initialComponents);
  }

  /// Returns a section's CMS content JSON by its type.
  Map<String, dynamic>? contentJsonFor(String type) {
    for (final section in _initialComponents.whereType<Map>()) {
      if (section['type'] != type) continue;
      final content = section['content_json'] ?? section['contentJson'];
      if (content is Map) return Map<String, dynamic>.from(content);
      return Map<String, dynamic>.from(section);
    }
    return null;
  }

  final SocketHelper _layoutSocketHelper = SocketHelper();
  final WidgetRegistry _registry = WidgetRegistry();

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
    _updateCategoryNameMap(sections);
    _initialComponents = sections;
    widgetList.clear();
    for (var index = 0; index < sections.length; index++) {
      final rawSection = sections[index];
      if (rawSection is! Map) {
        print('⚠️ DynamicLayout: Skipping invalid section at index $index');
        continue;
      }
      try {
        final section = Map<String, dynamic>.from(rawSection);
        final type = section['type']?.toString() ?? '';
        if (_excludedSectionTypes.contains(type)) continue;

        // Home spacing is intentionally compact and consistent. CMS spacer
        // values are still honored up to 12 px, but cannot create large gaps
        // between adjacent editorial sections.
        if (_currentSlug == 'home' && type == 'spacer') {
          final rawContent =
              section['content_json'] ?? section['contentJson'] ?? section;
          final content = rawContent is Map
              ? Map<String, dynamic>.from(rawContent)
              : <String, dynamic>{};
          final requestedHeight =
              double.tryParse('${content['height']}') ?? 10.0;
          content['height'] = requestedHeight.clamp(0.0, 12.0);
          section['content_json'] = content;
        }
        if (_currentSlug == 'home' && type == 'slider') {
          final rawContent = section['content_json'] ?? section['contentJson'];
          if (rawContent is Map) {
            final content = Map<String, dynamic>.from(rawContent);
            content['_compact_home_spacing'] = true;
            section['content_json'] = content;
          }
        }

        final widget = _registry.build(section);
        if (widget != null) {
          widgetList.add(widget);
        } else {
          print('ℹ️ DynamicLayout: No visible widget built for "$type"');
        }
      } catch (e) {
        print('⚠️ DynamicLayout: Failed building section $index: $e');
      }
    }
    print(
        '🧱 DynamicLayout: Built ${widgetList.length}/${sections.length} sections; registered=${_registry.registeredTypes}');
  }

  void _updateCategoryNameMap(List sections) {
    for (final rawSection in sections) {
      if (rawSection is! Map || rawSection['type'] != 'categories') continue;
      final rawContent =
          rawSection['content_json'] ?? rawSection['contentJson'] ?? rawSection;
      if (rawContent is Map && rawContent['categories'] is List) {
        _populateCategoryMap(rawContent['categories'] as List);
      }
    }
  }

  void _populateCategoryMap(List categories) {
    for (final cat in categories) {
      if (cat is! Map) continue;
      final id = (cat['_id'] ?? cat['id'])?.toString();
      final name = (cat['name'] ?? cat['title'])?.toString();
      if (id != null && id.isNotEmpty && name != null && name.isNotEmpty) {
        categoryNameMap[id] = name;
      }
      if (cat['children'] is List) {
        _populateCategoryMap(cat['children'] as List);
      }
    }
  }

  /// Builds CMS sections except those rendered by the host view itself.
  List<Widget> buildWidgetsExcluding(Iterable<String> excludedTypes) {
    final excluded = excludedTypes.toSet();
    return _initialComponents
        .whereType<Map<String, dynamic>>()
        .where((section) => !excluded.contains(section['type']?.toString()))
        .map(_registry.build)
        .whereType<Widget>()
        .toList(growable: false);
  }

  /// Fetch layout JSON from the API and build widgets.
  ///
  /// - [slug] — the page slug, e.g. `'home'`, `'category'`, etc.
  /// - [requestBody] — if provided, uses POST `mobile-app/by-json` instead of GET.
  Future<dynamic> fetchLayout(String slug, {dynamic requestBody}) async {
    try {
      isLayoutLoading.value = true;
      layoutError.value = '';
      dynamic response;

      // CMS changes are broadcast to the mobile app as well as the web app.
      // Register before the HTTP request so an update arriving during the
      // initial fetch is not missed.
      if (!_layoutSocketHelper.isConnected) {
        _layoutSocketHelper.connect();
      }
      enableSocketUpdates(domain: websiteDomain, slug: slug);

      if (requestBody != null) {
        response = await BasicProvider("mobile-app/by-json")
            .postRequest(requestBody)
            .catchError((e, stackTrace) => _handleApiError(e, stackTrace));
      } else {
        response = await BasicProvider("mobile-app/$slug")
            .getRequest()
            .catchError((e, stackTrace) => _handleApiError(e, stackTrace));
      }

      final sections = _extractSections(response);
      if (sections == null) {
        widgetList.clear();
        layoutError.value = response == null
            ? 'Could not load home content. Check your connection and try again.'
            : 'The home response did not contain a valid sections list.';
        print('⚠️ DynamicLayout: No valid sections found for "$slug"');
      } else {
        print(
            '📄 DynamicLayout: Received ${sections.length} sections for "$slug"');
        buildLayout(sections);
        if (sections.isEmpty) {
          layoutError.value = 'No home sections are configured yet.';
        } else if (widgetList.isEmpty) {
          layoutError.value =
              'Home sections were received, but none could be displayed.';
        }
      }

      return response;
    } catch (e) {
      print('DynamicLayoutMixin fetchLayout error: $e');
      layoutError.value = 'Could not display home content. Please try again.';
    } finally {
      isLayoutLoading.value = false;
    }
  }

  /// Accept the API's direct sections response and common `data` envelopes.
  List? _extractSections(dynamic response) {
    if (response is List) return response;
    if (response is! Map) return null;

    final sections = response['sections'];
    if (sections is List) return sections;

    final data = response['data'];
    if (data is List) return data;
    if (data is Map && data['sections'] is List) {
      return data['sections'] as List;
    }
    return null;
  }

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
    // A second controller can take over the same slug while the first route
    // is being disposed. Do not remove the newer controller's registration.
    if (identical(_slugHandlers[slug], this)) {
      _slugHandlers.remove(slug);
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
    print('DynamicLayoutMixin API stackTrace: $stackTrace');
  }

  @override
  void onClose() {
    final slug = _currentSlug;
    if (slug != null) {
      disableSocketUpdates(_currentDomain ?? websiteDomain, slug);
    }
    super.onClose();
  }
}
