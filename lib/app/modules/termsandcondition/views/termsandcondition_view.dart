import 'package:flutter/material.dart';
import 'package:foddu/app_colors.dart';
import 'package:get/get.dart';


import '../../../../components/app_bar/custom_app_bar.dart';
import '../../../../components/shimmer1/app_shimmer.dart';
import '../controllers/termsandcondition_controller.dart';


class TermsConditionsView extends StatelessWidget {
  const TermsConditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TermsConditionsController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),


            AppTopBar(title: 'Term & Conditions',),
            const SizedBox(height: 24),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return  _TermsShimmer();
                }

                return Scrollbar(
                  thickness: 3,
                  radius:    const Radius.circular(8),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    itemCount: controller.blocks.length,
                    itemBuilder: (_, i) {
                      final block = controller.blocks[i];
                      return block.type == 'heading'
                          ? _HeadingBlock(text: block.text,
                          addTopSpacing: i != 0)
                          : _ParagraphBlock(text: block.text);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeadingBlock extends StatelessWidget {
  final String text;
  final bool   addTopSpacing;

  const _HeadingBlock({
    required this.text,
    this.addTopSpacing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top:    addTopSpacing ? 28 : 0,
        bottom: 12,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize:   16,
          fontWeight: FontWeight.w700,
          color:      Color(0xFF1A1A1A),
          height:     1.4,
        ),
      ),
    );
  }
}

// ── Paragraph Block ───────────────────────────────────────────────
class _ParagraphBlock extends StatelessWidget {
  final String text;
  const _ParagraphBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF9E9E9E),
          height: 1.75,
        ),
      ),
    );
  }
}

// ── Terms & Conditions Shimmer ─────────────────────────────────
class _TermsShimmer extends StatelessWidget {
  const _TermsShimmer();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Block 1 — heading + 2 paragraphs
          ShimmerBox(width: 180, height: 14, radius: 7),
          const SizedBox(height: 16),
          ShimmerBox.full(height: 11, radius: 6),
          const SizedBox(height: 6),
          ShimmerBox.full(height: 11, radius: 6),
          const SizedBox(height: 6),
          ShimmerBox(width: 260, height: 11, radius: 6),
          const SizedBox(height: 20),
          ShimmerBox.full(height: 11, radius: 6),
          const SizedBox(height: 6),
          ShimmerBox.full(height: 11, radius: 6),
          const SizedBox(height: 6),
          ShimmerBox(width: 200, height: 11, radius: 6),

          // Block 2 — heading + 2 paragraphs
          const SizedBox(height: 28),
          ShimmerBox(width: 220, height: 14, radius: 7),
          const SizedBox(height: 16),
          ShimmerBox.full(height: 11, radius: 6),
          const SizedBox(height: 6),
          ShimmerBox.full(height: 11, radius: 6),
          const SizedBox(height: 6),
          ShimmerBox(width: 240, height: 11, radius: 6),
          const SizedBox(height: 20),
          ShimmerBox.full(height: 11, radius: 6),
          const SizedBox(height: 6),
          ShimmerBox(width: 180, height: 11, radius: 6),

          // Block 3 — heading + 2 paragraphs
          const SizedBox(height: 28),
          ShimmerBox(width: 160, height: 14, radius: 7),
          const SizedBox(height: 16),
          ShimmerBox.full(height: 11, radius: 6),
          const SizedBox(height: 6),
          ShimmerBox.full(height: 11, radius: 6),
          const SizedBox(height: 6),
          ShimmerBox(width: 210, height: 11, radius: 6),
          const SizedBox(height: 20),
          ShimmerBox.full(height: 11, radius: 6),
          const SizedBox(height: 6),
          ShimmerBox(width: 150, height: 11, radius: 6),

          // Block 4 — heading + 1 paragraph
          const SizedBox(height: 28),
          ShimmerBox(width: 200, height: 14, radius: 7),
          const SizedBox(height: 16),
          ShimmerBox.full(height: 11, radius: 6),
          const SizedBox(height: 6),
          ShimmerBox.full(height: 11, radius: 6),
          const SizedBox(height: 6),
          ShimmerBox(width: 190, height: 11, radius: 6),
        ],
      ),
    );
  }
}

