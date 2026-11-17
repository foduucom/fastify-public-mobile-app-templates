import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foduu_ecommerce/app/data/models/contact_sections.dart';
import 'package:foduu_ecommerce/app/modules/contact/controller/contact_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Section 1: Hero Header Banner Widget
// ─────────────────────────────────────────────────────────────────────────────
class ContactHeroBannerWidget extends StatelessWidget {
  const ContactHeroBannerWidget({Key? key, required this.data})
      : super(key: key);
  final ContactHeroHeaderData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: data.height.clamp(170, 230).toDouble(),
      decoration: BoxDecoration(color: context.surfaceColor),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (data.imageUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: data.imageUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                color: const Color(0xFF0F172A),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0F172A).withValues(alpha: 0.55),
                  const Color(0xFF0F172A).withValues(alpha: 0.92),
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
                // Breadcrumb Badge
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
                          size: 13, color: Colors.white.withValues(alpha: 0.9)),
                      const SizedBox(width: 5),
                      Text(
                        'Home / Contact Us',
                        style: TextStyle(
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
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                if (data.subHeading.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    data.subHeading,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Container(
                  width: 44,
                  height: 3,
                  decoration: BoxDecoration(
                    color: context.primaryColor,
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

// ─────────────────────────────────────────────────────────────────────────────
// Section 2: Dynamic Form Builder Card Widget
// ─────────────────────────────────────────────────────────────────────────────
class ContactFormCardWidget extends StatelessWidget {
  const ContactFormCardWidget({
    Key? key,
    required this.data,
    required this.controller,
  }) : super(key: key);

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
      return '+1 (555) 000-0000';
    }
    if (lower.contains('message')) {
      return 'How can our team help you?';
    }
    return 'Enter $name...';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
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
                      color: context.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    data.title.isNotEmpty ? data.title : 'Send a Message',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: context.onSurfaceColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Have questions or need assistance? Fill out the details below and our team will get back to you promptly.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  color: context.onSurfaceColor.withValues(alpha: 0.65),
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
                    int maxLines = 1;

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
                      maxLines = 4;
                    } else if (field.name.toLowerCase().contains('name')) {
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
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: context.onSurfaceColor,
                                ),
                              ),
                              if (field.required)
                                const Text(
                                  ' *',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          TextFormField(
                            controller: ctrl,
                            keyboardType: keyType,
                            maxLines: maxLines,
                            inputFormatters: formatters,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.onSurfaceColor,
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
                                fontSize: 13.5,
                                color: context.onSurfaceColor.withValues(alpha: 0.4),
                              ),
                              prefixIcon: isMessage
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 52, left: 12, right: 12),
                                      child: Icon(
                                        _iconForField(field.name, field.type),
                                        size: 20,
                                        color: context.onSurfaceColor
                                            .withValues(alpha: 0.55),
                                      ),
                                    )
                                  : Icon(
                                      _iconForField(field.name, field.type),
                                      size: 20,
                                      color: context.onSurfaceColor
                                          .withValues(alpha: 0.55),
                                    ),
                              filled: true,
                              fillColor: context.backgroundColor,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? Colors.white12
                                      : Colors.grey.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: context.primaryColor,
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
              // Privacy Policy Consent
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
                          activeColor: context.primaryColor,
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
                                fontSize: 13,
                                color: context.onSurfaceColor,
                              ),
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.toNamed(Routes.PRIVACY_POLICY);
                                    },
                                    child: Text(
                                      'privacy policy',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: context.primaryColor,
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
              // Submit Button
              Obx(() => controller.isSubmitting.value
                  ? Center(child: HelperFunctions().loadingIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text(
                          'SUBMIT MESSAGE',
                          style: TextStyle(
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
                          backgroundColor: context.primaryColor,
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

// ─────────────────────────────────────────────────────────────────────────────
// Section 3: Contact Channels Section (2-Column Grid)
// ─────────────────────────────────────────────────────────────────────────────
class ContactChannelsWidget extends StatelessWidget {
  const ContactChannelsWidget({
    Key? key,
    required this.data,
    required this.onCardTap,
  }) : super(key: key);

  final ContactChannelsData data;
  final void Function(ContactChannelCard) onCardTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.eyebrow.isNotEmpty) ...[
            Text(
              data.eyebrow.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: context.primaryColor,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            data.title.isNotEmpty ? data.title : 'Contact Channels',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.cards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final card = data.cards[index];
              return _ContactChannelTile(
                card: card,
                onTap: () => onCardTap(card),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ContactChannelTile extends StatelessWidget {
  const _ContactChannelTile({required this.card, required this.onTap});

  final ContactChannelCard card;
  final VoidCallback onTap;

  IconData get _fallbackIcon {
    if (card.isEmail) return Icons.mail_outline_rounded;
    if (card.isPhone) return Icons.phone_in_talk_outlined;
    if (card.heading.toLowerCase().contains('hour') ||
        card.heading.toLowerCase().contains('office')) {
      return Icons.access_time_rounded;
    }
    return Icons.location_on_outlined;
  }

  Widget _buildIcon(BuildContext context) {
    final img = card.image;

    if (img.isNotEmpty) {
      if (img.endsWith('.svg')) {
        return SvgPicture.network(
          card.fullImageUrl,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(context.primaryColor, BlendMode.srcIn),
          placeholderBuilder: (_) =>
              Icon(_fallbackIcon, color: context.primaryColor, size: 24),
        );
      }
      return CachedNetworkImage(
        imageUrl: card.fullImageUrl,
        width: 24,
        height: 24,
        fit: BoxFit.contain,
        errorWidget: (_, __, ___) =>
            Icon(_fallbackIcon, color: context.primaryColor, size: 24),
      );
    }
    return Icon(_fallbackIcon, color: context.primaryColor, size: 24);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: context.surfaceColor,
      borderRadius: BorderRadius.circular(14),
      elevation: 1.5,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
      child: InkWell(
        onTap: (card.isPhone || card.isEmail) ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.grey.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: _buildIcon(context)),
              ),
              const Spacer(),
              Text(
                card.heading,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: context.onSurfaceColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                card.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.35,
                  fontWeight: (card.isPhone || card.isEmail)
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: (card.isPhone || card.isEmail)
                      ? context.primaryColor
                      : context.onSurfaceColor.withValues(alpha: 0.7),
                ),
              ),
              if (card.footer.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  card.footer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: context.onSurfaceColor.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 4: FAQ Accordion Widget (Account & Access)
// ─────────────────────────────────────────────────────────────────────────────
class ContactFaqAccordionWidget extends StatelessWidget {
  const ContactFaqAccordionWidget({
    Key? key,
    required this.data,
    required this.controller,
  }) : super(key: key);

  final ContactFaqSectionData data;
  final ContactController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.eyebrow.isNotEmpty) ...[
            Text(
              data.eyebrow.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: context.primaryColor,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            data.title.isNotEmpty ? data.title : 'Account & Access',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.onSurfaceColor,
            ),
          ),
          if (data.subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              data.subtitle,
              style: TextStyle(
                fontSize: 12.5,
                color: context.onSurfaceColor.withValues(alpha: 0.65),
              ),
            ),
          ],
          const SizedBox(height: 16),
          for (int i = 0; i < data.items.length; i++)
            _FaqAccordionTile(
              index: i,
              item: data.items[i],
              controller: controller,
            ),
        ],
      ),
    );
  }
}

class _FaqAccordionTile extends StatelessWidget {
  const _FaqAccordionTile({
    required this.index,
    required this.item,
    required this.controller,
  });

  final int index;
  final ContactFaqItem item;
  final ContactController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final isExpanded = controller.expandedFaqIndex.value == index;

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isExpanded
                ? context.primaryColor.withValues(alpha: 0.5)
                : (isDark ? Colors.white12 : Colors.grey.withValues(alpha: 0.2)),
            width: isExpanded ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              InkWell(
                onTap: () => controller.toggleFaq(index),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.question,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: isExpanded
                                ? context.primaryColor
                                : context.onSurfaceColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: isExpanded
                              ? context.primaryColor
                              : context.onSurfaceColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Text(
                    item.answer,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.55,
                      color: context.onSurfaceColor.withValues(alpha: 0.75),
                    ),
                  ),
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 5: Still Stuck? Support CTA Banner Widget
// ─────────────────────────────────────────────────────────────────────────────
class ContactFaqCtaWidget extends StatelessWidget {
  const ContactFaqCtaWidget({
    Key? key,
    required this.data,
    required this.onOpenTicket,
  }) : super(key: key);

  final ContactFaqCtaData data;
  final VoidCallback onOpenTicket;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.subHeading.isNotEmpty
                            ? data.subHeading
                            : 'Can’t find what you’re looking for?',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: context.primaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.heading.isNotEmpty ? data.heading : 'Still Stuck?',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                if (data.imageUrl.isNotEmpty)
                  SvgPicture.network(
                    data.imageUrl,
                    width: 48,
                    height: 48,
                    colorFilter:
                        const ColorFilter.mode(Colors.white70, BlendMode.srcIn),
                    placeholderBuilder: (_) => const Icon(
                      Icons.headset_mic_rounded,
                      color: Colors.white70,
                      size: 40,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              data.description,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.toNamed(Routes.SEARCH);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Search Community',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onOpenTicket,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Open Direct Ticket',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
