import 'package:flutter/material.dart';
import '/components/resilience/friendly_error_state.dart';
import '/services/api_health_service.dart';
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

  /// Observable error flag from [DynamicLayoutMixin.hasError].
  final RxBool hasError;

  /// Observable error message from [DynamicLayoutMixin.errorMessage].
  final RxString errorMessage;

  /// Callback for pull-to-refresh. Required only in full-page mode.
  final Future<void> Function()? onRefresh;

  /// When `true`, skips the outer RefreshIndicator / SingleChildScrollView
  /// so this widget can live inside any existing scroll parent.
  final bool embedded;

  /// Optional widget shown while [isLoading] is true. Falls back to a
  /// CircularProgressIndicator when not provided.
  final Widget? loadingWidget;

  /// Full-page constructor (with its own scroll + pull-to-refresh).
  const FoduuStudioLayoutView({
    super.key,
    required this.widgetList,
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    required this.onRefresh,
    this.embedded = false,
    this.loadingWidget,
  });

  /// Embedded constructor — no scroll wrapper, safe inside Column/ListView.
  const FoduuStudioLayoutView.embedded({
    super.key,
    required this.widgetList,
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
  })  : onRefresh = null,
        embedded = true,
        loadingWidget = null;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      print("widgetList.length: ${widgetList.length}");

      final health = ApiHealthService.maybe;

      // Nothing to show and the backend has been unreachable for a while:
      // swap the skeleton for a calm "taking longer" state with auto-retry.
      if (widgetList.isEmpty &&
          health != null &&
          health.status.value == ApiHealth.down) {
        return FriendlyErrorState(
          onRetry: () async {
            await health.retryNow();
            await onRefresh?.call();
          },
        );
      }

      if (isLoading.value) {
        return loadingWidget ??
            Center(child: HelperFunctions().loadingIndicator());
      }

      if (hasError.value && widgetList.isEmpty) {
        return FriendlyErrorState(
          onRetry: () async {
            await health?.retryNow();
            await onRefresh?.call();
          },
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
