import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/contact_us_controller.dart';
import '/constants/constants.dart';
import '/app/routes/app_pages.dart';

class ContactUsView extends GetView<ContactUsController> {
  const ContactUsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => ContactUsController());
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Help & Contact',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Header Illustration / Text
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Icon(Icons.support_agent_rounded,
                    size: 80, color: colorScheme.primary.withOpacity(0.8)),
                const SizedBox(height: 16),
                Text(
                  "How can we help you?",
                  style: textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Select an option below to get your issues resolved or to read our policies.",
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Option 1: Helpline
          _buildOptionTile(
            context,
            title: "Helpline",
            subtitle: "Call or email our support team",
            icon: Icons.headset_mic_outlined,
            onTap: () => _showHelplineSheet(context),
          ),

          // Option 2: Write to Us (Form)
          _buildOptionTile(
            context,
            title: "Write to Us",
            subtitle: "Send us a direct message",
            icon: Icons.mail_outline_rounded,
            onTap: () => _showContactFormSheet(context),
          ),

          // Option 3: Privacy Policy
          _buildOptionTile(
            context,
            title: "Privacy Policy",
            subtitle: "Read how we protect your data",
            icon: Icons.privacy_tip_outlined,
            onTap: () {
              Get.toNamed(Routes.PRIVACY_POLICY);
            },
          ),

          // Option 4: Terms & Conditions
          _buildOptionTile(
            context,
            title: "Terms & Conditions",
            subtitle: "Read our rules and guidelines",
            icon: Icons.description_outlined,
            onTap: () {
              Get.toNamed(Routes.TERMS_CONDITIONS);
            },
          ),
        ],
      ),
    );
  }

  // ─── Reusable List Tile ────────────────────────────────────────────────
  Widget _buildOptionTile(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colorScheme.primary),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle,
            style:
                TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
        trailing: Icon(Icons.arrow_forward_ios,
            size: 16, color: colorScheme.onSurfaceVariant),
        onTap: onTap,
      ),
    );
  }

  // ─── Helpline Bottom Sheet ─────────────────────────────────────────────
  void _showHelplineSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: colorScheme.outline,
                        borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 24),
            Text("24/7 Helpline",
                style: textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.phone, color: colorScheme.primary),
              title: const Text("+91 98765 43210",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text("Mon - Sat (9:00 AM - 6:00 PM)"),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.email, color: colorScheme.primary),
              title: const Text("support@shoponline.com",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text("We typically reply within 24 hours"),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ─── Contact Form Bottom Sheet ─────────────────────────────────────────
  void _showContactFormSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final formKey = GlobalKey<FormState>();

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom +
                24 // Prevents keyboard from hiding form
            ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: colorScheme.outline,
                            borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 24),
                Text("Send us a message",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildTextField(context, controller.nameCtrl, "Full Name",
                    Icons.person_outline,
                    validator: (v) => v!.isEmpty ? "Required" : null),
                const SizedBox(height: 12),
                _buildTextField(context, controller.emailCtrl, "Email Address",
                    Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        !v!.isEmail ? "Valid email required" : null),
                const SizedBox(height: 12),
                _buildTextField(context, controller.messageCtrl, "Your Message",
                    Icons.message_outlined,
                    maxLines: 4,
                    validator: (v) =>
                        v!.isEmpty ? "Message cannot be empty" : null),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => controller.submitContactForm(formKey),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Submit",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildTextField(BuildContext context, TextEditingController ctrl,
      String hint, IconData icon,
      {int maxLines = 1,
      TextInputType? keyboardType,
      String? Function(String?)? validator}) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: maxLines == 1
            ? Icon(icon, color: colorScheme.onSurfaceVariant)
            : null,
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: colorScheme.outline.withOpacity(0.5))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: colorScheme.outline.withOpacity(0.5))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5)),
      ),
    );
  }
}
