import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app_colors.dart';

class AiRoomoaView extends StatefulWidget {
  const AiRoomoaView({super.key});

  @override
  State<AiRoomoaView> createState() => _AiRoomoaViewState();
}

class _AiRoomoaViewState extends State<AiRoomoaView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final Animation<double> _rotationAnim;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(); // ✅ Slow infinite rotation of the starburst

    _rotationAnim = Tween<double>(begin: 0, end: 2 * pi)
        .animate(_rotationController);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildTopBar(),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  _buildStarburstLogo(),
                  const SizedBox(height: 48),

                  // ── Title ─────────────────────────────────────
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Buy Furniture Smarter with AI',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Subtitle ──────────────────────────────────
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "Tell me your style or need I'll find the best deals and products just for you.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9E9E9E),
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Get Started Button ────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () => Get.toNamed('/aichat'), // ✅ clean single line
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A1A),
                          foregroundColor: AppColors.scaffoldBackground,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Profile Avatar
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.scaffoldBackground,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/profile_avatar.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.person,
                color: Color(0xFF9E9E9E),
                size: 28,
              ),
            ),
          ),

          const Spacer(),

          // Notification Button
          _IconCircleButton(
            icon: Icons.notifications_outlined,
            onTap: () => Get.toNamed('/notification'),
          ),
          const SizedBox(width: 10),

          // Cart Button
          _IconCircleButton(
            icon: Icons.shopping_basket_outlined,
            onTap: () => Get.toNamed('/cart'),
          ),
        ],
      ),
    );
  }

  // ── Animated Starburst + Logo ──────────────────────────────────
  Widget _buildStarburstLogo() {
    return SizedBox(
      width: 280,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [

          // ── Rotating Starburst ───────────────────────────────
          AnimatedBuilder(
            animation: _rotationAnim,
            builder: (_, __) => Transform.rotate(
              angle: _rotationAnim.value,
              child: CustomPaint(
                size: const Size(280, 250),
                painter: _StarburstPainter(),
              ),
            ),
          ),

          // ── Outer Dark Ring ───────────────────────────────────
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF3A3A3A),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),

          // ── Inner Light Circle ────────────────────────────────
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE8E6E2),
            ),
          ),

          // ── Logo Image ────────────────────────────────────────
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/splash_logo.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE8E6E2),
                ),
                child: const Icon(
                  Icons.home_work_outlined,
                  size: 52,
                  color: Color(0xFF6B6B6B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Starburst Painter ──────────────────────────────────────────────
class _StarburstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = size.width * 0.30;

    const totalRays = 60;

    for (int i = 0; i < totalRays; i++) {
      final angle = (2 * pi / totalRays) * i;

      // Alternate between long and short rays
      final isLong = i % 2 == 0;
      final endRadius = isLong ? outerRadius : outerRadius * 0.82;

      final startX = center.dx + innerRadius * cos(angle);
      final startY = center.dy + innerRadius * sin(angle);
      final endX   = center.dx + endRadius  * cos(angle);
      final endY   = center.dy + endRadius  * sin(angle);

      // Fade out towards edges
      final opacity = isLong ? 0.35 : 0.18;

      final paint = Paint()
        ..color = const Color(0xFF6B6B6B).withOpacity(opacity)
        ..strokeWidth = isLong ? 1.2 : 0.8
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Icon Circle Button ─────────────────────────────────────────────
class _IconCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconCircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color:AppColors.scaffoldBackground,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22, color: const Color(0xFF1A1A1A)),
      ),
    );
  }
}
