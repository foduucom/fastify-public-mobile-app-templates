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
  final RxBool? isStale;

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
    this.isStale,
  });

  /// Embedded constructor — no scroll wrapper, safe inside Column/ListView.
  const FoduuStudioLayoutView.embedded({
    super.key,
    required this.widgetList,
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    this.isStale,
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
        if (embedded) return const SizedBox.shrink();
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  errorMessage.value.isNotEmpty
                      ? errorMessage.value
                      : 'No content is available right now.',
                  textAlign: TextAlign.center,
                ),
                if (onRefresh != null) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try again'),
                  ),
                ],
              ],
            ),
          ),
        );
      }

      // ── Embedded mode: just a shrinkWrap list, no scroll wrapper ──
      if (embedded) {
        return Column(
          children: [
            if (_shouldShowRecoveryNotice)
              _RecoveryNotice(
                message: _recoveryMessage,
                onRetry: onRefresh,
              ),
            ...widgetList.toList(),
          ],
        );
      }

      // ── Full-page mode: own scroll + pull-to-refresh ──
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              if (_shouldShowRecoveryNotice)
                _RecoveryNotice(
                  message: _recoveryMessage,
                  onRetry: onRefresh,
                ),
              ...widgetList.toList(),
            ],
          ),
        ),
      );
    });
  }

  bool get _shouldShowRecoveryNotice =>
      isStale?.value == true || (hasError.value && widgetList.isNotEmpty);

  String get _recoveryMessage => isStale?.value == true
      ? 'Showing saved content while reconnecting.'
      : errorMessage.value.isNotEmpty
          ? errorMessage.value
          : 'Content could not be refreshed. Saved content is still shown.';
}

class _RecoveryNotice extends StatelessWidget {
  const _RecoveryNotice({required this.message, this.onRetry});

  final String message;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined,
              size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodySmall),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
