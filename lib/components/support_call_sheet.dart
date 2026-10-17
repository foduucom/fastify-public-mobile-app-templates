import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:new_fastify_template/constants/constants.dart';

/// Dials the support number, or lets the user pick when [supportContact]
/// holds several numbers separated by '/'.
void handleSupportCall(BuildContext context) {
  final phoneNumbers = supportContact
      .split('/')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  if (phoneNumbers.isEmpty) {
    Get.snackbar(
      "Support",
      "No support contact phone number is configured.",
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  if (phoneNumbers.length == 1) {
    launchUrlString('tel:${phoneNumbers[0]}');
    return;
  }

  final theme = Theme.of(context);
  final primaryColor = theme.primaryColor;
  final surfaceColor = theme.colorScheme.surface;
  final onSurfaceColor = theme.colorScheme.onSurface;
  final borderColor = theme.dividerColor;

  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Support Number',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: onSurfaceColor,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: onSurfaceColor.withOpacity(0.6)),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...phoneNumbers.map((number) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: borderColor),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: Icon(Icons.phone_rounded, color: primaryColor),
                ),
                title: Text(
                  number,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: onSurfaceColor,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: onSurfaceColor.withOpacity(0.5),
                ),
                onTap: () async {
                  Get.back();
                  await launchUrlString('tel:$number');
                },
              ),
            );
          }),
        ],
      ),
    ),
    isDismissible: true,
  );
}
