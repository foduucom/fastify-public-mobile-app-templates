import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foduu_ecommerce/components/commonWidgets/arrow_tooltip.dart';

/// A dynamic horizontal scroller wrapper that displays floating navigation
/// arrows on the left and right edges when content overflows, with smooth
/// scale + slide + fade transitions and optional edge fade scrims.
class DynamicHorizontalArrowScroller extends StatefulWidget {
  /// Builder receiving the [ScrollController] that must be attached to the inner
  /// horizontal scrollable (e.g., [ListView], [SingleChildScrollView]).
  final Widget Function(BuildContext context, ScrollController scrollController)
      builder;

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

  /// Whether to render soft edge fade scrims when scrollable.
  final bool showEdgeFade;

  /// Width of the edge fade scrims.
  final double edgeFadeWidth;

  const DynamicHorizontalArrowScroller({
    super.key,
    required this.builder,
    this.controller,
    this.scrollStep = 260.0,
    this.arrowSize = 34.0,
    this.iconSize = 20.0,
    this.edgePadding = 4.0,
    this.itemCount,
    this.enableHaptics = true,
    this.buttonColor,
    this.iconColor,
    this.showEdgeFade = true,
    this.edgeFadeWidth = 22.0,
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
      final canLeft = pos.pixels > 8;
      final canRight = maxScroll > 0 && pos.pixels < (maxScroll - 8);
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
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
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
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
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

  Widget _buildEdgeFade({required bool isLeft, required bool isVisible}) {
    final surface = Theme.of(context).colorScheme.surface;
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: widget.edgeFadeWidth,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
              end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
              colors: [
                surface.withOpacity(0.88),
                surface.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingArrow({
    required IconData icon,
    required bool isVisible,
    required VoidCallback onTap,
    required bool isLeft,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final defaultBgColor = widget.buttonColor ??
        (isDark
            ? colorScheme.surface.withOpacity(0.94)
            : colorScheme.surface.withOpacity(0.96));

    final defaultIconColor = widget.iconColor ?? colorScheme.onSurface;

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: isVisible
            ? Offset.zero
            : Offset(isLeft ? -0.25 : 0.25, 0.0),
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        child: AnimatedScale(
          scale: isVisible ? 1.0 : 0.78,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutBack,
          child: IgnorePointer(
            ignoring: !isVisible,
            child: ArrowTooltip(
              message: isLeft ? 'Scroll left' : 'Scroll right',
              direction: ArrowDirection.bottom,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.16),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(isDark ? 0.35 : 0.14),
                      blurRadius: 10,
                      spreadRadius: 0.5,
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
          if (widget.showEdgeFade) ...[
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _buildEdgeFade(isLeft: true, isVisible: _canScrollLeft),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: _buildEdgeFade(isLeft: false, isVisible: _canScrollRight),
            ),
          ],
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
