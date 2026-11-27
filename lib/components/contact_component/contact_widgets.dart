import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foduu_ecommerce/app/data/models/contact_sections.dart';
import 'package:foduu_ecommerce/app/data/models/form_schema_model.dart';
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
      height: data.height.clamp(165, 210).toDouble(),
      decoration: BoxDecoration(color: context.surfaceColor),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (data.imageUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: data.imageUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                color: context.primaryColor,
              ),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.45),
                  context.primaryColor.withValues(alpha: 0.88),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.28),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.home_outlined,
                          size: 13,
                          color: Colors.white.withValues(alpha: 0.92)),
                      const SizedBox(width: 5),
                      Text(
                        'Home / Contact Us',
                        style: TextStyle(
                          fontSize: 11.5,
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
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                if (data.subHeading.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    data.subHeading,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
                if (data.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    data.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 1B: Contact Section Header (rich_text: "Let's ConnectSend Your Message")
// ─────────────────────────────────────────────────────────────────────────────
class ContactSectionHeaderWidget extends StatelessWidget {
  const ContactSectionHeaderWidget({Key? key, required this.contentJson})
      : super(key: key);

  final Map<String, dynamic> contentJson;

  ({String eyebrow, String heading}) _parseContent() {
    final raw = (contentJson['html_content'] ??
            contentJson['content'] ??
            contentJson['text'] ??
            '')
        .toString();

    // Strip HTML tags while preserving boundaries between block/inline elements
    final spaced = raw
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</(p|div|h[1-6]|span)>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&rsquo;', "'")
        .replaceAll('&#39;', "'")
        .replaceAll('&amp;', '&')
        .trim();

    if (spaced.contains('\n')) {
      final parts = spaced
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (parts.length >= 2) {
        return (eyebrow: parts.first, heading: parts.sublist(1).join(' '));
      }
    }

    // Handle concatenated CMS string: "Let's ConnectSend Your Message"
    final lower = spaced.toLowerCase();
    const eyebrowPhrase = "let's connect";
    if (lower.startsWith(eyebrowPhrase) && spaced.length > eyebrowPhrase.length) {
      return (
        eyebrow: spaced.substring(0, eyebrowPhrase.length).trim(),
        heading: spaced.substring(eyebrowPhrase.length).trim(),
      );
    }

    // Fallback: split on camel-like boundary ("...ctSe...")
    final boundary = RegExp(r'([a-z])([A-Z])').firstMatch(spaced);
    if (boundary != null) {
      final idx = boundary.start + 1;
      return (
        eyebrow: spaced.substring(0, idx).trim(),
        heading: spaced.substring(idx).trim(),
      );
    }

    return (eyebrow: "Let's Connect", heading: spaced.isNotEmpty ? spaced : 'Send Your Message');
  }

  @override
  Widget build(BuildContext context) {
    final parsed = _parseContent();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (parsed.eyebrow.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                parsed.eyebrow.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: context.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (parsed.heading.isNotEmpty)
            Text(
              parsed.heading,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: context.onSurfaceColor,
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 1C: Contact Intro Subtitle (text_block)
// ─────────────────────────────────────────────────────────────────────────────
class ContactIntroTextWidget extends StatelessWidget {
  const ContactIntroTextWidget({Key? key, required this.contentJson})
      : super(key: key);

  final Map<String, dynamic> contentJson;

  @override
  Widget build(BuildContext context) {
    final text = (contentJson['text'] ?? '').toString().trim();
    if (text.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.5,
          height: 1.5,
          color: context.onSurfaceColor.withValues(alpha: 0.68),
        ),
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
    this.controller,
  }) : super(key: key);

  final ContactFormBuilderData data;
  final ContactController? controller;

  ContactController get _resolvedController =>
      controller ??
      (Get.isRegistered<ContactController>()
          ? Get.find<ContactController>()
          : Get.put(ContactController()));

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

  Iterable<String>? _autofillHintsForField(String name, String type) {
    final lower = name.toLowerCase();
    if (type == 'email' || lower.contains('email')) {
      return const [AutofillHints.email];
    }
    if (lower.contains('first')) return const [AutofillHints.givenName];
    if (lower.contains('last')) return const [AutofillHints.familyName];
    if (lower.contains('name')) return const [AutofillHints.name];
    if (type == 'tel' || lower.contains('phone') || lower.contains('mobile')) {
      return const [AutofillHints.telephoneNumber];
    }
    return null;
  }

  String _cleanPlaceholder(String name, String rawPlaceholder) {
    if (rawPlaceholder.isNotEmpty && !rawPlaceholder.contains('.....')) {
      return rawPlaceholder;
    }
    final lower = name.toLowerCase();
    if (lower.contains('first')) return 'Alex';
    if (lower.contains('last')) return 'Johnson';
    if (lower.contains('name')) return 'e.g. Alex Johnson';
    if (lower.contains('email')) return 'alex.johnson@example.com';
    if (lower.contains('phone') || lower.contains('mobile')) {
      return '+012 3456 7890';
    }
    if (lower.contains('message')) {
      return 'How can our support team assist you today?';
    }
    return 'Enter $name...';
  }

  Widget _buildFieldInput(
    BuildContext context,
    ContactController formCtrl,
    FormSchemaField field, {
    required bool isLast,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ctrl = formCtrl.controllerForField(field);
    final isEmail =
        field.type == 'email' || field.name.toLowerCase().contains('email');
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
        FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s'\-]")),
      ];
    }

    final labelText = field.label.isNotEmpty ? field.label : field.name;
    final placeholder = _cleanPlaceholder(labelText, field.placeholder);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  labelText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.onSurfaceColor,
                  ),
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
            textInputAction: isMessage
                ? TextInputAction.newline
                : (isLast ? TextInputAction.done : TextInputAction.next),
            autofillHints: _autofillHintsForField(field.name, field.type),
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
              if (isEmail && v.isNotEmpty && !GetUtils.isEmail(v)) {
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
                color: context.onSurfaceColor.withValues(alpha: 0.42),
              ),
              prefixIcon: isMessage
                  ? Padding(
                      padding: const EdgeInsets.only(
                          bottom: 52, left: 12, right: 12),
                      child: Icon(
                        _iconForField(field.name, field.type),
                        size: 20,
                        color: context.onSurfaceColor.withValues(alpha: 0.55),
                      ),
                    )
                  : Icon(
                      _iconForField(field.name, field.type),
                      size: 20,
                      color: context.onSurfaceColor.withValues(alpha: 0.55),
                    ),
              filled: true,
              fillColor: context.backgroundColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
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
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formCtrl = _resolvedController;

    final trimmedTitle = data.title.trim();
    final showCardTitle = trimmedTitle.isNotEmpty &&
        trimmedTitle.toUpperCase() != 'HI' &&
        trimmedTitle.length >= 3;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isDark ? Colors.white12 : Colors.grey.withValues(alpha: 0.2),
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
          key: formCtrl.formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showCardTitle) ...[
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
                      Expanded(
                        child: Text(
                          trimmedTitle,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: context.onSurfaceColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                ],
                Obx(() {
                  final fields = formCtrl.formFields;
                  final widgets = <Widget>[];
                  int i = 0;
                  while (i < fields.length) {
                    final current = fields[i];
                    final hasNext = i + 1 < fields.length;
                    final next = hasNext ? fields[i + 1] : null;
                    final isFirstAndLastName = next != null &&
                        current.name.toLowerCase().contains('first') &&
                        next.name.toLowerCase().contains('last');

                    if (isFirstAndLastName) {
                      widgets.add(
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildFieldInput(
                                context,
                                formCtrl,
                                current,
                                isLast: false,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildFieldInput(
                                context,
                                formCtrl,
                                next,
                                isLast: i + 1 == fields.length - 1,
                              ),
                            ),
                          ],
                        ),
                      );
                      i += 2;
                    } else {
                      widgets.add(
                        _buildFieldInput(
                          context,
                          formCtrl,
                          current,
                          isLast: i == fields.length - 1,
                        ),
                      );
                      i += 1;
                    }
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widgets,
                  );
                }),
                Obx(() {
                  final isSubmitting = formCtrl.isSubmitting.value;
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () {
                              HelperFunctions().closeKeyboard(context);
                              formCtrl.sendFormData();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
                        disabledBackgroundColor:
                            context.primaryColor.withValues(alpha: 0.65),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'SEND MESSAGE',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 3: Location Map Card Widget
// ─────────────────────────────────────────────────────────────────────────────
// class ContactLocationMapCard extends StatelessWidget {
//   const ContactLocationMapCard({Key? key, required this.data})
//       : super(key: key);

//   //final ContactLocationMapData data;

//   Future<void> _openMaps() async {
//     final uri = Uri.tryParse(data.mapsUrl);
//     if (uri == null) return;
//     try {
//       if (await canLaunchUrl(uri)) {
//         await launchUrl(uri, mode: LaunchMode.externalApplication);
//       }
//     } catch (_) {}
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
//       child: Container(
//         decoration: BoxDecoration(
//           color: context.surfaceColor,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color:
//                 isDark ? Colors.white12 : Colors.grey.withValues(alpha: 0.2),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.05),
//               blurRadius: 12,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Lightweight native styled map preview
//               InkWell(
//                 onTap: _openMaps,
//                 child: Container(
//                   height: 150,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: isDark
//                           ? [
//                               const Color(0xFF1E293B),
//                               const Color(0xFF0F172A),
//                             ]
//                           : [
//                               context.primaryColor.withValues(alpha: 0.08),
//                               context.primaryColor.withValues(alpha: 0.16),
//                             ],
//                     ),
//                   ),
//                   child: Stack(
//                     children: [
//                       // Subtle decorative map grid lines
//                       Positioned.fill(
//                         child: CustomPaint(
//                           painter: _MapGridPainter(
//                             lineColor: isDark
//                                 ? Colors.white.withValues(alpha: 0.06)
//                                 : context.primaryColor.withValues(alpha: 0.12),
//                           ),
//                         ),
//                       ),
//                       Center(
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Container(
//                               width: 52,
//                               height: 52,
//                               decoration: BoxDecoration(
//                                 color: context.primaryColor,
//                                 shape: BoxShape.circle,
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: context.primaryColor
//                                         .withValues(alpha: 0.35),
//                                     blurRadius: 14,
//                                     offset: const Offset(0, 4),
//                                   ),
//                                 ],
//                               ),
//                               child: const Icon(
//                                 Icons.location_on_rounded,
//                                 color: Colors.white,
//                                 size: 28,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 10, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: context.surfaceColor
//                                     .withValues(alpha: 0.92),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 data.addressLabel,
//                                 style: TextStyle(
//                                   fontSize: 11.5,
//                                   fontWeight: FontWeight.w600,
//                                   color: context.onSurfaceColor,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             data.city,
//                             style: TextStyle(
//                               fontSize: 17,
//                               fontWeight: FontWeight.w700,
//                               color: context.onSurfaceColor,
//                             ),
//                           ),
//                           const SizedBox(height: 2),
//                           Text(
//                             data.addressLabel,
//                             style: TextStyle(
//                               fontSize: 12.5,
//                               color: context.onSurfaceColor
//                                   .withValues(alpha: 0.65),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     ElevatedButton.icon(
//                       onPressed: _openMaps,
//                       icon: const Icon(Icons.map_outlined, size: 16),
//                       label: const Text(
//                         'Open in Maps',
//                         style: TextStyle(
//                           fontSize: 12.5,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: context.primaryColor,
//                         foregroundColor: Colors.white,
//                         elevation: 0,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 14, vertical: 10),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
                : (isDark
                    ? Colors.white12
                    : Colors.grey.withValues(alpha: 0.2)),
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
          color: context.primaryColor,
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
