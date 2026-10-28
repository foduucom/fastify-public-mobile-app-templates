import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zouhi/app/data/models/solutions_sections.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';
import '../controllers/solutions_controller.dart';

class SolutionsView extends GetView<SolutionsController> {
  const SolutionsView({Key? key}) : super(key: key);

  String _imageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (path.startsWith('assets/images/')) return '$url$path';
    return HelperFunctions().getImage(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeBackground,
      appBar: AppBar(
        title: const Text(
          'Solutions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Contact Team',
            icon: const Icon(Icons.headset_mic_outlined),
            onPressed: () => Get.toNamed(Routes.CONTACT),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.rawSections.isEmpty) {
          return _buildShimmerLoading(context);
        }

        final data = controller.data.value;

        return RefreshIndicator(
          onRefresh: controller.fetchSolutions,
          color: context.themePrimaryColor,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 36),
            children: [
              _buildHeader(context, data.header),
              _buildIntro(context, data.intro),
              _buildIndustrySolutions(context, data.byIndustry),
              _buildCapabilities(context, data.byNeed),
              _buildCta(context, data.cta),
            ],
          ),
        );
      }),
    );
  }

  // ─── 1. BANNER HEADER ──────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, SolutionsBannerHeader header) {
    return Container(
      width: double.infinity,
      height: header.height,
      decoration: BoxDecoration(
        color: const Color(0xFF12253D),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0A192D).withValues(alpha: 0.85),
            const Color(0xFF16324F).withValues(alpha: 0.92),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (header.imageUrl.isNotEmpty)
            Opacity(
              opacity: 0.22,
              child: CachedNetworkImage(
                imageUrl: _imageUrl(header.imageUrl),
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Solutions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 42,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00ADEF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 2. WHAT WE DELIVER (SOLUTIONS INTRO) ──────────────────────────
  Widget _buildIntro(BuildContext context, SolutionsIntroSection intro) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: context.themeWhiteColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.themeBorderColor.withValues(alpha: 0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (intro.imageUrl.isNotEmpty)
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: _imageUrl(intro.imageUrl),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 200,
                      color: Colors.black12,
                    ),
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.25),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (intro.eyebrow.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.themePrimaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        intro.eyebrow.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: context.themePrimaryColor,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    intro.title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18.5,
                      fontWeight: FontWeight.w700,
                      color: context.themeTextColor,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    intro.description,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      height: 1.55,
                      color: context.themeSecondrytext,
                    ),
                  ),
                  if (intro.statItem.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: context.themePrimaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: context.themePrimaryColor.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.domain_verification_rounded,
                            size: 20,
                            color: context.themePrimaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            intro.statItem,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: context.themePrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.toNamed(Routes.CONTACT),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.themePrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        intro.buttonText.isNotEmpty
                            ? intro.buttonText
                            : 'Talk To Our Team',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
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

  // ─── 3. SOLUTIONS BY INDUSTRY ──────────────────────────────────────
  Widget _buildIndustrySolutions(
      BuildContext context, SolutionsByIndustrySection section) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.eyebrow.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: context.themePrimaryLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                section.eyebrow.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: context.themePrimaryColor,
                ),
              ),
            ),
          const SizedBox(height: 6),
          Text(
            section.title.isNotEmpty
                ? section.title
                : 'Built For Every Environment',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 19.5,
              fontWeight: FontWeight.w700,
              color: context.themeTextColor,
            ),
          ),
          if (section.subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              section.subtitle,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: context.themeSecondrytext,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 18),
          ...section.cards.map((ind) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: context.themeWhiteColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.themeBorderColor.withValues(alpha: 0.6),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover Graphic
                  Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: _imageUrl(ind.coverImageUrl),
                        height: 155,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          height: 155,
                          color: const Color(0xFFE2E8F0),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          height: 155,
                          color: context.themePrimaryLight,
                          child: Center(
                            child: Icon(
                              ind.fallbackIcon,
                              size: 40,
                              color: context.themePrimaryColor,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          width: 38,
                          height: 38,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: context.themePrimaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: ind.iconUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: _imageUrl(ind.iconUrl),
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.contain,
                                  color: Colors.white,
                                  errorWidget: (_, __, ___) => Icon(
                                    ind.fallbackIcon,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  ind.fallbackIcon,
                                  size: 18,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ],
                  ),
                  // Content details
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ind.title,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: context.themeTextColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ind.description,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.5,
                            color: context.themeSecondrytext,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 14),
                        InkWell(
                          onTap: () {
                            BottombarController.switchTab(1, arguments: {
                              'name': ind.categoryName,
                              'categorySlug': ind.categorySlug,
                              'source': 'category',
                            });
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Explore Products',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: context.themePrimaryColor,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: context.themePrimaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── 4. SOLUTIONS BY NEED (CAPABILITIES) ────────────────────────────
  Widget _buildCapabilities(
      BuildContext context, SolutionsByNeedSection section) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.eyebrow.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: context.themePrimaryLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                section.eyebrow.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: context.themePrimaryColor,
                ),
              ),
            ),
          const SizedBox(height: 6),
          Text(
            section.title.isNotEmpty
                ? section.title
                : 'Whatever The Challenge, We Have A Solution',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 19.5,
              fontWeight: FontWeight.w700,
              color: context.themeTextColor,
            ),
          ),
          if (section.subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              section.subtitle,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: context.themeSecondrytext,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 16),
          ...section.cards.map((cap) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.themeWhiteColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: context.themeBorderColor.withValues(alpha: 0.6),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.themePrimaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: cap.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: _imageUrl(cap.imageUrl),
                            fit: BoxFit.contain,
                            color: context.themePrimaryColor,
                            errorWidget: (_, __, ___) => Icon(
                              cap.fallbackIcon,
                              size: 24,
                              color: context.themePrimaryColor,
                            ),
                          )
                        : Icon(
                            cap.fallbackIcon,
                            size: 24,
                            color: context.themePrimaryColor,
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cap.title,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: context.themeTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cap.description,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.5,
                            height: 1.45,
                            color: context.themeSecondrytext,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── 5. PROJECT CONSULTATION CTA ────────────────────────────────────
  Widget _buildCta(BuildContext context, SolutionsConsultationCta cta) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.themePrimaryColor,
              themePrimaryDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: context.themePrimaryColor.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cta.heading.isNotEmpty
                  ? cta.heading
                  : 'Not Sure Which Solution Fits Your Project?',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              cta.description.isNotEmpty
                  ? cta.description
                  : 'Tell us about your site and requirements — our engineers will recommend the right infrastructure and a bill of materials to match.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () => Get.toNamed(Routes.CONTACT),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: context.themePrimaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                cta.buttonText.isNotEmpty
                    ? cta.buttonText
                    : 'Request A Consultation',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: context.themePrimaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── SHIMMER LOADING PLACEHOLDER ───────────────────────────────────
  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }
}
