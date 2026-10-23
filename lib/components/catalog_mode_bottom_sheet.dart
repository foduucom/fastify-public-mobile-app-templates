import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/product_image_placeholder.dart';
import 'package:zouhi/components/support_call_sheet.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';

/// Displays the Catalog Mode action bottom sheet allowing the customer
/// to either stay on the current screen or navigate to the built-in Contact Us page.
void showCatalogModeBottomSheet(
  BuildContext context, {
  required String productName,
  required String productId,
  dynamic productImage,
  String buttonText = 'Contact for Pricing',
}) {
  final imageUrl = productImage != null
      ? HelperFunctions().getImage(productImage)
      : null;

  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: context.themeWhiteColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Product Header
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          errorWidget: (_, __, ___) =>
                              const ProductImagePlaceholder(radius: 6),
                        )
                      : const ProductImagePlaceholder(radius: 6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: context.themeTextColor,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF4F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          buttonText.isNotEmpty ? buttonText : 'Contact for Pricing',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B3B64),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded,
                      color: context.themeSecondrytext),
                  onPressed: () => Get.back(),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 14),

            Text(
              'This product requires custom quotation. What would you like to do?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: context.themeSecondrytext,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // Option 1: Go to Contact Us Screen (Primary Action)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back(); // Close bottom sheet
                  Get.toNamed(
                    Routes.CONTACT,
                    arguments: {
                      'productId': productId,
                      'productName': productName,
                      'source': 'catalog_mode',
                    },
                  );
                },
                icon: const Icon(Icons.contact_mail_outlined, size: 19),
                label: const Text(
                  'Go to Contact Us Screen',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.themePrimaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Option 2: Stay on Screen (Secondary Action)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.themeTextColor,
                  side: BorderSide(color: context.themeBorderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Stay on Screen',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Quick Direct Channels
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Get.back();
                      handleSupportCall(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone_in_talk_rounded,
                              size: 16, color: context.themePrimaryColor),
                          const SizedBox(width: 6),
                          Text(
                            'Call Sales',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: context.themeTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      Get.back();
                      final subject = Uri.encodeComponent(
                          'Pricing Inquiry: $productName [ID: $productId]');
                      final body = Uri.encodeComponent(
                        'Hello Vision Infrastructure Team,\n\n'
                        'I am interested in receiving custom pricing and availability for:\n'
                        'Product: $productName\n'
                        'Product ID: $productId\n\n'
                        'Please contact me with bulk/wholesale pricing details.\n\n'
                        'Thank you!',
                      );
                      final mailtoUrl =
                          'mailto:$supportEmail?subject=$subject&body=$body';
                      if (await canLaunchUrlString(mailtoUrl)) {
                        await launchUrlString(mailtoUrl);
                      } else {
                        Get.snackbar(
                          'Contact Email',
                          'Please email us at $supportEmail',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.email_outlined,
                              size: 16, color: context.themePrimaryColor),
                          const SizedBox(width: 6),
                          Text(
                            'Email Inquiry',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: context.themeTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
