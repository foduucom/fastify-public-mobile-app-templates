import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/data/models/page_model.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';
import '../controllers/services_controller.dart';

class ServicesView extends GetView<ServicesController> {
  const ServicesView({Key? key}) : super(key: key);

  String _imageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return path.startsWith('/') ? '$url${path.substring(1)}' : '$url$path';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeBackground,
      appBar: AppBar(
        backgroundColor: context.themeWhiteColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: context.themeTextColor,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Services',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
            fontSize: 17,
            color: context.themeTextColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.support_agent_rounded,
              color: context.themePrimaryColor,
            ),
            tooltip: 'Contact Support',
            onPressed: () => Get.toNamed(Routes.CONTACT),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.components.isEmpty) {
          return Center(child: HelperFunctions().loadingIndicator());
        }

        if (controller.components.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.signal_wifi_connected_no_internet_4_rounded,
                  size: 48,
                  color: context.themeSecondrytext.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  controller.error.value.isNotEmpty
                      ? controller.error.value
                      : 'Unable to load Services',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: context.themeTextColor,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.fetchServices,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.themePrimaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 11),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchServices,
          color: context.themePrimaryColor,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 40),
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
      case 'services_page-header':
      case 'about-us_page-header':
        return _buildHeader(
          context,
          s('header_image'),
          s('h1_services').isNotEmpty ? s('h1_services') : 'Services',
        );

      case 'services_services-intro':
        return _buildIntro(context, f);

      case 'services_core-services-tabs':
        return _buildTabsSection(context, f);

      case 'about-us_why-choose':
        return _buildWhyChoose(context, f);

      case 'services_services-cta':
        return _buildCta(context, f);

      default:
        return const SizedBox.shrink();
    }
  }

  // ---------------------------------------------------------------------------
  // 1. PAGE HEADER COMPONENT
  // ---------------------------------------------------------------------------
  Widget _buildHeader(BuildContext context, String imagePath, String title) {
    final effectiveImage = imagePath.isNotEmpty
        ? imagePath
        : '/images/2026/08/29/slide-2-73b3aa6d.webp';

    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFF12253D),
        image: DecorationImage(
          image: CachedNetworkImageProvider(_imageUrl(effectiveImage)),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            const Color(0xFF0A192D).withOpacity(0.78),
            BlendMode.darken,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'HOME',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              const Text(
                'SERVICES',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Technical support, deployment and warranty services',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. SERVICES INTRO COMPONENT
  // ---------------------------------------------------------------------------
  Widget _buildIntro(BuildContext context, Map<String, dynamic> f) {
    String s(String key) => f[key]?.toString().trim() ?? '';
    final heroImg = s('hero_image');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: context.themeWhiteColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.themeBorderColor.withOpacity(0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (heroImg.isNotEmpty)
              CachedNetworkImage(
                imageUrl: _imageUrl(heroImg),
                width: double.infinity,
                height: 190,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 190,
                  color: context.themePrimaryLight,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.themePrimaryColor,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.themePrimaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      (s('section_tagline').isNotEmpty
                              ? s('section_tagline')
                              : 'Support You Can Rely On')
                          .toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: context.themePrimaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    s('section_title').isNotEmpty
                        ? s('section_title')
                        : 'Real Support, Before And After The Sale',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.themeTextColor,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    s('section_description').isNotEmpty
                        ? s('section_description')
                        : 'Buying the right hardware is only half the job. Our team backs every order with hands-on technical support, professional installation, and a straightforward warranty process — so your network stays up and your team isn\'t left troubleshooting alone.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      height: 1.5,
                      color: context.themeSecondrytext,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Get.toNamed(Routes.CONTACT),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                      label: Text(
                        s('cta_text').isNotEmpty
                            ? s('cta_text')
                            : 'Contact Support',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.themePrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
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

  // ---------------------------------------------------------------------------
  // 3. CORE SERVICES TABS COMPONENT
  // ---------------------------------------------------------------------------
  Widget _buildTabsSection(BuildContext context, Map<String, dynamic> f) {
    String s(String key) => f[key]?.toString().trim() ?? '';

    final tabConfigs = [
      {
        'title': 'Technical Support',
        'subtitle': 'Pre & post-sales guidance',
        'icon': Icons.headset_mic_rounded,
        'prefix': 'tab1',
        'defaultImage': '/images/2026/08/29/2-1a3e1162.webp',
        'defaultHeading': 'Technical Support',
        'defaultDesc':
            'Our engineers help you choose the right products, troubleshoot issues, and answer configuration questions by phone, chat, or email — before and after your purchase.',
        'features': [
          'Pre-sales product guidance',
          'Configuration & troubleshooting help',
          'Phone, chat & email support',
        ],
      },
      {
        'title': 'Installation & Deployment',
        'subtitle': 'On-site setup & testing',
        'icon': Icons.build_circle_rounded,
        'prefix': 'tab2',
        'defaultImage': '/images/2026/08/29/3-aaed866d.webp',
        'defaultHeading': 'Installation & Deployment',
        'defaultDesc':
            'Need it done right the first time? Our technicians handle on-site installation, cabling, and testing so your network goes live without surprises.',
        'features': [
          'On-site installation & cabling',
          'Rack & equipment setup',
          'Post-install testing & sign-off',
        ],
      },
      {
        'title': 'Warranty & RMA',
        'subtitle': 'Returns & replacements',
        'icon': Icons.verified_user_rounded,
        'prefix': 'tab3',
        'defaultImage': '/images/2026/08/29/2-1a3e1162.webp',
        'defaultHeading': 'Warranty & RMA',
        'defaultDesc':
            'Every product we sell is backed by manufacturer warranty and a simple, transparent return process — no runaround if something goes wrong.',
        'features': [
          'Manufacturer-backed warranty',
          'Straightforward RMA process',
          'Fast replacement turnaround',
        ],
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: context.themePrimaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                (s('section_subtitle').isNotEmpty
                        ? s('section_subtitle')
                        : 'What We Offer')
                    .toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: context.themePrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            s('section_title').isNotEmpty
                ? s('section_title')
                : 'Our Core Services',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.themeTextColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            s('section_description').isNotEmpty
                ? s('section_description')
                : "From the first question to long after installation, here's how we support you.",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: context.themeSecondrytext,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          // Interactive Segmented Tab Selector
          Obx(() {
            final activeTab = controller.selectedTab.value;
            return Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.themeWhiteColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: context.themeBorderColor.withOpacity(0.6),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(tabConfigs.length, (index) {
                  final isSelected = activeTab == index;
                  final cfg = tabConfigs[index];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => controller.changeTab(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.themePrimaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: context.themePrimaryColor
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cfg['icon'] as IconData,
                              size: 19,
                              color: isSelected
                                  ? Colors.white
                                  : context.themeSecondrytext,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cfg['title'] as String,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10.5,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : context.themeTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
          const SizedBox(height: 14),
          // Active Tab Content Card
          Obx(() {
            final activeTab = controller.selectedTab.value;
            final cfg = tabConfigs[activeTab];
            final prefix = cfg['prefix'] as String;

            final heading = s('${prefix}_heading').isNotEmpty
                ? s('${prefix}_heading')
                : cfg['defaultHeading'] as String;
            final paragraph = s('${prefix}_paragraph').isNotEmpty
                ? s('${prefix}_paragraph')
                : cfg['defaultDesc'] as String;
            final image = s('${prefix}_image').isNotEmpty
                ? s('${prefix}_image')
                : cfg['defaultImage'] as String;
            final featureItems = cfg['features'] as List<String>;

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Container(
                key: ValueKey<int>(activeTab),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: context.themeWhiteColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.themeBorderColor.withOpacity(0.6),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (image.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: _imageUrl(image),
                          width: double.infinity,
                          height: 170,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            height: 170,
                            color: context.themePrimaryLight,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: context.themePrimaryColor,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      heading,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: context.themeTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      paragraph,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        height: 1.5,
                        color: context.themeSecondrytext,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.themeBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: featureItems.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: context.themePrimaryColor
                                        .withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: context.themePrimaryColor,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: context.themeTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. WHY CHOOSE VISION INFRASTRUCTURE (4 PILLARS GRID)
  // ---------------------------------------------------------------------------
  Widget _buildWhyChoose(BuildContext context, Map<String, dynamic> f) {
    String s(String key) => f[key]?.toString().trim() ?? '';

    final pillars = [
      {
        'title': 'Certified Quality',
        'desc':
            'Every product meets strict industry standards for performance and durability.',
        'icon': Icons.verified_rounded,
        'color': context.themePrimaryColor,
        'bg': context.themePrimaryLight,
      },
      {
        'title': 'Expert Support',
        'desc':
            'Our technical team is with you from product selection through installation.',
        'icon': Icons.headset_mic_rounded,
        'color': const Color(0xFF00897B),
        'bg': const Color(0xFFE0F2F1),
      },
      {
        'title': 'Reliable Delivery',
        'desc':
            'Timely, competitive delivery for projects of every scale, across India.',
        'icon': Icons.local_shipping_rounded,
        'color': const Color(0xFFE65100),
        'bg': const Color(0xFFFFF3E0),
      },
      {
        'title': 'Competitive Pricing',
        'desc':
            'Single-source procurement that keeps your infrastructure budget on track.',
        'icon': Icons.sell_rounded,
        'color': const Color(0xFF512DA8),
        'bg': const Color(0xFFEDE7F6),
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: context.themePrimaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'WHY VISION INFRASTRUCTURE',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: context.themePrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            s('feature_heading').isNotEmpty
                ? s('feature_heading')
                : 'Why Choose Vision Infrastructure',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.themeTextColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Everything you need from a single, dependable network infrastructure partner.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: context.themeSecondrytext,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          // 2x2 Grid of Value Pillars
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pillars.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.88,
            ),
            itemBuilder: (context, index) {
              final p = pillars[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.themeWhiteColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: context.themeBorderColor.withOpacity(0.6),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: p['bg'] as Color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        p['icon'] as IconData,
                        size: 22,
                        color: p['color'] as Color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      p['title'] as String,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: context.themeTextColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        p['desc'] as String,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11.5,
                          height: 1.4,
                          color: context.themeSecondrytext,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. CALL TO ACTION & 24/7 HOTLINE COMPONENT
  // ---------------------------------------------------------------------------
  Widget _buildCta(BuildContext context, Map<String, dynamic> f) {
    String s(String key) => f[key]?.toString().trim() ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
      child: Column(
        children: [
          // Primary Gradient Banner
          Container(
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
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: context.themePrimaryColor.withOpacity(0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.handshake_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'READY TO WORK WITH US',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  s('section_heading').isNotEmpty
                      ? s('section_heading')
                      : 'Need Help With An Order Or Installation?',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  s('section_description').isNotEmpty
                      ? s('section_description')
                      : "Our support team is ready to help — reach out and we'll get back to you with next steps.",
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed(Routes.CONTACT),
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: Text(
                    s('cta_button_text').isNotEmpty
                        ? s('cta_button_text')
                        : 'Get In Touch',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: context.themePrimaryColor,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: context.themePrimaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // 24/7 Hotline Quick Action Card (matching the website footer)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: context.themeWhiteColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: context.themeBorderColor.withOpacity(0.6),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00897B).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone_in_talk_rounded,
                    size: 22,
                    color: Color(0xFF00897B),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Got Question? Call us 24/7',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: context.themeSecondrytext,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        supportContact,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: context.themeTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => controller.makePhoneCall(supportContact),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00897B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.call_rounded, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Call Now',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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
  }
}
