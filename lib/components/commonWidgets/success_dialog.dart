import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/components/app_text.dart';
import 'package:foduu_ecommerce/components/buttons/primary_action_button.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:get/get.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final String buttonText;
  final VoidCallback onPressed;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    this.buttonText = "Continue",
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final width = Get.width;
    final height = Get.height;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        width: width * 0.92, // ≈ 345
        padding: EdgeInsets.fromLTRB(
          width * 0.043, // left 16
          height * 0.04, // top 32
          width * 0.043, // right 16
          height * 0.02, // bottom 16
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(height * 0.025), // ≈ 20
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Hug content
          children: [
            // 1️⃣ Image
            SizedBox(
              width: width * 0.65,
              height: height * 0.125,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(height: height * 0.025),

            // 2️⃣ Text Content
            Container(
              width: width * 0.83,
              padding: EdgeInsets.symmetric(horizontal: width * 0.055),
              child: Column(
                children: [
                   SizedBox(
                    width: width * 0.73,
                    child: AppText(
                      title,
                      fontSize: height * 0.022,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ),
                  SizedBox(height: height * 0.0025),
                  SizedBox(
                    width: width * 0.73,
                    child: AppText(
                      description,
                      fontSize: height * 0.017,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                      textAlign: TextAlign.center,
                      maxLines: 5,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: height * 0.025),

            // 3️⃣ Action Button
            SizedBox(
              width: double.infinity,
              height: height * 0.06,
              child: PrimaryActionButton(
                text: buttonText,
                onPressed: onPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
