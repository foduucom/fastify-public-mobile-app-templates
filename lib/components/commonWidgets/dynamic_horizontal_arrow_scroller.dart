import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A dynamic horizontal scroller wrapper that displays floating navigation
/// arrows on the left and right edges when content overflows.
///
/// Mirrors the smooth floating scroll action arrow pattern from Vision Infrastructure.
class DynamicHorizontalArrowScroller extends StatefulWidget {
  /// Builder receiving the [ScrollController] that must be attached to the inner
  /// horizontal scrollable (e.g., [ListView], [SingleChildScrollView]).
  final Widget Function(BuildContext context, ScrollController scrollController) builder;

  /// Optional external [ScrollController]. If null, this widget creates, manages,
  /// and disposes its own controller.
  final ScrollController? controller;

  /// Pixels to scroll on each arrow tap.
  final double scrollStep;

  /// Diameter of the circular arrow button.
  final double arrowSize;

  /// Size of the chevron icon.
  final double iconSize;

  /// Distance from the horizontal outer edge.
  final double edgePadding;

  /// Optional item count dependency to trigger recalculation when data changes.
  final int? itemCount;

  /// Whether to trigger a light haptic feedback on arrow tap.
  final bool enableHaptics;

  /// Custom background color for the button. Defaults to theme surface color.
  final Color? buttonColor;

  /// Custom icon color for the button. Defaults to theme onSurface color.
  final Color? iconColor;

  const DynamicHorizontalArrowScroller({
    super.key,
    required this.builder,
    this.controller,
    this.scrollStep = 260.0,
    this.arrowSize = 36.0,
    this.iconSize = 22.0,
    this.edgePadding = 4.0,
    this.itemCount,
    this.enableHaptics = true,
    this.buttonColor,
    this.iconColor,
  });

  @override
  State<DynamicHorizontalArrowScroller> createState() =>
      _DynamicHorizontalArrowScrollerState();
}

class _DynamicHorizontalArrowScrollerState
    extends State<DynamicHorizontalArrowScroller> {
  ScrollController? _internalController;
  ScrollController get _effectiveController =>
      widget.controller ?? _internalController!;

  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = ScrollController();
    }
    _effectiveController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollArrows());
  }

  @override
  void didUpdateWidget(covariant DynamicHorizontalArrowScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onScroll);
      if (widget.controller == null) {
        _internalController ??= ScrollController();
      } else {
        _internalController?.dispose();
        _internalController = null;
      }
      _effectiveController.addListener(_onScroll);
    }
    if (widget.itemCount != oldWidget.itemCount) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _updateScrollArrows());
    }
  }

  void _onScroll() {
    _updateScrollArrows();
  }

  void _updateScrollArrows() {
    if (!mounted || !_effectiveController.hasClients) return;
    try {
      final pos = _effectiveController.position;
      final maxScroll = pos.maxScrollExtent;
      final canLeft = pos.pixels > 10;
      final canRight = maxScroll > 0 && pos.pixels < (maxScroll - 10);
      if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
        setState(() {
          _canScrollLeft = canLeft;
          _canScrollRight = canRight;
        });
      }
    } catch (_) {
      // Catch possible scroll position attachment transitions
    }
  }

  void _scrollLeft() {
    if (!_effectiveController.hasClients) return;
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
    final target = (_effectiveController.offset - widget.scrollStep)
        .clamp(0.0, _effectiveController.position.maxScrollExtent);
    _effectiveController.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  void _scrollRight() {
    if (!_effectiveController.hasClients) return;
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
    final target = (_effectiveController.offset + widget.scrollStep)
        .clamp(0.0, _effectiveController.position.maxScrollExtent);
    _effectiveController.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController?.removeListener(_onScroll);
      _internalController?.dispose();
    } else {
      widget.controller?.removeListener(_onScroll);
    }
    super.dispose();
  }

  Widget _buildFloatingArrow({
    required IconData icon,
    required bool isVisible,
    required VoidCallback onTap,
    required bool isLeft,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultBgColor = widget.buttonColor ??
        (isDark
            ? theme.colorScheme.surface.withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.95));

    final defaultIconColor = widget.iconColor ?? theme.colorScheme.onSurface;

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      child: IgnorePointer(
        ignoring: !isVisible,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.16),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: defaultBgColor,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                width: widget.arrowSize,
                height: widget.arrowSize,
                child: Center(
                  child: Icon(
                    icon,
                    size: widget.iconSize,
                    color: defaultIconColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis == Axis.horizontal) {
          _updateScrollArrows();
        }
        return false;
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          widget.builder(context, _effectiveController),
          // Left dynamic floating action arrow button
          Positioned(
            left: widget.edgePadding,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildFloatingArrow(
                icon: Icons.chevron_left_rounded,
                isVisible: _canScrollLeft,
                onTap: _scrollLeft,
                isLeft: true,
              ),
            ),
          ),
          // Right dynamic floating action arrow button
          Positioned(
            right: widget.edgePadding,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildFloatingArrow(
                icon: Icons.chevron_right_rounded,
                isVisible: _canScrollRight,
                onTap: _scrollRight,
                isLeft: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

