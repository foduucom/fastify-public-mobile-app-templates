import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foddu/app/modules/profile_legacy/profile/controllers/profile_controller.dart';
import 'package:foddu/app/modules/profile_legacy/profile/views/editprofile_view.dart';
import 'package:foddu/app/modules/auth/auth_details.dart';
import 'package:foddu/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foddu/app/routes/app_pages.dart';
import 'package:foddu/components/commonWidgets/user_avatar.dart';
import 'package:foddu/components/support_call_sheet.dart';
import 'package:foddu/constants/constants.dart';
import 'package:foddu/constants/dynamic_theme.dart';
import 'package:foddu/constants/helper_functions.dart';
import 'package:get/get.dart';

class ProfileView extends GetView<ProfileController> {
  ProfileView({Key? key}) : super(key: key);

  final ProfileController _profileController =
      Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>()
          : Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      AuthDetails.loggedIn.value = AuthDetails.isUserLogin();
      return _buildBody(context);
    });
  }

  Widget _buildBody(BuildContext context) {
    if (!AuthDetails.loggedIn.value) {
      return _buildGuestBody(context);
    }
    return _buildAuthorizedBody(context);
  }

  // ═════════════════════════════════════════════════════════════════════
  // ── A. AUTHORIZED PROFILE EXPERIENCE (Luxury Daksh Store Theme) ──────
  // ═════════════════════════════════════════════════════════════════════
  Widget _buildAuthorizedBody(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(
          "My Profile",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: context.onSurfaceColor,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: context.backgroundColor,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: context.outlineColor.withOpacity(0.08),
            height: 1,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFFD4AF37),
        backgroundColor: context.surfaceColor,
        onRefresh: () async {
          await controller.fetchDataFromServer();
          await controller.fetchExtraStats();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            // 1. Digital VIP Privilege Pass Header
            _buildVipPassCard(context, isDark),
            const SizedBox(height: 14),

            // 2. 4-Hub Interactive Metrics Grid (Orders, Wishlist, Coupons, Addresses)
            _buildQuickMetricsMatrix(context, isDark),
            const SizedBox(height: 14),

            // 3. Active Coupons & Exclusive Vouchers Showcase Banner
            _buildCouponsShowcaseBanner(context, isDark),
            const SizedBox(height: 14),

            // 4. In-Transit Order Snapshot (Contextual)
            _buildRecentOrderSnapshot(context, isDark),

            // 5. Section: Orders & Purchases
            _buildSectionHeader(context, "ORDERS & PURCHASES"),
            _buildCardGroup(
              context,
              [
                _buildTile(
                  context: context,
                  icon: Icons.local_shipping_outlined,
                  iconColor: const Color(0xFF8B5CF6),
                  title: "My Orders",
                  subtitle: "Track, return, or reorder items",
                  onTap: () => Get.toNamed(Routes.ORDERS),
                ),
                _buildTile(
                  context: context,
                  icon: Icons.favorite_border_rounded,
                  iconColor: const Color(0xFFEF4444),
                  title: "Your Wishlist",
                  subtitle: "Saved luxury items & timepieces",
                  onTap: () => Get.toNamed(Routes.WISHLIST),
                ),
                _buildTile(
                  context: context,
                  icon: Icons.local_offer_outlined,
                  iconColor: const Color(0xFFD4AF37),
                  title: "Coupons & Vouchers",
                  subtitle: "Exclusive discounts & member promo codes",
                  onTap: () => Get.toNamed(Routes.COUPONS),
                  badgeText: controller.couponsCount.value > 0
                      ? "${controller.couponsCount.value} Offers"
                      : null,
                ),
                _buildTile(
                  context: context,
                  icon: Icons.location_on_outlined,
                  iconColor: const Color(0xFF10B981),
                  title: "Saved Addresses",
                  subtitle: "Home, work & delivery addresses",
                  onTap: () => Get.toNamed(Routes.ADDRESS_LIST),
                ),
                _buildTile(
                  context: context,
                  icon: Icons.credit_card_outlined,
                  iconColor: const Color(0xFF3B82F6),
                  title: "Payment Methods",
                  subtitle: "Saved cards, UPI & digital wallets",
                  onTap: () => Get.toNamed(Routes.PAYMENT),
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 6. Section: VIP Concierge & Support
            _buildSectionHeader(context, "CONCIERGE & SUPPORT"),
            _buildCardGroup(
              context,
              [
                _buildTile(
                  context: context,
                  icon: Icons.headset_mic_outlined,
                  iconColor: const Color(0xFF10B981),
                  title: "24/7 VIP Concierge Support",
                  subtitle: "Direct live assistance & call concierge",
                  onTap: () => handleSupportCall(context),
                ),
                _buildTile(
                  context: context,
                  icon: Icons.confirmation_num_outlined,
                  iconColor: const Color(0xFFF59E0B),
                  title: "Support Tickets",
                  subtitle: "View and raise service inquiries",
                  onTap: () => Get.toNamed(Routes.SUPPORT_TICKET),
                ),
                _buildTile(
                  context: context,
                  icon: Icons.rate_review_outlined,
                  iconColor: const Color(0xFFEC4899),
                  title: "My Reviews & Ratings",
                  subtitle: "Reviews you've shared on timepieces",
                  onTap: () => Get.toNamed(Routes.MY_REVIEWS),
                ),
                _buildTile(
                  context: context,
                  icon: Icons.article_outlined,
                  iconColor: const Color(0xFF6366F1),
                  title: "Horology & Style Blogs",
                  subtitle: "Watch care, craftsmanship & luxury stories",
                  onTap: () => Get.toNamed(Routes.BLOG),
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 7. Section: Preferences & Security
            _buildSectionHeader(context, "PREFERENCES & SECURITY"),
            _buildCardGroup(
              context,
              [
                _buildTile(
                  context: context,
                  icon: Icons.lock_outline_rounded,
                  iconColor: const Color(0xFFD4AF37),
                  title: "Change Password",
                  subtitle: "Update account login credentials",
                  onTap: () => _showChangePasswordDialog(context),
                ),
                _buildThemeSwitcherTile(context, isDark),
              ],
            ),
            const SizedBox(height: 20),

            // 8. Section: Legal & About
            _buildSectionHeader(context, "LEGAL & ABOUT"),
            _buildCardGroup(
              context,
              [
                _buildTile(
                  context: context,
                  icon: Icons.info_outline_rounded,
                  iconColor: const Color(0xFF64748B),
                  title: "About Daksh Store",
                  subtitle: "Our heritage, craftsmanship & vision",
                  onTap: () => Get.toNamed(Routes.ABOUTUS),
                ),
                _buildTile(
                  context: context,
                  icon: Icons.shield_outlined,
                  iconColor: const Color(0xFF64748B),
                  title: "Terms & Conditions",
                  subtitle: "Rules governing use of our platform",
                  onTap: () => Get.toNamed(Routes.TERMS_CONDITIONS),
                ),
                _buildTile(
                  context: context,
                  icon: Icons.privacy_tip_outlined,
                  iconColor: const Color(0xFF64748B),
                  title: "Privacy Policy",
                  subtitle: "How your data & privacy are protected",
                  onTap: () => Get.toNamed(Routes.PRIVACY_POLICY),
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 9. Sign Out Button
            _buildSignOutButton(context, isDark),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // ── VIP Digital Privilege Pass Header ────────────────────────────────
  Widget _buildVipPassCard(BuildContext context, bool isDark) {
    return Obx(() {
      final name = controller.profiledata['name']?.toString().trim() ?? '';
      final displayName = name.isNotEmpty ? name : 'Valued Customer';
      final email = controller.profiledata['email']?.toString().trim() ?? '';
      final phone = controller.profiledata['mobile']?.toString().trim() ?? '';
      final avatarUrl = controller.imagePath.value;
      final wallet = controller.walletBalance.value;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.4)
                  : const Color(0xFFD4AF37).withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Mini Header: VIP Tag + Tier
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.workspace_premium_rounded,
                      color: Color(0xFFD4AF37),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "DAKSH PRIVILEGE CLUB",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Gold Elite",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Middle: Avatar + Name + Email + Edit Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Metallic Gold Ring Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFF3E5AB),
                        Color(0xFFD4AF37),
                        Color(0xFF8A6D1E),
                      ],
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
                  padding: const EdgeInsets.all(2.5),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.surfaceColor,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: UserAvatar(
                      imageUrl: avatarUrl.isNotEmpty ? avatarUrl : null,
                      name: displayName,
                      radius: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Name & Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: context.onSurfaceColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        email.isNotEmpty ? email : phone,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: context.onSurfaceColor.withOpacity(0.65),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (wallet > 0) ...[
                        const SizedBox(height: 5),
                        Text(
                          "Wallet: \$$wallet",
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Edit Button
                InkWell(
                  onTap: () {
                    Get.to(() => const EditprofileView())?.then((_) {
                      controller.fetchDataFromServer();
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.5),
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
                          "Edit",
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
          ],
        ),
      );
    });
  }

  // ── 4-Hub Interactive Metrics Grid ───────────────────────────────────
  Widget _buildQuickMetricsMatrix(BuildContext context, bool isDark) {
    return Obx(() {
      return Row(
        children: [
          // Orders
          Expanded(
            child: _buildMetricTile(
              context: context,
              icon: Icons.local_shipping_outlined,
              iconColor: const Color(0xFF8B5CF6),
              title: "Orders",
              subtitle: controller.orderStatusLabel.value,
              onTap: () => Get.toNamed(Routes.ORDERS),
            ),
          ),
          const SizedBox(width: 10),

          // Wishlist
          Expanded(
            child: _buildMetricTile(
              context: context,
              icon: Icons.favorite_border_rounded,
              iconColor: const Color(0xFFEF4444),
              title: "Wishlist",
              subtitle: "${controller.wishlistCount.value} Saved",
              onTap: () => Get.toNamed(Routes.WISHLIST),
            ),
          ),
          const SizedBox(width: 10),

          // Coupons
          Expanded(
            child: _buildMetricTile(
              context: context,
              icon: Icons.local_offer_outlined,
              iconColor: const Color(0xFFD4AF37),
              title: "Coupons",
              subtitle: controller.couponsCount.value > 0
                  ? "${controller.couponsCount.value} Offers"
                  : "Explore",
              isGold: true,
              onTap: () => Get.toNamed(Routes.COUPONS),
            ),
          ),
          const SizedBox(width: 10),

          // Addresses
          Expanded(
            child: _buildMetricTile(
              context: context,
              icon: Icons.location_on_outlined,
              iconColor: const Color(0xFF10B981),
              title: "Addresses",
              subtitle: "${controller.addresses.length} Saved",
              onTap: () => Get.toNamed(Routes.ADDRESS_LIST),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMetricTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isGold = false,
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
            color: isGold
                ? const Color(0xFFD4AF37).withOpacity(0.35)
                : context.outlineColor.withOpacity(0.08),
            width: isGold ? 1.2 : 1,
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
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withOpacity(0.12),
              ),
              child: Icon(icon, color: iconColor, size: 19),
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
                color: isGold
                    ? const Color(0xFFD4AF37)
                    : context.onSurfaceColor.withOpacity(0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ── Active Coupons & Exclusive Vouchers Showcase Banner ───────────────
  Widget _buildCouponsShowcaseBanner(BuildContext context, bool isDark) {
    return Obx(() {
      final code = controller.featuredCouponCode.value;
      final discount = controller.featuredCouponDiscount.value;

      return InkWell(
        onTap: () => Get.toNamed(Routes.COUPONS),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF241E10), const Color(0xFF1A1813)]
                  : [const Color(0xFFFFFBEA), const Color(0xFFF9F5E8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFD4AF37).withOpacity(0.4),
              width: 1.2,
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
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Exclusive Member Perks",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              discount,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Use code "$code" on checkout for extra savings',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color:
                            isDark ? Colors.white70 : const Color(0xFF555555),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "Explore",
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
    });
  }

  // ── Contextual Recent Order Snapshot ─────────────────────────────────
  Widget _buildRecentOrderSnapshot(BuildContext context, bool isDark) {
    return Obx(() {
      final orderId = controller.recentOrderNumber.value;
      if (orderId.isEmpty) return const SizedBox.shrink();

      final status = controller.recentOrderStatus.value;

      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withOpacity(0.25),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withOpacity(0.12),
              ),
              child: const Icon(
                Icons.local_shipping_rounded,
                color: Color(0xFF8B5CF6),
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order #${orderId.length > 8 ? orderId.substring(orderId.length - 8) : orderId} • $status",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.onSurfaceColor,
                    ),
                  ),
                  Text(
                    "Track delivery progress in real time",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: context.onSurfaceColor.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => Get.toNamed(Routes.ORDERS),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  "Track >",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ═════════════════════════════════════════════════════════════════════
  // ── B. SKIP / GUEST PROFILE EXPERIENCE (High-Converting Luxury) ──────
  // ═════════════════════════════════════════════════════════════════════
  Widget _buildGuestBody(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(
          "Account",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: context.onSurfaceColor,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: context.backgroundColor,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: context.outlineColor.withOpacity(0.08),
            height: 1,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          // 1. "The Daksh Circle" VIP Invitation Hero
          _buildGuestHeroCard(context, isDark),
          const SizedBox(height: 16),

          // 2. Today's Store Coupons Discovery Card
          _buildGuestCouponsDiscoveryCard(context, isDark),
          const SizedBox(height: 16),

          // 3. Instant Guest Order Tracker Utility
          _buildGuestOrderTrackerCard(context, isDark),
          const SizedBox(height: 20),

          // 4. Section: Concierge & Store Discovery Hub
          _buildSectionHeader(context, "EXPLORE & CUSTOMER CARE"),
          _buildCardGroup(
            context,
            [
              _buildTile(
                context: context,
                icon: Icons.headset_mic_outlined,
                iconColor: const Color(0xFF10B981),
                title: "24/7 VIP Customer Support",
                subtitle: "Call concierge or message support",
                onTap: () => handleSupportCall(context),
              ),
              _buildTile(
                context: context,
                icon: Icons.help_outline_rounded,
                iconColor: const Color(0xFFF59E0B),
                title: "Help Center & FAQs",
                subtitle: "Frequently asked questions and guides",
                onTap: () => Get.toNamed(Routes.HELPANDSUPPORT),
              ),
              _buildTile(
                context: context,
                icon: Icons.article_outlined,
                iconColor: const Color(0xFF6366F1),
                title: "From Our Horology Blog",
                subtitle: "Watch collecting trends, news & stories",
                onTap: () => Get.toNamed(Routes.BLOG),
              ),
              _buildTile(
                context: context,
                icon: Icons.mail_outline_rounded,
                iconColor: const Color(0xFF3B82F6),
                title: "Contact Us",
                subtitle: "Send a message or concierge inquiry",
                onTap: () => Get.toNamed(Routes.CONTACTUS),
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 5. Section: Preferences
          _buildSectionHeader(context, "PREFERENCES"),
          _buildCardGroup(
            context,
            [
              _buildThemeSwitcherTile(context, isDark),
            ],
          ),
          const SizedBox(height: 20),

          // 6. Section: Legal & About
          _buildSectionHeader(context, "LEGAL & ABOUT"),
          _buildCardGroup(
            context,
            [
              _buildTile(
                context: context,
                icon: Icons.info_outline_rounded,
                iconColor: const Color(0xFF64748B),
                title: "About Daksh Store",
                subtitle: "Our heritage, craftsmanship & vision",
                onTap: () => Get.toNamed(Routes.ABOUTUS),
              ),
              _buildTile(
                context: context,
                icon: Icons.shield_outlined,
                iconColor: const Color(0xFF64748B),
                title: "Terms & Conditions",
                subtitle: "Rules governing use of our platform",
                onTap: () => Get.toNamed(Routes.TERMS_CONDITIONS),
              ),
              _buildTile(
                context: context,
                icon: Icons.privacy_tip_outlined,
                iconColor: const Color(0xFF64748B),
                title: "Privacy Policy",
                subtitle: "How we collect & protect your data",
                onTap: () => Get.toNamed(Routes.PRIVACY_POLICY),
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  // ── "The Daksh Circle" VIP Invitation Hero ───────────────────────────
  Widget _buildGuestHeroCard(BuildContext context, bool isDark) {
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
                  Icons.workspace_premium_rounded,
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
                      "The Daksh Circle",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Unlock VIP Privileges & Vouchers",
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
          const SizedBox(height: 14),
          Text(
            "Join our exclusive community of horology collectors. Sign in to track orders live, sync your luxury wishlist, and unlock member-only coupons.",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              height: 1.45,
              color: isDark ? Colors.white70 : const Color(0xFF555555),
            ),
          ),
          const SizedBox(height: 14),

          // Value Pillars
          _buildGuestPerk(Icons.local_offer_outlined,
              "Welcome Privilege: Up to 15% off first luxury order"),
          const SizedBox(height: 6),
          _buildGuestPerk(Icons.local_shipping_outlined,
              "Priority Dispatch & Real-Time Order Tracking"),
          const SizedBox(height: 6),
          _buildGuestPerk(Icons.favorite_border_rounded,
              "Cloud-Synced Wishlist Across All Your Devices"),
          const SizedBox(height: 18),

          // Dual Action CTAs: Sign In + Register
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    isOtpLogin
                        ? Get.toNamed(Routes.MOBILELOGIN)
                        : Get.toNamed(Routes.LOGIN);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Sign In",
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
                  onPressed: () {
                    isOtpLogin
                        ? Get.toNamed(Routes.MOBILEREGISTER)
                        : Get.toNamed(Routes.REGISTER);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: BorderSide(
                      color: const Color(0xFFD4AF37).withOpacity(0.6),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Create Account",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
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

  Widget _buildGuestPerk(IconData icon, String text) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          size: 15,
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

  // ── Today's Active Store Coupons Discovery Card ──────────────────────
  Widget _buildGuestCouponsDiscoveryCard(BuildContext context, bool isDark) {
    return Obx(() {
      final code = controller.featuredCouponCode.value;
      final discount = controller.featuredCouponDiscount.value;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD4AF37).withOpacity(0.12),
              ),
              child: const Icon(
                Icons.discount_outlined,
                color: Color(0xFFD4AF37),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Today's Active Coupons",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: context.onSurfaceColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            discount,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Code "$code" available • Tap to browse vouchers',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Explore",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Instant Guest Order Tracker ──────────────────────────────────────
  Widget _buildGuestOrderTrackerCard(BuildContext context, bool isDark) {
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF8B5CF6).withOpacity(0.12),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: Color(0xFF8B5CF6),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Track a Guest Order",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Enter your Order ID to check live shipping status",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: context.onSurfaceColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => _showGuestOrderTrackSheet(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              side: BorderSide(
                color: const Color(0xFF8B5CF6).withOpacity(0.4),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Track",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8B5CF6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════
  // ── SHARED REUSABLE COMPONENTS (Modern Luxury Styling) ───────────────
  // ═════════════════════════════════════════════════════════════════════

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: context.onSurfaceColor.withOpacity(0.55),
        ),
      ),
    );
  }

  Widget _buildCardGroup(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.outlineColor.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badgeText,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
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
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: context.onSurfaceColor.withOpacity(0.55),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (badgeText != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Icon(
                    Icons.chevron_right_rounded,
                    color: context.onSurfaceColor.withOpacity(0.4),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 68,
            endIndent: 16,
            color: context.outlineColor.withOpacity(0.06),
          ),
      ],
    );
  }

  // ── Theme Switcher Tile ──────────────────────────────────────────────
  Widget _buildThemeSwitcherTile(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
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
                  "Theme Appearance",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isDark ? "Dark Onyx Theme" : "Light Clean Theme",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
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
                    Text("System Default"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ThemeMode.light,
                child: Row(
                  children: [
                    Icon(Icons.light_mode, size: 18),
                    SizedBox(width: 10),
                    Text("Light Clean"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ThemeMode.dark,
                child: Row(
                  children: [
                    Icon(Icons.dark_mode, size: 18),
                    SizedBox(width: 10),
                    Text("Dark Onyx"),
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
                    isDark ? "Dark" : "Light",
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

  // ── Sign Out Button with Bottom Sheet Confirmation ───────────────────
  Widget _buildSignOutButton(BuildContext context, bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _confirmSignOut(context, isDark),
        icon: const Icon(Icons.logout_rounded,
            color: Color(0xFFEF4444), size: 18),
        label: const Text(
          "LOG OUT",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 0.8,
            color: Color(0xFFEF4444),
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(
            color: const Color(0xFFEF4444).withOpacity(0.4),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, bool isDark) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.outlineColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEF4444).withOpacity(0.12),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFEF4444),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Sign Out?",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.onSurfaceColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Are you sure you want to sign out from your account?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: context.onSurfaceColor.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: context.onSurfaceColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Sign Out",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true) {
      if (Get.isRegistered<BottombarController>()) {
        await Get.find<BottombarController>().logout();
      } else {
        await AuthDetails.logout();
      }
    }
  }

  // ── Change Password Modal ────────────────────────────────────────────
  void _showChangePasswordDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Form(
              key: controller.changePasswordFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.outlineColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "Change Password",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.onSurfaceColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Ensure your new password contains at least 6 characters.",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: context.onSurfaceColor.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Old Password
                  TextFormField(
                    controller: controller.oldPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Current Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // New Password
                  TextFormField(
                    controller: controller.newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "New Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Confirm Password
                  TextFormField(
                    controller: controller.comfirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Confirm New Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => controller.changePassword(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Update Password",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Guest Order Tracking Sheet ───────────────────────────────────────
  void _showGuestOrderTrackSheet(BuildContext context) {
    final trackCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.outlineColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  "Track Guest Order",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: context.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Enter the Order ID provided in your SMS or email receipt.",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: context.onSurfaceColor.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: trackCtrl,
                  decoration: InputDecoration(
                    labelText: "Order ID (e.g. DK-84920)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.receipt_long_rounded),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (trackCtrl.text.trim().isEmpty) {
                        HelperFunctions()
                            .showSnackBarError("Please enter your Order ID");
                        return;
                      }
                      Navigator.pop(ctx);
                      Get.toNamed(Routes.ORDERS);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Check Status",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
