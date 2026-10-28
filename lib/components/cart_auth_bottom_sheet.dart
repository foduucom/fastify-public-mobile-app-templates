import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/buttons/appbutton.dart';
import 'package:zouhi/constants/theme_ext.dart';

/// Shown when a guest (skip mode) tries to add an item to the cart.
Future<void> showCartAuthBottomSheet({String? title, String? message}) async {
  if (Get.isBottomSheetOpen == true) return;
  final context = Get.context!;
  await Get.bottomSheet(
    Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: context.themegreyColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.themeRedColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 30,
              color: context.themeRedColor,
            ),
          ),
            const SizedBox(height: 18),
            Text(
              title ?? 'Sign in to Add to Cart',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: context.themeTextColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message ??
                  'Sign in to add items to your cart, sync your selections across devices, and checkout.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                fontFamily: 'Poppins',
                color: context.themeSecondrytext,
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              itemText: 'Log In / Sign Up',
              keypressEvent: () {
                Get.back();
                Get.toNamed(Routes.LOGIN);
              },
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: TextButton(
                onPressed: Get.back,
                child: Text(
                  'Maybe Later',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: context.themeSecondrytext,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}
