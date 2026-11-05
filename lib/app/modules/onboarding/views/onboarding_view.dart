import 'package:flutter/material.dart';
import 'package:foddu/app/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:foddu/components/app_network_image.dart';
import 'package:foddu/components/buttons/primary_action_button.dart';
import 'package:foddu/constants/dynamic_theme.dart';
import 'package:get/get.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background PageView Carousel (Full Screen Hero) ──────────
          Positioned.fill(
            child: Listener(
              onPointerDown: (_) => controller.pauseAutoPagination(),
              onPointerUp: (_) => controller.resumeAutoPagination(),
              onPointerCancel: (_) => controller.resumeAutoPagination(),
              child: Obx(
                () => PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: controller.handlePageChange,
                  itemCount: controller.totalPages,
                  itemBuilder: (context, index) {
                    return _buildPageContent(index);
                  },
                ),
              ),
            ),
          ),

          // ── Top-Right Quick Skip Button ──────────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 16),
                child: Obx(() {
                  if (controller.isLastPage) return const SizedBox.shrink();
                  return GestureDetector(
                    onTap: controller.handleSkipPress,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // ── Bottom Elevated Sheet Card (Luxury Styling) ──────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dynamic Expanding Pill Indicators
                    _buildPageIndicator(context),

                    const SizedBox(height: 18),

                    // Editorial Headline / Description
                    _buildDescription(context),

                    const SizedBox(height: 22),

                    // Dynamic Bottom Action Button from Backend
                    _buildFooterButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(int index) {
    return Obx(() {
      final slide = controller.getSlide(index);

      if (slide.isAsset || slide.fullImageUrl.isEmpty) {
        return Image.asset(
          slide.filePath.isNotEmpty
              ? slide.filePath
              : 'assets/images/womenAtOnboarding.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      }

      return AppNetworkImage(
        key: ValueKey('${slide.fullImageUrl}_$index'),
        url: slide.fullImageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: Container(
          color: const Color(0xFF1E1E1E),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        ),
        errorWidget: Image.asset(
          'assets/images/womenAtOnboarding.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    });
  }

  Widget _buildPageIndicator(BuildContext context) {
    return Obx(() {
      final colorScheme = Theme.of(context).colorScheme;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          controller.totalPages,
          (index) {
            final isSelected = controller.currentIndex.value == index;

            return GestureDetector(
              onTap: () => controller.goToPage(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: isSelected ? 28 : 8,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outlineVariant.withOpacity(0.6),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildDescription(BuildContext context) {
    return Obx(() {
      final colorScheme = Theme.of(context).colorScheme;
      final slide = controller.currentSlide;

      return SizedBox(
        height: 62,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.15),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Column(
              key: ValueKey<int>(controller.currentIndex.value),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (slide.heading.isNotEmpty) ...[
                  Text(
                    slide.heading,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
                Text(
                  slide.description,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: slide.heading.isNotEmpty ? 13 : 17,
                    fontWeight: slide.heading.isNotEmpty
                        ? FontWeight.w400
                        : FontWeight.w700,
                    height: 1.35,
                    letterSpacing: -0.2,
                    color: slide.heading.isNotEmpty
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildFooterButton() {
    return Obx(() {
      final isLastPage = controller.isLastPage;
      final slide = controller.currentSlide;

      // Prioritize backend provided button_text directly
      final buttonLabel = slide.buttonText.isNotEmpty
          ? slide.buttonText
          : (isLastPage ? 'Get Started' : 'Skip');

      return PrimaryActionButton(
        text: buttonLabel,
        onPressed: controller.handlePrimaryButtonPress,
      );
    });
  }
}
