import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFEEECE8),
      body: Column(              // ✅ Column — no more Stack overlap
        children: [

          const SizedBox(height: 20,),

          // ── Image Area (top 53%) ────────────────────────────
          SizedBox(
            height: size.height * 0.53,
            width: double.infinity,
            child: PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              itemCount: controller.pages.length,
              itemBuilder: (_, index) => _OnboardingPage(
                item: controller.pages[index],
              ),
            ),
          ),

          // ── White Bottom Panel (remaining space) ────────────
          Expanded(
            child: _BottomPanel(),
          ),
        ],
      ),
    );
  }
}

// ── Onboarding Page ───────────────────────────────────────────────
class _OnboardingPage extends StatelessWidget {
  final OnboardingItem item;
  const _OnboardingPage({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Image.asset(
        item.imagePath,
        fit: BoxFit.contain,    // ✅ contain keeps phone mockup fully visible
      ),
    );
  }
}

// ── Bottom White Panel ────────────────────────────────────────────
class _BottomPanel extends GetView<OnboardingController> {
  const _BottomPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 420,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft:  Radius.circular(46),
          topRight: Radius.circular(46),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      child: Obx(() {
        final item   = controller.pages[controller.currentPage.value];
        final isLast = controller.isLastPage;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF000000),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              item.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFF666666),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),

            // ── Dot Indicators ────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                controller.pages.length,
                    (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width:  controller.currentPage.value == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: controller.currentPage.value == i
                        ? const Color(0xFF1A1A1A)
                        : const Color(0xFFD0D0D0),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // ── Next / Get Started Button ─────────────────────
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: controller.onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000000),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                ),
                child: Text(
                  isLast ? 'Get Started' : 'Next',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ),

            // ── Skip Button ───────────────────────────────────
            if (!isLast) ...[
              const SizedBox(height: 6),
              TextButton(
                onPressed: controller.onSkip,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF888888),  // ✅ fixed: was 0x000000 (transparent)
                  ),
                ),
              ),
            ] else
              const SizedBox(height: 18),
          ],
        );
      }),
    );
  }
}
