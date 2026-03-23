import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/app_bar/custom_app_bar.dart';
import '../../../../components/shimmer1/app_shimmer.dart';
import '../controllers/helpandsupport_controller.dart';

class HelpSupportView extends StatelessWidget {
  const HelpSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HelpSupportController());

    return Scaffold(
      backgroundColor: const Color(0xFFEEECE8),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            AppTopBar(title: 'Help & Support',),
            const SizedBox(height: 20),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SearchBar(controller: controller),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: Obx(() {
                // ✅ NEW
                if (controller.isLoading.value) {
                  return const _HelpShimmer();
                }


                final faqs = controller.filteredFaqs;
                if (faqs.isEmpty) {
                  return const Center(
                    child: Text('No results found',
                        style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF9E9E9E))),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: faqs.length,
                  itemBuilder: (_, i) => Obx(() {
                    final isOpen = controller.expandedIndex.value == i;
                    return _FaqItem(
                      title:    faqs[i]['title']  ?? '',
                      answer:   faqs[i]['answer'] ?? '',
                      isOpen:   isOpen,
                      isLast:   i == faqs.length - 1,
                      onTap:    () => controller.toggleExpand(i),
                    );
                  }),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

}

// ── Search Bar ────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final HelpSupportController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          const Icon(Icons.search_rounded,
              size: 22, color: Color(0xFFB0AEAB)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: controller.onSearch,
              style: const TextStyle(
                  fontSize: 15, color: Color(0xFF1A1A1A)),
              decoration: const InputDecoration(
                hintText: 'Search language',
                hintStyle: TextStyle(
                    fontSize: 15, color: Color(0xFFB0AEAB)),
                border:        InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String title;
  final String answer;
  final bool isOpen;
  final bool isLast;
  final VoidCallback onTap;

  const _FaqItem({
    required this.title,
    required this.answer,
    required this.isOpen,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedRotation(
                  turns:    isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Answer (animated expand) ─────────────────────────
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          firstCurve:  Curves.easeOut,
          secondCurve: Curves.easeIn,
          crossFadeState: isOpen
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF9E9E9E),
                height: 1.6,
              ),
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),

        // ── Divider ───────────────────────────────────────────
        if (!isLast)
          Container(height: 1, color: const Color(0xFFDEDCDA)),
      ],
    );
  }
}
// ── Help & Support Shimmer ────────────────────────────────────────
class _HelpShimmer extends StatelessWidget {
  const _HelpShimmer();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 7,
        separatorBuilder: (_, __) => Container(
          height: 1,
          color: const Color(0xFFDEDCDA),
        ),
        itemBuilder: (_, i) => _FaqRowShimmer(
          // every 3rd item show an expanded answer block
          expanded: i == 1,
        ),
      ),
    );
  }
}

class _FaqRowShimmer extends StatelessWidget {
  final bool expanded;
  const _FaqRowShimmer({this.expanded = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox.full(height: 13, radius: 6),
                    if (expanded) ...[
                      const SizedBox(height: 6),
                      ShimmerBox(width: 200, height: 13, radius: 6),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Arrow icon placeholder
              const ShimmerCircle(size: 22),
            ],
          ),

          // Expanded answer block
          if (expanded) ...[
            const SizedBox(height: 16),
            ShimmerBox.full(height: 11, radius: 6),
            const SizedBox(height: 6),
            ShimmerBox.full(height: 11, radius: 6),
            const SizedBox(height: 6),
            ShimmerBox(width: 220, height: 11, radius: 6),
            const SizedBox(height: 6),
            ShimmerBox(width: 180, height: 11, radius: 6),
          ],
        ],
      ),
    );
  }
}

