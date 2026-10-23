import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:zouhi/app/data/models/category_products_page.dart';
import 'package:zouhi/app/modules/shop/views/productdetail_view.dart';
import 'package:zouhi/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:zouhi/components/product_image_placeholder.dart';
import 'package:zouhi/components/support_call_sheet.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';

/// Modern B2B Product Card specifically designed for quote-based categories
/// (Fibre Cable, Connectors & Adaptors), maintaining parent website standards
/// from vision.vbought.com/home with improved visual organization and attention.
class ContactPricingProductCard extends StatelessWidget {
  final CategoryProduct product;
  final VoidCallback onContactPricing;
  final VoidCallback? onCardTap;

  const ContactPricingProductCard({
    super.key,
    required this.product,
    required this.onContactPricing,
    this.onCardTap,
  });

  String _cleanText(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'&nbsp;'), ' ')
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'&lt;'), '<')
        .replaceAll(RegExp(r'&gt;'), '>')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> _toggleWishlist(BuildContext context) async {
    if (!Get.isRegistered<WishlistController>()) {
      Get.put(WishlistController(), permanent: true);
    }
    final wishlist = Get.find<WishlistController>();
    if (!HelperFunctions.checkAndPromptLogin(
        message: "Please login to add products to your wishlist.")) {
      return;
    }
    final productId = product.id;
    if (wishlist.wishlistProductIds.contains(productId)) {
      wishlist.wishlistProductIds.remove(productId);
      wishlist.update();
      await wishlist.removeProductFromWishlist(productid: productId);
    } else {
      wishlist.wishlistProductIds.add(productId);
      wishlist.update();
      await wishlist.addProductToWishlist(productid: productId);
    }
  }

  void _showContactPricingSheet(BuildContext context) {
    final imageUrl = product.image == null
        ? null
        : HelperFunctions().getImage(product.image);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: context.themeWhiteColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
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
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Product Info Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
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
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: context.themeTextColor,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF4F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Custom B2B Pricing',
                            style: TextStyle(
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

              const SizedBox(height: 18),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 14),

              Text(
                'How would you like to inquire?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: context.themeTextColor,
                ),
              ),
              const SizedBox(height: 10),

              // Action 1: Call Toll-Free
              _InquiryActionTile(
                icon: Icons.phone_in_talk_rounded,
                iconColor: const Color(0xFF20558A),
                iconBg: const Color(0xFFEEF4F9),
                title: 'Call Support & Sales',
                subtitle: 'Toll-free line: $supportContact',
                onTap: () {
                  Get.back();
                  handleSupportCall(context);
                },
              ),

              const SizedBox(height: 8),

              // Action 2: Email Quote Request
              _InquiryActionTile(
                icon: Icons.email_outlined,
                iconColor: const Color(0xFF0284C7),
                iconBg: const Color(0xFFE0F2FE),
                title: 'Email Quote Request',
                subtitle: supportEmail,
                onTap: () async {
                  Get.back();
                  final subject = Uri.encodeComponent(
                      'Quote Inquiry: ${product.name} [ID: ${product.id}]');
                  final body = Uri.encodeComponent(
                    'Hello Vision Infrastructure Team,\n\n'
                    'I am interested in receiving custom pricing and availability for:\n'
                    'Product: ${product.name}\n'
                    'Product ID: ${product.id}\n\n'
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
              ),

              const SizedBox(height: 8),

              // Action 3: View Full Specs
              _InquiryActionTile(
                icon: Icons.description_outlined,
                iconColor: const Color(0xFF475569),
                iconBg: const Color(0xFFF1F5F9),
                title: 'View Full Specifications',
                subtitle: 'Datasheet, variants & product overview',
                onTap: () {
                  Get.back();
                  Get.to(
                    () => ProductdetailView(),
                    preventDuplicates: false,
                    arguments: {'productId': product.id},
                  );
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.image == null
        ? null
        : HelperFunctions().getImage(product.image);
    final hasRealImage = imageUrl != null &&
        imageUrl.isNotEmpty &&
        imageUrl != HelperFunctions.getNoImage();

    final cleanDesc = _cleanText(product.description);
    final discountPercent = product.discountPercent;

    return Container(
      decoration: BoxDecoration(
        color: context.themeWhiteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onCardTap ?? () => _showContactPricingSheet(context),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Media Area with Discount/Quote Badge (Left) and Wishlist Heart (Right)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AspectRatio(
                      aspectRatio: 1.25,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBFBFB),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: hasRealImage
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.contain,
                                memCacheWidth: 400,
                                errorWidget: (_, __, ___) =>
                                    const ProductImagePlaceholder(
                                  radius: 6,
                                  padding: EdgeInsets.all(6),
                                ),
                              )
                            : const ProductImagePlaceholder(
                                radius: 6,
                                padding: EdgeInsets.all(6),
                              ),
                      ),
                    ),

                    // Top-Left Badge (Discount or Quote on Request)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: discountPercent > 0
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF212529),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$discountPercent% OFF',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins',
                                  letterSpacing: 0.3,
                                ),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF4F9),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(0xFF20558A)
                                      .withValues(alpha: 0.2),
                                  width: 0.8,
                                ),
                              ),
                              child: const Text(
                                'QUOTE',
                                style: TextStyle(
                                  color: Color(0xFF20558A),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins',
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                    ),

                    // Top-Right Wishlist Heart Icon Button (Mirrors parent site hover overlay)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GetBuilder<WishlistController>(
                        init: Get.isRegistered<WishlistController>()
                            ? Get.find<WishlistController>()
                            : Get.put(WishlistController(), permanent: true),
                        builder: (wishController) {
                          final isFav = wishController.wishlistProductIds
                              .contains(product.id);
                          return InkWell(
                            onTap: () => _toggleWishlist(context),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.92),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(5),
                              child: isFav
                                  ? SvgPicture.asset(
                                      'assets/icon/like.svg',
                                      width: 12,
                                      height: 12,
                                    )
                                  : SvgPicture.asset(
                                      'assets/icon/unlike.svg',
                                      width: 12,
                                      height: 12,
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Product Name (Bold, 2 lines max)
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: context.themeTextColor,
                  ),
                ),

                const SizedBox(height: 3),

                // Short Description (Muted grey, 2 lines max)
                if (cleanDesc.isNotEmpty)
                  Text(
                    cleanDesc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10.5,
                      height: 1.3,
                      color: context.themeSecondrytext,
                    ),
                  ),

                const SizedBox(height: 6),

                // Dedicated Pricing Status Pill (Innovation for B2B organization)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.request_quote_outlined,
                            size: 11,
                            color: Color(0xFF1B3B64),
                          ),
                          SizedBox(width: 3.5),
                          Text(
                            'Price on Request',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B3B64),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                const SizedBox(height: 6),

                // Full-Width "Contact for Pricing" Button with Vision Navy Palette
                SizedBox(
                  width: double.infinity,
                  height: 33,
                  child: ElevatedButton(
                    onPressed: onContactPricing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B3B64),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mail_outline_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                        SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'Contact for Pricing',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 3),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 9,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InquiryActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _InquiryActionTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.themeTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: context.themeSecondrytext,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.themeSecondrytext,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
