import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:foduu_ecommerce/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:foduu_ecommerce/components/buttons/primary_action_button.dart';
import 'package:get/get.dart';

class HomeWishlistEmptyView extends GetView<WishlistController> {
  final VoidCallback? onShoppingPressed;
  final String? title;
  final String? description;
  final IconData? icon;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const HomeWishlistEmptyView({
    super.key,
    required this.colorScheme,
    required this.textTheme,
    this.onShoppingPressed,
    this.title,
    this.description,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final width = Get.width;
    final height = Get.height;

    return Scaffold(
      body: Center(
        child: Container(
          width: width * 0.835, // ≈ 313
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.053, // ≈ 20
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Container
              Container(
                width: width * 0.33, // ≈ 124
                height: height * 0.155, // ≈ 125
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(height * 0.12), // ≈ 100
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                ),
                child: Center(
                  child: Icon(
                    icon ?? Icons.inventory_2_outlined, // BOX icon
                    size: height * 0.087, // ≈ 70
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),

              SizedBox(height: height * 0.025), // gap 20

              // Text Section
              SizedBox(
                width: width * 0.73, // ≈ 273
                child: Column(
                  children: [
                    // Title
                    Text(
                      title ?? "Your wishlist is empty",
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: height * 0.022, // ≈ 18
                        fontWeight: FontWeight.w700,
                        height: 1.66, // ≈ 30
                        color: colorScheme.onSurface,
                      ),
                    ),

                    SizedBox(height: height * 0.005), // gap 4

                    // Description
                    Text(
                      description ??
                          "Start adding your favorite items to create your personalized shopping list.",
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: height * 0.018, // ≈ 14
                        fontWeight: FontWeight.w500,
                        height: 1.43, // ≈ 20
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.025), // gap 20

              // Action Button
              PrimaryActionButton(
                text: "Start Shopping",
                onPressed: onShoppingPressed ??
                    () {
                      // Default navigation
                      Get.back();
                      // Navigate to shopping page
                      // Get.toNamed(Routes.SHOP);
                    },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
