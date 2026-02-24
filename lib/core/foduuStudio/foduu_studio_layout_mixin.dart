// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
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
  // ─── Observable state ────────────────────────────────────────
  final widgetList = <Widget>[].obs;
  final isLayoutLoading = true.obs;

  // ─── Internal state ──────────────────────────────────────────
  List _initialComponents = [];
  List _lastSocketSections = [];

  final SocketHelper _layoutSocketHelper = SocketHelper();
  final WidgetRegistry _registry = WidgetRegistry();

  String? _currentDomain;
  String? _currentSlug;

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
    widgetList.clear();
    for (var section in sections) {
      if (section is Map<String, dynamic>) {
        final widget = _registry.build(section);
        if (widget != null) widgetList.add(widget);
      }
    }
  }

  /// Fetch layout JSON from the API and build widgets.
  ///
  /// - [slug] — the page slug, e.g. `'home'`, `'category'`, etc.
  /// - [requestBody] — if provided, uses POST `mobile-app/by-json` instead of GET.
  Future<dynamic> fetchLayout(String slug, {dynamic requestBody}) async {
    try {
      isLayoutLoading.value = true;
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
            .catchError((e) => _handleApiError(e));
      } else {
        response = await BasicProvider("mobile-app/$slug")
            .getRequest()
            .catchError((e) => _handleApiError(e));
      }

      if (response != null) {
        var list = response['sections'];
        if (list != null && list is List) {
          _initialComponents = list;
          buildLayout(list);
        }
      }

      return response;
    } catch (e) {
      print('DynamicLayoutMixin fetchLayout error: $e');
    } finally {
      isLayoutLoading.value = false;
    }
  }

  /// Enable real-time socket-driven layout updates.
  ///
  /// Typically called from the homepage controller for web.
  void enableSocketUpdates({
    required String domain,
    required String slug,
  }) {
    try {
      if (_currentDomain == domain && _currentSlug == slug) return;

      _currentDomain = domain;
      _currentSlug = slug;

      final eventName = '${domain}:mobileapp';
      print('🟢 DynamicLayout: Socket listener for event: $eventName');

      _layoutSocketHelper.off(eventName);

      _layoutSocketHelper.on(eventName, (data) {
        print('📩 DynamicLayout: Socket event received for $eventName');
        _handleSocketEvent(data, slug);
      });
    } catch (e) {
      print('❌ DynamicLayout: enableSocketUpdates error: $e');
    }
  }

  /// Stop listening for socket updates.
  void disableSocketUpdates(String domain, String slug) {
    _layoutSocketHelper.off('${domain}:mobileapp-${slug}');
  }

  // ═══════════════════════════════════════════════════════════════
  //  SOCKET INTERNALS (extracted from HomepageController)
  // ═══════════════════════════════════════════════════════════════

  void _handleSocketEvent(dynamic data, String slug) {
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

    var contentJson = decodedData['content_json'];
    if (contentJson is String) {
      contentJson = json.decode(contentJson);
    }

    var themeData = contentJson['theme_color'];
    var newSections = contentJson['sections'];

    // 1️⃣ Handle Theme Update
    if (themeData != null) {
      print('🎨 DynamicLayout: Theme update detected');
      DynamicThemeManager().updateFromApi(themeData);

      if (Get.isRegistered<ThemeController>()) {
        Get.find<ThemeController>().refreshTheme();
      }
    }

    // 2️⃣ Handle Content/Widget Update
    if (newSections != null && newSections is List) {
      _handleSectionUpdate(newSections, slug);
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
  dynamic _handleApiError(dynamic error) {
    print('DynamicLayoutMixin API error: $error');
    // If the controller also mixes in BaseController, you can call handleError
    // here. For now we just print and swallow.
  }
}
