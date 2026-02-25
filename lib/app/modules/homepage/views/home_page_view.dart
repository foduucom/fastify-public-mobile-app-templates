import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/home_wishlist/views/home_wishlist_empty_view.dart';
import 'package:foduu_ecommerce/app/modules/home_wishlist/views/home_wishlist_view.dart';
import 'package:foduu_ecommerce/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:foduu_ecommerce/app/modules/homepage/views/material/responsive_bottom_nav.dart';
import 'package:foduu_ecommerce/app/modules/homepage/views/material/responsive_circle_icon.dart';
import 'package:foduu_ecommerce/app/modules/homepage/views/material/responsive_common_header.dart';
import 'package:foduu_ecommerce/app/modules/homepage/views/material/shopping_card.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/home_component/home_banner.dart';
import 'package:foduu_ecommerce/components/home_component/home_category.dart';
import 'package:foduu_ecommerce/components/home_component/home_products.dart';
import 'package:foduu_ecommerce/constants/app_loader.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/core/foduuStudio/foduu_studio_layout_view.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class HomePageView extends GetView<HomepageController> {
  const HomePageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FoduuStudioLayoutView(
        widgetList: controller.widgetList,
        isLoading: controller.isLoading,
        onRefresh: () async {
          await controller.getDashboardDesign(controller.pageSlug);
        },
      ),
    );
  }

  // Fallback method for static products (can be removed once API is confirmed working)
  // Widget _buildStaticProducts(
  //     BuildContext context, double width, double height) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       // Header Row
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Text(
  //             "Featured Product",
  //             style: TextStyle(
  //               fontFamily: 'Plus Jakarta Sans',
  //               fontWeight: FontWeight.w700,
  //               fontSize: height * 0.02,
  //               height: 1.75,
  //               color: context.onBackgroundColor, // Theme-aware title
  //             ),
  //           ),
  //           Text(
  //             "See More",
  //             textAlign: TextAlign.right,
  //             style: TextStyle(
  //               fontFamily: 'Plus Jakarta Sans',
  //               fontWeight: FontWeight.w600,
  //               fontSize: height * 0.018,
  //               height: 1.85,
  //               color: DefaultThemeColors.secondarymain, // Brand color
  //             ),
  //           ),
  //         ],
  //       ),

  //       SizedBox(height: height * 0.02),

  //       GridView.builder(
  //         shrinkWrap: true,
  //         physics: const NeverScrollableScrollPhysics(),
  //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //           crossAxisCount: 2,
  //           mainAxisSpacing: height * 0.015,
  //           crossAxisSpacing: width * 0.03,
  //           childAspectRatio: (width * 0.406) / (height * 0.310),
  //         ),
  //         itemCount: 6,
  //         itemBuilder: (context, index) {
  //           return ShoppingCard(
  //             width: width,
  //             height: height,
  //             imagePath: "assets/images/shopping_image_1.png",
  //             title: "Oliver Blazer New Version",
  //             storeName: "Agliza Store",
  //             price: "\$85.23",
  //             rating: 4.5,
  //             onTap: () {
  //               print("Card tapped");
  //               // Pass the product as argument to navigation
  //               Get.toNamed(
  //                 Routes.PRODUCTDETAILS,
  //               );
  //             },
  //           );
  //         },
  //       ),
  //     ],
  //   );
  // }
}
