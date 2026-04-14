import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/components/app_text.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/primary_action_button.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:get/get.dart';
import '../controllers/add_profile_controllers.dart';

class AddProfileView extends GetView<AddProfileController> {
  const AddProfileView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var width = Get.width;
    var height = Get.height;
    final colorScheme = Theme.of(context).colorScheme;

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
                  color: colorScheme.onSurface,
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
                        "Add a Profile Photo",
                        fontSize: height * 0.03,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        "Personalize your account and enhance your profile visibility with a profile photo.",
                        fontSize: height * 0.018,
                        height: 1.4,
                        letterSpacing: 0,
                        maxLines: 3,
                        color: colorScheme.onSurfaceVariant,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: height * 0.02),

                Container(
                  height: height * 0.55,
                  alignment: Alignment.center,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 1️⃣ Main Circular Image Container
                      Container(
                        width: height * 0.27, // ≈ 214.52
                        height: height * 0.27, // ≈ 214.52
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, // radius ≈ 117224872
                          image: const DecorationImage(
                            image:
                                AssetImage("assets/images/profile_image.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // 2️⃣ Bottom-Right Circular Button
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: height * 0.068, // ≈ 54
                          height: height * 0.068, // ≈ 54
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, // radius ≈ 540
                            color: colorScheme.surface,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.delete,
                              size: height * 0.03, // ≈ 24
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: height * 0.02),

                PrimaryActionButton(
                    text: "Continue",
                    onPressed: () {
                      print("Continue");
                      Get.toNamed(Routes.CHOOSECATEGORY);
                    }),
              ],
            )),
          ],
        ),
      ),
    ));
  }
}
