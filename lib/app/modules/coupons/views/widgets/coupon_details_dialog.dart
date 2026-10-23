import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/modules/coupons/controllers/coupons_controller.dart';
import 'package:zouhi/app/modules/coupons/models/coupon_model.dart';
import 'package:zouhi/constants/theme_ext.dart';

class CouponDetailsDialog extends StatefulWidget {
  final CouponModel coupon;

  const CouponDetailsDialog({Key? key, required this.coupon}) : super(key: key);

  @override
  State<CouponDetailsDialog> createState() => _CouponDetailsDialogState();
}

class _CouponDetailsDialogState extends State<CouponDetailsDialog> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _productsScrollController = ScrollController();
  final ScrollController _dialogScrollController = ScrollController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _productsScrollController.dispose();
    _dialogScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const navyPrimary = Color(0xFF133E6D);
    const greenSavings = Color(0xFF16A34A);

    final coupon = widget.coupon;
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.85;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: context.themeWhiteColor,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: maxHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dialog Header: "Coupon Details" + Close Button [X]
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Text(
                    'Coupon Details',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: context.themetitleColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: context.themeSecondrytext,
                      size: 22,
                    ),
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                controller: _dialogScrollController,
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Voucher Box: Dashed Container with Code & Discount
                    DottedBorder(
                      color: navyPrimary,
                      strokeWidth: 1.4,
                      dashPattern: const [6, 4],
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              coupon.code,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                                letterSpacing: 1.2,
                                color: navyPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              coupon.displayDiscountOff,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: greenSavings,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Metadata Details Rows
                    _buildDetailRow(
                      context,
                      label: 'Coupon Type',
                      value: coupon.displayCouponType,
                    ),
                    _buildDetailRow(
                      context,
                      label: 'Discount Type',
                      value: coupon.displayDiscountType,
                    ),
                    _buildDetailRow(
                      context,
                      label: 'Minimum Order',
                      value: coupon.displayMinOrder,
                    ),
                    _buildDetailRow(
                      context,
                      label: 'Valid From',
                      value: coupon.displayValidFrom,
                    ),
                    _buildDetailRow(
                      context,
                      label: 'Valid Until',
                      value: coupon.displayValidUntil,
                      valueColor: coupon.endDate == null ? greenSavings : null,
                    ),
                    const SizedBox(height: 16),

                    // APPLICABLE PRODUCTS SECTION
                    Row(
                      children: [
                        Icon(
                          Icons.business_center_rounded,
                          size: 16,
                          color: context.themeSecondrytext,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'APPLICABLE PRODUCTS',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                            letterSpacing: 0.6,
                            color: context.themeSecondrytext,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Dynamic Products Display based on Tester Feedback:
                    _buildApplicableProductsContent(context, coupon),
                  ],
                ),
              ),
            ),

            // Fixed Bottom CTA: [📋 COPY COUPON CODE]
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
              decoration: BoxDecoration(
                color: context.themeWhiteColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.find<CouponsController>()
                        .copyCouponCode(coupon.code, context: context);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.copy_rounded, size: 17),
                  label: const Text(
                    'COPY COUPON CODE',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navyPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: context.themeSecondrytext,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: valueColor ?? context.themetitleColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicableProductsContent(
      BuildContext context, CouponModel coupon) {
    const navyPrimary = Color(0xFF133E6D);

    // Case 1: All Products (e.g. LJDJ6C6IVM, W5TB8 where product_ids is empty)
    if (!coupon.hasProductRestrictions) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF16A34A),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Applicable to All Products',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: Color(0xFF15803D),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'This coupon can be used on any product across our entire catalog with no restriction.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11.5,
                      color: Color(0xFF166534),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Case 2: Few Products (<= 5 products, e.g. 2 minimum products)
    if (coupon.productIds.length <= 5 && coupon.productIds.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF4F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Valid on ${coupon.productIds.length} specific item(s):',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: navyPrimary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: coupon.productIds.map((product) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 14,
                      color: navyPrimary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        product.name.isNotEmpty ? product.name : 'Product',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      );
    }

    // Case 3: Many Products (> 5 products, e.g. RESTRICT2 with 400+ products)
    final filteredProducts = _searchQuery.isEmpty
        ? coupon.productIds
        : coupon.productIds
            .where((p) =>
                p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Friendly notice card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: navyPrimary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Applicable to Selected Products (${coupon.productCount} qualifying items)',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: navyPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Quick search box for large catalogs
        if (coupon.productIds.length > 8)
          Container(
            height: 36,
            margin: const EdgeInsets.only(bottom: 10),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
              style: const TextStyle(fontSize: 12, fontFamily: 'Poppins'),
              decoration: InputDecoration(
                hintText: 'Search eligible products...',
                hintStyle: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  color: context.themeSecondrytext.withOpacity(0.7),
                ),
                prefixIcon: const Icon(Icons.search, size: 16),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: navyPrimary),
                ),
              ),
            ),
          ),

        // Responsive grid/chips of items matching image 2 & 3
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 220),
          child: Scrollbar(
            controller: _productsScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _productsScrollController,
              primary: false,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: filteredProducts.take(80).map((product) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      product.name.isNotEmpty ? product.name : 'Product',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF334155),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        if (filteredProducts.length > 80)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '+ and ${filteredProducts.length - 80} more eligible products',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: context.themeSecondrytext,
              ),
            ),
          ),
      ],
    );
  }
}
