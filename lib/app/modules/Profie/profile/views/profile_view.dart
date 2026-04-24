import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../components/app_back_button.dart';
import '../../../../../components/app_bar.dart';
import '../../../../../components/app_bar2.dart';
import '/app/modules/auth/auth_details.dart';
import '/app/modules/bottomar/controllers/bottombar_controller.dart';
import '/app/modules/Profie/profile/controllers/profile_controller.dart';
import '/app/modules/Profie/profile/views/editprofile_view.dart';
import '/app/routes/app_pages.dart';
import '/components/buttons/appbutton.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';

class ProfileView extends GetView<ProfileController> {
  ProfileView({Key? key}) : super(key: key);

  final profileController =
      Get.lazyPut<ProfileController>(() => ProfileController());
  final bottomeController = Get.find<BottombarController>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // ── Not logged in ──────────────────────────────────────────────────
    if (!AuthDetails.isUserLogin()) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const CustomAppBar2(
          title: 'Profile',
          showBackButton: false,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                'Login to View Profile',
                style: textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: Get.width * 0.6,
              child: AppButton(
                itemText: 'Login',
                keypressEvent: () => Get.offAllNamed(Routes.LOGIN),
              ),
            ),
          ],
        ),
      );
    }

    // ── Logged in ──────────────────────────────────────────────────────
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar2(
        title: 'Profile',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── User Info Card ─────────────────────────────────────────
            Row(
              children: [
                Obx(() => ClipOval(
                      child: controller.profiledata['featured_image'] == null
                          ? Container(
                              height: 56,
                              width: 56,
                              color: colorScheme.surfaceContainerHighest,
                              child: Image.asset(
                                'assets/images/user.png',
                                color: colorScheme.onSurface,
                                fit: BoxFit.cover,
                              ),
                            )
                          : CachedNetworkImage(
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              imageUrl: HelperFunctions().getImage(
                                  controller.profiledata['featured_image']),
                              errorWidget: (context, url, error) => Container(
                                height: 56,
                                width: 56,
                                color: colorScheme.surfaceContainerHighest,
                                child: Image.asset(
                                  'assets/images/user.png',
                                  color: colorScheme.onSurface,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                    )),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Text(
                            controller.profiledata['name']?.toString() ?? '',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          )),
                      const SizedBox(height: 2),
                      Obx(() => Text(
                            '@${controller.profiledata['email']?.toString().split('@').first ?? ''}',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ── Personal Info ──────────────────────────────────────────
            _sectionLabel(context, 'Personal Info', textTheme),
            _settingsTile(
              context: context,
              assetPath: 'assets/images/profile_icon.png',
              label: 'Profile',
              onTap: () => Get.to(() => const EditprofileView()),
            ),
            _divider(),
            _settingsTile(
              context: context,
              assetPath: 'assets/images/payment_icon.png',
              label: 'Payment Method',
              onTap: () => Get.toNamed(Routes.PAYMENT),
            ),
            _divider(),
            _settingsTile(
              context: context,
              assetPath: 'assets/images/Wallet.png',
              label: 'Orders',
              onTap: () => Get.toNamed(Routes.ORDERS),
            ),
            _divider(),
            _settingsTile(
              context: context,
              assetPath: 'assets/icon/heart.png',
              label: 'WishList',
              onTap: () => Get.toNamed(Routes.WISHLIST),
            ),

            const SizedBox(height: 20),

            // ── Security ──────────────────────────────────────────────
            _sectionLabel(context, 'Security', textTheme),
            _settingsTile(
              context: context,
              assetPath: 'assets/images/change_password_icon.png',
              label: 'Change Password',
              onTap: () => Get.toNamed(Routes.RESETPASSWORD),
            ),
            _divider(),
            _settingsTile(
              context: context,
              assetPath: 'assets/images/forgot_password_icon.png',
              label: 'Forgot Password',
              onTap: () => Get.toNamed(Routes.FORGETPASSWORD),
            ),
            _divider(),
            _settingsTile(
              context: context,
              assetPath: 'assets/icon/security_icon.png',
              label: 'Security',
              onTap: () => Get.toNamed(Routes.SECURITY),
            ),
            _divider(),
            _settingsTile(
              context: context,
              assetPath: 'assets/images/notification_icon.png',
              label: 'Notifications',
              onTap: () => Get.toNamed(Routes.NOTIFICATION),
            ),

            const SizedBox(height: 10),

            // ── About ─────────────────────────────────────────────────
            _sectionLabel(context, 'About', textTheme),
            _settingsTile(
              context: context,
              assetPath: 'assets/images/legal_icon.png',
              label: 'Legal and Policies',
              onTap: () {},
            ),
            _divider(),
            _settingsTile(
              context: context,
              assetPath: 'assets/icon/help.png',
              label: 'Help & Support',
              onTap: () => Get.toNamed(Routes.CONTACTUS),
            ),

            const SizedBox(height: 32),

            // ── Log Out Button ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: () => Get.find<BottombarController>().logout(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Log Out',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Section Label ─────────────────────────────────────────────────────
  Widget _sectionLabel(
      BuildContext context, String label, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        label,
        style: textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
          fontSize: 12,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  // ── Divider ───────────────────────────────────────────────────────────
  Widget _divider() => Builder(
        builder: (context) => Divider(
          height: 1,
          thickness: 1,
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          indent: 52,
        ),
      );

  // ── Settings Tile — uses asset image instead of Icon ─────────────────
  Widget _settingsTile({
    required BuildContext context,
    required String assetPath, // ✅ asset path instead of IconData
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            // ✅ Asset image inside colored rounded box
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  // color: colorScheme.primary.withValues(alpha: 0.08),
                  // borderRadius: BorderRadius.circular(10),
                  ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                assetPath,
                // ✅ tints image to primary color
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 22,
                ),
          ],
        ),
      ),
    );
  }
}
