import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zouhi/app/data/models/privacy_sections.dart';
import 'package:zouhi/app/data/models/terms_sections.dart';
import 'package:zouhi/app/modules/helpandsupport/controllers/policy_controller.dart';
import 'package:zouhi/constants/theme_ext.dart';

Future<void> _openPolicyUrl(String rawUrl) async {
  if (Get.isRegistered<PolicyController>()) {
    await Get.find<PolicyController>().openUrl(rawUrl);
    return;
  }
  final uri = Uri.tryParse(rawUrl);
  if (uri != null && await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Renders an individual CMS `rich_text` or `text_block` section for
/// Privacy Policy (`https://vision.foduu.store/privacy-policy`) or
/// Terms & Conditions (`https://vision.foduu.store/terms-conditions`)
/// inside `FoduuStudioLayoutView`, preserving exact document styling
/// while supporting 1:1 CMS reordering, visibility toggles, and block injection.
class PolicySectionWidget extends StatelessWidget {
  final Map<String, dynamic> contentJson;
  final bool isPrivacy;

  const PolicySectionWidget({
    super.key,
    required this.contentJson,
    required this.isPrivacy,
  });

  factory PolicySectionWidget.fromContentJson(
    Map<String, dynamic> json, {
    required bool isPrivacy,
  }) {
    return PolicySectionWidget(
      contentJson: json,
      isPrivacy: isPrivacy,
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = (contentJson['_section_type'] ??
            (contentJson.containsKey('html_content')
                ? 'rich_text'
                : 'text_block'))
        .toString();
    final id = contentJson['id']?.toString() ?? '';

    final sectionMap = {
      'type': type,
      'id': id,
      'visible': true,
      'content_json': contentJson,
    };

    if (isPrivacy) {
      return _buildPrivacySection(context, sectionMap, type);
    }
    return _buildTermsSection(context, sectionMap, type);
  }

  Widget _buildPrivacySection(
    BuildContext context,
    Map<String, dynamic> sectionMap,
    String type,
  ) {
    final parsed = PrivacyPageData.fromSections([sectionMap]);
    final isHeaderSection = type == 'rich_text' &&
        (contentJson['html_content'] ?? contentJson['text'] ?? '')
            .toString()
            .toLowerCase()
            .contains('privacy policy');

    // Avoid falling back to full canonical page when a single section is empty
    final blocks = parsed.blocks;
    if (!isHeaderSection &&
        blocks.length == PrivacyPageData.canonical().blocks.length &&
        contentJson['id'] != 'canonical_all') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.themeWhiteColor,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: context.themeBorderColor.withValues(alpha: 0.75),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isHeaderSection) ...[
              Text(
                'Privacy Policy',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: context.themeTextColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                'Vision Infrastructure Solutions',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: context.themeSecondrytext,
                ),
              ),
              const SizedBox(height: 12.0),
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
                  height: 1.0, thickness: 1.0, color: context.themeBorderColor),
              const SizedBox(height: 8.0),
            ],
            ...blocks.map((block) => _buildPrivacyBlock(context, block)),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsSection(
    BuildContext context,
    Map<String, dynamic> sectionMap,
    String type,
  ) {
    final parsed = TermsPageData.fromSections([sectionMap]);
    final isHeaderSection = type == 'rich_text' &&
        (contentJson['html_content'] ?? contentJson['text'] ?? '')
            .toString()
            .toLowerCase()
            .contains('terms');

    final blocks = parsed.blocks;
    if (!isHeaderSection &&
        blocks.length == TermsPageData.canonical().blocks.length &&
        contentJson['id'] != 'canonical_all') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.themeWhiteColor,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: context.themeBorderColor.withValues(alpha: 0.75),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isHeaderSection) ...[
              Text(
                'Terms & Conditions',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: context.themeTextColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12.0),
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
                  height: 1.0, thickness: 1.0, color: context.themeBorderColor),
              const SizedBox(height: 8.0),
            ],
            ...blocks.map((block) => _buildTermsBlock(context, block)),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyBlock(BuildContext context, PrivacyContentBlock block) {
    switch (block.type) {
      case PrivacyBlockType.heading:
        return Padding(
          padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
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
        return _buildDynamicLinkedText(
          context,
          block.text,
          size: block.size,
          alignment: block.alignment,
        );

      case PrivacyBlockType.bulletList:
        return _buildPrivacyBulletList(context, block);

      case PrivacyBlockType.contact:
        return _buildPrivacyContactBlock(context, block);

      case PrivacyBlockType.lastUpdated:
        return Container(
          width: double.infinity,
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
      BuildContext context, PrivacyContentBlock block) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        ...block.listItems.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 9.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
        }),
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
    );
  }

  Widget _buildPrivacyContactBlock(
      BuildContext context, PrivacyContentBlock block) {
    final email = block.email ?? 'sales@visioninfrastructurecanada.com';
    final website = block.website ?? 'www.visioninfrastructurecanada.com';
    final companyName = block.companyName ?? 'Vision Infrastructure Canada';
    final webUrl = block.url ??
        (website.startsWith('http') ? website : 'https://$website');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (block.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: Text(
              block.text,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.5,
                height: 1.6,
                color: context.themeTextColor,
              ),
            ),
          ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.themeWhiteColor,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: context.themeBorderColor.withValues(alpha: 0.9),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 14.0),
                decoration: BoxDecoration(
                  color: context.themePrimaryColor.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(13.0),
                    topRight: Radius.circular(13.0),
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => _openPolicyUrl('mailto:$email'),
                      child: Row(
                        children: [
                          Icon(Icons.mail_outline_rounded,
                              size: 18, color: context.themePrimaryColor),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              email,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: context.themePrimaryColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    InkWell(
                      onTap: () => _openPolicyUrl(webUrl),
                      child: Row(
                        children: [
                          Icon(Icons.language_rounded,
                              size: 18, color: context.themePrimaryColor),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              website,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: context.themePrimaryColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          Icon(Icons.open_in_new_rounded,
                              size: 15, color: context.themePrimaryColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTermsBlock(BuildContext context, TermsContentBlock block) {
    switch (block.type) {
      case TermsBlockType.heading:
        return Padding(
          padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
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
        return _buildDynamicLinkedText(
          context,
          block.text,
          size: block.size,
          alignment: block.alignment,
        );

      case TermsBlockType.contact:
        final portalUrl = block.url ?? 'https://vision.foduu.store/contact';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDynamicLinkedText(
              context,
              block.text,
              size: block.size,
              alignment: block.alignment,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _openPolicyUrl(portalUrl),
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: const Text('Open Contact Portal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.themePrimaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        );

      case TermsBlockType.lastUpdated:
        return Container(
          width: double.infinity,
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

  Widget _buildDynamicLinkedText(
    BuildContext context,
    String text, {
    double size = 15.0,
    String alignment = 'left',
  }) {
    TextAlign textAlign = TextAlign.left;
    if (alignment == 'center') textAlign = TextAlign.center;
    if (alignment == 'right') textAlign = TextAlign.right;

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
        spans.add(TextSpan(text: sanitizedText.substring(lastEnd, match.start)));
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
            onTap: () => _openPolicyUrl(targetUrl),
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
}
