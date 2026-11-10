import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foddu/app/modules/profile/controller/profile_controller.dart';
import 'package:foddu/app/routes/app_pages.dart';
import 'package:foddu/constants/dynamic_theme.dart';
import 'package:get/get.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: context.primaryColor,
                    ),
                  );
                }

                return RefreshIndicator(
                  color: const Color(0xFFD4AF37),
                  backgroundColor: context.surfaceColor,
                  onRefresh: () async {
                    controller.checkAuthAndLoad();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: controller.isLoggedIn.value
                        ? _AuthorizedProfileContent()
                        : _GuestProfileContent(),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final canPop = Navigator.canPop(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: context.outlineColor.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (canPop)
            InkWell(
              onTap: () => Get.back(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.surfaceColor,
                  border: Border.all(
                    color: context.outlineColor.withOpacity(0.12),
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: context.onSurfaceColor,
                ),
              ),
            )
          else
            const SizedBox(width: 38),
          Expanded(
            child: Text(
              'My Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.onSurfaceColor,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(width: 38),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// ── 1. AUTHORIZED PROFILE CONTENT (Matches User Screenshot + Luxury) ───
// ═══════════════════════════════════════════════════════════════════════
class _AuthorizedProfileContent extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // 1. VIP User Info Card
        _UserInfoCard(),
        const SizedBox(height: 16),

        // 2. 4-Box Quick Action Metrics Matrix
        _QuickActionsMatrix(),
        const SizedBox(height: 16),

        // 3. Luxury Coupons Privilege Banner
        _CouponsPrivilegeBanner(),
        const SizedBox(height: 24),

        // 4. Section: Orders & Purchases
        const _SectionHeader(title: 'ORDERS & PURCHASES'),
        const SizedBox(height: 10),
        _MenuContainer(items: controller.accountSettings),
        const SizedBox(height: 24),

        // 5. Section: Security & Preferences
        const _SectionHeader(title: 'SECURITY & PREFERENCES'),
        const SizedBox(height: 10),
        _SecurityAndThemeContainer(),
        const SizedBox(height: 24),

        // 6. Section: Activity & Support
        const _SectionHeader(title: 'ACTIVITY & SUPPORT'),
        const SizedBox(height: 10),
        _MenuContainer(items: controller.otherSettings),
        const SizedBox(height: 24),

        // 7. Sign Out Action Button
        _SignOutButton(),
        const SizedBox(height: 100),
      ],
    );
  }
}

// ── User Info Card ─────────────────────────────────────────────────────
class _UserInfoCard extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final name = controller.userName.value.trim().isNotEmpty
          ? controller.userName.value.trim()
          : 'Valued Customer';
      final email = controller.userEmail.value.trim();
      final phone = controller.userMobile.value.trim();
      final hasWallet = controller.walletBal.value > 0;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gold ring avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFE5C07B),
                    Color(0xFFD4AF37),
                    Color(0xFF8A6D1E),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(2),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.surfaceColor,
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildAvatarImage(context),
              ),
            ),
            const SizedBox(width: 14),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: context.onSurfaceColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasWallet) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '\$${controller.walletBal.value.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      email,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: context.onSurfaceColor.withOpacity(0.65),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (phone.isNotEmpty && email.isEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      phone,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: context.onSurfaceColor.withOpacity(0.65),
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),

                  // Membership Tier Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.35),
                        width: 0.8,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 12,
                          color: Color(0xFFD4AF37),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Daksh VIP Member',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD4AF37),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Edit Profile Button
            InkWell(
              onTap: controller.onEditProfileTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: Color(0xFFD4AF37),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Edit',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAvatarImage(BuildContext context) {
    final letter = controller.userName.value.trim().isNotEmpty
        ? controller.userName.value.trim()[0].toUpperCase()
        : 'D';

    final fallback = Center(
      child: Text(
        letter,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(0xFFD4AF37),
        ),
      ),
    );

    if (controller.avatarUrl.value.isNotEmpty) {
      return Image.network(
        controller.avatarUrl.value,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }
    if (controller.avatarPath.value.isNotEmpty &&
        controller.avatarPath.value.startsWith('/')) {
      return Image.file(
        File(controller.avatarPath.value),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }
    return fallback;
  }
}

// ── 4-Box Quick Action Metrics Matrix ──────────────────────────────────
class _QuickActionsMatrix extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
        children: [
          // Orders
          Expanded(
            child: _buildMetricTile(
              context,
              icon: Icons.local_shipping_outlined,
              title: 'Orders',
              subtitle: controller.orderStatusLabel.value,
              onTap: () => Get.toNamed(Routes.ORDERS),
            ),
          ),
          const SizedBox(width: 10),

          // Wishlist
          Expanded(
            child: _buildMetricTile(
              context,
              icon: Icons.favorite_border_rounded,
              title: 'Wishlist',
              subtitle: '${controller.wishlistCount.value}',
              onTap: () => Get.toNamed(Routes.WISHLIST),
            ),
          ),
          const SizedBox(width: 10),

          // Coupons
          Expanded(
            child: _buildMetricTile(
              context,
              icon: Icons.local_offer_outlined,
              title: 'Coupons',
              subtitle: controller.couponsCount.value > 0
                  ? '${controller.couponsCount.value} Offers'
                  : 'Explore',
              badgeColor: const Color(0xFFD4AF37),
              onTap: () => Get.toNamed(Routes.COUPONS),
            ),
          ),
          const SizedBox(width: 10),

          // Addresses
          Expanded(
            child: _buildMetricTile(
              context,
              icon: Icons.location_on_outlined,
              title: 'Addresses',
              subtitle: '${controller.addresses.length}',
              onTap: () => Get.toNamed(Routes.ADDRESS_LIST),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? badgeColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.outlineColor.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (badgeColor ?? context.primaryColor).withOpacity(0.1),
              ),
              child: Icon(
                icon,
                color: badgeColor ?? context.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.onSurfaceColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: badgeColor ?? context.onSurfaceColor.withOpacity(0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Luxury Coupons Privilege Banner ────────────────────────────────────
class _CouponsPrivilegeBanner extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => Get.toNamed(Routes.COUPONS),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF262010),
                    const Color(0xFF1E1E1E),
                  ]
                : [
                    const Color(0xFFFFF9E6),
                    const Color(0xFFFAF7EE),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFE5C07B), Color(0xFFD4AF37)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.confirmation_num_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        'Exclusive Member Perks',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: Color(0xFFD4AF37),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Save extra on checkout with active store vouchers',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: isDark ? Colors.white70 : const Color(0xFF555555),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Explore',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Security & Theme Container ─────────────────────────────────────────
class _SecurityAndThemeContainer extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.outlineColor.withOpacity(0.08),
        ),
      ),
      child: Column(
        children: [
          // Change Password
          _MenuTile(
            icon: Icons.lock_outline_rounded,
            title: 'Change Password',
            subtitle: 'Update your security credentials',
            onTap: controller.onChangePasswordTap,
          ),
          Divider(
            height: 1,
            color: context.outlineColor.withOpacity(0.06),
            indent: 68,
          ),

          // Theme Mode Switcher
          _ThemeSwitcherTile(),
        ],
      ),
    );
  }
}

// ── Theme Switcher Tile ────────────────────────────────────────────────
class _ThemeSwitcherTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD4AF37).withOpacity(0.12),
            ),
            child: Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: const Color(0xFFD4AF37),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme Appearance',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isDark ? 'Dark Onyx Theme' : 'Light Clean Theme',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: context.onSurfaceColor.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<ThemeMode>(
            onSelected: (mode) {
              if (Get.isRegistered<ThemeController>()) {
                Get.find<ThemeController>().setThemeMode(mode);
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            color: context.surfaceColor,
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: ThemeMode.system,
                child: Row(
                  children: [
                    Icon(Icons.settings_brightness, size: 18),
                    SizedBox(width: 10),
                    Text('System Default'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ThemeMode.light,
                child: Row(
                  children: [
                    Icon(Icons.light_mode, size: 18),
                    SizedBox(width: 10),
                    Text('Light Theme'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ThemeMode.dark,
                child: Row(
                  children: [
                    Icon(Icons.dark_mode, size: 18),
                    SizedBox(width: 10),
                    Text('Dark Onyx Theme'),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: context.outlineColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isDark ? 'Dark' : 'Light',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.onSurfaceColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.unfold_more_rounded,
                    size: 16,
                    color: context.onSurfaceColor.withOpacity(0.6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Generic Menu Container ─────────────────────────────────────────────
class _MenuContainer extends StatelessWidget {
  final List<ProfileMenuModel> items;
  const _MenuContainer({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.outlineColor.withOpacity(0.08),
        ),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;
          return Column(
            children: [
              _MenuTile(
                icon: item.icon ?? Icons.arrow_forward_ios_rounded,
                title: item.title,
                subtitle: item.subtitle,
                onTap: item.onTap,
                trailing: item.trailing,
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: context.outlineColor.withOpacity(0.06),
                  indent: 68,
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Single Menu Tile ───────────────────────────────────────────────────
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.primaryColor.withOpacity(0.08),
                ),
                child: Icon(
                  icon,
                  color: context.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.onSurfaceColor,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: context.onSurfaceColor.withOpacity(0.55),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: context.onSurfaceColor.withOpacity(0.4),
                    size: 22,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sign Out Button ────────────────────────────────────────────────────
class _SignOutButton extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => controller.onSignOut(context),
        icon: const Icon(Icons.logout_rounded,
            color: Color(0xFFE53935), size: 18),
        label: const Text(
          'Sign Out',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFFE53935),
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(
            color: const Color(0xFFE53935).withOpacity(0.3),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// ── 2. SKIP / GUEST PROFILE CONTENT (Modern High-Conversion Guest UI) ──
// ═══════════════════════════════════════════════════════════════════════
class _GuestProfileContent extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // 1. VIP Club Invitation Hero Card
        _GuestClubHeroCard(),
        const SizedBox(height: 18),

        // 2. Guest Coupons & Offers Teaser Card
        _GuestCouponsDiscoveryCard(),
        const SizedBox(height: 24),

        // 3. Section: Store & Policies
        const _SectionHeader(title: 'EXPLORE & CUSTOMER CARE'),
        const SizedBox(height: 10),
        _GuestStoreMenuContainer(),
        const SizedBox(height: 24),

        // 4. Guest Theme Switcher
        _SecurityAndThemeContainer(),
        const SizedBox(height: 100),
      ],
    );
  }
}

// ── VIP Club Invitation Hero Card ──────────────────────────────────────
class _GuestClubHeroCard extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE5C07B), Color(0xFFD4AF37)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.diamond_outlined,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Daksh Store',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Unlock Member Privileges',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Sign in to sync your wishlist across devices, receive member-only coupon discounts, and enjoy seamless order tracking.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              height: 1.5,
              color: isDark ? Colors.white70 : const Color(0xFF555555),
            ),
          ),
          const SizedBox(height: 16),

          // Benefits bullet points
          _buildPerkRow(
              Icons.local_offer_outlined, 'Exclusive Welcome & Member Coupons'),
          const SizedBox(height: 6),
          _buildPerkRow(
              Icons.local_shipping_outlined, 'Real-time Tracking & Order History'),
          const SizedBox(height: 6),
          _buildPerkRow(
              Icons.favorite_border_rounded, 'Cloud Synced Luxury Wishlist'),
          const SizedBox(height: 20),

          // Action Buttons: Sign In + Register
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.onLoginTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.onRegisterTap,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: const Color(0xFFD4AF37).withOpacity(0.6),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerkRow(IconData icon, String text) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          size: 16,
          color: Color(0xFFD4AF37),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Guest Coupons & Offers Discovery Card ──────────────────────────────
class _GuestCouponsDiscoveryCard extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.outlineColor.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD4AF37).withOpacity(0.12),
            ),
            child: const Icon(
              Icons.discount_outlined,
              color: Color(0xFFD4AF37),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Coupons & Offers",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Browse available promo codes to apply at checkout',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: context.onSurfaceColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Get.toNamed(Routes.COUPONS),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Browse',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Guest Store Menu Container ─────────────────────────────────────────
class _GuestStoreMenuContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.outlineColor.withOpacity(0.08),
        ),
      ),
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.help_outline_rounded,
            title: 'Help Center & FAQs',
            subtitle: 'Find answers, shipping & return policies',
            onTap: () => Get.toNamed(Routes.HELPANDSUPPORT),
          ),
          Divider(
            height: 1,
            color: context.outlineColor.withOpacity(0.06),
            indent: 68,
          ),
          _MenuTile(
            icon: Icons.info_outline_rounded,
            title: 'About Daksh Store',
            subtitle: 'Our craftsmanship, history & vision',
            onTap: () => Get.toNamed(Routes.ABOUTUS),
          ),
          Divider(
            height: 1,
            color: context.outlineColor.withOpacity(0.06),
            indent: 68,
          ),
          _MenuTile(
            icon: Icons.mail_outline_rounded,
            title: 'Contact Us',
            subtitle: 'Reach our luxury concierge team',
            onTap: () => Get.toNamed(Routes.CONTACTUS),
          ),
          Divider(
            height: 1,
            color: context.outlineColor.withOpacity(0.06),
            indent: 68,
          ),
          _MenuTile(
            icon: Icons.shield_outlined,
            title: 'Terms of Service',
            subtitle: 'Store policies & conditions',
            onTap: () => Get.toNamed(Routes.TERMS_CONDITIONS),
          ),
        ],
      ),
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: context.onSurfaceColor.withOpacity(0.55),
      ),
    );
  }
}
