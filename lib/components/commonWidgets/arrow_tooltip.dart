import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

/// Direction the tooltip's pointer arrow faces toward the target widget.
enum ArrowDirection { top, bottom, left, right }

/// Industry-standard directional tooltip with a custom-painted arrow pointer.
///
/// Supports long-press / hover discovery and optional one-time onboarding
/// coachmarks persisted via [GetStorage].
class ArrowTooltip extends StatefulWidget {
  final String message;
  final Widget child;
  final ArrowDirection direction;
  final Color? backgroundColor;
  final Color? textColor;
  final Duration autoDismissDuration;
  final bool showOnLongPress;
  final bool showCoachmarkOnMount;
  final String? storageKey;
  final double maxWidth;

  const ArrowTooltip({
    super.key,
    required this.message,
    required this.child,
    this.direction = ArrowDirection.bottom,
    this.backgroundColor,
    this.textColor,
    this.autoDismissDuration = const Duration(milliseconds: 2200),
    this.showOnLongPress = true,
    this.showCoachmarkOnMount = false,
    this.storageKey,
    this.maxWidth = 220,
  });

  @override
  State<ArrowTooltip> createState() => ArrowTooltipState();
}

class ArrowTooltipState extends State<ArrowTooltip>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _dismissTimer;
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnim = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    if (widget.showCoachmarkOnMount && widget.storageKey != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final box = GetStorage();
        final seen = box.read(widget.storageKey!) == true;
        if (!seen) {
          box.write(widget.storageKey!, true);
          show();
        }
      });
    }
  }

  /// Programmatically displays the tooltip.
  void show() {
    if (!mounted || widget.message.trim().isEmpty) return;
    _removeOverlayImmediate();

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final targetSize = renderBox.size;
    final targetPos = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = widget.backgroundColor ?? colorScheme.inverseSurface;
    final fgColor = widget.textColor ?? colorScheme.onInverseSurface;

    _overlayEntry = OverlayEntry(
      builder: (ctx) => _TooltipOverlay(
        targetPos: targetPos,
        targetSize: targetSize,
        screenSize: screenSize,
        message: widget.message,
        direction: widget.direction,
        backgroundColor: bgColor,
        textColor: fgColor,
        maxWidth: widget.maxWidth,
        fadeAnim: _fadeAnim,
        scaleAnim: _scaleAnim,
        onDismiss: hide,
      ),
    );

    overlay.insert(_overlayEntry!);
    _animController.forward(from: 0);

    _dismissTimer?.cancel();
    _dismissTimer = Timer(widget.autoDismissDuration, hide);
  }

  /// Dismisses the tooltip with a reverse animation.
  Future<void> hide() async {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    if (_overlayEntry == null) return;
    if (mounted) {
      try {
        await _animController.reverse();
      } catch (_) {}
    }
    _removeOverlayImmediate();
  }

  void _removeOverlayImmediate() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlayImmediate();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPress: widget.showOnLongPress
            ? () {
                HapticFeedback.selectionClick();
                show();
              }
            : null,
        child: widget.child,
      ),
    );
  }
}

class _TooltipOverlay extends StatelessWidget {
  final Offset targetPos;
  final Size targetSize;
  final Size screenSize;
  final String message;
  final ArrowDirection direction;
  final Color backgroundColor;
  final Color textColor;
  final double maxWidth;
  final Animation<double> fadeAnim;
  final Animation<double> scaleAnim;
  final VoidCallback onDismiss;

  const _TooltipOverlay({
    required this.targetPos,
    required this.targetSize,
    required this.screenSize,
    required this.message,
    required this.direction,
    required this.backgroundColor,
    required this.textColor,
    required this.maxWidth,
    required this.fadeAnim,
    required this.scaleAnim,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    const double arrowHeight = 6.0;
    const double arrowWidth = 12.0;
    const double gap = 6.0;
    const double screenMargin = 12.0;

    final targetCenterX = targetPos.dx + targetSize.width / 2;
    final targetCenterY = targetPos.dy + targetSize.height / 2;

    // Estimate tooltip width so it stays clamped within viewport edges.
    final textPainter = TextPainter(
      text: TextSpan(
        text: message,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      maxLines: 2,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth - 24);

    final boxWidth = (textPainter.width + 24).clamp(64.0, maxWidth);
    final boxHeight = textPainter.height + 16;

    double left = targetCenterX - boxWidth / 2;
    left = left.clamp(screenMargin, screenSize.width - boxWidth - screenMargin);

    // Arrow offset relative to tooltip box left edge.
    final arrowX = (targetCenterX - left - arrowWidth / 2)
        .clamp(10.0, boxWidth - arrowWidth - 10.0);

    double top;
    if (direction == ArrowDirection.top) {
      // Tooltip sits below target; arrow points UP.
      top = targetPos.dy + targetSize.height + gap;
    } else if (direction == ArrowDirection.bottom) {
      // Tooltip sits above target; arrow points DOWN.
      top = targetPos.dy - boxHeight - arrowHeight - gap;
    } else {
      top = (targetCenterY - boxHeight / 2)
          .clamp(screenMargin, screenSize.height - boxHeight - screenMargin);
    }

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDismiss,
            child: const SizedBox.expand(),
          ),
        ),
        Positioned(
          left: left,
          top: top,
          child: IgnorePointer(
            child: FadeTransition(
              opacity: fadeAnim,
              child: ScaleTransition(
                scale: scaleAnim,
                alignment: direction == ArrowDirection.top
                    ? Alignment.topCenter
                    : Alignment.bottomCenter,
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (direction == ArrowDirection.top)
                        Padding(
                          padding: EdgeInsets.only(left: arrowX),
                          child: CustomPaint(
                            size: const Size(arrowWidth, arrowHeight),
                            painter: _ArrowPainter(
                              color: backgroundColor,
                              pointUp: true,
                            ),
                          ),
                        ),
                      Container(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                            height: 1.25,
                          ),
                        ),
                      ),
                      if (direction == ArrowDirection.bottom)
                        Padding(
                          padding: EdgeInsets.only(left: arrowX),
                          child: CustomPaint(
                            size: const Size(arrowWidth, arrowHeight),
                            painter: _ArrowPainter(
                              color: backgroundColor,
                              pointUp: false,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final Color color;
  final bool pointUp;

  const _ArrowPainter({required this.color, required this.pointUp});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    if (pointUp) {
      path.moveTo(0, size.height);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.pointUp != pointUp;
}
