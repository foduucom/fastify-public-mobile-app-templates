import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/privacy_policy_controller.dart';

class PrivacyPolicyView extends GetView<PrivacyPolicyController> {
  const PrivacyPolicyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => PrivacyPolicyController());
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Privacy Policy',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "How we protect your data",
                style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold, color: colorScheme.primary),
              ),
              const SizedBox(height: 8),
              Text(
                "Last updated: October 2025",
                style: textTheme.labelMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                title: "1. Information We Collect",
                content:
                    "We collect information you provide directly to us when you create an account, make a purchase, or contact customer support. This includes your name, email address, phone number, shipping address, and payment details.",
              ),
              _buildSection(
                context,
                title: "2. How We Use Your Information",
                content:
                    "We use the information we collect to process your orders, send order confirmations, provide customer support, and improve our services. We may also use your email to send promotional offers, which you can opt out of at any time.",
              ),
              _buildSection(
                context,
                title: "3. Data Security",
                content:
                    "We implement a variety of security measures to maintain the safety of your personal information. Your personal data is contained behind secured networks and is only accessible by a limited number of persons who have special access rights to such systems.",
              ),
              _buildSection(
                context,
                title: "4. Sharing with Third Parties",
                content:
                    "We do not sell, trade, or otherwise transfer to outside parties your Personally Identifiable Information unless we provide users with advance notice. This does not include website hosting partners and other parties who assist us in operating our website, so long as those parties agree to keep this information confidential.",
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title, required String content}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
              height: 1.6, // Enhances readability
            ),
          ),
        ],
      ),
    );
  }
}
