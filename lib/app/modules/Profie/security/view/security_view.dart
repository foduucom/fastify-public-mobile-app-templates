// lib/app/modules/security/views/security_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../components/app_back_button.dart';
import '../../../../../components/app_bar.dart';
import '../controller/security_controller.dart';

class SecurityView extends GetView<SecurityController> {
  const SecurityView({Key? key}) : super(key: key);

  // ✅ Only fix — prevents "SecurityController not found" crash
  @override
  SecurityController get controller => Get.put(SecurityController());

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar:  CustomAppBar(title: 'Security'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // ── Face ID ───────────────────────────────────────────
              Obx(() => _SecurityToggleTile(
                label: 'Face ID',
                value: controller.isFaceIdEnabled.value,
                onChanged: controller.toggleFaceId,
                colorScheme: colorScheme,
                textTheme: textTheme,
                showDivider: true,
              )),

              // ── Remember Password ─────────────────────────────────
              Obx(() => _SecurityToggleTile(
                label: 'Remember Password',
                value: controller.isRememberPassword.value,
                onChanged: controller.toggleRememberPassword,
                colorScheme: colorScheme,
                textTheme: textTheme,
                showDivider: true,
              )),

              // ── Touch ID ──────────────────────────────────────────
              Obx(() => _SecurityToggleTile(
                label: 'Touch ID',
                value: controller.isTouchIdEnabled.value,
                onChanged: controller.toggleTouchId,
                colorScheme: colorScheme,
                textTheme: textTheme,
                showDivider: false,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable Toggle Row ───────────────────────────────────────────────────────
class _SecurityToggleTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool showDivider;

  const _SecurityToggleTile({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.colorScheme,
    required this.textTheme,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: textTheme.bodyLarge?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.white,
                activeTrackColor: colorScheme.primary,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.shade300,
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade200,
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }
}