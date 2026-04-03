import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../components/app_back_button.dart';
import '../../../../../components/app_bar.dart';
import '../controller/terms_conditions_controller.dart';

class TermsConditionsView extends GetView<TermsConditionsController> {
  const TermsConditionsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => TermsConditionsController());
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar:  CustomAppBar(title: 'Terms Conditions'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Intro Header ──────────────────────────────────────
              Text(
                'Rules and Guidelines',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please read these terms carefully before using our application.',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // ── Sections ──────────────────────────────────────────
              _buildSection(
                context,
                title: '1. Acceptance of Terms',
                content:
                'By accessing and using this application, you accept and agree to be bound by the terms and provision of this agreement. In addition, when using this application\'s particular services, you shall be subject to any posted guidelines or rules applicable to such services.',
              ),
              _buildSection(
                context,
                title: '2. User Accounts',
                content:
                'If you create an account on the application, you are responsible for maintaining the security of your account and you are fully responsible for all activities that occur under the account and any other actions taken in connection with it.',
              ),
              _buildSection(
                context,
                title: '3. Products and Pricing',
                content:
                'All products and prices are subject to change without notice. We reserve the right to modify or discontinue any product at any time. We shall not be liable to you or to any third-party for any modification, price change, suspension, or discontinuance of products.',
              ),
              _buildSection(
                context,
                title: '4. Return and Refund',
                content:
                'Our return policy lasts 7 days. If 7 days have gone by since your purchase, unfortunately, we can\'t offer you a refund or exchange. To be eligible for a return, your item must be unused and in the same condition that you received it.',
              ),

              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSection(
      BuildContext context, {
        required String title,
        required String content,
      }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
