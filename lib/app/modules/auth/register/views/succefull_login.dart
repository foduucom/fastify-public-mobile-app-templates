import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/routes/app_pages.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback? onContinue;

  const SuccessDialog({
    Key? key,
    this.title      = 'You have logged in\nsuccessfully',
    this.subtitle   = 'Lorem Ipsum is simply dummy text of the\nprinting and typesetting industry.',
    this.buttonText = 'Continue',
    this.onContinue,
  }) : super(key: key);

  // ── Static helper to show it easily anywhere ──────────────────────
  static void show({
    String title      = 'You have logged in\nsuccessfully',
    String subtitle   = 'Lorem Ipsum is simply dummy text of the\nprinting and typesetting industry.',
    String buttonText = 'Continue',
    VoidCallback? onContinue,
  }) {
    Get.dialog(
      SuccessDialog(
        title:       title,
        subtitle:    subtitle,
        buttonText:  buttonText,
        onContinue:  onContinue,
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.35),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // ── Green Checkmark Circle ──────────────────────────────
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFF2ECC71),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 48,
              ),
            ),

            const SizedBox(height: 28),

            // ── Title ───────────────────────────────────────────────
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 12),

            // ── Subtitle ────────────────────────────────────────────
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            // ── Continue Button ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: onContinue ??
                        () {
                      Get.back();
                      Get.offAllNamed(Routes.BOTTOMBAR);
                    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}