import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/choose_category/controllers/choose_category_controllers.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/components/app_text.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/primary_action_button.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:get/get.dart';

class ChooseCategoryView extends GetView<ChooseCategoryController> {
  const ChooseCategoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = Get.width;
    var height = Get.height;

    return Scaffold(
        body: SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button — fully left aligned
            Padding(
              padding: EdgeInsets.only(
                left: width * 0.01, // minimal edge padding
                top: height * 0.01,
              ),
              child: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.arrow_back,
                  size: width * 0.06,
                ),
              ),
            ),

            // Scrollable Content
            Expanded(
                child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.03,
                vertical: height * 0.02,
              ),
              children: [
                // Title + Description
                Container(
                  //margin: const EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        "Discover Your Style Identity",
                        fontSize: height * 0.03,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        "Pick a Category that Aligns with Your Fashion Personality",
                        fontSize: height * 0.018,
                        height: 1.4,
                        letterSpacing: 0,
                        maxLines: 3,
                        color: DefaultThemeColors.darklighter,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: height * 0.03),

                Obx(() {
                  return Container(
                    alignment: Alignment.centerLeft,
                    width: width * 0.7,
                    height: height * 0.37,
                    child: Wrap(
                      spacing: width * 0.0001, // casual horizontal spacing
                      runSpacing: height * 0.015, // casual vertical spacing
                      children: controller.categoryList.map((category) {
                        final bool isActive =
                            controller.selectedCategory.value == category;

                        return GestureDetector(
                          onTap: () {
                            controller.selectedCategory.value = category;
                          },
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: width * 0.12,
                              maxWidth: width * 0.30,
                            ),
                            child: Container(
                              height: height * 0.05,
                              padding: EdgeInsets.symmetric(
                                horizontal: width * 0.05,
                                vertical: height * 0.0075,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? DefaultThemeColors.mainprimary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(height * 2),
                                border: Border.all(
                                  color: isActive
                                      ? DefaultThemeColors.mainprimary
                                      : DefaultThemeColors.darkOnSecondary,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  category,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.w500,
                                    fontSize: height * 0.02,
                                    height: 1.75,
                                    letterSpacing: 0,
                                    color: isActive
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onInverseSurface
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),

                SizedBox(height: height * 0.02),

                PrimaryActionButton(
                    text: "Continue",
                    onPressed: () {
                      print("Continue");
                      Get.toNamed(Routes.BOTTOMBAR);
                    }),

                SizedBox(height: height * 0.01),

                PrimaryActionButton(
                    text: "Skip",
                    backgroundColor:
                        Theme.of(context).colorScheme.onInverseSurface,
                    textColor: DefaultThemeColors.mainprimary,
                    onPressed: () {
                      print("Skip");
                    }),
              ],
            )),
          ],
        ),
      ),
    ));
  }
}
