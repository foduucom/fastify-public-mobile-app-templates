import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:foddu/app/routes/app_pages.dart';
import 'package:foddu/components/buttons/appbutton.dart';

/// Shown when a guest in skip mode attempts to checkout or perform an action
/// requiring authentication from Cart.
Future<void> showCartAuthBottomSheet({
  String? title,
  String? message,
  String? buttonText,
  VoidCallback? onLoginSuccess,
}) async {
  if (Get.isBottomSheetOpen == true) return;
  final context = Get.context;
  if (context == null) return;

  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  await Get.bottomSheet(
    Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle pill
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Icon badge
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 32,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 18),

            // Title
            Text(
              title ?? 'Sign in to Place Order',
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              message ??
                  'Sign in to choose delivery address, apply coupons, and complete your order seamlessly.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),

            // Primary Log In Button
            AppButton(
              itemText: buttonText ?? 'LOG IN / SIGN UP',
              keypressEvent: () {
                Get.back();
                Get.toNamed(Routes.LOGIN);
              },
            ),
            const SizedBox(height: 10),

            // Maybe Later dismiss button
            SizedBox(
              width: double.infinity,
              height: 40,
              child: TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Maybe Later',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
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
