import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:zouhi/app/modules/coupons/models/coupon_model.dart';
import 'package:zouhi/constants/theme_ext.dart';

class CouponCard extends StatelessWidget {
  final CouponModel coupon;
  final VoidCallback onInfoTap;
  final VoidCallback onCopyTap;

  const CouponCard({
    Key? key,
    required this.coupon,
    required this.onInfoTap,
    required this.onCopyTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const navyPrimary = Color(0xFF133E6D);
    const tealInfo = Color(0xFF128CA7);
    const greenSavings = Color(0xFF16A34A);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Dashed border voucher card
          DottedBorder(
            color: context.themeBorderColor.withOpacity(0.9),
            strokeWidth: 1.2,
            dashPattern: const [6, 4],
            borderType: BorderType.RRect,
            radius: const Radius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              decoration: BoxDecoration(
                color: context.themeWhiteColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Code Box + Info/Copy Action buttons
                  Row(
                    children: [
                      // Coupon Code Pill/Box
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFCBD5E1),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          coupon.code,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: 0.8,
                            color: navyPrimary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Info button (i)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onInfoTap,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: tealInfo,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.info_outline_rounded,
                              color: Colors.white,
                              size: 19,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Copy button [COPY]
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onCopyTap,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 36,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 0),
                            decoration: BoxDecoration(
                              color: navyPrimary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.copy_rounded,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'COPY',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Savings Headline: "Save $10.00 on this order!"
                  Text(
                    coupon.savingsHeadline,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: greenSavings,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Condition Subtitle: "Get $10.00 Off on orders above $10.00"
                  Text(
                    coupon.orderConditionSubtitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: context.themeSecondrytext,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Scope Pill Tag: [💼 Specific Products] or [🛍 All Products]
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: coupon.hasProductRestrictions
                          ? const Color(0xFFEAF2F9)
                          : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          coupon.hasProductRestrictions
                              ? Icons.work_outline_rounded
                              : Icons.shopping_bag_outlined,
                          size: 13,
                          color: coupon.hasProductRestrictions
                              ? const Color(0xFF13508F)
                              : const Color(0xFF15803D),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          coupon.scopeBadgeLabel,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: coupon.hasProductRestrictions
                                ? const Color(0xFF13508F)
                                : const Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top Badge: "PRODUCT DISCOUNT"
          Positioned(
            top: -9,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: navyPrimary,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                coupon.badgeText,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
