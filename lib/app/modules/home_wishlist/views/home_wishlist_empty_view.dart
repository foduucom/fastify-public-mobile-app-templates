import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:foduu_ecommerce/app/modules/home_wishlist/controllers/home_wishlist_controllers.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/primary_action_button.dart';
import 'package:get/get.dart';

class HomeWishlistEmptyView extends GetView<HomeWishlistControllers> {
  const HomeWishlistEmptyView({super.key});

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
              Container(
                width: width * 0.33, // ≈ 124
                height: height * 0.155, // ≈ 125
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(height * 0.12), // ≈ 100
                  color: const Color(0xFFF5F5F5),
                ),
                child: Center(
                  child: Icon(
                    Icons.inventory_2_outlined, // BOX icon
                    size: height * 0.087, // ≈ 70
                    color: const Color(0xFF666666),
                  ),
                ),
              ),

              SizedBox(height: height * 0.025), // gap 20
              SizedBox(
                width: width * 0.73, // ≈ 273
                child: Column(
                  children: [
                    // Title
                    Text(
                      "Your wishlist is empty",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: height * 0.022, // ≈ 18
                        fontWeight: FontWeight.w700,
                        height: 1.66, // ≈ 30
                        color: const Color(0xFF232323),
                      ),
                    ),

                    SizedBox(height: height * 0.005), // gap 4

                    // Description
                    Text(
                      "Start adding your favorite items to create your personalized shopping list.",
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: height * 0.018, // ≈ 14
                        fontWeight: FontWeight.w500,
                        height: 1.43, // ≈ 20
                        color: const Color(0xFF858585),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.025), // gap 20

              PrimaryActionButton(
                text: "Start Shopping",
                onPressed: () {
                  // navigation later
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
