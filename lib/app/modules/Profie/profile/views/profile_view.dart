import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foduu_ecommerce/app/modules/Profie/profile/controllers/profile_controller.dart';
import 'package:foduu_ecommerce/app/modules/Profie/profile/views/editprofile_view.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/outlinebutton.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/components/support_call_sheet.dart';
import 'package:get/get.dart';

class ProfileView extends GetView<ProfileController> {
  ProfileView({Key? key}) : super(key: key);
  final profileController =
      Get.lazyPut<ProfileController>(() => ProfileController());

  final bottomeController = Get.find<BottombarController>();

  @override
  Widget build(BuildContext context) {
    // Rebuilds the moment the session is torn down, so cached account data
    // and the account menu never outlive a dead session.
    return Obx(() {
      AuthDetails.loggedIn.value;
      return _buildBody(context);
    });
  }

  Widget _buildBody(BuildContext context) {
    if (!AuthDetails.loggedIn.value) {
      return _buildGuestBody(context);
    } else {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      final primaryColor = theme.primaryColor;
      final surfaceColor = theme.colorScheme.surface;
      final onSurfaceColor = theme.colorScheme.onSurface;
      final secondaryTextColor = onSurfaceColor.withOpacity(0.65);
      final cardBorderColor = isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.black.withOpacity(0.06);
      final hairlineColor = isDark
          ? Colors.white.withOpacity(0.07)
          : Colors.black.withOpacity(0.06);

      return SafeArea(
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'Profile',
              style: TextStyle(
                fontFamily: 'lato',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: onSurfaceColor,
              ),
            ),
            elevation: 0,
            backgroundColor: surfaceColor,
            automaticallyImplyLeading: false,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              16,
              14,
              16,
              MediaQuery.of(context).padding.bottom + 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Obx(
                        () {
                          final featuredImage =
                              controller.profiledata['featured_image'];
                          final hasImage = featuredImage != null &&
                              featuredImage.toString().isNotEmpty &&
                              featuredImage != 'null';
                          return Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor.withOpacity(0.1),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.25),
                                width: 1.5,
                              ),
                            ),
                            child: ClipOval(
                              child: hasImage
                                  ? CachedNetworkImage(
                                      width: 58,
                                      height: 58,
                                      fit: BoxFit.cover,
                                      imageUrl: HelperFunctions().getImage(
                                        controller
                                            .profiledata['featured_image'],
                                      ),
                                      errorWidget: (context, url, error) => Icon(
                                        Icons.person_rounded,
                                        size: 30,
                                        color: primaryColor,
                                      ),
                                    )
                                  : Icon(
                                      Icons.person_rounded,
                                      size: 30,
                                      color: primaryColor,
                                    ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(
                              () => Text(
                                controller.profiledata['name']?.toString() ??
                                    'User',
                                style: TextStyle(
                                  fontFamily: 'lato',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: onSurfaceColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Obx(
                              () => Text(
                                controller.profiledata['email']?.toString() ??
                                    '',
                                style: TextStyle(
                                  fontFamily: 'lato',
                                  fontSize: 12,
                                  color: secondaryTextColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 32,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Get.to(() => const EditprofileView());
                          },
                          icon: const Icon(Icons.edit_outlined, size: 14),
                          label: const Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Lato',
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(
                                color: primaryColor.withOpacity(0.35)),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            backgroundColor: primaryColor.withOpacity(0.04),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Group 1: Orders & Purchases
                _buildSectionHeader('Orders & Shopping', onSurfaceColor),
                _buildSectionCard(
                  surfaceColor: surfaceColor,
                  borderColor: cardBorderColor,
                  children: [
                    _buildGuestTile(
                      context,
                      icon: Icons.local_shipping_outlined,
                      title: 'Orders',
                      subtitle: 'Ongoing Orders, Recent Orders..',
                      onTap: () => Get.toNamed(Routes.ORDERS),
                      primaryColor: primaryColor,
                      textColor: onSurfaceColor,
                      secondaryColor: secondaryTextColor,
                    ),
                    _buildHairlineDivider(hairlineColor),
                    _buildGuestTile(
                      context,
                      icon: Icons.favorite_border_rounded,
                      title: 'Your Wishlist',
                      subtitle: 'Your Saved Products',
                      onTap: () => Get.toNamed(Routes.WISHLIST),
                      primaryColor: primaryColor,
                      textColor: onSurfaceColor,
                      secondaryColor: secondaryTextColor,
                    ),
                    _buildHairlineDivider(hairlineColor),
                    _buildGuestTile(
                      context,
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Payment',
                      subtitle: 'Saved Cards, Wallets',
                      onTap: () => Get.toNamed(Routes.PAYMENT),
                      primaryColor: primaryColor,
                      textColor: onSurfaceColor,
                      secondaryColor: secondaryTextColor,
                    ),
                    _buildHairlineDivider(hairlineColor),
                    _buildGuestTile(
                      context,
                      icon: Icons.location_on_outlined,
                      title: 'Saved Address',
                      subtitle: 'Home, office..',
                      onTap: () => Get.toNamed(Routes.ADDRESS_LIST),
                      primaryColor: primaryColor,
                      textColor: onSurfaceColor,
                      secondaryColor: secondaryTextColor,
                    ),
                  ],
                ),

                // Group 2: Feedback & Support
                _buildSectionHeader('Feedback & Support', onSurfaceColor),
                _buildSectionCard(
                  surfaceColor: surfaceColor,
                  borderColor: cardBorderColor,
                  children: [
                    _buildGuestTile(
                      context,
                      icon: Icons.star_outline_rounded,
                      title: 'My Reviews',
                      subtitle: 'Reviews you have written',
                      onTap: () => Get.toNamed(Routes.MY_REVIEWS),
                      primaryColor: primaryColor,
                      textColor: onSurfaceColor,
                      secondaryColor: secondaryTextColor,
                    ),
                    _buildHairlineDivider(hairlineColor),
                    _buildGuestTile(
                      context,
                      icon: Icons.confirmation_number_outlined,
                      title: 'Support Ticket',
                      subtitle: 'Raise & track support requests',
                      onTap: () => Get.toNamed(Routes.SUPPORT_TICKET),
                      primaryColor: primaryColor,
                      textColor: onSurfaceColor,
                      secondaryColor: secondaryTextColor,
                    ),
                  ],
                ),

                // Group 3: Legal & Policies
                _buildSectionHeader('Legal & Policies', onSurfaceColor),
                _buildSectionCard(
                  surfaceColor: surfaceColor,
                  borderColor: cardBorderColor,
                  children: [
                    _buildGuestTile(
                      context,
                      icon: Icons.description_outlined,
                      title: 'Terms & Conditions',
                      subtitle: 'Platform usage terms',
                      onTap: () => Get.toNamed(Routes.TERMS_CONDITIONS),
                      primaryColor: primaryColor,
                      textColor: onSurfaceColor,
                      secondaryColor: secondaryTextColor,
                    ),
                    _buildHairlineDivider(hairlineColor),
                    _buildGuestTile(
                      context,
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'How your data is handled',
                      onTap: () => Get.toNamed(Routes.PRIVACY_POLICY),
                      primaryColor: primaryColor,
                      textColor: onSurfaceColor,
                      secondaryColor: secondaryTextColor,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Sign Out Action Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text(
                      'LOG OUT',
                      style: TextStyle(
                        fontFamily: 'lato',
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: BorderSide(
                        color: Colors.redAccent.withOpacity(0.4),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.redAccent.withOpacity(0.04),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Modern Footer with Trust Badge
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 13,
                            color: secondaryTextColor.withOpacity(0.7),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '100% Secure & Encrypted Shopping',
                            style: TextStyle(
                              fontFamily: 'lato',
                              fontSize: 11,
                              color: secondaryTextColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$appName • Version 1.0.0',
                        style: TextStyle(
                          fontFamily: 'lato',
                          fontSize: 11.5,
                          color: secondaryTextColor.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    }
  }

  void _confirmLogout(BuildContext context) {
    final theme = Theme.of(context);
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Log Out',
          style: TextStyle(fontFamily: 'lato', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to sign out of your account?',
          style: TextStyle(fontFamily: 'lato', fontSize: 13.5),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'lato',
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Get.back();
              Get.find<BottombarController>().logout();
            },
            child: const Text(
              'Log Out',
              style: TextStyle(fontFamily: 'lato', fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestBody(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final surfaceColor = theme.colorScheme.surface;
    final onSurfaceColor = theme.colorScheme.onSurface;
    final secondaryTextColor = onSurfaceColor.withOpacity(0.65);
    final cardBorderColor =
        isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06);
    final hairlineColor =
        isDark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.06);

    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Account',
            style: TextStyle(
              fontFamily: 'lato',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: onSurfaceColor,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: surfaceColor,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Guest Hero Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: primaryColor.withOpacity(0.12),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.25),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.person_outline_rounded,
                            size: 28,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, Guest',
                                style: TextStyle(
                                  fontFamily: 'lato',
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: onSurfaceColor,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Sign in to track orders, save items & get personalized deals.',
                                style: TextStyle(
                                  fontFamily: 'lato',
                                  fontSize: 12,
                                  color: secondaryTextColor,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Quick benefits tags
                    Row(
                      children: [
                        _buildBenefitChip(
                          icon: Icons.local_offer_outlined,
                          label: 'Exclusive Offers',
                          primaryColor: primaryColor,
                          textColor: onSurfaceColor,
                        ),
                        const SizedBox(width: 8),
                        _buildBenefitChip(
                          icon: Icons.local_shipping_outlined,
                          label: 'Track Orders',
                          primaryColor: primaryColor,
                          textColor: onSurfaceColor,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Dual Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () {
                                isOtpLogin
                                    ? Get.toNamed(Routes.MOBILELOGIN)
                                    : Get.toNamed(Routes.LOGIN);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontFamily: 'lato',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: OutlinedButton(
                              onPressed: () {
                                isOtpLogin
                                    ? Get.toNamed(Routes.MOBILEREGISTER)
                                    : Get.toNamed(Routes.REGISTER);
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: primaryColor,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: primaryColor.withOpacity(0.04),
                              ),
                              child: Text(
                                'Create Account',
                                style: TextStyle(
                                  fontFamily: 'lato',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Group 1: Support & Help
              _buildSectionHeader('Help & Support', onSurfaceColor),
              _buildSectionCard(
                surfaceColor: surfaceColor,
                borderColor: cardBorderColor,
                children: [
                  _buildGuestTile(
                    context,
                    icon: Icons.support_agent_rounded,
                    title: '24/7 Customer Support',
                    subtitle: 'Call $supportContact',
                    onTap: () => handleSupportCall(context),
                    primaryColor: primaryColor,
                    textColor: onSurfaceColor,
                    secondaryColor: secondaryTextColor,
                  ),
                  _buildHairlineDivider(hairlineColor),
                  _buildGuestTile(
                    context,
                    icon: Icons.help_outline_rounded,
                    title: 'Help & FAQs',
                    subtitle: 'Frequently asked questions and guides',
                    onTap: () => Get.toNamed(Routes.HELPANDSUPPORT),
                    primaryColor: primaryColor,
                    textColor: onSurfaceColor,
                    secondaryColor: secondaryTextColor,
                  ),
                  _buildHairlineDivider(hairlineColor),
                  _buildGuestTile(
                    context,
                    icon: Icons.mail_outline_rounded,
                    title: 'Contact Us',
                    subtitle: 'Send us a message or inquiry',
                    onTap: () => Get.toNamed(Routes.CONTACTUS),
                    primaryColor: primaryColor,
                    textColor: onSurfaceColor,
                    secondaryColor: secondaryTextColor,
                  ),
                ],
              ),

              // Group 2: Discover & Stories
              _buildSectionHeader('About & Discover', onSurfaceColor),
              _buildSectionCard(
                surfaceColor: surfaceColor,
                borderColor: cardBorderColor,
                children: [
                  _buildGuestTile(
                    context,
                    icon: Icons.article_outlined,
                    title: 'From Our Blog',
                    subtitle: 'Read trends, news & stories',
                    onTap: () => Get.toNamed(Routes.BLOG),
                    primaryColor: primaryColor,
                    textColor: onSurfaceColor,
                    secondaryColor: secondaryTextColor,
                  ),
                  _buildHairlineDivider(hairlineColor),
                  _buildGuestTile(
                    context,
                    icon: Icons.info_outline_rounded,
                    title: 'About Us',
                    subtitle: 'Learn more about $appName',
                    onTap: () => Get.toNamed(Routes.ABOUTUS),
                    primaryColor: primaryColor,
                    textColor: onSurfaceColor,
                    secondaryColor: secondaryTextColor,
                  ),
                ],
              ),

              // Group 3: Legal & Security
              _buildSectionHeader('Legal & Policies', onSurfaceColor),
              _buildSectionCard(
                surfaceColor: surfaceColor,
                borderColor: cardBorderColor,
                children: [
                  _buildGuestTile(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'How we collect and protect your data',
                    onTap: () => Get.toNamed(Routes.PRIVACY_POLICY),
                    primaryColor: primaryColor,
                    textColor: onSurfaceColor,
                    secondaryColor: secondaryTextColor,
                  ),
                  _buildHairlineDivider(hairlineColor),
                  _buildGuestTile(
                    context,
                    icon: Icons.gavel_rounded,
                    title: 'Terms & Conditions',
                    subtitle: 'Rules governing use of our service',
                    onTap: () => Get.toNamed(Routes.TERMSANDCONDITION),
                    primaryColor: primaryColor,
                    textColor: onSurfaceColor,
                    secondaryColor: secondaryTextColor,
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // Modern Footer with Trust Badge
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 13,
                          color: secondaryTextColor.withOpacity(0.7),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '100% Secure & Encrypted Shopping',
                          style: TextStyle(
                            fontFamily: 'lato',
                            fontSize: 11,
                            color: secondaryTextColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$appName • Version 1.0.0',
                      style: TextStyle(
                        fontFamily: 'lato',
                        fontSize: 11.5,
                        color: secondaryTextColor.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 20),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontFamily: 'lato',
          fontSize: 11,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w700,
          color: textColor.withOpacity(0.55),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required Color surfaceColor,
    required Color borderColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildHairlineDivider(Color dividerColor) {
    return Divider(
      height: 1,
      thickness: 0.6,
      color: dividerColor,
      indent: 58,
      endIndent: 14,
    );
  }

  Widget _buildBenefitChip({
    required IconData icon,
    required String label,
    required Color primaryColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'lato',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color primaryColor,
    required Color textColor,
    required Color secondaryColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: primaryColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'lato',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'lato',
                        fontSize: 11.5,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: secondaryColor.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class profileSection extends StatelessWidget {
  profileSection(
      {Key? key,
      required this.assetIcon,
      required this.profileOption,
      required this.optionDetial,
      required this.ontap})
      : super(key: key);
  String assetIcon;
  String profileOption;
  String optionDetial;
  VoidCallback ontap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: ontap,
        child: Row(
          children: [
            assetIcon.endsWith('.svg')
                ? SvgPicture.asset(assetIcon, width: 25)
                : Image.asset(assetIcon, width: 25),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profileOption,
                    style: const TextStyle(
                        fontSize: 14,
                        // color: themeTextColor,
                        fontFamily: 'lato')),
                Text(optionDetial,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'lato',
                      // color: themeSecondrytext
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
