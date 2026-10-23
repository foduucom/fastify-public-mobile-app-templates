import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/theme_ext.dart';

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
      "Error",
      "No support contact phone numbers configured.",
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  if (phoneNumbers.length == 1) {
    launchUrlString('tel:${phoneNumbers[0]}');
    return;
  }

  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
      decoration: BoxDecoration(
        color: context.themeWhiteColor,
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
                  color: context.themeTextColor,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: context.themeSecondrytext),
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
                side: BorderSide(color: context.themeBorderColor),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: context.themePrimaryColor.withOpacity(0.1),
                  child: Icon(Icons.phone_rounded,
                      color: context.themePrimaryColor),
                ),
                title: Text(
                  number,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: context.themeTextColor,
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: context.themeSecondrytext),
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
