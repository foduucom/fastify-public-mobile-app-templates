import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zouhi/app/data/models/page_model.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/theme_ext.dart';
import '../controllers/solutions_controller.dart';

class SolutionsView extends GetView<SolutionsController> {
  const SolutionsView({Key? key}) : super(key: key);

  String _imageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return path.startsWith('/') ? '$url${path.substring(1)}' : '$url$path';
  }

  String _stripHtml(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
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
        if (controller.isLoading.value && controller.components.isEmpty) {
          return _buildShimmerLoading(context);
        }
        if (controller.components.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.themePrimaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_off_rounded,
                      size: 36,
                      color: context.themePrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.error.value.isNotEmpty
                        ? controller.error.value
                        : 'Unable to load Solutions',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.themeTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please check your connection and try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: context.themeSecondrytext,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: controller.fetchSolutions,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.themePrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchSolutions,
          color: context.themePrimaryColor,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 36),
            children: controller.components
                .map((c) => _renderComponent(context, c))
                .toList(),
          ),
        );
      }),
    );
  }

  Widget _renderComponent(BuildContext context, PageComponent c) {
    final f = c.fields;
    String s(String key) => f[key]?.toString().trim() ?? '';

    switch (c.type) {
      case 'about-us_page-header':
      case 'solutions_page-header':
        return _buildHeader(
          context,
          s('header_image'),
          s('h1_about_us').isNotEmpty ? s('h1_about_us') : 'Solutions',
        );

      case 'solutions_solutions-intro':
        return _buildIntro(context, f);

      case 'solutions_industry-solutions':
        return _buildIndustrySolutions(context, f);

      case 'solutions_solution-capabilities':
        return _buildCapabilities(context, f);

      case 'solutions_solution-cta':
        return _buildCta(context, f);

      case 'spacer_bs':
        final h = double.tryParse(
                s('height').replaceAll(RegExp(r'[^0-9.]'), '')) ??
            16.0;
        return SizedBox(height: h);

      default:
        return const SizedBox.shrink();
    }
  }

  // ─── 1. BANNER HEADER ──────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, String imagePath, String title) {
    return Container(
      width: double.infinity,
      height: 145,
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
          if (imagePath.isNotEmpty)
            Opacity(
              opacity: 0.18,
              child: CachedNetworkImage(
                imageUrl: _imageUrl(imagePath),
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
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
  Widget _buildIntro(BuildContext context, Map<String, dynamic> f) {
    String s(String key) => f[key]?.toString().trim() ?? '';
    final bgImg = s('background_image');
    final statItem = _stripHtml(s('stat_item'));

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
            if (bgImg.isNotEmpty)
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: _imageUrl(bgImg),
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
                  if (s('section_subtitle').isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.themePrimaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        s('section_subtitle').toUpperCase(),
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
                    s('section_title').isNotEmpty
                        ? s('section_title')
                        : 'Network Infrastructure Solutions Built Around Your Industry',
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
                    s('section_description').isNotEmpty
                        ? s('section_description')
                        : 'From data centers to retail chains, Vision Infrastructure designs, supplies, and supports the fiber optic, switching, and surveillance backbone that keeps your operations connected.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      height: 1.55,
                      color: context.themeSecondrytext,
                    ),
                  ),
                  if (statItem.isNotEmpty) ...[
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
                            statItem,
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
                        s('cta_text').isNotEmpty
                            ? s('cta_text')
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
      BuildContext context, Map<String, dynamic> f) {
    String s(String key) => f[key]?.toString().trim() ?? '';

    // Industry solutions exactly matching https://vision.vbought.com/solution
    final industries = [
      {
        'title': 'Data Center & Enterprise',
        'desc':
            'High-density fiber cabling, switching, and rack infrastructure engineered for uptime and scale.',
        'image':
            'https://vision.vbought.com/assets/images/demos/demo15/categories/Networking.webp',
        'icon': Icons.dns_rounded,
        'categorySlug': 'networking',
        'categoryName': 'Networking',
      },
      {
        'title': 'ISP & Telecom',
        'desc':
            'FTTH drop cables, splitters, and outside-plant fiber built for large-scale last-mile rollouts.',
        'image':
            'https://vision.vbought.com/assets/images/demos/demo15/categories/Fiber Cables.webp',
        'icon': Icons.cell_tower_rounded,
        'categorySlug': 'fiber-cables',
        'categoryName': 'Fiber Cables',
      },
      {
        'title': 'Retail & Warehousing',
        'desc':
            'PoE switching and surveillance-ready networking for multi-site retail and logistics operations.',
        'image':
            'https://vision.vbought.com/assets/images/demos/demo15/categories/Transceivers.webp',
        'icon': Icons.storefront_rounded,
        'categorySlug': 'transceivers',
        'categoryName': 'Transceivers',
      },
      {
        'title': 'Education Campuses',
        'desc':
            'Structured cabling and patch panels that scale across classrooms, labs, and administration buildings.',
        'image':
            'https://vision.vbought.com/assets/images/demos/demo15/categories/Panels, Enclosures & Racks.webp',
        'icon': Icons.school_rounded,
        'categorySlug': 'panels-enclosures-and-racks',
        'categoryName': 'Panels, Enclosures & Racks',
      },
      {
        'title': 'Healthcare Facilities',
        'desc':
            'Reliable, redundant network paths for mission-critical systems and always-on patient care.',
        'image':
            'https://vision.vbought.com/assets/images/demos/demo15/categories/Switches.webp',
        'icon': Icons.local_hospital_rounded,
        'categorySlug': 'switches',
        'categoryName': 'Switches',
      },
      {
        'title': 'Security & Surveillance',
        'desc':
            'Bandwidth-ready backbones and PoE switching purpose-built for city-wide and campus camera networks.',
        'image':
            'https://vision.vbought.com/assets/images/pages/about_us/4.jpg',
        'icon': Icons.videocam_rounded,
        'categorySlug': 'security-and-surveillance',
        'categoryName': 'Security & Surveillance',
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (s('section_eyebrow').isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: context.themePrimaryLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                s('section_eyebrow').toUpperCase(),
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
            s('section_title').isNotEmpty
                ? s('section_title')
                : 'Built For Every Environment',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 19.5,
              fontWeight: FontWeight.w700,
              color: context.themeTextColor,
            ),
          ),
          if (s('section_subtitle').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              s('section_subtitle'),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: context.themeSecondrytext,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 18),
          ...industries.map((ind) {
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
                        imageUrl: _imageUrl(ind['image'] as String),
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
                              ind['icon'] as IconData,
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 6,
                              )
                            ],
                          ),
                          child: Icon(
                            ind['icon'] as IconData,
                            size: 18,
                            color: context.themePrimaryColor,
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
                          ind['title'] as String,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: context.themeTextColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ind['desc'] as String,
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
                              'name': ind['categoryName'],
                              'categorySlug': ind['categorySlug'],
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
                                  s('link_text').isNotEmpty
                                      ? s('link_text')
                                      : 'Explore Products',
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
  Widget _buildCapabilities(BuildContext context, Map<String, dynamic> f) {
    String s(String key) => f[key]?.toString().trim() ?? '';

    // Solutions By Need capabilities exactly matching the website
    final capabilities = [
      {
        'title': 'Network Design & Planning',
        'desc':
            'Site surveys, capacity planning, and topology design that scale with your growth, not against it.',
        'icon': Icons.schema_rounded,
      },
      {
        'title': 'Network Security & Redundancy',
        'desc':
            'Failover paths, managed switching, and access control designed to keep critical systems online.',
        'icon': Icons.security_rounded,
      },
      {
        'title': 'Legacy Network Upgrades',
        'desc':
            'Migrate aging copper and unmanaged gear to fiber-ready, centrally managed infrastructure with minimal downtime.',
        'icon': Icons.published_with_changes_rounded,
      },
      {
        'title': 'Deployment & After-Sales Support',
        'desc':
            'On-site installation, testing, and ongoing technical support long after the network goes live.',
        'icon': Icons.support_agent_rounded,
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (s('section_subtitle').isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: context.themePrimaryLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                s('section_subtitle').toUpperCase(),
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
            s('section_title').isNotEmpty
                ? s('section_title')
                : 'Whatever The Challenge, We Have A Solution',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 19.5,
              fontWeight: FontWeight.w700,
              color: context.themeTextColor,
            ),
          ),
          const SizedBox(height: 16),
          ...capabilities.map((cap) {
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.themePrimaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      cap['icon'] as IconData,
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
                          cap['title'] as String,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: context.themeTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cap['desc'] as String,
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
  Widget _buildCta(BuildContext context, Map<String, dynamic> f) {
    String s(String key) => f[key]?.toString().trim() ?? '';

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
              s('cta_heading').isNotEmpty
                  ? s('cta_heading')
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
              s('cta_description').isNotEmpty
                  ? s('cta_description')
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
                s('cta_button_text').isNotEmpty
                    ? s('cta_button_text')
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
