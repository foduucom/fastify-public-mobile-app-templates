import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/components/support_call_sheet.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import '../controllers/helpandsupport_controller.dart';

class HelpandsupportView extends GetView<HelpandsupportController> {
  const HelpandsupportView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final surfaceColor = theme.colorScheme.surface;
    final onSurfaceColor = theme.colorScheme.onSurface;
    final secondaryTextColor = onSurfaceColor.withOpacity(0.65);
    final borderColor = theme.dividerColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Help & Support',
          style: TextStyle(
            fontFamily: 'lato',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: onSurfaceColor,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: surfaceColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: onSurfaceColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.getFaqs();
        },
        color: primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor,
                      primaryColor.withOpacity(0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.headset_mic_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'How can we help?',
                            style: TextStyle(
                              fontFamily: 'lato',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'We are here to assist you 24/7 with your questions and orders.',
                            style: TextStyle(
                              fontFamily: 'lato',
                              fontSize: 12.5,
                              color: Colors.white70,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Contact Channels
              Text(
                'Reach Us Directly',
                style: TextStyle(
                  fontFamily: 'lato',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: onSurfaceColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildContactCard(
                      context: context,
                      icon: Icons.email_outlined,
                      title: 'Email Support',
                      subtitle: supportEmail,
                      onTap: () {
                        final Uri emailUri = Uri(
                          scheme: 'mailto',
                          path: supportEmail,
                          query: 'subject=Support Inquiry - $appName',
                        );
                        launchUrl(emailUri);
                      },
                      primaryColor: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildContactCard(
                      context: context,
                      icon: Icons.phone_outlined,
                      title: 'Call Us',
                      subtitle: supportContact,
                      onTap: () => handleSupportCall(context),
                      primaryColor: primaryColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Support Tickets Tile
              Card(
                elevation: 0,
                color: surfaceColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: borderColor),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.confirmation_number_outlined,
                        color: primaryColor, size: 22),
                  ),
                  title: Text(
                    'Support Tickets',
                    style: TextStyle(
                      fontFamily: 'lato',
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                      color: onSurfaceColor,
                    ),
                  ),
                  subtitle: Text(
                    'View or raise technical and order tickets',
                    style: TextStyle(
                      fontFamily: 'lato',
                      fontSize: 12,
                      color: secondaryTextColor,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: secondaryTextColor,
                  ),
                  onTap: () => Get.toNamed(Routes.SUPPORT_TICKET),
                ),
              ),

              const SizedBox(height: 24),

              // Frequently Asked Questions
              Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontFamily: 'lato',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: onSurfaceColor,
                ),
              ),
              const SizedBox(height: 12),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (controller.faqs.isEmpty) {
                  return Card(
                    elevation: 0,
                    color: surfaceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: borderColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'No FAQs currently available.',
                          style: TextStyle(
                            fontFamily: 'lato',
                            fontSize: 13,
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.faqs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = controller.faqs[index];
                    final question = (item['question'] ??
                            item['name'] ??
                            item['title'] ??
                            'General Inquiry')
                        .toString();

                    final answer = (item['answer'] ??
                            item['description'] ??
                            item['details'] ??
                            '')
                        .toString();

                    final subFaqs = item['faqs_detail'] is List
                        ? (item['faqs_detail'] as List)
                        : [];

                    return Card(
                      elevation: 0,
                      color: surfaceColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: borderColor),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        title: Text(
                          question,
                          style: TextStyle(
                            fontFamily: 'lato',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: onSurfaceColor,
                          ),
                        ),
                        children: [
                          if (answer.isNotEmpty)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                answer,
                                style: TextStyle(
                                  fontFamily: 'lato',
                                  fontSize: 13,
                                  color: secondaryTextColor,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          if (subFaqs.isNotEmpty) ...[
                            if (answer.isNotEmpty) const SizedBox(height: 10),
                            ...subFaqs.map((sub) {
                              final subQ = (sub['name'] ??
                                      sub['question'] ??
                                      'Detail')
                                  .toString();
                              final subA = (sub['answer'] ??
                                      sub['description'] ??
                                      '')
                                  .toString();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '• $subQ',
                                      style: TextStyle(
                                        fontFamily: 'lato',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: onSurfaceColor,
                                      ),
                                    ),
                                    if (subA.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 12, top: 2),
                                        child: Text(
                                          subA,
                                          style: TextStyle(
                                            fontFamily: 'lato',
                                            fontSize: 12.5,
                                            color: secondaryTextColor,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    );
                  },
                );
              }),

              const SizedBox(height: 24),

              // Helpful Links & Policies
              Text(
                'Helpful Links',
                style: TextStyle(
                  fontFamily: 'lato',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: onSurfaceColor,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                color: surfaceColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: borderColor),
                ),
                child: Column(
                  children: [
                    _buildLinkTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () => Get.toNamed(Routes.PRIVACY_POLICY),
                      textColor: onSurfaceColor,
                      secondaryColor: secondaryTextColor,
                    ),
                    Divider(height: 1, color: borderColor, indent: 56),
                    _buildLinkTile(
                      icon: Icons.gavel_outlined,
                      title: 'Terms & Conditions',
                      onTap: () => Get.toNamed(Routes.TERMSANDCONDITION),
                      textColor: onSurfaceColor,
                      secondaryColor: secondaryTextColor,
                    ),
                    Divider(height: 1, color: borderColor, indent: 56),
                    _buildLinkTile(
                      icon: Icons.info_outline,
                      title: 'About Us',
                      onTap: () => Get.toNamed(Routes.ABOUTUS),
                      textColor: onSurfaceColor,
                      secondaryColor: secondaryTextColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primaryColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'lato',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'lato',
                fontSize: 11.5,
                color: theme.colorScheme.onSurface.withOpacity(0.65),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color textColor,
    required Color secondaryColor,
  }) {
    return ListTile(
      leading: Icon(icon, size: 20, color: secondaryColor),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'lato',
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: textColor,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded,
          size: 13, color: secondaryColor),
      onTap: onTap,
      dense: true,
    );
  }
}
