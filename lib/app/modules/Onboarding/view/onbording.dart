import 'package:flutter/material.dart';
import '/app/modules/intro/controllers/intro_controller.dart';
import 'package:get/get.dart';

class onbording extends GetView<IntroController> {
  const onbording({Key? key}) : super(key: key);

  static const List<String> _bgImages = [
    'assets/images/onboarding_1.png',
    'assets/images/onboarding_2.png',
    'assets/images/onboarding_3.png',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [

          // ── 1. Background PageView ─────────────────────────────────
          PageView.builder(
            controller: controller.pageController,
            onPageChanged: (value) =>
            controller.selectedPageIndex.value = value,
            itemCount: controller.introPage.length,
            itemBuilder: (_, index) => Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(_bgImages[index], fit: BoxFit.cover),
                Container(color: Colors.black.withOpacity(0.35)),
              ],
            ),
          ),

          // ── 2. Floating card ───────────────────────────────────────
          Positioned(
            left: 20, right: 20, bottom: 40,
            child: Obx(() {
              final index = controller.selectedPageIndex.value;
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve:  Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.08, 0),
                    end:   Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: _OnboardingCard(
                  key: ValueKey(index),
                  index: index,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  introPage: controller.introPage,
                  totalPages: controller.introPage.length,
                  onSkip: controller.onProceedNext,
                  onNext: () => controller.pageController.animateToPage(
                    index + 1,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                  ),
                  onGetStarted: controller.onProceedNext,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Card — fixed size on all pages ───────────────────────────────────────────
class _OnboardingCard extends StatelessWidget {
  final int index;
  final List introPage;
  final int totalPages;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final VoidCallback onGetStarted;

  const _OnboardingCard({
    required super.key,
    required this.index,
    required this.introPage,
    required this.totalPages,
    required this.colorScheme,
    required this.textTheme,
    required this.onSkip,
    required this.onNext,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    final isLastPage = index + 1 == totalPages;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // ── Title ───────────────────────────────────────────────────
          Text(
            introPage[index]["title"].toString(),
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // ── Description ─────────────────────────────────────────────
          Text(
            introPage[index]["descrition"].toString(),
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // ── Page Dots ───────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalPages, (dotIndex) {
              final bool isActive = index == dotIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? colorScheme.primary
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),

          // ── Actions — fixed height keeps card same size on all pages ─
          SizedBox(
            height: 100, // ✅ tallest variant (last page) locks all pages
            child: isLastPage

            // Last page: Get Started + Register
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: onGetStarted,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Get Started',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey.shade500),
                    children: [
                      TextSpan(
                        text: 'Register',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )

            // Pages 1 & 2: Skip + Arrow
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'Skip',
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onNext,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(Icons.arrow_forward,
                        color: colorScheme.onPrimary, size: 24),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}