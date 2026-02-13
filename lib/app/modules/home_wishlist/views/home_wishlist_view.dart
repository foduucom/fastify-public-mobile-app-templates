import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/home_wishlist/controllers/home_wishlist_controllers.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:get/get.dart';

class HomeWishlistView extends GetView<HomeWishlistControllers> {
  const HomeWishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    var width = Get.width;
    var height = Get.height;

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.04,
            vertical: height * 0.02,
          ),
          child: Obx(
            () => GridView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: controller.favoriteCollections.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: width * 0.06,
                mainAxisSpacing: width * 0.06,
                childAspectRatio: (width * 0.43) / (height * 0.26),
              ),
              itemBuilder: (context, index) {
                final collection = controller.favoriteCollections[index];
                return _favoriteCollectionCard(
                  width,
                  height,
                  collection,
                  index,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _favoriteCollectionCard(
    var width,
    var height,
    Map<String, dynamic> collection,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        print('Tapped on: ${collection['title']}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width * 0.43,
            height: width * 0.43,
            padding: EdgeInsets.all(width * 0.02),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height * 0.01),
              border: Border.all(
                color: DefaultThemeColors.darklight.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: GridView.count(
              crossAxisCount: 2,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: width * 0.02,
              crossAxisSpacing: width * 0.02,
              children: List.generate(
                collection['images'].length,
                (imageIndex) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(height * 0.006),
                      image: DecorationImage(
                        image: AssetImage(collection['images'][imageIndex]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: height * 0.01),
          Text(
            collection['title'] ?? 'No Title',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: height * 0.018,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: height * 0.003),
          Text(
            collection['subtitle'] ?? '0 Items',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: height * 0.015,
              fontWeight: FontWeight.w500,
              height: 2,
              color: DefaultThemeColors.darklighter,
            ),
          ),
        ],
      ),
    );
  }
}
