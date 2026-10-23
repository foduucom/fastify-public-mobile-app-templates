import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:zouhi/app/modules/helpandsupport/controllers/helpandsupport_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/check_internet_widget.dart';
import 'package:zouhi/components/support_call_sheet.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpAndSupportView extends GetView<HelpandsupportController> {
  const HelpAndSupportView({Key? key}) : super(key: key);

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeBackground,
      body: FoduuCheckInternetBody(
        child: CustomScrollView(
          slivers: [
            // ─── Gradient AppBar ───────────────────────────────────────
            SliverAppBar(
              expandedHeight: 170,
              floating: false,
              pinned: true,
              backgroundColor: context.themePrimaryDark,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: themegradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative circles
                      Positioned(
                        right: -40,
                        top: -30,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.07),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -25,
                        bottom: -40,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.07),
                          ),
                        ),
                      ),
                      // Title content
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 24,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.22),
                              ),
                              child: const Icon(
                                Icons.headset_mic_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Help & Support',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 15),
                ),
                onPressed: () => Get.back(),
              ),
            ),

            // ─── Body ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Section Label ──
                    const _SectionLabel(
                      title: 'Reach Us Directly',
                      subtitle: 'Call or email us 24/7',
                    ),
                    const SizedBox(height: 14),

                    // ── Contact Cards ──
                    Row(
                      children: [
                        // Email card — solid brand blue
                        Expanded(
                          child: _ContactCard(
                            icon: Icons.email_rounded,
                            title: 'Email',
                            description: supportEmail,
                            cardColor: context.themePrimaryColor,
                            isOutlined: false,
                            onTap: () {
                              final Uri emailLaunchUri = Uri(
                                scheme: 'mailto',
                                path: supportEmail,
                                query: encodeQueryParameters(<String, String>{
                                  'subject': 'Help from Mobile App',
                                }),
                              );
                              launchUrl(emailLaunchUri);
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Phone card — white with brand-blue accent
                        Expanded(
                          child: _ContactCard(
                            icon: Icons.phone_rounded,
                            title: 'Phone',
                            description: supportContact,
                            cardColor: context.themePrimaryColor,
                            isOutlined: true,
                            onTap: () => handleSupportCall(context),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ── Policies Section ──
                    // _SectionLabel(
                    //   title: 'Policies & Legal',
                    //   subtitle: 'Read carefully before you proceed',
                    // ),
                    // const SizedBox(height: 14),

                    // _PolicyCard(
                    //   svgIcon: 'assets/icon/help-refund.svg',
                    //   title: 'Return & Refund Policy',
                    //   subtitle: 'Know your rights on returns',
                    //   onTap: () => Get.toNamed(Routes.POLICY_DETAIL,
                    //       arguments: {
                    //         'type': 'refund',
                    //         'title': 'Return & Refund Policy'
                    //       }),
                    // ),
                    // const SizedBox(height: 10),
                    _PolicyCard(
                      svgIcon: 'assets/icon/help-privacy.svg',
                      title: 'Privacy Policy',
                      subtitle: 'How we handle your data',
                      onTap: () => Get.toNamed(Routes.POLICY_DETAIL,
                          arguments: {
                            'type': 'privacy',
                            'title': 'Privacy Policy'
                          }),
                    ),
                    const SizedBox(height: 10),
                    _PolicyCard(
                      svgIcon: 'assets/icon/help-termscondition.svg',
                      title: 'Terms & Conditions',
                      subtitle: 'Rules governing usage',
                      onTap: () => Get.toNamed(Routes.POLICY_DETAIL,
                          arguments: {
                            'type': 'terms',
                            'title': 'Terms & Conditions'
                          }),
                    ),
                    const SizedBox(height: 10),
                    _PolicyCard(
                      iconData: Icons.business_outlined,
                      title: 'About Us',
                      subtitle: 'Learn more about Vision Infrastructure',
                      onTap: () => Get.toNamed(Routes.ABOUTUS),
                    ),
                    const SizedBox(height: 10),
                    _PolicyCard(
                      iconData: Icons.hub_outlined,
                      title: 'Network Solutions',
                      subtitle: 'Infrastructure built around your industry',
                      onTap: () => Get.toNamed(Routes.SOLUTIONS),
                    ),


                    const SizedBox(height: 28),

                    // ── Info Banner ──
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: context.themePrimaryLight,
                        borderRadius: BorderRadius.circular(themeButtonRadius),
                        border: Border.all(
                            color: context.themePrimaryColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: context.themePrimaryColor, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'For urgent queries, call us toll-free at $supportContact or email $supportEmail. Our support team is available 24/7.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: context.themePrimaryDark,
                                height: 1.55,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({Key? key, required this.title, required this.subtitle})
      : super(key: key);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: context.themetitleColor,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12.5, color: context.themeSecondrytext),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Contact Card Widget
// ─────────────────────────────────────────────────────────────────────────────
class _ContactCard extends StatelessWidget {
  const _ContactCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.cardColor,
    required this.isOutlined,
    required this.onTap,
  }) : super(key: key);

  final IconData icon;
  final String title;
  final String description;
  final Color cardColor;
  final bool isOutlined;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isFilled = !isOutlined;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
        decoration: BoxDecoration(
          color: isFilled ? cardColor : context.themeWhiteColor,
          borderRadius: BorderRadius.circular(themeBorderRadiusValue),
          border: isFilled
              ? null
              : Border.all(color: context.themeBorderColor, width: 1),
          boxShadow: isFilled ? cardShadowHover : cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isFilled
                    ? Colors.white.withOpacity(0.22)
                    : cardColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  color: isFilled ? Colors.white : cardColor, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                color: isFilled ? Colors.white : context.themeTextColor,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: isFilled
                    ? Colors.white.withOpacity(0.85)
                    : context.themeSecondrytext,
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Policy Card Widget
// ─────────────────────────────────────────────────────────────────────────────
class _PolicyCard extends StatelessWidget {
  const _PolicyCard({
    Key? key,
    this.svgIcon,
    this.iconData,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  final String? svgIcon;
  final IconData? iconData;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.themeWhiteColor,
      borderRadius: BorderRadius.circular(themeBorderRadiusValue),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(themeBorderRadiusValue),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: context.themeWhiteColor,
            borderRadius: BorderRadius.circular(themeBorderRadiusValue),
            border: Border.all(color: context.themeBorderColor),
            boxShadow: cardShadow,
          ),
          child: Row(
            children: [
              // Icon box — brand-blue tint
              Container(
                width: 46,
                height: 46,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: context.themePrimaryLight,
                  borderRadius: BorderRadius.circular(themeButtonRadius),
                ),
                child: svgIcon != null
                    ? SvgPicture.asset(
                        svgIcon!,
                        colorFilter: ColorFilter.mode(
                            context.themePrimaryColor, BlendMode.srcIn),
                      )
                    : Icon(iconData, color: context.themePrimaryColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.5,
                        color: context.themetitleColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                          fontSize: 12, color: context.themeSecondrytext),
                    ),
                  ],
                ),
              ),
              // Arrow — brand-blue tint
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: context.themePrimaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: context.themePrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
