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
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class HomePageView extends GetView<HomepageController> {
  const HomePageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = Get.width;
    var height = Get.height;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // MAIN CONTENT AREA - Use Expanded to fill remaining space
            Expanded(
              child: _homeBody(context),
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder for other pages - replace with your actual pages
  Widget _placeholderPage(String title) {
    return Center(
      child: Text(
        title,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _homeBody(BuildContext context) {
    var width = Get.width;
    var height = Get.height;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.05,
          vertical: height * 0.02,
        ),
        child: Column(
          children: [
            // Instead of hardcoded banner, use:
            Obx(() {
              print(
                  'HomePage rebuilding... isLoading: ${controller.isLoading.value}');

              if (controller.widgetList.isEmpty || controller.isLoading.value) {
                // Show loading or fallback
                print('widgetList is empty, showing fallback');
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: double.infinity,
                    height: height * 0.18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                  ),
                );
              }

              for (int i = 0; i < controller.widgetList.length; i++) {
                var widget = controller.widgetList[i];
                print('$i: ${widget.runtimeType}');

                if (widget is HomeBanner) {
                  print('Found HomeBanner at index $i!');
                  return widget;
                }
              }

              // If no banner found, show fallback or empty
              return SizedBox.shrink();
            }),

            SizedBox(height: height * 0.01),

            Obx(() {
              // Find the CategoryHome widget in widgetList
              var categoryHomeWidget = controller.widgetList.firstWhere(
                (widget) => widget is CategoryHome,
                orElse: () => null,
              );

              if (controller.isLoading.value || categoryHomeWidget == null) {
                return SizedBox(
                  height: height * 0.06, // Adjust based on your category height
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 6, // Show 6 shimmer category items
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          right: width * 0.03,
                          left: index == 0 ? width * 0.05 : 0,
                        ),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: width * 0.25, // Adjust width as needed
                            height: height * 0.045,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              // Use the CategoryHome widget's buildListView method
              return categoryHomeWidget;
            }),

            SizedBox(height: height * 0.02),

            // GridView for products - Wrap with Expanded
            Obx(() {
              if (controller.isLoading.value) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section title shimmer
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16, top: 16, bottom: 12),
                        child: Container(
                          width: 150,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // Horizontal categories shimmer
                      SizedBox(
                        height: 100, // Adjust based on your design
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: 6, // Show 6 shimmer items
                          itemBuilder: (context, index) {
                            return Container(
                              width: 80,
                              margin: EdgeInsets.only(right: 12),
                              child: Column(
                                children: [
                                  // Category image
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  // Category name - two lines for text
                                  Column(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Container(
                                        width: 30,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }

              final hasProducts = controller.widgetList
                  .any((widget) => widget is TrendingProductSection);

              if (!hasProducts) {
                return _buildStaticProducts(width, height);
              }

              return Column(
                children: controller.widgetList
                    .where((widget) => widget is TrendingProductSection)
                    .map<Widget>((dynamic item) => item as Widget)
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Fallback method for static products (can be removed once API is confirmed working)
  Widget _buildStaticProducts(double width, double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Featured Product",
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
                fontSize: height * 0.02,
                height: 1.75,
              ),
            ),
            Text(
              "See More",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
                fontSize: height * 0.018,
                height: 1.85,
                color: DefaultThemeColors.secondarymain,
              ),
            ),
          ],
        ),

        SizedBox(height: height * 0.02),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: height * 0.015,
            crossAxisSpacing: width * 0.03,
            childAspectRatio: (width * 0.406) / (height * 0.310),
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return ShoppingCard(
              width: width,
              height: height,
              imagePath: "assets/images/shopping_image_1.png",
              title: "Oliver Blazer New Version",
              storeName: "Agliza Store",
              price: "\$85.23",
              rating: 4.5,
              onTap: () {
                print("Card tapped");

                // Create the product object
                // final product = Product(
                //   id: "1",
                //   imagePath: "assets/images/shopping_image_1.png",
                //   title: "Oliver Blazer New Version",
                //   storeName: "Agliza Store",
                //   price: "\$85.23",
                //   reviews: "48",
                //   rating: 4.5,
                //   description:
                //       "Kahoona Crewneck Gray are a popular and versatile wardrobe staple...",
                //   images: [
                //     'assets/images/shopping_image_1.png',
                //     'assets/images/women-1.png',
                //     'assets/images/kidscard1.png',
                //     'assets/images/flowerprint.png',
                //     'assets/images/categeory.png',
                //     'assets/images/categoryimg.png',
                //     'assets/images/categerrybeauty.png',
                //     'assets/images/shopping_image_1.png',
                //   ],
                // );

                // Pass the product as argument to navigation
                Get.toNamed(
                  Routes.PRODUCTDETAILS,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
