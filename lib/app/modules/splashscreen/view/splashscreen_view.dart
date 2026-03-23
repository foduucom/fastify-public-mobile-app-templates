import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/splash_controller.dart';

// ✅ StatelessWidget — NOT GetView
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Directly puts and creates controller immediately
    Get.put(SplashController());

    return Scaffold(
      backgroundColor: const Color(0xFFECE8E5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Logo ────────────────────────────────────────────
            Image.asset(
              'assets/images/splash_logo.png',
              width: 134.16,
              height: 135,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),

            // ── App Name ────────────────────────────────────────
            const Text(
              'ROOMORA',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w500,
                color: Color(0xFF000000),
                letterSpacing: -2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
