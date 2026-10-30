import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:foddu/constants/constants.dart';
import 'package:foddu/components/support_call_sheet.dart';
import 'package:foddu/components/commonWidgets/secondary_app_header.dart';
import 'package:foddu/app/routes/app_pages.dart';
import '../controllers/helpandsupport_controller.dart';

class HelpandsupportView extends GetView<HelpandsupportController> {
  const HelpandsupportView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: SecondaryAppHeader(
            title: 'Help & Support',
            showRight: false,
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await controller.getFaqs();
          },
          color: colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modern Hero Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withOpacity(0.82),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
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
                          children: [
                            const Text(
                              'How can we help you?',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'We are ready to assist with orders, accounts, and questions.',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12.5,
                                color: Colors.white.withOpacity(0.85),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Reach Us Directly
                Text(
                  'Reach Us Directly',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.bold,
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
                            query: 'subject=Support Inquiry - ',
                          );
                          launchUrl(emailUri);
                        },
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
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Support Tickets Tile
                Material(
                  color: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Get.toNamed(Routes.SUPPORT_TICKET),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.confirmation_number_outlined,
                              color: colorScheme.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Support Tickets',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.5,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Open or check the status of support tickets',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Frequently Asked Questions
                Text(
                  'Frequently Asked Questions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.bold,
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
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                      ),
                      child: Center(
                        child: Text(
                          'No FAQs currently available.',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
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
                              'Inquiry')
                          .toString();

                      final answer = (item['answer'] ??
                              item['description'] ??
                              item['details'] ??
                              '')
                          .toString();

                      final subFaqs = item['faqs_detail'] is List
                          ? (item['faqs_detail'] as List)
                          : [];

                      return Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: ExpansionTile(
                          shape: const Border(),
                          collapsedShape: const Border(),
                          tilePadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          childrenPadding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          title: Text(
                            question,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          children: [
                            if (answer.isNotEmpty)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  answer,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 13,
                                    color: colorScheme.onSurfaceVariant,
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
                                        '• ',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      if (subA.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 12, top: 2),
                                          child: Text(
                                            subA,
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 12.5,
                                              color: colorScheme.onSurfaceVariant,
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      _buildLinkTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        onTap: () => Get.toNamed(Routes.PRIVACY_POLICY),
                        colorScheme: colorScheme,
                      ),
                      Divider(
                        height: 1,
                        color: colorScheme.outline.withOpacity(0.15),
                        indent: 56,
                      ),
                      _buildLinkTile(
                        icon: Icons.gavel_outlined,
                        title: 'Terms & Conditions',
                        onTap: () => Get.toNamed(Routes.TERMSANDCONDITION),
                        colorScheme: colorScheme,
                      ),
                      Divider(
                        height: 1,
                        color: colorScheme.outline.withOpacity(0.15),
                        indent: 56,
                      ),
                      _buildLinkTile(
                        icon: Icons.info_outline,
                        title: 'About Us',
                        onTap: () => Get.toNamed(Routes.ABOUTUS),
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
              ],
            ),
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
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: colorScheme.primary, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11.5,
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return ListTile(
      leading: Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: colorScheme.onSurface,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 13,
        color: colorScheme.onSurfaceVariant.withOpacity(0.6),
      ),
      onTap: onTap,
      dense: true,
    );
  }
}
