import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/modules/intro/controllers/intro_controller.dart';

class IntroView extends GetView<IntroController> {
  const IntroView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("GRACPSURT" , style: TextStyle(color: colorScheme.onSurface, fontSize: 32, fontWeight: FontWeight.w600),),
            // ── Logo ─────────────────────────────────────────────────
            // Image.asset(
            //   'assets/images/app_logo.png',
            //   width: 140,
            //   color: colorScheme.onPrimary,
            // ),
            const SizedBox(height: 32),

            // ── Loading indicator ─────────────────────────────────────
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: colorScheme.onPrimary,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}