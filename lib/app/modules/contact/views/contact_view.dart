import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/data/models/contact_sections.dart';
import 'package:foduu_ecommerce/app/modules/contact/controller/contact_controller.dart';
import 'package:foduu_ecommerce/components/contact_component/contact_widgets.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactView extends GetView<ContactController> {
  const ContactView({Key? key}) : super(key: key);

  Future<void> _launchUrl(Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _handleCardTap(ContactChannelCard card) {
    if (card.isEmail) {
      final email = card.text.trim();
      if (email.isNotEmpty) {
        _launchUrl(Uri(scheme: 'mailto', path: email));
      }
    } else if (card.isPhone) {
      final phone = card.cleanPhone;
      if (phone.isNotEmpty) {
        _launchUrl(Uri(scheme: 'tel', path: phone));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Contact Us',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0.0,
      ),
      body: GestureDetector(
        onTap: () => HelperFunctions().closeKeyboard(context),
        child: Obx(() {
          final sections = controller.sectionsData.value;
          final isInitialLoading = controller.isPageLoading.value &&
              controller.rawSections.isEmpty &&
              sections.channels.cards.isEmpty;

          if (isInitialLoading) {
            return Center(child: HelperFunctions().loadingIndicator());
          }

          return RefreshIndicator(
            onRefresh: controller.fetchContactLayout,
            color: context.primaryColor,
            child: ListView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.zero,
              children: [
                // 1. Hero Header Banner
                ContactHeroBannerWidget(data: sections.heroHeader),

                // 2. Dynamic Form Builder Card
                ContactFormCardWidget(
                  data: sections.formBuilder,
                  controller: controller,
                ),

                // 3. Contact Channels Section (2-Column Grid)
                ContactChannelsWidget(
                  data: sections.channels,
                  onCardTap: _handleCardTap,
                ),

                // 4. FAQ Accordion Section (Account & Access)
                ContactFaqAccordionWidget(
                  data: sections.faq,
                  controller: controller,
                ),

                // 5. Still Stuck? Support CTA Banner
                ContactFaqCtaWidget(
                  data: sections.faqCta,
                  onOpenTicket: () {
                    scrollController.animateTo(
                      180,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        }),
      ),
    );
  }
}
