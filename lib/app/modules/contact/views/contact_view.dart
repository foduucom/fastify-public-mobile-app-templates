import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zouhi/app/data/models/contact_broadcast_sections.dart';
import 'package:zouhi/app/modules/contact/controller/contact_controller.dart';
import 'package:zouhi/components/check_internet_widget.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';
class ContactView extends GetView<ContactController> {
  const ContactView({Key? key}) : super(key: key);

  Future<void> _open(Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _handleCardTap(ContactInfoCard card) {
    if (card.isEmail) {
      final email = card.text.trim();
      if (email.isNotEmpty) {
        _open(Uri(scheme: 'mailto', path: email));
      }
    } else if (card.isPhone) {
      final phone = card.cleanPhone;
      if (phone.isNotEmpty) {
        _open(Uri(scheme: 'tel', path: phone));
      }
    } else if (card.text.toLowerCase().startsWith('http')) {
      _open(Uri.parse(card.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeBackground,
      appBar: AppBar(
        title: const Text('Contact Us'),
        elevation: 0.0,
      ),
      body: GestureDetector(
        onTap: () => HelperFunctions().closeKeyboard(context),
        child: FoduuCheckInternetBody(
          child: Obx(() {
            final sections = controller.sectionsData.value;
            final isInitialLoading = controller.isPageLoading.value &&
                controller.rawSections.isEmpty &&
                sections.infoBadges.cards.isEmpty;

            if (isInitialLoading) {
              return Center(child: HelperFunctions().loadingIndicator());
            }

            return RefreshIndicator(
              onRefresh: controller.fetchContactLayout,
              color: context.themePrimaryColor,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.zero,
                children: [
                  // Section 1: Enterprise Optical Fiber Hero Banner
                  _ContactHeroBanner(data: sections.heroSlider),

                  // Section 2: Contact Information Badges
                  _ContactInfoBadgesSection(
                    data: sections.infoBadges,
                    onCardTap: _handleCardTap,
                  ),

                  // Section 3: Mid-Page Illustration Banner (Parent Web Parity)
                  if (sections.promoBanner != null &&
                      sections.promoBanner!.imageUrl.isNotEmpty)
                    _ContactIllustrationBanner(
                      data: sections.promoBanner!,
                      onTap: () {
                        final link = sections.promoBanner!.link;
                        if (link.isNotEmpty && link.startsWith('http')) {
                          _open(Uri.parse(link));
                        }
                      },
                    ),

                  // Section 4: Modern Contact Form Card
                  _ContactFormCard(
                    data: sections.formBuilder,
                    controller: controller,
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Section 1: Enterprise Optical Fiber Hero Banner matching Parent Website
class _ContactHeroBanner extends StatelessWidget {
  const _ContactHeroBanner({required this.data});
  final ContactHeroSliderData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: data.height.clamp(170, 230).toDouble(),
      decoration: BoxDecoration(color: context.themeSecondryColor),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (data.imageUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: data.imageUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => CachedNetworkImage(
                imageUrl:
                    'https://vision.foduu.store/images/2026/08/29/slide-2-73b3aa6d.webp',
                fit: BoxFit.cover,
              ),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0A192D).withValues(alpha: 0.45),
                  const Color(0xFF0A192D).withValues(alpha: 0.88),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Glassmorphism Breadcrumb Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.home_outlined,
                          size: 13,
                          color: Colors.white.withValues(alpha: 0.90)),
                      const SizedBox(width: 5),
                      Text(
                        'Home / Contact Us',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  data.heading.isNotEmpty ? data.heading : 'Contact Us',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 44,
                  height: 3,
                  decoration: BoxDecoration(
                    color: context.themePrimaryColor,
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
}

/// Section 2: Contact Information Badges Section
class _ContactInfoBadgesSection extends StatelessWidget {
  const _ContactInfoBadgesSection({
    required this.data,
    required this.onCardTap,
  });

  final ContactInfoBadgesData data;
  final void Function(ContactInfoCard) onCardTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.eyebrow.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: context.themePrimaryLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                data.eyebrow.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: context.themePrimaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            data.title.isNotEmpty ? data.title : 'Contact Information',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: context.themeTextColor,
            ),
          ),
          if (data.subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              data.subtitle,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                height: 1.5,
                color: context.themeSecondrytext,
              ),
            ),
          ],
          const SizedBox(height: 16),
          for (final card in data.cards)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ContactCardTile(
                card: card,
                onTap: () => onCardTap(card),
              ),
            ),
        ],
      ),
    );
  }
}

/// Single interactive Contact Card
class _ContactCardTile extends StatelessWidget {
  const _ContactCardTile({required this.card, required this.onTap});

  final ContactInfoCard card;
  final VoidCallback onTap;

  IconData get _fallbackIcon {
    if (card.isEmail) return Icons.mail_outline_rounded;
    if (card.isPhone) return Icons.phone_in_talk_outlined;
    return Icons.location_on_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.themeWhiteColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 2.0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.themeBorderColor.withValues(alpha: 0.70),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Circular/Rounded Gradient Icon Badge (Parent Web Parity)
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.themePrimaryColor,
                      context.themeSecondryColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: context.themePrimaryColor.withValues(alpha: 0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: card.image.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: card.fullImageUrl,
                          width: 26,
                          height: 26,
                          fit: BoxFit.contain,
                          color: Colors.white,
                          errorWidget: (_, __, ___) =>
                              Icon(_fallbackIcon, color: Colors.white, size: 24),
                        )
                      : Icon(_fallbackIcon, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.heading,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: context.themeSecondrytext,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      card.text,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.themeTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: context.themePrimaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: context.themePrimaryColor,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section 3: High-Impact Mid-Page Contact Illustration Banner
class _ContactIllustrationBanner extends StatelessWidget {
  const _ContactIllustrationBanner({
    required this.data,
    required this.onTap,
  });

  final ContactPromoBannerData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Semantics(
        button: true,
        label: 'Contact Us Illustration Banner',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(data.borderRadius),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(data.borderRadius),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(data.borderRadius),
              child: CachedNetworkImage(
                imageUrl: data.imageUrl,
                height: data.height.clamp(150, 220).toDouble(),
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: data.height.clamp(150, 220).toDouble(),
                  color: Colors.grey.withValues(alpha: 0.12),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => CachedNetworkImage(
                  imageUrl:
                      'https://vision.foduu.store/images/2026/08/29/3-aaed866d.webp',
                  height: data.height.clamp(150, 220).toDouble(),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Section 4: Modern State-of-the-Art Contact Form Card
class _ContactFormCard extends StatelessWidget {
  const _ContactFormCard({
    required this.data,
    required this.controller,
  });

  final ContactFormBuilderData data;
  final ContactController controller;

  IconData _iconForField(String name, String type) {
    final lowerName = name.toLowerCase();
    final lowerType = type.toLowerCase();
    if (lowerType == 'email' || lowerName.contains('email')) {
      return Icons.mail_outline_rounded;
    }
    if (lowerType == 'tel' ||
        lowerName.contains('phone') ||
        lowerName.contains('mobile')) {
      return Icons.phone_outlined;
    }
    if (lowerType == 'textarea' ||
        lowerName == 'message' ||
        lowerName.contains('message')) {
      return Icons.chat_bubble_outline_rounded;
    }
    return Icons.person_outline_rounded;
  }

  String _cleanPlaceholder(String name, String rawPlaceholder) {
    if (rawPlaceholder.isNotEmpty && !rawPlaceholder.contains('.....')) {
      return rawPlaceholder;
    }
    final lower = name.toLowerCase();
    if (lower.contains('name')) return 'e.g. John Doe';
    if (lower.contains('email')) return 'name@company.com';
    if (lower.contains('phone') || lower.contains('mobile')) {
      return '+91 98765 43210';
    }
    if (lower.contains('message')) {
      return 'Describe your inquiry or optical product requirements...';
    }
    return 'Enter $name...';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: context.themeWhiteColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 22,
                    decoration: BoxDecoration(
                      color: context.themePrimaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    data.title.isNotEmpty ? data.title : 'Send Us a Message',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: context.themeSecondryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Have a question or looking for enterprise quotes? Fill out the details below and our team will get back to you.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  height: 1.45,
                  color: context.themeSecondrytext,
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                final fields = controller.formFields;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: fields.map((field) {
                    final ctrl = controller.controllerForField(field);
                    final isEmail = field.type == 'email' ||
                        field.name.toLowerCase().contains('email');
                    final isTel = field.type == 'tel' ||
                        field.name.toLowerCase().contains('phone') ||
                        field.name.toLowerCase().contains('mobile');
                    final isMessage = field.type == 'textarea' ||
                        field.name.toLowerCase() == 'message' ||
                        field.label.toLowerCase().contains('message');

                    List<TextInputFormatter>? formatters;
                    TextInputType keyType = TextInputType.text;
                    int maxLine = 1;

                    if (isEmail) {
                      keyType = TextInputType.emailAddress;
                    } else if (isTel) {
                      keyType = TextInputType.phone;
                      formatters = [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(15),
                      ];
                    } else if (isMessage) {
                      keyType = TextInputType.multiline;
                      maxLine = 4;
                    } else if (field.name == 'Name' ||
                        field.label.toLowerCase().contains('name')) {
                      formatters = [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z\s]')),
                      ];
                    }

                    final labelText =
                        field.label.isNotEmpty ? field.label : field.name;
                    final placeholder =
                        _cleanPlaceholder(labelText, field.placeholder);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                labelText,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: context.themeTextColor,
                                ),
                              ),
                              if (field.required)
                                const Text(
                                  ' *',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          TextFormField(
                            controller: ctrl,
                            keyboardType: keyType,
                            maxLines: maxLine,
                            inputFormatters: formatters,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: context.themeTextColor,
                            ),
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (field.required && v.isEmpty) {
                                return 'Please enter $labelText';
                              }
                              if (isEmail &&
                                  v.isNotEmpty &&
                                  !GetUtils.isEmail(v)) {
                                return 'Enter a valid email address';
                              }
                              if (isTel && v.isNotEmpty) {
                                final minDigits = field.min ?? 10;
                                if (v.length < minDigits) {
                                  return 'Please enter valid $minDigits-digit phone number';
                                }
                              }
                              if (isMessage && v.isNotEmpty && v.length < 3) {
                                return 'Message must be at least 3 characters';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: placeholder,
                              hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13.5,
                                color: context.themeSecondrytext
                                    .withValues(alpha: 0.70),
                              ),
                              prefixIcon: isMessage
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 50, left: 12, right: 12),
                                      child: Icon(
                                        _iconForField(field.name, field.type),
                                        size: 20,
                                        color: context.themeSecondrytext,
                                      ),
                                    )
                                  : Icon(
                                      _iconForField(field.name, field.type),
                                      size: 20,
                                      color: context.themeSecondrytext,
                                    ),
                              filled: true,
                              fillColor: context.themeBackground,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: context.themePrimaryColor,
                                  width: 1.5,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.redAccent,
                                  width: 1,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.redAccent,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: 2),
              // Privacy Policy Checkbox
              Obx(() => Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: controller.agreePolicy.value,
                          onChanged: (val) {
                            controller.agreePolicy.value = val ?? false;
                          },
                          activeColor: context.themePrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            controller.agreePolicy.toggle();
                          },
                          child: RichText(
                            text: TextSpan(
                              text: 'I agree with the site ',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: context.themeTextColor,
                              ),
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.toNamed(Routes.POLICY_DETAIL,
                                          arguments: {'type': 'privacy'});
                                    },
                                    child: Text(
                                      'privacy policy',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: context.themePrimaryColor,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
              const SizedBox(height: 22),
              // Submit Button with icon and elevation
              Obx(() => controller.isLoading.value
                  ? Center(
                      child: CircularProgressIndicator(
                          color: context.themePrimaryColor))
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text(
                          'SUBMIT MESSAGE',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        onPressed: () {
                          HelperFunctions().closeKeyboard(context);
                          controller.sendFormData();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.themePrimaryColor,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}

