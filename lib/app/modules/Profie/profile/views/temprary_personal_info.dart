import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/components/buttons/primary_action_button.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:get/get.dart';

class TempraryPersonalInfo extends StatelessWidget {
  const TempraryPersonalInfo({super.key});

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
            "Personal Info",
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
          SizedBox(height: height * 0.015),
          Container(
            width: width * 0.92, // ≈ 345
            padding: EdgeInsets.only(
              top: height * 0.03, // ≈ 24
              left: width * 0.03, // ≈ 12
              right: width * 0.03,
              bottom: height * 0.015, // ≈ 12
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height * 0.015), // ≈ 12
              border: Border.all(color: DefaultThemeColors.darklight),
            ),
            child: Column(
              children: [
                Container(
                  width: height * 0.1125, // ≈ 90
                  height: height * 0.1125, // ≈ 90
                  alignment: Alignment.center,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: height * 0.1125,
                        height: height * 0.1125,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle, // huge radius
                          image: DecorationImage(
                            image:
                                AssetImage("assets/images/profile_image.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: height * 0.0375, // ≈ 30
                          height: height * 0.0375, // ≈ 30
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, // radius ≈ 540
                            color: Theme.of(Get.context!)
                                .colorScheme
                                .onInverseSurface,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.edit_outlined, // Pencil / Pen
                              size: height * 0.0225, // ≈ 18
                              color: DefaultThemeColors.darkmain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                _profileFieldRow(
                  title: "Fullname",
                  value: "Roberto Lavaruno",
                  icon: Icons.person_outline,
                  enabled: false,
                ),

                SizedBox(height: height * 0.015), // gap 12

                _profileFieldRow(
                  title: "Email",
                  value: "robertolavaruno@gmail.com",
                  icon: Icons.email_outlined,
                  enabled: false,
                ),

                SizedBox(height: height * 0.015),

                _profileFieldRow(
                  title: "Phone Number",
                  value: "+1 234 567 890",
                  icon: Icons.call_outlined,
                  enabled: true,
                ),

                SizedBox(height: height * 0.015),

                _profileFieldRow(
                  title: "Password",
                  value: "••••••••",
                  icon: Icons.lock_outline,
                  enabled: true,
                ),

                SizedBox(height: height * 0.015),

                _profileFieldRow(
                  title: "Address",
                  value: "Historical st, West Anderson 43. CA",
                  icon: Icons.location_on_outlined,
                  enabled: true,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: PrimaryActionButton(
        text: "Update Profile",
        onPressed: () {
          print("Clicked On Update Profile");
        },
      ),
    );
  }

  Widget _profileFieldRow({
    required String title,
    required String value,
    required IconData icon,
    required bool enabled,
  }) {
    final width = Get.width;
    final height = Get.height;

    return SizedBox(
      width: width * 0.86, // ≈ 321
      height: height * 0.10, // ≈ 80
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width * 0.86,
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: height * 0.015, // ≈ 12
                fontWeight: FontWeight.w600, // SemiBold
                height: 2, // ≈ 24
                color: DefaultThemeColors.darklighter,
              ),
            ),
          ),

          SizedBox(height: height * 0.005), // gap 4
          Container(
            width: width * 0.86,
            height: height * 0.065, // ≈ 52
            padding: EdgeInsets.all(width * 0.04), // ≈ 16
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height * 0.01), // ≈ 8
              border: Border.all(color: DefaultThemeColors.darklight),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: height * 0.025, // ≈ 20
                  color: DefaultThemeColors.darklighter,
                ),

                SizedBox(width: width * 0.04), // gap 16
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: height * 0.018, // ≈ 14
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      color: enabled
                          ? DefaultThemeColors.lightOnSecondary
                          : DefaultThemeColors.darklighter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
