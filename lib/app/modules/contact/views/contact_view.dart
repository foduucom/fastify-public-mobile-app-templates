import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zouhi/app/data/models/contact_sections.dart';
import 'package:zouhi/app/data/models/page_model.dart';
import 'package:zouhi/app/modules/contact/controller/contact_controller.dart';
import 'package:zouhi/components/buttons/appbutton.dart';
import 'package:zouhi/components/check_internet_widget.dart';
import 'package:zouhi/components/cms/cms_widgets.dart';
import 'package:zouhi/components/foduuformtextfield.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';

const _navy = Color(0xFF12253D);
const _accent = Color(0xFF00ADEF);

class ContactView extends GetView<ContactController> {
  const ContactView({Key? key}) : super(key: key);

  Future<void> _open(Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  /// Opens a mailto:/tel:/maps target for an info item. Only whitelisted
  /// schemes from the CMS are launched.
  void _openItem(ContactInfoItem item) {
    final link = item.link;
    final lower = link.toLowerCase();
    if (lower.startsWith('mailto:') ||
        lower.startsWith('tel:') ||
        lower.startsWith('https://')) {
      _open(Uri.parse(link));
      return;
    }
    final cls = item.iconHtml.toLowerCase();
    if (cls.contains('envelop') || item.value.contains('@')) {
      _open(Uri(scheme: 'mailto', path: item.value));
    } else if (cls.contains('phone')) {
      _open(Uri(
          scheme: 'tel', path: item.value.replaceAll(RegExp(r'[^\d+]'), '')));
    } else {
      _openMap(item.value);
    }
  }

  void _openMap(String address) {
    if (address.isEmpty) return;
    _open(Uri.https(
        'www.google.com', '/maps/search/', {'api': '1', 'query': address}));
  }

  String _addressFrom(List<PageComponent> components) {
    for (final c in components) {
      if (c.type != 'contact-us_contact-information') continue;
      final v = c.fields['address_text']?.toString().trim() ?? '';
      if (v.isNotEmpty) return v;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeBackground,
      appBar: AppBar(title: const Text('Contact Us'), elevation: 0.0),
      body: GestureDetector(
        onTap: () => HelperFunctions().closeKeyboard(context),
        child: FoduuCheckInternetBody(
          child: Obx(() {
            if (controller.isPageLoading.value &&
                controller.components.isEmpty) {
              return Center(child: HelperFunctions().loadingIndicator());
            }
            if (controller.components.isEmpty) {
              return _ErrorState(
                message: controller.error.value.isNotEmpty
                    ? controller.error.value
                    : 'Unable to load Contact page',
                onRetry: controller.fetchContactPage,
              );
            }
            final address = _addressFrom(controller.components);
            return RefreshIndicator(
              onRefresh: controller.fetchContactPage,
              color: context.themePrimaryColor,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.zero,
                children: controller.components
                    .map((c) => _section(context, c, address))
                    .toList(),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _section(BuildContext context, PageComponent c, String address) {
    switch (c.type) {
      case 'services_page-header':
        final t = c.fields['h1_services']?.toString().trim() ?? '';
        return CmsPageHeader(
          title: t.isEmpty ? 'Contact Us' : t,
          imagePath: c.fields['header_image']?.toString() ?? '',
        );
      case 'contact-us_contact-information':
        return _InfoSection(
          data: ContactInfoSection.fromComponent(c),
          onTap: _openItem,
        );
      case 'contact-us_contact-form-section_form_banner':
        return _FormBanner(
          data: FormBannerSection.fromComponent(c),
          controller: controller,
        );
      case 'contact-us_google-map':
        return address.isEmpty
            ? const SizedBox.shrink()
            : _MapCard(address: address, onTap: () => _openMap(address));
      case 'spacer_bs':
        final h = double.tryParse((c.fields['height']?.toString() ?? '')
                .replaceAll(RegExp(r'[^0-9.]'), '')) ??
            16.0;
        return CmsSpacer(h.clamp(0, 120).toDouble());
      case 'shop_footer-newsletter_form_banner':
        return _NewsletterBanner(
          data: NewsletterSection.fromComponent(c),
          controller: controller,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.signal_wifi_connected_no_internet_4_rounded,
              size: 48, color: context.themeSecondrytext.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(message,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: context.themeTextColor)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.data, required this.onTap});
  final ContactInfoSection data;
  final void Function(ContactInfoItem) onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.title,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: context.themeTextColor)),
          if (data.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(data.description,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    height: 1.5,
                    color: context.themeSecondrytext)),
          ],
          const SizedBox(height: 16),
          for (final item in data.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _InfoCard(item: item, onTap: () => onTap(item)),
            ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.item, required this.onTap});
  final ContactInfoItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${item.heading}: ${item.value}',
      child: Material(
        color: context.themeWhiteColor,
        borderRadius: BorderRadius.circular(14),
        elevation: 1.5,
        shadowColor: Colors.black26,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconFromHtml(item.iconHtml),
                      color: _accent, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.heading,
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: context.themeSecondrytext)),
                      const SizedBox(height: 2),
                      Text(item.value,
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: context.themeTextColor)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: context.themeSecondrytext),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FormBanner extends StatelessWidget {
  const _FormBanner({required this.data, required this.controller});
  final FormBannerSection data;
  final ContactController controller;

  @override
  Widget build(BuildContext context) {
    final bg = cmsImageUrl(data.backgroundImage);
    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: _navy,
        image: bg.isEmpty
            ? null
            : DecorationImage(
                image: CachedNetworkImageProvider(bg),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    const Color(0xFF0A192D).withOpacity(0.72),
                    BlendMode.darken),
              ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 18, offset: Offset(0, 8))
          ],
        ),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.title,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _navy)),
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
                        LengthLimitingTextInputFormatter(10),
                      ];
                    } else if (isMessage) {
                      keyType = TextInputType.multiline;
                      maxLine = 5;
                    } else if (field.name == 'Name' ||
                        field.label.toLowerCase().contains('name')) {
                      formatters = [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z\s]')),
                      ];
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: FoduuFormTextField(
                        title: field.label.isNotEmpty
                            ? field.label
                            : field.name,
                        controller: ctrl,
                        fieldHintText: field.placeholder,
                        keyType: keyType,
                        maxLine: maxLine,
                        inputFormatters: formatters,
                        validCheck: (value) {
                          final v = value?.trim() ?? '';
                          if (field.required && v.isEmpty) {
                            return 'Please enter ${field.label.isNotEmpty ? field.label : 'this field'}!';
                          }
                          if (isEmail &&
                              v.isNotEmpty &&
                              !GetUtils.isEmail(v)) {
                            return 'Enter a valid email address!';
                          }
                          if (isTel && v.isNotEmpty && v.length != 10) {
                            return 'Please enter valid 10-digit mobile number!';
                          }
                          if (isMessage && v.isNotEmpty && v.length < 3) {
                            return 'Please enter message greater than 3 characters';
                          }
                          return null;
                        },
                        validationmsg: '',
                      ),
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: 5),
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
                                    child: const Text(
                                      'privacy policy',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _accent,
                                        decoration:
                                            TextDecoration.underline,
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
              const SizedBox(height: 20),
              Obx(() => controller.isLoading.value
                  ? Center(
                      child: CircularProgressIndicator(
                          color: context.themePrimaryColor))
                  : AppButton(
                      itemText: 'SUBMIT',
                      keypressEvent: () {
                        HelperFunctions().closeKeyboard(context);
                        controller.sendFormData();
                      },
                    )),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({required this.address, required this.onTap});
  final String address;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Semantics(
        button: true,
        label: 'Open $address in maps',
        child: Material(
          color: const Color(0xFFE8F4FB),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 140,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.map_outlined, size: 44, color: _accent),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Find us on the map',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _navy)),
                        const SizedBox(height: 4),
                        Text(address,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12.5,
                                color: _navy)),
                        const SizedBox(height: 8),
                        const Text('OPEN IN MAPS',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: _accent)),
                      ],
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
}

class _NewsletterBanner extends StatelessWidget {
  const _NewsletterBanner({required this.data, required this.controller});
  final NewsletterSection data;
  final ContactController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
      color: _navy,
      child: Column(
        children: [
          Icon(iconFromHtml(data.iconHtml, fallback: Icons.mail_outline),
              size: 38, color: _accent),
          const SizedBox(height: 12),
          Text(data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          if (data.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(data.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.white.withOpacity(0.8))),
          ],
          const SizedBox(height: 18),
          TextField(
            controller: controller.newsletterController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(
              hintText: 'Your E-mail Address',
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: Obx(() => ElevatedButton(
                  onPressed: controller.isSubscribing.value
                      ? null
                      : () {
                          HelperFunctions().closeKeyboard(context);
                          controller.subscribeNewsletter();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: controller.isSubscribing.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('SUBSCRIBE',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1)),
                )),
          ),
        ],
      ),
    );
  }
}
