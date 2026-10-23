import 'package:flutter/material.dart';
import 'package:zouhi/app/modules/shop/controllers/productdetial_controller.dart';
import 'package:zouhi/components/review.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme_ext.dart';

class AllReview extends StatelessWidget {
  final List reviewData;
  final ProductdetialController controller;
  final String name;
  final int rating;

  const AllReview({
    Key? key,
    required this.reviewData,
    required this.controller,
    required this.name,
    required this.rating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: context.colors.surface,
        appBar: AppBar(
          title: Text(
            'Customer Reviews (${reviewData.length})',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          elevation: 0,
          backgroundColor: context.colors.surface,
          foregroundColor: context.colors.onSurface,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CUSTOMER REVIEWS & FEEDBACK',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.themeSecondrytext,
                    letterSpacing: 0.5,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  separatorBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(
                      thickness: 0.8,
                      color: context.colors.outline.withOpacity(0.3),
                    ),
                  ),
                  shrinkWrap: true,
                  itemCount: reviewData.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = reviewData[index];
                    final reviewerName = item['name'] ??
                        item['customer_id']?['name'] ??
                        item['customer_name'] ??
                        item['customer']?['name'] ??
                        item['user_name'] ??
                        item['user']?['name'] ??
                        'Guest';
                    final dateStr = controller
                        .getDate(item['created_at'] ?? item['updated_at']);
                    final reviewText = item['summary'] ??
                        item['comment'] ??
                        item['review'] ??
                        '';
                    final num ratingVal = item['rating'] ?? 0;

                    return customerReview(
                      profileimage: HelperFunctions().getImage(
                        item['customer']?['featured_image'] ??
                            item['customer_id']?['featured_image'] ??
                            item['customer_id']?['avatar'],
                      ),
                      name: "$reviewerName | $dateStr",
                      review: reviewText.toString(),
                      rating: ratingVal.toInt(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
