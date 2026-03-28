import 'package:flutter/material.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';

/// A reusable view widget that renders a dynamic layout from an observable
/// widget list.
///
/// **Full-page mode** (default) — use as the entire `body`:
///
/// ```dart
/// body: DynamicLayoutView(
///   widgetList: controller.widgetList,
///   isLoading: controller.isLayoutLoading,
///   onRefresh: () => controller.fetchLayout('my-page'),
/// ),
/// ```
///
/// **Embedded mode** — drop it *inside* another scrollable (Column,
/// ListView, SingleChildScrollView, etc.):
///
/// ```dart
/// DynamicLayoutView.embedded(
///   widgetList: controller.widgetList,
///   isLoading: controller.isLayoutLoading,
/// ),
/// ```
class FoduuStudioLayoutView extends StatelessWidget {
  /// Observable list of widgets built by [DynamicLayoutMixin.buildLayout].
  final RxList<Widget> widgetList;

  /// Observable loading flag from [DynamicLayoutMixin.isLayoutLoading].
  final RxBool isLoading;

  /// Callback for pull-to-refresh. Required only in full-page mode.
  final Future<void> Function()? onRefresh;

  /// When `true`, skips the outer RefreshIndicator / SingleChildScrollView
  /// so this widget can live inside any existing scroll parent.
  final bool embedded;

  /// Full-page constructor (with its own scroll + pull-to-refresh).
  const FoduuStudioLayoutView({
    super.key,
    required this.widgetList,
    required this.isLoading,
    required this.onRefresh,
    this.embedded = false,
  });

  /// Embedded constructor — no scroll wrapper, safe inside Column/ListView.
  const FoduuStudioLayoutView.embedded({
    super.key,
    required this.widgetList,
    required this.isLoading,
  })  : onRefresh = null,
        embedded = true;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoading.value) {
        return Column(
          children: [
            Center(child: HelperFunctions().loadingIndicator()),
          ],
        );
      }

      if (widgetList.isEmpty) {
        return const SizedBox.shrink();
      }

      // ── Embedded mode: just a shrinkWrap list, no scroll wrapper ──
      if (embedded) {
        return Column(
          children: widgetList.toList(),
        );
      }

      // ── Full-page mode: own scroll + pull-to-refresh ──
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: widgetList.toList(),
          ),
        ),
      );
    });
  }
}
