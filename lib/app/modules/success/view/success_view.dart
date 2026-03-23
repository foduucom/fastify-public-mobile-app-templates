import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/app_bar/custom_app_bar.dart';

class OrderSuccessView extends StatefulWidget {
  const OrderSuccessView({super.key});

  @override
  State<OrderSuccessView> createState() => _OrderSuccessViewState();
}

class _OrderSuccessViewState extends State<OrderSuccessView>
    with TickerProviderStateMixin {

  late AnimationController _badgeCtrl;
  late AnimationController _confettiCtrl;
  late AnimationController _textCtrl;

  late Animation<double> _badgeScale;
  late Animation<double> _badgeFade;
  late Animation<double> _textFade;
  late Animation<Offset>  _textSlide;

  // Confetti pieces data
  final List<_ConfettiPiece> _pieces = [];
  late Animation<double> _confettiAnim;

  // Order data passed via Get.arguments
  String get _orderNo =>
      (Get.arguments as Map?)?['order_no']?.toString() ?? '';

  @override
  void initState() {
    super.initState();
    _generateConfetti();

    // ── Badge pop animation ───────────────────────────────────
    _badgeCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 600),
    );
    _badgeScale = CurvedAnimation(
      parent: _badgeCtrl,
      curve:  Curves.elasticOut,
    );
    _badgeFade = CurvedAnimation(
      parent: _badgeCtrl,
      curve:  Curves.easeIn,
    );

    // ── Confetti fall animation ───────────────────────────────
    _confettiCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 2200),
    );
    _confettiAnim = CurvedAnimation(
      parent: _confettiCtrl,
      curve:  Curves.easeOut,
    );

    // ── Text slide-up animation ───────────────────────────────
    _textCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 500),
    );
    _textFade = CurvedAnimation(
      parent: _textCtrl,
      curve:  Curves.easeIn,
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end:   Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textCtrl,
      curve:  Curves.easeOut,
    ));

    // ── Sequence: badge → confetti → text ────────────────────
    _badgeCtrl.forward().then((_) {
      _confettiCtrl.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _textCtrl.forward();
      });
    });
  }

  void _generateConfetti() {
    final rng = Random();
    final colors = [
      const Color(0xFFFFD700), // gold
      const Color(0xFF7C5CBF), // purple
      const Color(0xFF4CAF82), // green
      const Color(0xFFE91E8C), // pink
      const Color(0xFF2196F3), // blue
      const Color(0xFFFF5722), // orange
    ];
    for (int i = 0; i < 48; i++) {
      _pieces.add(_ConfettiPiece(
        x:      rng.nextDouble(),
        y:      rng.nextDouble() * 0.7,
        color:  colors[rng.nextInt(colors.length)],
        size:   rng.nextDouble() * 10 + 6,
        angle:  rng.nextDouble() * pi * 2,
        isRect: rng.nextBool(),
        speed:  rng.nextDouble() * 0.4 + 0.6,
        sway:   (rng.nextDouble() - 0.5) * 0.08,
      ));
    }
  }

  @override
  void dispose() {
    _badgeCtrl.dispose();
    _confettiCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFEEECE8),
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(title: 'Help & Support',),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _confettiAnim,
                    builder: (_, __) => CustomPaint(
                      size: Size(size.width, size.height * 0.65),
                      painter: _ConfettiPainter(
                        pieces:   _pieces,
                        progress: _confettiAnim.value,
                      ),
                    ),
                  ),

                  // ── Center content ────────────────────────
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _badgeScale,
                        child: FadeTransition(
                          opacity: _badgeFade,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1A1A1A),
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval( // ✅ ensures image stays circular
                              child: Padding(
                                padding: const EdgeInsets.all(20), // adjust spacing
                                child: Image.asset(
                                  'assets/images/logo_success.png', // 🔁 your actual path
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // ── Text ──────────────────────────────
                      SlideTransition(
                        position: _textSlide,
                        child: FadeTransition(
                          opacity: _textFade,
                          child: Column(
                            children: [
                              const Text('Order Successful!',
                                  style: TextStyle(
                                      fontSize:   26,
                                      fontWeight: FontWeight.w800,
                                      color:      Color(0xFF1A1A1A))),
                              const SizedBox(height: 10),
                              const Text(
                                'You have successfully made order',
                                style: TextStyle(
                                    fontSize: 14,
                                    color:    Color(0xFF9E9E9E),
                                    height:   1.5),
                              ),
                              if (_orderNo.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.circular(50),
                                  ),
                                  child: Text(
                                    '# $_orderNo',
                                    style: const TextStyle(
                                        fontSize:   13,
                                        fontWeight: FontWeight.w700,
                                        color:      Color(0xFF1A1A1A),
                                        letterSpacing: 0.5),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                children: [

                  // View Order
                  SizedBox(
                    width:  double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () =>
                          Get.toNamed('/orders'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A1A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(50)),
                      ),
                      child: const Text('View Order',
                          style: TextStyle(
                              fontSize:   16,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Back to Home
                  SizedBox(
                    width:  double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => Get.offAllNamed('/home'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1A1A1A),
                        side: const BorderSide(
                            color: Color(0xFFD0CEC9), width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(50)),
                      ),
                      child: const Text('Back to home',
                          style: TextStyle(
                              fontSize:   16,
                              fontWeight: FontWeight.w600,
                              color:      Color(0xFF1A1A1A))),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Confetti Data Model ───────────────────────────────────────────
class _ConfettiPiece {
  final double x, y, size, angle, speed, sway;
  final Color  color;
  final bool   isRect;

  const _ConfettiPiece({
    required this.x,
    required this.y,
    required this.size,
    required this.angle,
    required this.speed,
    required this.sway,
    required this.color,
    required this.isRect,
  });
}

// ── Confetti Painter ──────────────────────────────────────────────
class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> pieces;
  final double progress;

  const _ConfettiPainter({
    required this.pieces,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in pieces) {
      final fallY  = p.y + progress * p.speed * 0.85;
      final swayX  = p.x + sin(progress * pi * 2 + p.angle) * p.sway;
      final opacity = (1.0 - (fallY - 0.6).clamp(0.0, 1.0) / 0.4)
          .clamp(0.0, 1.0);

      if (fallY > 1.1 || opacity <= 0) continue;

      final dx     = swayX * size.width;
      final dy     = fallY * size.height;
      final rotate = p.angle + progress * pi * 3;

      paint.color = p.color.withOpacity(opacity);

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(rotate);

      if (p.isRect) {
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero,
              width:  p.size,
              height: p.size * 0.55),
          paint,
        );
      } else {
        // Ribbon / line piece
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset.zero,
                width:  p.size * 0.35,
                height: p.size * 1.4),
            const Radius.circular(2),
          ),
          paint,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) =>
      old.progress != progress;
}
