import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';

class ShoppingCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String storeName;
  final String price;
  final double rating;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const ShoppingCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.storeName,
    required this.price,
    required this.rating,
    required this.width,
    required this.height,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(height * 0.015),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(width * 0.02),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height * 0.015),
          border: Border.all(
            color: DefaultThemeColors.darklight,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: double.infinity,
              height: height * 0.18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height * 0.012),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(height: height * 0.01),

            // Product Title
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
                fontSize: height * 0.018,
                height: 1.4,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            SizedBox(height: height * 0.004),

            // Store Name
            Text(
              storeName,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w400,
                fontSize: height * 0.015,
                height: 2,
                color: DefaultThemeColors.darklighter,
              ),
            ),

            const Spacer(),

            // Price & Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price
                Row(
                  children: [
                    Icon(
                      Icons.sell_outlined,
                      size: height * 0.02,
                      color: DefaultThemeColors.mainprimary,
                    ),
                    SizedBox(width: width * 0.005),
                    Text(
                      price,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: height * 0.018,
                        color: DefaultThemeColors.mainprimary,
                      ),
                    ),
                  ],
                ),

                // Rating
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: height * 0.02,
                      color: DefaultThemeColors.alertWarninglight,
                    ),
                    SizedBox(width: width * 0.005),
                    Text(
                      rating.toString(),
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: height * 0.018,
                        color: DefaultThemeColors.darkdark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
