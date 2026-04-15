import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:foduu_ecommerce/components/buttons/primary_action_button.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:get/get.dart';

class OnboardingView extends GetView<OnboardingController> {
  OnboardingView({Key? key}) : super(key: key);

  ColorScheme get colorScheme => Theme.of(Get.context!).colorScheme;
  TextTheme get textTheme => Theme.of(Get.context!).textTheme;

  final height = Get.height;
  final width = Get.width;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // PageView for swiping between onboarding screens
            PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.handlePageChange,
              itemCount: controller.totalPages,
              itemBuilder: (context, index) {
                return _buildPageContent(index);
              },
            ),

            // Bottom Overlay with Badge and White Container
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomOverlay(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(int index) {
    final pageContent = controller.getPageContent(index);

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(pageContent['image']!),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildBottomOverlay(BuildContext context) {
    return Obx(() {
      final height = Get.height;
      final width = Get.width;
      return Container(
        height: height * 0.61,
        width: width,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Badge
              // Container(
              //   height: height * 0.38,
              //   width: width,
              //   child: Image.asset(
              //     'assets/images/Badge.png',
              //     fit: BoxFit.contain,
              //   ),
              // ),

              SizedBox(height: height * 0.38),
              // White Container (25% of screen height - reduced)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        context.surfaceColor, // Changed to theme surface color
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15), // Reduced padding
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceEvenly, // Changed to spaceEvenly
                      children: [
                        // Page Indicator
                        _buildPageIndicator(),

                        SizedBox(height: 1),

                        // Description Text
                        _buildDescription(context),

                        // Full Width Button
                        _buildFooterButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
      );
    });
  }

  Widget _buildDescription(BuildContext context) {
    final pageContent = controller.getCurrentPageContent();

    return SizedBox(
      height: height * 0.08,
      child: SingleChildScrollView(
        child: Text(
          pageContent['description']!,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1.4,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8), // Reduced padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          controller.totalPages,
          (index) => Container(
            width: Get.width * 0.2, // Smaller sizes
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: controller.currentIndex.value == index
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterButton() {
    final isLastPage = controller.isLastPage;

    return PrimaryActionButton(
      text: isLastPage ? 'Get Started' : 'SKIP',
      onPressed: () {
        if (isLastPage) {
          controller.navigateToMainApp();
        } else {
          controller.goToPage(controller.currentIndex.value + 1);
        }
      },
    );
  }
}
