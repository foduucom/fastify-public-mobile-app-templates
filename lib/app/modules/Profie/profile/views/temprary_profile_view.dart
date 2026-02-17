import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/Profie/profile/controllers/profile_controller.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:get/get.dart';

class TempraryProfileView extends GetView<ProfileController> {
  const TempraryProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    var width = Get.width;
    var height = Get.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: SizedBox(
          width: width * 0.26, // ≈ 97
          child: Text(
            "My Profile",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: height * 0.025, // ≈ 20
              fontWeight: FontWeight.w700, // Bold
              height: 1.6, // ≈ 32 line-height
            ),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.05,
          vertical: height * 0.02,
        ),
        children: [
          Container(
            width: width * 0.92, // ≈ 345
            padding: EdgeInsets.all(width * 0.03), // ≈ 12
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height * 0.015), // ≈ 12
              border: Border.all(color: DefaultThemeColors.darklight),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: height * 0.075, // ≈ 60
                  height: height * 0.075, // ≈ 60
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle, // huge radius from figma
                    image: DecorationImage(
                      image: AssetImage("assets/images/profile_image.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                SizedBox(width: width * 0.05), // ≈ gap 20
                SizedBox(
                  width: width * 0.60, // ≈ 241
                  height: height * 0.07, // ≈ 48
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Roberto Lavaruno",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: height * 0.022, // ≈ 18
                          fontWeight: FontWeight.w600, // SemiBold
                          height: 1.66, // ≈ 30
                        ),
                      ),
                      Text(
                        "robertolavaruno@gmail.com",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: height * 0.018, // ≈ 14
                          fontWeight: FontWeight.w500, // Medium
                          height: 1.4, // ≈ 20
                          color: DefaultThemeColors.darklighter,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: height * 0.0215),
          Container(
            width: width * 0.92, // ≈ 345
            height: height * 0.69, // ≈ 552
            child: Column(
              children: List.generate(controller.profileMenu.length, (index) {
                final item = controller.profileMenu[index];

                return Container(
                  width: width * 0.92,
                  padding: EdgeInsets.only(
                    bottom: height * 0.025, // ≈ 20
                  ),
                  margin: EdgeInsets.only(
                    bottom: height * 0.02, // visual gap
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: DefaultThemeColors.darklight,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item['icon'],
                        size: height * 0.025, // ≈ 20
                      ),

                      SizedBox(width: width * 0.03), // ≈ gap 12

                      Expanded(
                        child: Text(
                          item['title'],
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: height * 0.018, // ≈ 14
                            fontWeight: FontWeight.w600, // SemiBold
                            height: 1.4, // ≈ 20
                          ),
                        ),
                      ),

                      IconButton(
                        icon: Icon(
                          Icons.chevron_right,
                          size: height * 0.025,
                        ),
                        onPressed: () {
                          print("On Clicked: ${item['title']}");
                          item[
                              'onPressed'](); // ✅ Call the function, not just reference it
                        },
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
