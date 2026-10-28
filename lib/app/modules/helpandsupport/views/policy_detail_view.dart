import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:zouhi/app/data/models/privacy_sections.dart';
import 'package:zouhi/app/data/models/terms_sections.dart';
import 'package:zouhi/app/modules/helpandsupport/controllers/policy_controller.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';

class PolicyDetailView extends GetView<PolicyController> {
  const PolicyDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDocumentStyle =
        controller.policyType == 'terms' || controller.policyType == 'privacy';

    return Scaffold(
      backgroundColor:
          isDocumentStyle ? const Color(0xFFF7F8FA) : context.themeWhiteColor,
      appBar: AppBar(
        backgroundColor: context.themePrimaryColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: context.themeWhiteColor),
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: (isDocumentStyle || controller.titleArg != null)
            ? Text(
                controller.titleArg ??
                    (controller.policyType == 'privacy'
                        ? 'Privacy Policy'
                        : 'Terms & Conditions'),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600,
                  color: context.themeWhiteColor,
                ),
              )
            : Obx(() {
                final page = controller.pageData.value?.data;
                return Text(
                  page?.name ?? '',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17.0,
                    fontWeight: FontWeight.w600,
                    color: context.themeWhiteColor,
                  ),
                );
              }),
      ),
      body: Obx(() {
        if (controller.policyType == 'terms') {
          return _buildTermsBody(context);
        }
        if (controller.policyType == 'privacy') {
          return _buildPrivacyBody(context);
        }

        if (controller.isLoading.value && controller.pageData.value == null) {
          return Center(child: HelperFunctions().loadingIndicator());
        }

        if (controller.error.isNotEmpty && controller.pageData.value == null) {
          return _buildErrorView(context);
        }

        final page = controller.pageData.value?.data;
        if (page == null || page.content.isEmpty) {
          return _buildEmptyView(context);
        }

        // Extract breadcrumb for banner
        dynamic breadcrumb;
        for (var comp in page.content) {
          if (comp.type == 'breadcrumb') {
            breadcrumb = comp;
            break;
          }
        }

        String title = '';
        String bgImage = '';
        if (breadcrumb != null) {
          final Map<String, dynamic> fields = breadcrumb.fields is Map
              ? (breadcrumb.fields as Map).cast<String, dynamic>()
              : {};
          title = fields['title'] ?? fields['heading'] ?? fields['name'] ?? '';
          bgImage = fields['bg_image'] ?? fields['background_image'] ?? '';
        }
        if (title.isEmpty) {
          // Flat-format CMS pages (e.g. privacy-policy) carry the heading as title_text
          for (var comp in page.content) {
            final t = comp.fields['title_text']?.toString() ?? '';
            if (t.isNotEmpty) {
              title = t;
              break;
            }
          }
        }
        if (title.isEmpty) {
          title = controller.titleArg ?? page.name ?? '';
        }

        return RefreshIndicator(
          onRefresh: () =>
              controller.fetchPolicy(controller.policyType, forceRefresh: true),
          color: context.themePrimaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero Banner — ENHANCED with theme gradient overlay ✨
                _buildHeroBanner(context, title: title, bgImage: bgImage),

                // ── Offline Mode strip — enhanced with theme colors ✨
                if (controller.isOfflineMode.value)
                  _buildOfflineBanner(context),

                // ── Policy content with animations ✨
                ...page.content
                    .where((component) => component.type != 'breadcrumb')
                    .map((component) => _renderComponent(context, component))
                    .toList(),

                const SizedBox(height: 48.0), // ✨ Increased bottom spacing
              ],
            ),
          ),
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  CMS BROADCASTING PRIVACY POLICY (log3.txt & vision.foduu.store/privacy-policy)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPrivacyBody(BuildContext context) {
    final privacy = controller.privacyData.value;
    if (controller.isLoading.value && privacy == null) {
      return Center(child: HelperFunctions().loadingIndicator());
    }

    if (privacy == null || privacy.blocks.isEmpty) {
      return _buildEmptyView(context);
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchPolicy('privacy', forceRefresh: true),
      color: context.themePrimaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
        child: Column(
          children: [
            // Offline Mode strip if offline
            if (controller.isOfflineMode.value)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildOfflineBanner(context),
              ),

            // ── Single Unified Document Card (.kv-privacy-card from parent website) ──
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.themeWhiteColor,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: context.themeBorderColor.withValues(alpha: 0.85),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Document Title (<h1 class="kv-privacy-title">Privacy Policy</h1>)
                    Text(
                      privacy.pageTitle,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: context.themeTextColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    // Document Subtitle (<p class="kv-privacy-subtitle">Vision Infrastructure Solutions</p>)
                    Text(
                      privacy.subtitle,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: context.themeSecondrytext,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    // Brand accent underline
                    Container(
                      width: 32.0,
                      height: 3.0,
                      decoration: BoxDecoration(
                        color: context.themePrimaryColor,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Divider(
                        height: 1.0,
                        thickness: 1.0,
                        color: context.themeBorderColor),

                    // Content stream directly from API sections
                    ...privacy.blocks
                        .map((block) => _buildPrivacyBlock(context, block))
                        .toList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyBlock(BuildContext context, PrivacyContentBlock block) {
    switch (block.type) {
      case PrivacyBlockType.heading:
        // Mirrors <h3>Section Title</h3> on parent website
        return Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
          child: Text(
            block.text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17.5,
              fontWeight: FontWeight.bold,
              color: context.themeTextColor,
              letterSpacing: -0.3,
              height: 1.35,
            ),
          ),
        );

      case PrivacyBlockType.paragraph:
        // Mirrors <p>Paragraph copy</p> on parent website
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: _buildDynamicLinkedText(
            context,
            block.text,
            size: block.size,
            alignment: block.alignment,
          ),
        );

      case PrivacyBlockType.bulletList:
        return _buildPrivacyBulletList(context, block);

      case PrivacyBlockType.contact:
        return _buildPrivacyContactBlock(context, block);

      case PrivacyBlockType.lastUpdated:
        // Mirrors <div class="kv-privacy-bottom"><p>Last updated...</p></div> on parent website
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 24.0),
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: context.themegreyColor.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: context.themeBorderColor.withValues(alpha: 0.8),
              width: 1.0,
            ),
          ),
          child: Text(
            block.text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.0,
              height: 1.55,
              color: context.themeSecondrytext,
            ),
          ),
        );
    }
  }

  Widget _buildPrivacyBulletList(
    BuildContext context,
    PrivacyContentBlock block,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Intro text (e.g. "Depending on how you interact with us, we may collect:")
          if (block.introText != null && block.introText!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: _buildDynamicLinkedText(
                context,
                block.introText!,
                size: block.size,
                alignment: block.alignment,
              ),
            ),

          // 2. Unordered bullet items (<ul><li>...</li></ul>)
          ...block.listItems.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 9.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand navy bullet dot centered vertically to the first line
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8.5, left: 2.0, right: 10.0),
                    child: Container(
                      width: 6.0,
                      height: 6.0,
                      decoration: BoxDecoration(
                        color: context.themePrimaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // List item body with URL linking and Poppins typography
                  Expanded(
                    child: _buildDynamicLinkedText(
                      context,
                      item,
                      size: block.size,
                      alignment: block.alignment,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          // 3. Outro text (e.g. "We do not seek to collect sensitive information...")
          if (block.outroText != null && block.outroText!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: _buildDynamicLinkedText(
                context,
                block.outroText!,
                size: block.size,
                alignment: block.alignment,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrivacyContactBlock(
    BuildContext context,
    PrivacyContentBlock block,
  ) {
    String? email = block.email;
    String? website = block.website;
    String? companyName = block.companyName;
    String? effectiveDate = block.effectiveDate;
    String? regulatoryNotice = block.regulatoryNotice;
    String intro = block.text;

    // Fallback on-the-fly extraction if block was parsed from a raw paragraph or legacy cache
    if (email == null) {
      final emailMatch =
          RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}')
              .firstMatch(block.text);
      email = emailMatch?.group(0) ?? 'sales@visioninfrastructurecanada.com';
    }
    if (website == null) {
      final webMatch =
          RegExp(r'(?:https?:\/\/|www\.)[a-zA-Z0-9.\-_]+(?:\/[^\s]*)?')
              .firstMatch(block.text);
      website = webMatch?.group(0) ?? 'www.visioninfrastructurecanada.com';
    }
    if (companyName == null) {
      if (block.text.contains('Vision Infrastructure Canada')) {
        companyName = 'Vision Infrastructure Canada';
      } else {
        companyName = 'Vision Infrastructure Canada';
      }
    }
    if (effectiveDate == null) {
      final dateMatch = RegExp(
        r'(?:January|February|March|April|May|June|July|August|September|October|November|December)\s+\d{1,2},\s+\d{4}',
        caseSensitive: false,
      ).firstMatch(block.text);
      effectiveDate = dateMatch?.group(0);
    }
    if (regulatoryNotice == null) {
      final regMatch = RegExp(
        r'We will review privacy enquiries and complaints and respond within a reasonable period[\s\S]*?(?:jurisdiction\.|applicable law\.)',
        caseSensitive: false,
      ).firstMatch(block.text);
      regulatoryNotice = regMatch?.group(0)?.trim();
    }
    // Clean intro text from raw block text
    final introMatch = RegExp(
      r'^([\s\S]*?)(?:Vision Infrastructure Canada|Email:|Website:|Webiste:|sales@)',
      caseSensitive: false,
    ).firstMatch(block.text);
    if (introMatch != null && introMatch.group(1)!.trim().isNotEmpty) {
      intro = introMatch.group(1)!.trim();
    } else if (intro.toLowerCase().contains('sales@') ||
        intro.toLowerCase().contains('www.')) {
      intro =
          'If you have questions about this Privacy Policy, wish to make a privacy request, or want to raise a concern about how personal information is handled, please contact:';
    }

    final webUrl = block.url ??
        (website.startsWith('http') ? website : 'https://$website');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Intro text
        if (intro.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              intro,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.5,
                height: 1.6,
                color: context.themeTextColor,
              ),
            ),
          ),

        // 2. Elevated Official Contact Card (Industry Standard)
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            color: context.themeWhiteColor,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: context.themeBorderColor.withValues(alpha: 0.9),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: context.themePrimaryColor.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header banner with official company badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 14.0),
                decoration: BoxDecoration(
                  color: context.themePrimaryColor.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: context.themeBorderColor.withValues(alpha: 0.7),
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color:
                            context.themePrimaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Icon(
                        Icons.shield_outlined,
                        color: context.themePrimaryColor,
                        size: 22.0,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            companyName,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15.0,
                              fontWeight: FontWeight.w700,
                              color: context.themeTextColor,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            'Official Privacy & Compliance Office',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12.0,
                              color: context.themeSecondrytext,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Interactive Channels
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Email Tile
                    _buildInteractiveContactTile(
                      context,
                      icon: Icons.mail_outline_rounded,
                      title: 'Email',
                      value: email,
                      actionLabel: 'Send email',
                      onTap: () => controller.openUrl('mailto:$email'),
                    ),
                    const SizedBox(height: 12.0),
                    Divider(
                      height: 1.0,
                      thickness: 0.8,
                      color: context.themeBorderColor.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 12.0),
                    // Website Tile (Typo corrected, clickable)
                    _buildInteractiveContactTile(
                      context,
                      icon: Icons.language_rounded,
                      title: 'Website',
                      value: website,
                      actionLabel: 'Open site',
                      trailingIcon: Icons.open_in_new_rounded,
                      onTap: () => controller.openUrl(webUrl),
                    ),
                  ],
                ),
              ),

              // Action Buttons Bar
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0),
                child: Row(
                  children: [
                    // Primary Email Button
                    Expanded(
                      child: Material(
                        color: context.themePrimaryColor,
                        borderRadius: BorderRadius.circular(10.0),
                        child: InkWell(
                          onTap: () => controller.openUrl('mailto:$email'),
                          borderRadius: BorderRadius.circular(10.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 11.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.email_outlined,
                                  color: context.themeWhiteColor,
                                  size: 16.0,
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  'Email Us',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w600,
                                    color: context.themeWhiteColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    // Secondary Website Button
                    Expanded(
                      child: Material(
                        color: context.themeWhiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(
                            color: context.themePrimaryColor,
                            width: 1.3,
                          ),
                        ),
                        child: InkWell(
                          onTap: () => controller.openUrl(webUrl),
                          borderRadius: BorderRadius.circular(10.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 11.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.open_in_new_rounded,
                                  color: context.themePrimaryColor,
                                  size: 15.0,
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  'Visit Website',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w600,
                                    color: context.themePrimaryColor,
                                  ),
                                ),
                              ],
                            ),
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

        // 3. Regulatory compliance / enquiries response card
        if (regulatoryNotice != null && regulatoryNotice.isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16.0),
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: context.themePrimaryColor,
                  size: 20.0,
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    regulatoryNotice,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.5,
                      height: 1.55,
                      color: context.themeSecondrytext,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // 4. Effective Date Badge (if present)
        if (effectiveDate != null && effectiveDate.isNotEmpty)
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: context.themegreyColor.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: context.themeBorderColor.withValues(alpha: 0.7),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 15.0,
                  color: context.themeSecondrytext,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    'Effective Date: $effectiveDate • $companyName',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: context.themeSecondrytext,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Reusable interactive contact channel tile for email/website
  Widget _buildInteractiveContactTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String actionLabel,
    IconData trailingIcon = Icons.arrow_forward_ios_rounded,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
          child: Row(
            children: [
              Container(
                width: 38.0,
                height: 38.0,
                decoration: BoxDecoration(
                  color: context.themePrimaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(9.0),
                ),
                child: Icon(
                  icon,
                  color: context.themePrimaryColor,
                  size: 19.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: context.themeSecondrytext,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: context.themePrimaryColor,
                          decoration: TextDecoration.underline,
                          decorationColor:
                              context.themePrimaryColor.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                trailingIcon,
                size: trailingIcon == Icons.arrow_forward_ios_rounded
                    ? 13.0
                    : 16.0,
                color: context.themePrimaryColor.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  CMS BROADCASTING TERMS & CONDITIONS (log3.txt & vision.foduu.store/terms-conditions)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTermsBody(BuildContext context) {
    final terms = controller.termsData.value;
    if (controller.isLoading.value && terms == null) {
      return Center(child: HelperFunctions().loadingIndicator());
    }

    if (terms == null || terms.blocks.isEmpty) {
      return _buildEmptyView(context);
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchPolicy('terms', forceRefresh: true),
      color: context.themePrimaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
        child: Column(
          children: [
            // Offline Mode strip if offline
            if (controller.isOfflineMode.value)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildOfflineBanner(context),
              ),

            // ── Single Unified Document Card (.kv-terms-card from parent website) ──
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.themeWhiteColor,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: context.themeBorderColor.withOpacity(0.85),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Document Title (<h1 class="kv-terms-title">Terms & Conditions</h1>)
                    Text(
                      terms.pageTitle,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: context.themeTextColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    // Brand accent underline
                    Container(
                      width: 32.0,
                      height: 3.0,
                      decoration: BoxDecoration(
                        color: context.themePrimaryColor,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Divider(
                        height: 1.0,
                        thickness: 1.0,
                        color: context.themeBorderColor),

                    // Content stream directly from API sections
                    ...terms.blocks
                        .map((block) => _buildTermsBlock(context, block))
                        .toList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsBlock(BuildContext context, TermsContentBlock block) {
    switch (block.type) {
      case TermsBlockType.heading:
        // Mirrors <h3>Section Title</h3> on parent website
        return Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
          child: Text(
            block.text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17.5,
              fontWeight: FontWeight.bold,
              color: context.themeTextColor,
              letterSpacing: -0.3,
              height: 1.35,
            ),
          ),
        );

      case TermsBlockType.paragraph:
        // Mirrors <p>Paragraph copy</p> on parent website
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: _buildDynamicLinkedText(
            context,
            block.text,
            size: block.size,
            alignment: block.alignment,
          ),
        );

      case TermsBlockType.contact:
        return _buildTermsContactBlock(context, block);

      case TermsBlockType.lastUpdated:
        // Mirrors <div class="kv-terms-bottom"><p>Last updated...</p></div> on parent website
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 24.0),
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: context.themegreyColor.withOpacity(0.35),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: context.themeBorderColor.withOpacity(0.8),
              width: 1.0,
            ),
          ),
          child: Text(
            block.text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.0,
              height: 1.55,
              color: context.themeSecondrytext,
            ),
          ),
        );
    }
  }

  Widget _buildTermsContactBlock(
    BuildContext context,
    TermsContentBlock block,
  ) {
    final portalUrl = block.url ?? 'https://vision.vbought.com';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            block.text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: block.size,
              height: 1.65,
              color: context.themeTextColor,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 4.0, bottom: 8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: context.themeBorderColor.withValues(alpha: 0.85),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42.0,
                    height: 42.0,
                    decoration: BoxDecoration(
                      color: context.themePrimaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Icon(
                      Icons.support_agent_rounded,
                      color: context.themePrimaryColor,
                      size: 24.0,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vision Support Team',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: context.themeTextColor,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          'Questions about our terms, orders, or services?',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.0,
                            color: context.themeSecondrytext,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14.0),
              Divider(
                height: 1.0,
                thickness: 1.0,
                color: context.themeBorderColor.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  // Primary in-app Contact button
                  Expanded(
                    child: Material(
                      color: context.themePrimaryColor,
                      borderRadius: BorderRadius.circular(9.0),
                      child: InkWell(
                        onTap: () => Get.toNamed('/contact'),
                        borderRadius: BorderRadius.circular(9.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.mail_outline_rounded,
                                color: context.themeWhiteColor,
                                size: 16.0,
                              ),
                              const SizedBox(width: 6.0),
                              Text(
                                'Contact Us',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                  color: context.themeWhiteColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  // Secondary external website portal button
                  Expanded(
                    child: Material(
                      color: context.themeWhiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9.0),
                        side: BorderSide(
                          color: context.themePrimaryColor,
                          width: 1.2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => controller.openUrl(portalUrl),
                        borderRadius: BorderRadius.circular(9.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.open_in_new_rounded,
                                color: context.themePrimaryColor,
                                size: 15.0,
                              ),
                              const SizedBox(width: 6.0),
                              Text(
                                'Visit Website',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                  color: context.themePrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicLinkedText(
    BuildContext context,
    String text, {
    double size = 15.0,
    String alignment = 'left',
  }) {
    TextAlign textAlign = TextAlign.left;
    if (alignment == 'center') textAlign = TextAlign.center;
    if (alignment == 'right') textAlign = TextAlign.right;

    // 1. Sanitize text: fix typo "Webiste:", filter out internal lawyer/CMS template notes
    String sanitizedText = text
        .replaceAll(RegExp(r'Webiste:', caseSensitive: false), 'Website:')
        .replaceAll(
          RegExp(
            r'Important:\s*This policy is a general template and should be reviewed against[^\n]*before publication\.?',
            caseSensitive: false,
          ),
          '',
        )
        .replaceAll('\r\n', '\n')
        .replaceAll(RegExp(r'\n[ \t]+'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();

    // 2. Comprehensive regex matching emails, web URLs, and www domains
    final linkRegex = RegExp(
      r'([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})|((?:https?:\/\/|www\.)[^\s]+)',
    );
    final matches = linkRegex.allMatches(sanitizedText);

    if (matches.isEmpty) {
      return Text(
        sanitizedText,
        textAlign: textAlign,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: size,
          height: 1.65,
          color: context.themeTextColor,
        ),
      );
    }

    final spans = <InlineSpan>[];
    int lastEnd = 0;
    for (final match in matches) {
      if (match.start > lastEnd) {
        spans
            .add(TextSpan(text: sanitizedText.substring(lastEnd, match.start)));
      }
      final matchedString = match.group(0)!;
      final isEmail =
          matchedString.contains('@') && !matchedString.startsWith('http');
      final targetUrl = isEmail
          ? 'mailto:$matchedString'
          : (matchedString.startsWith('http')
              ? matchedString
              : 'https://$matchedString');

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: InkWell(
            onTap: () => controller.openUrl(targetUrl),
            child: Text(
              matchedString,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: size,
                fontWeight: FontWeight.w600,
                color: context.themePrimaryColor,
                decoration: TextDecoration.underline,
                decorationColor: context.themePrimaryColor,
              ),
            ),
          ),
        ),
      );
      lastEnd = match.end;
    }
    if (lastEnd < sanitizedText.length) {
      spans.add(TextSpan(text: sanitizedText.substring(lastEnd)));
    }

    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: size,
          height: 1.65,
          color: context.themeTextColor,
        ),
        children: spans,
      ),
    );
  }

  // ✨ ENHANCED: Hero banner with theme gradient overlay (height increased to 240)
  Widget _buildHeroBanner(BuildContext context,
      {required String title, required String bgImage}) {
    final isAsset = bgImage.isEmpty ||
        (bgImage.startsWith("assets/") &&
            !bgImage.startsWith("assets/images/first/"));

    return AnimatedOpacity(
      duration: themeAnimationDuration,
      opacity: 1.0,
      // child: Padding(
      //   padding: pageSurroundingPadding,
      child: ClipRRect(
        //borderRadius: BorderRadius.circular(20.0), // ✨ Increased from 16
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24.0),
          bottomRight: Radius.circular(24.0),
        ), // ✅ Only bottom corners rounded
        child: Container(
          width: double.infinity,
          //height: 240.0, // ✨ Increased from 200
          height: 260.0,
          decoration: BoxDecoration(
            color: context.themegreyColor,
            // borderRadius: BorderRadius.circular(20.0),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.1), // ✨ Slightly stronger shadow
            //     blurRadius: 16,
            //     offset: const Offset(0, 6),
            //   ),
            // ],
          ),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: isAsset
                    ? Image.asset(
                        bgImage.isEmpty
                            ? "assets/images/helpandsupport.jpg"
                            : bgImage,
                        fit: BoxFit.cover,
                      )
                    : CachedNetworkImage(
                        imageUrl: _getImageUrl(bgImage),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: HelperFunctions().loadingIndicator(),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: context.themegreyColor,
                          child: const Center(
                            child: Icon(Icons.error),
                          ),
                        ),
                      ),
              ),
              // ✨ ENHANCED: Theme gradient overlay using actual theme colors
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.55),
                        Colors.black.withOpacity(0.35),
                        context.themePrimaryColor.withOpacity(0.75),
                        context.themePrimaryColor.withOpacity(0.88),
                      ],
                      stops: const [0.0, 0.25, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
              // Centered title text with enhanced styling
              Positioned.fill(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28.0, // ✨ Increased from 26
                        fontWeight: FontWeight.bold,
                        color: context.themeWhiteColor,
                        letterSpacing: -0.5,
                        height: 1.3, // ✨ Added line height
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 10.0, // ✨ Increased from 8
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    //);
  }

  // ✨ ENHANCED: Offline banner with theme colors
  Widget _buildOfflineBanner(BuildContext context) {
    return AnimatedOpacity(
      duration: themeAnimationDuration,
      opacity: 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 12.0, vertical: 4.0), // ✨ Reduced vertical padding
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0), // ✨ Increased from 12
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.0),
            child: Container(
              width: double.infinity,
              color: context.themePrimaryColor,
              padding: const EdgeInsets.symmetric(
                  vertical: 12.0, horizontal: 18.0), // ✨ Increased padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.wifi_off_outlined,
                          color: context.themeWhiteColor,
                          size: 20.0), // ✨ Increased size
                      const SizedBox(width: 12.0), // ✨ Increased spacing
                      Text(
                        "Offline Mode - Showing cached content",
                        style: TextStyle(
                          color: context.themeWhiteColor,
                          fontSize: 13.5, // ✨ Slightly larger
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(Get.context!).showSnackBar(
                        const SnackBar(
                          content: Text("Pull down to refresh content"),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: context.themeWhiteColor
                            .withOpacity(0.25), // ✨ Slightly more opaque
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: context.themeWhiteColor,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getImageUrl(String bgImage) {
    if (bgImage.startsWith("http://") || bgImage.startsWith("https://")) {
      return bgImage;
    }
    if (bgImage.startsWith("assets/images/first/") ||
        !bgImage.startsWith("assets/")) {
      // Relative URL on the server
      return bgImage.startsWith('/')
          ? "$url${bgImage.substring(1)}"
          : "$url$bgImage";
    }
    return bgImage;
  }

  Widget _renderComponent(BuildContext context, dynamic component) {
    final type = component.type ?? '';
    final Map<String, dynamic> fields = component.fields is Map
        ? (component.fields as Map).cast<String, dynamic>()
        : {};

    if (type == 'breadcrumb') {
      return const SizedBox.shrink();
    }

    if (type == 'text_bs') {
      final textblock = fields['textblock'] ?? fields['content'] ?? '';
      final emailAddress = fields['email_address'] ?? '';
      return Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16.0, vertical: 8.0), // ✨ Adjusted horizontal padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBeautifulTextBlock(context, textblock),
            if (emailAddress.isNotEmpty) ...[
              const SizedBox(height: 28.0), // ✨ Increased spacing
              _buildEmailContactCard(context, emailAddress),
            ],
          ],
        ),
      );
    }

    // Flat CMS format: intro_title/intro_content, usage_title/usage_content, ...
    final flatSections = _parseFlatSections(fields);
    if (flatSections.isNotEmpty) {
      return _buildFlatPolicy(context, fields, flatSections);
    }

    // Match policy term users or custom component layouts dynamically
    final hasSectionTitle = fields.containsKey('section_title');
    final hasTermFields =
        fields.keys.any((String key) => key.startsWith('term_'));

    if (type.contains('term-user') ||
        hasSectionTitle ||
        hasTermFields ||
        type.isNotEmpty) {
      final sectionTitle =
          fields['section_title'] ?? fields['title'] ?? fields['heading'] ?? '';
      final emailAddress = fields['email_address'] ?? '';

      // Extract terms dynamically (supports term_1_title, term_1_text, term_1_text_1, etc. up to term 30)
      List<Map<String, dynamic>> parsedTerms = [];
      for (int i = 1; i <= 30; i++) {
        final termTitle = fields['term_${i}_title']?.toString() ?? '';
        final termSubtitle = fields['term_${i}_subtitle']?.toString() ??
            fields['term_${i}_subtitle_1']?.toString() ??
            '';

        List<String> paragraphs = [];
        if (fields.containsKey('term_${i}_text')) {
          paragraphs.add(fields['term_${i}_text'].toString());
        }
        if (fields.containsKey('term_${i}_text_1')) {
          paragraphs.add(fields['term_${i}_text_1'].toString());
        }
        if (fields.containsKey('term_${i}_text_2')) {
          paragraphs.add(fields['term_${i}_text_2'].toString());
        }
        if (fields.containsKey('term_${i}_text_3')) {
          paragraphs.add(fields['term_${i}_text_3'].toString());
        }

        if (termTitle.isNotEmpty ||
            termSubtitle.isNotEmpty ||
            paragraphs.isNotEmpty) {
          parsedTerms.add({
            'title': termTitle,
            'subtitle': termSubtitle,
            'paragraphs': paragraphs,
          });
        }
      }

      // Fallback to standard fields if no sequential terms were parsed
      final standardTitle = fields['title'] ?? fields['heading'] ?? '';
      final standardContent = fields['content'] ??
          fields['description'] ??
          fields['body'] ??
          fields['textblock'] ??
          '';

      if (parsedTerms.isEmpty &&
          sectionTitle.isEmpty &&
          emailAddress.isEmpty &&
          standardTitle.isEmpty &&
          standardContent.isEmpty) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16.0, vertical: 12.0), // ✨ Increased vertical padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✨ ENHANCED: Section Header with left accent bar
            if (sectionTitle.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(
                    left: 4.0, top: 8.0, bottom: 12.0), // ✨ Adjusted padding
                child: Row(
                  children: [
                    // Left accent bar with theme color
                    Container(
                      width: 5, // ✨ Slightly thicker
                      height: 30, // ✨ Slightly taller
                      decoration: BoxDecoration(
                        color: context.themePrimaryColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 14), // ✨ Increased spacing
                    Expanded(
                      child: Text(
                        sectionTitle,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize:
                              22.0, // ✨ Slightly smaller from 24 for better hierarchy
                          fontWeight: FontWeight.bold,
                          color: context.themeTextColor,
                          letterSpacing: -0.4,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                  height: 1.0, thickness: 1.2, color: context.themeBorderColor),
              const SizedBox(height: 24.0), // ✨ Increased spacing
            ],

            // ✨ ENHANCED: Sequentially Render parsed terms with enhanced card styling
            ...parsedTerms.asMap().entries.map((entry) {
              final index = entry.key;
              final term = entry.value;
              final tTitle = term['title'] as String;
              final tSubtitle = term['subtitle'] as String;
              final tParagraphs = term['paragraphs'] as List<String>;

              return AnimatedOpacity(
                duration: Duration(milliseconds: 300 + (index * 50)),
                opacity: 1.0,
                child: Container(
                  margin: const EdgeInsets.only(
                      bottom: 20.0), // ✨ Increased from 16
                  decoration: BoxDecoration(
                    color: context
                        .themeWhiteColor, // ✨ Slight off-white instead of pure white
                    borderRadius:
                        BorderRadius.circular(14.0), // ✨ Increased from 12
                    border: Border.all(
                      color: context.themeBorderColor,
                      width: 1.2, // ✨ Increased from 0.8
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(0.1), // ✨ Stronger shadow
                        blurRadius: 14, // ✨ Increased from 8
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✨ Top accent bar on card
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: context.themePrimaryColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            topRight: Radius.circular(14),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(
                            18.0), // ✨ Increased padding from 16
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (tTitle.isNotEmpty) ...[
                              Text(
                                tTitle,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 17.0, // ✨ Slightly smaller from 18
                                  fontWeight: FontWeight.bold,
                                  color: context.themeTextColor,
                                  letterSpacing: -0.3,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(
                                  height: 10.0), // ✨ Increased from 8
                            ],
                            if (tSubtitle.isNotEmpty) ...[
                              Text(
                                tSubtitle,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                  color: context.themeSecondrytext,
                                  letterSpacing: -0.2,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(
                                  height: 10.0), // ✨ Increased from 8
                            ],
                            if ((tTitle.isNotEmpty || tSubtitle.isNotEmpty) &&
                                tParagraphs.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0), // ✨ Increased from 8
                                child: Divider(
                                    height: 1.0,
                                    color: context.themeBorderColor),
                              ),
                            ...tParagraphs.map((para) => Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 12.0), // ✨ Increased from 8
                                  child: Html(
                                    data: para,
                                    style: {
                                      "body": Style(
                                        fontSize: FontSize(15.0),
                                        color: context.themeTextColor,
                                        margin: Margins.zero,
                                        padding: HtmlPaddings.zero,
                                        lineHeight: const LineHeight(
                                            1.7), // ✨ Increased from 1.6
                                      ),
                                      "p": Style(
                                        margin: Margins.only(
                                            bottom:
                                                10.0), // ✨ Increased spacing
                                      ),
                                      "strong": Style(
                                        fontWeight: FontWeight.bold,
                                        color: context.themeTextColor,
                                      ),
                                    },
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            // ✨ ENHANCED: Render standard title / content with enhanced card styling
            if (standardTitle.isNotEmpty || standardContent.isNotEmpty)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: 1.0,
                child: Container(
                  margin: const EdgeInsets.only(
                      bottom: 20.0), // ✨ Increased from 16
                  decoration: BoxDecoration(
                    color: context.themeWhiteColor, // ✨ Slight off-white
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(
                      color: context.themeBorderColor,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✨ Top accent bar on card
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: context.themePrimaryColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            topRight: Radius.circular(14),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (standardTitle.isNotEmpty) ...[
                              Text(
                                standardTitle,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.bold,
                                  color: context.themeTextColor,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              Divider(
                                  height: 1.0, color: context.themeBorderColor),
                              const SizedBox(height: 16.0),
                            ],
                            if (standardContent.isNotEmpty)
                              Html(
                                data: standardContent,
                                style: {
                                  "body": Style(
                                    fontSize: FontSize(15.0),
                                    color: context.themeTextColor,
                                    margin: Margins.zero,
                                    padding: HtmlPaddings.zero,
                                    lineHeight: const LineHeight(1.7),
                                  ),
                                  "p": Style(
                                    margin: Margins.only(bottom: 10.0),
                                  ),
                                  "strong": Style(
                                    fontWeight: FontWeight.bold,
                                    color: context.themeTextColor,
                                  ),
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ✨ ENHANCED: Email Contact Widget
            if (emailAddress.isNotEmpty) ...[
              const SizedBox(height: 16.0), // ✨ Increased from 12
              _buildEmailContactCard(context, emailAddress),
            ],
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// Parses `<prefix>_title` / `<prefix>_content` pairs in field order.
  List<MapEntry<String, String>> _parseFlatSections(
      Map<String, dynamic> fields) {
    final sections = <MapEntry<String, String>>[];
    for (final key in fields.keys) {
      if (!key.endsWith('_content')) continue;
      final prefix = key.substring(0, key.length - '_content'.length);
      final title = fields['${prefix}_title']?.toString().trim() ?? '';
      final body = fields[key]?.toString().trim() ?? '';
      if (title.isEmpty && body.isEmpty) continue;
      sections.add(MapEntry(title, body));
    }
    return sections;
  }

  Widget _buildFlatPolicy(
    BuildContext context,
    Map<String, dynamic> fields,
    List<MapEntry<String, String>> sections,
  ) {
    final subtitle = fields['subtitle_text']?.toString() ?? '';
    final lastUpdated = fields['last_updated_date']?.toString() ?? '';
    final copyright = fields['copyright_text']?.toString() ?? '';
    final contactTitle = fields['contact_title']?.toString() ?? '';
    final contactIntro = fields['contact_intro']?.toString() ?? '';
    final contactEmail = fields['contact_email']?.toString() ?? '';

    final htmlStyle = {
      "body": Style(
        fontSize: FontSize(15.0),
        color: context.themeTextColor,
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
        lineHeight: const LineHeight(1.7),
      ),
      "p": Style(margin: Margins.only(bottom: 10.0)),
      "strong":
          Style(fontWeight: FontWeight.bold, color: context.themeTextColor),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15.0,
                fontWeight: FontWeight.w600,
                color: context.themeSecondrytext,
              ),
            ),
          if (lastUpdated.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Last updated: $lastUpdated',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  color: context.themeSecondrytext,
                ),
              ),
            ),
          const SizedBox(height: 16.0),
          ...sections.map((section) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: context.themeWhiteColor,
                  borderRadius: BorderRadius.circular(14.0),
                  border:
                      Border.all(color: context.themeBorderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.themePrimaryColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(14),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (section.key.isNotEmpty) ...[
                            Text(
                              section.key,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold,
                                color: context.themeTextColor,
                                letterSpacing: -0.3,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                          ],
                          if (section.value.isNotEmpty)
                            Html(data: section.value, style: htmlStyle),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          if (contactTitle.isNotEmpty || contactIntro.isNotEmpty) ...[
            if (contactTitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
                child: Text(
                  contactTitle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                    color: context.themeTextColor,
                  ),
                ),
              ),
            if (contactIntro.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
                child: Text(
                  contactIntro,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.0,
                    height: 1.6,
                    color: context.themeSecondrytext,
                  ),
                ),
              ),
          ],
          if (contactEmail.isNotEmpty)
            _buildEmailContactCard(context, contactEmail),
          if (copyright.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Center(
                child: Text(
                  '© $copyright',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.0,
                    color: context.themeSecondrytext,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ✨ ENHANCED: Error view with theme styling
  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: context.themePrimaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: context.themePrimaryColor,
                size: 60.0, // ✨ Increased from 56
              ),
            ),
            const SizedBox(height: 24.0), // ✨ Increased spacing
            Text(
              "Unable to load policy",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: context.themeTextColor,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14.0), // ✨ Increased spacing
            Text(
              "Please check your network connectivity and try again.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.themeSecondrytext,
                fontSize: 15.0,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32.0), // ✨ Increased spacing
            ElevatedButton.icon(
              onPressed: () => controller.fetchPolicy(controller.policyType,
                  forceRefresh: true),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text("Retry",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.themePrimaryColor,
                foregroundColor: context.themeWhiteColor,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32.0, vertical: 14.0),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(32.0), // ✨ Increased from 30
                ),
                elevation: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✨ ENHANCED: Empty view with theme styling
  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: themePrimaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.document_scanner_outlined,
                color: themePrimaryColor.withOpacity(0.7),
                size: 60.0,
              ),
            ),
            const SizedBox(height: 24.0),
            const Text(
              "No policy content available",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: themeTextColor,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton.icon(
              onPressed: () => controller.fetchPolicy(controller.policyType,
                  forceRefresh: true),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text("Refresh",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: themePrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32.0, vertical: 14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
                elevation: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✨ ENHANCED: Beautiful text block with improved typography and theme
  Widget _buildBeautifulTextBlock(BuildContext context, String text) {
    if (text.isEmpty) return const SizedBox.shrink();

    final cleanText = text.replaceAll('[Insert Date]', 'May 21, 2026');

    final List<String> lines = cleanText.split('\n');
    final List<Widget> widgets = [];

    bool isPreviousLineEmpty = false;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Handle empty lines (paragraph breaks)
      if (line.trim().isEmpty) {
        if (!isPreviousLineEmpty && widgets.isNotEmpty) {
          // Add spacing for paragraph breaks
          widgets.add(const SizedBox(height: 14.0)); // ✨ Increased from 12
          isPreviousLineEmpty = true;
        }
        continue;
      }

      isPreviousLineEmpty = false;
      final trimmedLine = line.trim();

      // Title handling (first line only)
      if (i == 0) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0), // ✨ Increased from 8
            child: Text(
              trimmedLine,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: context.themeTextColor,
                letterSpacing: -0.5,
                height: 1.35,
              ),
            ),
          ),
        );
        continue;
      }

      // Section headers (1., 2., 3., etc.) - Enhanced with left accent bar
      final sectionReg = RegExp(r'^\d+\.\s+');
      if (sectionReg.hasMatch(trimmedLine)) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(
                top: 24.0, bottom: 10.0), // ✨ Increased spacing
            child: Row(
              children: [
                Container(
                  width: 5, // ✨ Slightly thicker
                  height: 22, // ✨ Slightly taller
                  decoration: BoxDecoration(
                    color: themePrimaryColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 14), // ✨ Increased spacing
                Expanded(
                  child: Text(
                    trimmedLine,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 19.0,
                      fontWeight: FontWeight.bold,
                      color: context.themeTextColor,
                      letterSpacing: -0.3,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Check if this line starts with a bullet point
      final bulletMatch =
          RegExp(r'^[\u2022\u25CF\-\*]\s*').hasMatch(trimmedLine);

      if (bulletMatch) {
        // Bullet point line
        final bulletContent = trimmedLine
            .replaceFirst(RegExp(r'^[\u2022\u25CF\-\*]\s*'), '')
            .trim();

        // Check if bullet contains a colon for bold label
        if (bulletContent.contains(':') && bulletContent.indexOf(':') < 40) {
          final colonIndex = bulletContent.indexOf(':');
          final label = bulletContent.substring(0, colonIndex).trim();
          final description = bulletContent.substring(colonIndex + 1).trim();

          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0), // ✨ Increased from 6
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                        top: 8.0, right: 14.0), // ✨ Adjusted margins
                    width: 7.0, // ✨ Slightly larger
                    height: 7.0,
                    decoration: BoxDecoration(
                      color: themePrimaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15.0,
                          color: context.themeTextColor,
                          height: 1.7, // ✨ Increased from 1.6
                        ),
                        children: [
                          TextSpan(
                            text: "$label: ",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: description),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0), // ✨ Increased from 6
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8.0, right: 14.0),
                    width: 7.0,
                    height: 7.0,
                    decoration: BoxDecoration(
                      color: themePrimaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      bulletContent,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15.0,
                        color: context.themeTextColor,
                        height: 1.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        continue;
      }

      // Regular text line (no bullet, no section header)
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0), // ✨ Increased from 6
          child: Text(
            trimmedLine,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15.0,
              color: context.themeTextColor,
              height: 1.7, // ✨ Increased from 1.6
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  // ✨ ENHANCED: Email contact card with theme styling and shadow
  Widget _buildEmailContactCard(BuildContext context, String emailAddress) {
    return AnimatedOpacity(
      duration: themeAnimationDuration,
      opacity: 1.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0), // ✨ Increased from 14
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 14, // ✨ Increased from 12
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Card(
          color: const Color(0xFFFEFEFE), // ✨ Slight off-white
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(
                color: themeBorderColor, width: 1.2), // ✨ Thicker border
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0), // ✨ Increased from 18
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12), // ✨ Increased from 10
                  decoration: BoxDecoration(
                    color: themePrimaryColor
                        .withOpacity(0.12), // ✨ Slightly more visible
                    borderRadius:
                        BorderRadius.circular(14), // ✨ Increased from 12
                  ),
                  child: Icon(
                    Icons.mail_outline_rounded,
                    color: themePrimaryColor,
                    size: 34.0, // ✨ Increased from 32
                  ),
                ),
                const SizedBox(width: 18.0), // ✨ Increased spacing
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Have questions about these terms?",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 15.0,
                          color: themeTextColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 8.0), // ✨ Increased from 6
                      Text(
                        emailAddress,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: themePrimaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15.0,
                          decoration: TextDecoration.underline,
                          decorationColor: themePrimaryColor.withOpacity(0.6),
                          decorationThickness: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
