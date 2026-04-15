import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../components/app_bar.dart';
import '../controller/notificatin_controller.dart';

class NotificationSettingsView
    extends GetView<NotificationSettingsController> {

  // ✅ const removed — constructor has a body
  NotificationSettingsView({Key? key}) : super(key: key) {
    Get.put(NotificationSettingsController());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(title: 'Notifications'),

      // ✅ ListView fixes the 399420px overflow
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Section Label ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 16, 20, 2),
                  child: Text(
                    'Messages Notifications',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),

                // ── Payment ───────────────────────────────────────────
                Obx(() => _NotifToggleTile(
                  label: 'Payment',
                  value: controller.isPaymentEnabled.value,
                  onChanged: controller.togglePayment,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  showDivider: true,
                )),

                // ── New Recipe ─────────────────────────────────────────
                Obx(() => _NotifToggleTile(
                  label: 'New Recipe',
                  value: controller.isNewRecipeEnabled.value,
                  onChanged: controller.toggleNewRecipe,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  showDivider: true,
                )),

                // ── Streaming ──────────────────────────────────────────
                Obx(() => _NotifToggleTile(
                  label: 'Streaming',
                  value: controller.isStreamingEnabled.value,
                  onChanged: controller.toggleStreaming,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  showDivider: true,
                )),

                // ── Notification ───────────────────────────────────────
                Obx(() => _NotifToggleTile(
                  label: 'Notification',
                  value: controller.isNotificationEnabled.value,
                  onChanged: controller.toggleNotification,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  showDivider: false,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable Toggle Row ───────────────────────────────────────────────────────
class _NotifToggleTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool showDivider;

  const _NotifToggleTile({
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: colorScheme.onPrimary,
                activeTrackColor: colorScheme.primary,
                inactiveThumbColor: colorScheme.surface,
                inactiveTrackColor: colorScheme.outline,
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.outline,
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }
}