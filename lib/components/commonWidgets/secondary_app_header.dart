import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/homepage/views/material/responsive_circle_icon.dart';
import 'package:get/get.dart';

class SecondaryAppHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final bool showBack;
  final bool showRight;
  final IconData rightIcon;

  const SecondaryAppHeader({
    Key? key,
    required this.title,
    this.onBack,
    this.showRight = true,
    this.showBack = true,
    this.rightIcon = Icons.more,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = Get.size;
    final height = size.height;
    final width = size.width;

    return Column(
      children: [
        SizedBox(height: height * 0.02),
        Container(
          width: width * 0.92,
          height: height * 0.055,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// BACK BUTTON
              showBack
                  ? ResponsiveCircleIcon(
                      width: width,
                      height: height,
                      icon: Icons.arrow_back_ios_new,
                      onTap: onBack ?? () => Get.back(),
                      diameter: height * 0.022,
                    )
                  : SizedBox(width: height * 0.055),

              /// TITLE
              SizedBox(
                width: width * 0.64,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: height * 0.02,
                    fontWeight: FontWeight.w700,
                    height: 1.75,
                  ),
                ),
              ),

              /// RIGHT ICON / ACTION
              showRight
                  ? ResponsiveCircleIcon(
                      width: width,
                      height: height,
                      icon: rightIcon,
                      diameter: height * 0.022)
                  : SizedBox(width: height * 0.055),
            ],
          ),
        ),
      ],
    );
  }
}
