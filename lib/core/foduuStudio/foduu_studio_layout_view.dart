import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
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
  final RxBool? hasError;
  final RxString? errorMessage;
  final RxBool? isStale;

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
    this.hasError,
    this.errorMessage,
    this.isStale,
    this.embedded = false,
  });

  /// Embedded constructor — no scroll wrapper, safe inside Column/ListView.
  const FoduuStudioLayoutView.embedded({
    super.key,
    required this.widgetList,
    required this.isLoading,
    this.hasError,
    this.errorMessage,
    this.isStale,
    this.onRefresh,
  }) : embedded = true;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoading.value && widgetList.isEmpty) {
        return const _HomeBoutiqueSkeleton();
      }

      if (hasError?.value == true && widgetList.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  errorMessage?.value.isNotEmpty == true
                      ? errorMessage!.value
                      : 'Unable to load this content.',
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

      if (widgetList.isEmpty) {
        return const SizedBox.shrink();
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
          padding: const EdgeInsets.only(top: 8.0, bottom: 44.0),
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
      isStale?.value == true ||
      (hasError?.value == true && widgetList.isNotEmpty);

  String get _recoveryMessage => isStale?.value == true
      ? 'Showing saved content while reconnecting.'
      : 'Content could not be refreshed. Your saved content is still shown.';
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
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 18,
            color: scheme.onSecondaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: TextStyle(color: scheme.onSecondaryContainer)),
          ),
          if (onRetry != null)
            IconButton(
              tooltip: 'Retry',
              visualDensity: VisualDensity.compact,
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
            ),
        ],
      ),
    );
  }
}

class _HomeBoutiqueSkeleton extends StatelessWidget {
  const _HomeBoutiqueSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Hero banner placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 380,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Circular categories row placeholder
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, __) => Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 50,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 2-column product grid placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (_, __) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 120,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 60,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
